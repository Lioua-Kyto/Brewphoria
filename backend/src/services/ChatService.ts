import { ChatRepository } from "../repositories/ChatRepository";
import { GoogleGenAI } from "@google/genai";
import { env } from "../config/env";
import { redis } from "../config/redis";
import { ProductRepository } from "../repositories/ProductRepository";
import { NotFoundError } from "../utils/errors";
import { logger } from "../config/logger";

const chatRepo = new ChatRepository();
const productRepo = new ProductRepository();
const ai = new GoogleGenAI({ apiKey: env.GEMINI_API_KEY });

// v2: catalog now spans the full active catalogue (not just the top 20) and
// includes live stock, so the assistant can answer "do you have X" / "how many
// are left" for any product, merchandise included.
const CATALOG_CACHE_KEY = "brewphoria:chat:catalog:v2";
const CATALOG_TTL = 600; // 10 min

async function getProductCatalogContext(): Promise<string> {
  const cached = await redis.get<string>(CATALOG_CACHE_KEY);
  if (cached) return cached;

  const products = await productRepo.findTopProducts(500);
  const context = products
    .map((p) => {
      const stock =
        p.stock > 0 ? `${p.stock} in stock` : "out of stock";
      return `- ${p.name} [slug:${p.slug}]: $${Number(p.price).toFixed(2)}, ${stock}, Rating: ${Number(p.avgRating).toFixed(1)}/5, ${p.description.slice(0, 100)}`;
    })
    .join("\n");

  await redis.set(CATALOG_CACHE_KEY, context, CATALOG_TTL);
  return context;
}

const SYSTEM_PROMPT = (
  catalog: string,
) => `You are BrewBot, a helpful assistant for BrewPhoria — a premium coffee e-commerce app.
You help customers discover products, answer questions about their orders, and provide coffee brewing tips.
Be friendly, concise, and enthusiastic about coffee.

Current product catalog:
${catalog}

Rules:
- The catalog above is the FULL catalogue (drinks, coffee beans, teas, and merchandise). If a product is in it, we sell it — never tell a customer we don't carry something that appears above.
- Only recommend or discuss products from the catalog above.
- Each line includes live stock ("N in stock" / "out of stock") — use it to answer availability questions accurately. Do not claim you lack access to stock levels.
- If asked about prices or availability, give accurate information based on the catalog.
- Do not make up products or prices.
- Keep responses under 200 words unless a detailed answer is genuinely needed.
- When you recommend ONE specific product the customer should add, end your reply with a tag on its own line using that product's slug from the catalog, exactly: [[product:<slug>]]. Include at most one such tag, and only when suggesting a specific item to order.`;

export class ChatService {
  async chat(
    userId: string,
    message: string,
    sessionId?: string,
  ): Promise<{
    reply: string;
    sessionId: string;
    product?: {
      id: string;
      slug: string;
      name: string;
      image: string;
      price: number;
      meta?: string;
    };
  }> {
    // 1. Get or create session
    let session = sessionId
      ? await chatRepo.findSession(sessionId, userId)
      : null;

    if (sessionId && !session) {
      throw new NotFoundError("Chat session");
    }

    if (!session) {
      session = await chatRepo.createSession(userId);
    }

    // 2. Load last 10 messages for context
    const history = await chatRepo.getRecentMessages(session.id, 10);
    const historyReversed = [...history].reverse();

    // 3. Build Gemini messages
    const catalog = await getProductCatalogContext();
    const systemPrompt = SYSTEM_PROMPT(catalog);

    const contents = historyReversed.map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: m.content }],
    }));
    contents.push({ role: "user", parts: [{ text: message }] });

    // 4. Call Gemini
    let reply: string;
    try {
      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash",
        contents,
        config: {
          systemInstruction: systemPrompt,
          temperature: 0.7,
          maxOutputTokens: 1024,
        },
      });
      reply =
        response.text ??
        "I'm sorry, I couldn't generate a response. Please try again.";
    } catch (err) {
      logger.error("Gemini error:", err);
      reply =
        "I'm having trouble connecting right now. Please try again in a moment.";
    }

    // 5. Resolve an optional product recommendation tag, then strip it.
    let product:
      | {
          id: string;
          slug: string;
          name: string;
          image: string;
          price: number;
          meta?: string;
        }
      | undefined;
    const tagMatch = reply.match(/\[\[product:([a-z0-9-]+)\]\]/i);
    if (tagMatch) {
      reply = reply.replace(tagMatch[0], "").trim();
      const recommended = await productRepo.findBySlug(tagMatch[1]!);
      if (recommended && recommended.isActive) {
        product = {
          id: recommended.id,
          slug: recommended.slug,
          name: recommended.name,
          image: recommended.images[0] ?? "",
          price: Number(recommended.price),
          meta: recommended.category?.name,
        };
      }
    }

    // 6. Save both messages (clean text, without the tag)
    await chatRepo.saveMessage({
      sessionId: session.id,
      role: "user",
      content: message,
    });
    await chatRepo.saveMessage({
      sessionId: session.id,
      role: "assistant",
      content: reply,
    });
    await chatRepo.updateSessionTimestamp(session.id);

    return { reply, sessionId: session.id, product };
  }
}
