import { copyFileSync, existsSync, mkdirSync, readdirSync } from "fs";
import { join } from "path";
import { config } from "dotenv";
import {
  PrismaClient,
  OrderStatus,
  LoyaltyTier,
  NotificationType,
} from "@prisma/client";
import { Pool } from "pg";
import { PrismaPg } from "@prisma/adapter-pg";

config();

const connectionString = process.env.DATABASE_URL;
if (!connectionString)
  throw new Error("DATABASE_URL is not set in your .env file");

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

// ─── Helpers ────────────────────────────────────────────────────────────────
function slug(name: string) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}
function pick<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}
function rand(min: number, max: number) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// ─── Image URL helper ────────────────────────────────────────────────────────
// Set IMG_BASE_URL env var to override (e.g. http://192.168.x.x:3000 for real device)
const IMG_BASE = (process.env.IMG_BASE_URL ?? "http://10.0.2.2:3000").replace(/\/$/, "");
function localImg(filename: string): string {
  return `${IMG_BASE}/uploads/products/${encodeURIComponent(filename)}`;
}

// ─── Categories ──────────────────────────────────────────────────────────────
const CATEGORIES = [
  {
    name: "Espresso & Hot Drinks",
    img: "https://images.unsplash.com/photo-1510591509098-f4fdc6d0ff04?w=800&q=80",
  },
  {
    name: "Cold Brew & Iced",
    img: "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800&q=80",
  },
  {
    name: "Pastries & Baked Goods",
    img: "https://images.unsplash.com/photo-1509365465985-25d11c17e812?w=800&q=80",
  },
  {
    name: "Coffee Beans & Grounds",
    img: "https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800&q=80",
  },
  {
    name: "Tea & Alternatives",
    img: "https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=800&q=80",
  },
  {
    name: "Merchandise",
    img: "https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?w=800&q=80",
  },
];

// ─── Products per category (10 each) ─────────────────────────────────────────
const PRODUCTS: Record<
  string,
  {
    name: string;
    description: string;
    price: number;
    img: string;
    featured?: boolean;
  }[]
> = {
  "Espresso & Hot Drinks": [
    {
      name: "Classic Espresso",
      price: 3.5,
      featured: true,
      img: localImg("classic espresso.png"),
      description:
        "A concentrated shot of rich, bold espresso with a silky crema.",
    },
    {
      name: "Double Espresso",
      price: 4.0,
      img: "https://images.unsplash.com/photo-1596078843435-3c55054f77ef?w=800&q=80",
      description: "Two shots of our signature espresso for maximum intensity.",
    },
    {
      name: "Cappuccino",
      price: 4.5,
      featured: true,
      img: localImg("cappuccino.png"),
      description: "Equal parts espresso, steamed milk, and velvety foam.",
    },
    {
      name: "Flat White",
      price: 4.75,
      img: localImg("flat white.png"),
      description: "A smooth, velvety espresso drink with microfoam milk.",
    },
    {
      name: "Caramel Macchiato",
      price: 5.25,
      featured: true,
      img: "https://images.unsplash.com/photo-1572442388796-5c28d4f5e3e0?w=800&q=80",
      description:
        "Espresso marked with steamed milk and house-made caramel drizzle.",
    },
    {
      name: "Vanilla Latte",
      price: 5.0,
      img: "https://images.unsplash.com/photo-1570968915860-54d5c301fa9f?w=800&q=80",
      description: "Espresso blended with steamed milk and pure vanilla syrup.",
    },
    {
      name: "Hazelnut Latte",
      price: 5.0,
      img: "https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=800&q=80",
      description: "Smooth latte with roasted hazelnut flavour.",
    },
    {
      name: "Mocha",
      price: 5.25,
      img: "https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=800&q=80",
      description: "Espresso with rich dark chocolate sauce and steamed milk.",
    },
    {
      name: "Americano",
      price: 3.75,
      img: "https://images.unsplash.com/photo-1551030173-122aaef7f7be?w=800&q=80",
      description: "Espresso diluted with hot water for a clean, bold cup.",
    },
    {
      name: "Cortado",
      price: 4.25,
      img: "https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?w=800&q=80",
      description: "Equal parts ristretto and warm textured milk.",
    },
  ],
  "Cold Brew & Iced": [
    {
      name: "Classic Cold Brew",
      price: 4.5,
      featured: true,
      img: localImg("classic cold brew.png"),
      description:
        "20-hour slow-steeped cold brew — smooth, low-acid, and refreshing.",
    },
    {
      name: "Vanilla Sweet Cream CBrew",
      price: 5.25,
      featured: true,
      img: "https://images.unsplash.com/photo-1591160654748-aebe26f0d2ce?w=800&q=80",
      description:
        "Cold brew topped with a delicate float of house-made vanilla sweet cream.",
    },
    {
      name: "Nitro Cold Brew",
      price: 5.5,
      featured: true,
      img: localImg("nitro cold brew.png"),
      description:
        "Cold brew infused with nitrogen for a creamy, stout-like texture.",
    },
    {
      name: "Iced Caramel Latte",
      price: 5.25,
      img: localImg("iced caramel latte.png"),
      description:
        "Chilled espresso and milk over ice, finished with caramel drizzle.",
    },
    {
      name: "Iced Matcha Latte",
      price: 5.0,
      img: localImg("iced matcha latte.png"),
      description:
        "Ceremonial-grade matcha whisked into cold oat milk over ice.",
    },
    {
      name: "Iced Americano",
      price: 4.0,
      img: "https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=800&q=80",
      description: "Espresso over ice, topped with cold water.",
    },
    {
      name: "Cold Brew Tonic",
      price: 5.75,
      img: "https://images.unsplash.com/photo-1499638673689-79a0b0e5eab7?w=800&q=80",
      description:
        "Tangy tonic water meets bold cold brew — unexpectedly delicious.",
    },
    {
      name: "Brown Sugar Oat Shaken",
      price: 5.5,
      img: "https://images.unsplash.com/photo-1625772452859-1d495c5e5edf?w=800&q=80",
      description: "Espresso shaken with brown sugar syrup and oat milk.",
    },
    {
      name: "Passion Iced Tea Lemonade",
      price: 4.75,
      img: "https://images.unsplash.com/photo-1556679908-2a8e69b7e6dc?w=800&q=80",
      description:
        "Vibrant passion-fruit tea blended with fresh lemonade over ice.",
    },
    {
      name: "Mango Dragonfruit Refresh",
      price: 5.0,
      img: localImg("mango dragonfruit refresh.png"),
      description: "Tropical mango dragonfruit with coconut milk and ice.",
    },
  ],
  "Pastries & Baked Goods": [
    {
      name: "Butter Croissant",
      price: 3.0,
      featured: true,
      img: localImg("butter croissant.png"),
      description: "A classic, flaky, perfectly laminated butter croissant.",
    },
    {
      name: "Almond Croissant",
      price: 3.75,
      featured: true,
      img: localImg("almond croissant.png"),
      description: "Twice-baked croissant filled and topped with almond cream.",
    },
    {
      name: "Blueberry Muffin",
      price: 3.25,
      img: "https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=800&q=80",
      description: "Giant bakery-style muffin bursting with fresh blueberries.",
    },
    {
      name: "Banana Bread",
      price: 3.5,
      img: "https://images.unsplash.com/photo-1575517111839-3a3843ee7f5d?w=800&q=80",
      description:
        "Moist banana bread with walnuts and a sprinkle of sea salt.",
    },
    {
      name: "Chocolate Chip Scone",
      price: 3.5,
      img: "https://images.unsplash.com/photo-1599785209672-6e8b279bd3dd?w=800&q=80",
      description: "A buttery, crumbly scone loaded with dark chocolate chips.",
    },
    {
      name: "Cinnamon Roll",
      price: 4.25,
      featured: true,
      img: localImg("cinnamon roll.png"),
      description:
        "Jumbo roll swirled with cinnamon sugar, topped with cream-cheese icing.",
    },
    {
      name: "Pain au Chocolat",
      price: 3.75,
      img: "https://images.unsplash.com/photo-1549903072-77c5f6b7addb?w=800&q=80",
      description: "Flaky pastry encasing two batons of 70% dark chocolate.",
    },
    {
      name: "Avocado Toast",
      price: 6.5,
      img: localImg("avocado toast.png"),
      description:
        "Sourdough topped with smashed avocado, chilli flakes, and lemon.",
    },
    {
      name: "Egg & Cheese Brioche",
      price: 5.75,
      img: "https://images.unsplash.com/photo-1525351484163-7529414f2171?w=800&q=80",
      description:
        "Toasted brioche bun with a fried egg, aged cheddar, and hot sauce.",
    },
    {
      name: "Brownie Bar",
      price: 3.25,
      img: "https://images.unsplash.com/photo-1564355808539-d4fb67e0fd2a?w=800&q=80",
      description: "Dense, fudgy brownie with a glossy crinkle top.",
    },
  ],
  "Coffee Beans & Grounds": [
    {
      name: "BrewPhoria House Blend 250g",
      price: 14.99,
      featured: true,
      img: localImg("cream-white 250g.png"),
      description:
        "Our signature medium roast with notes of dark chocolate and hazelnut.",
    },
    {
      name: "Ethiopian Yirgacheffe 250g",
      price: 17.99,
      featured: true,
      img: localImg("matte kraft-brown 250g.png"),
      description:
        "Light roast with jasmine, bergamot, and stone-fruit brightness.",
    },
    {
      name: "Colombian Supremo 250g",
      price: 15.99,
      img: "https://images.unsplash.com/photo-1498804103079-a6351af1037f?w=800&q=80",
      description:
        "Balanced medium roast with caramel sweetness and mild acidity.",
    },
    {
      name: "Sumatra Mandheling 250g",
      price: 16.99,
      img: "https://images.unsplash.com/photo-1442551382982-e56a35c9b3b7?w=800&q=80",
      description:
        "Full-bodied dark roast with earthy, cedar, and dark-cocoa notes.",
    },
    {
      name: "Guatemala Antigua 250g",
      price: 16.49,
      img: "https://images.unsplash.com/photo-1501747315-124a0eaca060?w=800&q=80",
      description:
        "Smooth medium-dark roast, toffee sweetness and smoky finish.",
    },
    {
      name: "Kenya AA 250g",
      price: 18.49,
      img: "https://images.unsplash.com/photo-1495474472287-4d8b68991a37?w=800&q=80",
      description:
        "Bright winy acidity with blackcurrant and grapefruit complexity.",
    },
    {
      name: "Decaf Colombia 250g",
      price: 15.49,
      img: "https://images.unsplash.com/photo-1567006483105-2b1e1e2c7c5e?w=800&q=80",
      description:
        "Swiss-water process decaf — all the flavor, none of the caffeine.",
    },
    {
      name: "Espresso Blend 1kg",
      price: 42.99,
      featured: true,
      img: localImg("matte black coffee 1kg.png"),
      description: "A 1 kg bag of our crowd-favourite espresso blend.",
    },
    {
      name: "Cold Brew Coarse Grind 500g",
      price: 22.99,
      img: "https://images.unsplash.com/photo-1588515724527-074a7f0ee2bc?w=800&q=80",
      description:
        "Pre-ground to the perfect coarseness for immersion cold brew.",
    },
    {
      name: "Single-Origin Sampler Box",
      price: 34.99,
      featured: true,
      img: localImg("Single-Origin Sampler Box.png"),
      description: "Four 62 g taster bags from four different origins.",
    },
  ],
  "Tea & Alternatives": [
    {
      name: "Ceremonial Matcha 30g",
      price: 18.99,
      featured: true,
      img: localImg("Ceremonial Matcha 30g.png"),
      description:
        "First-harvest, stone-ground ceremonial-grade matcha from Uji, Japan.",
    },
    {
      name: "Culinary Matcha 100g",
      price: 14.99,
      img: "https://images.unsplash.com/photo-1515823064-d6e0c04616a7?w=800&q=80",
      description: "Perfect for lattes, baking, and smoothies.",
    },
    {
      name: "Chai Concentrate 500ml",
      price: 9.99,
      featured: true,
      img: localImg("Chai Concentrate 500ml.png"),
      description: "Bold house-made spiced chai — just add milk.",
    },
    {
      name: "Earl Grey Loose Leaf 75g",
      price: 11.99,
      img: localImg("Earl Grey Loose Leaf 75g.png"),
      description: "Classic bergamot-scented black tea.",
    },
    {
      name: "Chamomile Honey 20 Bags",
      price: 8.99,
      img: "https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&q=80",
      description: "Calming chamomile with a hint of wildflower honey.",
    },
    {
      name: "Peppermint Herbal 20 Bags",
      price: 7.99,
      img: "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80",
      description: "Pure peppermint leaves, naturally caffeine-free.",
    },
    {
      name: "Turmeric Golden Latte Mix",
      price: 12.99,
      img: "https://images.unsplash.com/photo-1579954115563-e72dea7c1f89?w=800&q=80",
      description: "Blend of turmeric, ginger, cinnamon, and black pepper.",
    },
    {
      name: "Oat Milk Barista 1L",
      price: 4.99,
      img: localImg("Oat Milk Barista 1L.png"),
      description: "Professionally formulated oat milk for silky microfoam.",
    },
    {
      name: "Almond Milk 1L",
      price: 4.49,
      img: "https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?w=800&q=80",
      description: "Unsweetened almond milk, perfect for lattes.",
    },
    {
      name: "Coconut Creamer 500ml",
      price: 5.49,
      img: "https://images.unsplash.com/photo-1505252585461-e8c3f2aba4af?w=800&q=80",
      description: "Rich, creamy coconut-based dairy-free creamer.",
    },
  ],
  Merchandise: [
    {
      name: "BrewPhoria Ceramic Mug",
      price: 18.0,
      featured: true,
      img: localImg("BrewPhoria Ceramic Mug.png"),
      description: "Handcrafted 12 oz ceramic mug with the BrewPhoria logo.",
    },
    {
      name: "Double-Wall Glass 350ml",
      price: 22.0,
      img: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80",
      description:
        "Borosilicate double-wall glass — keeps drinks hot and hands cool.",
    },
    {
      name: "Travel Tumbler 16oz",
      price: 32.0,
      featured: true,
      img: localImg("Travel Tumbler 16oz.png"),
      description:
        "Stainless-steel vacuum-insulated tumbler, keeps cold 24 h / hot 12 h.",
    },
    {
      name: "Stainless Pour-Over Set",
      price: 45.0,
      img: "https://images.unsplash.com/photo-1495474472287-4d8b68991a37?w=800&q=80",
      description:
        "Elegant stainless pour-over dripper with carafe and 50 filters.",
    },
    {
      name: "French Press 600ml",
      price: 38.0,
      img: "https://images.unsplash.com/photo-1519082274554-ad38ee7e9b9b?w=800&q=80",
      description: "Classic bodum-style stainless-steel French press.",
    },
    {
      name: "AeroPress Original",
      price: 42.0,
      featured: true,
      img: localImg("AeroPress Original.png"),
      description: "The iconic AeroPress coffee and espresso maker kit.",
    },
    {
      name: "Burr Grinder Entry",
      price: 55.0,
      img: "https://images.unsplash.com/photo-1585155770297-9a37ee8a2c67?w=800&q=80",
      description: "Compact ceramic burr grinder with 15 grind settings.",
    },
    {
      name: "BrewPhoria Tote Bag",
      price: 15.0,
      img: localImg("BrewPhoria Tote Bag.png"),
      description: "Heavy-duty natural canvas tote with embroidered logo.",
    },
    {
      name: "Barista Tool Kit",
      price: 28.0,
      img: "https://images.unsplash.com/photo-1612614774866-73b9cef81dd5?w=800&q=80",
      description:
        "Tamper, distribution tool, and knock box in a gift-ready set.",
    },
    {
      name: "Gift Card $25",
      price: 25.0,
      img: "https://images.unsplash.com/photo-1549465220-1a9c1c5b82b8?w=800&q=80",
      description:
        "A $25 BrewPhoria gift card — the perfect gift for any coffee lover.",
    },
  ],
};

const REVIEW_COMMENTS = [
  "Absolutely love this! Will order again.",
  "Great quality, very happy with my purchase.",
  "Exactly as described. Fast shipping too.",
  "My new daily staple — can't start the day without it.",
  "Good product but shipping took a while.",
  "Surprised by the quality at this price point.",
  "Perfect gift for my coffee-obsessed partner.",
  "Rich flavor, smooth finish. Highly recommend.",
  "A bit too strong for my taste but great quality.",
  "BrewPhoria never disappoints!",
  "5 stars — worth every penny.",
  "Packaging was beautiful and the product is even better.",
];

const CITY_DATA = [
  { city: "Portland", state: "OR", postalCode: "97201" },
  { city: "Seattle", state: "WA", postalCode: "98101" },
  { city: "Austin", state: "TX", postalCode: "78701" },
  { city: "Denver", state: "CO", postalCode: "80201" },
  { city: "Chicago", state: "IL", postalCode: "60601" },
];

// ─── Main ────────────────────────────────────────────────────────────────────
async function main() {
  console.log("🌱  Starting BrewPhoria seed…");

  // ── 0. Copy product images to uploads/products/ ───────────────────────────
  const localImgsDir = join(__dirname, "Products PNG");
  const uploadsDir = join(process.cwd(), "uploads", "products");
  mkdirSync(uploadsDir, { recursive: true });
  let copied = 0;
  for (const filename of readdirSync(localImgsDir)) {
    if (!/\.(png|jpe?g|webp)$/i.test(filename)) continue;
    const dest = join(uploadsDir, filename);
    if (!existsSync(dest)) {
      copyFileSync(join(localImgsDir, filename), dest);
      copied++;
    }
  }
  console.log(`   Images: ${copied} new file(s) copied to uploads/products/`);

  // ── 1. Categories ─────────────────────────────────────────────────────────
  console.log("   Creating categories…");
  const categories = await Promise.all(
    CATEGORIES.map((c) =>
      prisma.category.upsert({
        where: { slug: slug(c.name) },
        update: { imageUrl: c.img },
        create: {
          name: c.name,
          slug: slug(c.name),
          imageUrl: c.img,
          isActive: true,
        },
      }),
    ),
  );

  // ── 2. Products ───────────────────────────────────────────────────────────
  console.log("   Creating products…");

  // Product `type` drives which customization option groups & detail metadata
  // show on the product detail screen (see ProductService.getBySlug). Most
  // categories map 1:1 to a type, except "Tea & Alternatives" which mixes
  // drinkable items (matcha, chai) with retail packaged goods (loose tea,
  // milk alternatives) — those are called out individually below.
  const CATEGORY_TYPE: Record<string, "DRINK" | "BEANS" | "MERCH"> = {
    "Espresso & Hot Drinks": "DRINK",
    "Cold Brew & Iced": "DRINK",
    "Pastries & Baked Goods": "MERCH",
    "Coffee Beans & Grounds": "BEANS",
    "Tea & Alternatives": "MERCH",
    Merchandise: "MERCH",
  };
  const DRINK_OVERRIDES = new Set([
    "Ceremonial Matcha 30g",
    "Culinary Matcha 100g",
    "Chai Concentrate 500ml",
  ]);
  function productType(catName: string, productName: string): "DRINK" | "BEANS" | "MERCH" {
    if (DRINK_OVERRIDES.has(productName)) return "DRINK";
    return CATEGORY_TYPE[catName] ?? "MERCH";
  }

  const allProducts: {
    id: string;
    name: string;
    price: number;
    images: string[];
  }[] = [];
  for (const cat of categories) {
    const list = PRODUCTS[cat.name] ?? [];
    for (const p of list) {
      const s = slug(p.name);
      const imageUrl = p.img;
      const type = productType(cat.name, p.name);
      const product = await prisma.product.upsert({
        where: { slug: s },
        update: { images: [imageUrl], type },
        create: {
          name: p.name,
          slug: s,
          description: p.description,
          price: p.price,
          categoryId: cat.id,
          images: [imageUrl],
          stock: rand(20, 150),
          isActive: true,
          isFeatured: p.featured ?? false,
          type,
        },
      });
      allProducts.push({
        id: product.id,
        name: product.name,
        price: p.price,
        images: [imageUrl],
      });
    }
  }

  // ── 2b. Modifier groups, per category ─────────────────────────────────────
  // Attached at category level (all products sharing a category share its
  // option groups), but ProductService.getBySlug gates on the *product's*
  // type before returning them — see the MERCH short-circuit there — so a
  // MERCH product sitting in a category that also has groups (e.g. a retail
  // milk bottle in "Tea & Alternatives") never receives them.
  console.log("   Creating modifier groups…");
  const DRINK_MODIFIER_GROUPS = [
    {
      name: "Size",
      selectionType: "SINGLE" as const,
      isRequired: true,
      sortOrder: 0,
      options: [
        { label: "Small", priceDelta: -0.4, sortOrder: 0 },
        { label: "Medium", priceDelta: 0, isDefault: true, sortOrder: 1 },
        { label: "Large", priceDelta: 0.6, sortOrder: 2 },
      ],
    },
    {
      name: "Milk",
      selectionType: "SINGLE" as const,
      isRequired: false,
      sortOrder: 1,
      options: [
        { label: "Whole", priceDelta: 0, isDefault: true, sortOrder: 0 },
        { label: "Oat", priceDelta: 0.6, sortOrder: 1 },
        { label: "Almond", priceDelta: 0.6, sortOrder: 2 },
        { label: "Skim", priceDelta: 0, sortOrder: 3 },
      ],
    },
    {
      name: "Sweetness",
      selectionType: "SINGLE" as const,
      isRequired: false,
      sortOrder: 2,
      options: [
        { label: "No sugar", priceDelta: 0, sortOrder: 0 },
        { label: "Light", priceDelta: 0, isDefault: true, sortOrder: 1 },
        { label: "Regular", priceDelta: 0, sortOrder: 2 },
        { label: "Extra sweet", priceDelta: 0, sortOrder: 3 },
      ],
    },
    {
      name: "Add-ons",
      selectionType: "MULTI" as const,
      isRequired: false,
      sortOrder: 3,
      options: [
        { label: "Extra espresso shot", priceDelta: 0.8, sortOrder: 0 },
        { label: "Vanilla syrup", priceDelta: 0.5, sortOrder: 1 },
        { label: "Caramel drizzle", priceDelta: 0.5, sortOrder: 2 },
        { label: "Whipped cream", priceDelta: 0.4, sortOrder: 3 },
      ],
    },
  ];
  const BEANS_MODIFIER_GROUPS = [
    {
      name: "Grind",
      selectionType: "SINGLE" as const,
      isRequired: false,
      sortOrder: 0,
      options: [
        { label: "Whole Bean", priceDelta: 0, isDefault: true, sortOrder: 0 },
        { label: "Ground", priceDelta: 0, sortOrder: 1 },
      ],
    },
  ];
  const CATEGORY_MODIFIER_GROUPS: Record<
    string,
    typeof DRINK_MODIFIER_GROUPS | typeof BEANS_MODIFIER_GROUPS
  > = {
    "Espresso & Hot Drinks": DRINK_MODIFIER_GROUPS,
    "Cold Brew & Iced": DRINK_MODIFIER_GROUPS,
    "Tea & Alternatives": DRINK_MODIFIER_GROUPS,
    "Coffee Beans & Grounds": BEANS_MODIFIER_GROUPS,
  };
  for (const cat of categories) {
    const groups = CATEGORY_MODIFIER_GROUPS[cat.name];
    if (!groups) continue;
    await prisma.modifierGroup.deleteMany({ where: { categoryId: cat.id } });
    for (const g of groups) {
      await prisma.modifierGroup.create({
        data: {
          categoryId: cat.id,
          name: g.name,
          selectionType: g.selectionType,
          isRequired: g.isRequired,
          sortOrder: g.sortOrder,
          options: {
            create: g.options.map((o) => ({
              label: o.label,
              priceDelta: o.priceDelta,
              isDefault: (o as { isDefault?: boolean }).isDefault ?? false,
              sortOrder: o.sortOrder,
            })),
          },
        },
      });
    }
  }

  // ── 2c. Product detail metadata (roast / nutrition / tasting notes) ────────
  // Gated by the product's own `type`, not its category, so a mixed category
  // like "Tea & Alternatives" only decorates the drinkable items. Roast level
  // and tasting notes are coffee metadata (relevant to bean bags too);
  // calories/caffeine/prep-time are drink-specific and DRINK-only.
  console.log("   Adding product metadata…");
  const NOTE_POOL = [
    "Chocolate", "Caramel", "Nutty", "Citrus", "Floral",
    "Berry", "Toffee", "Vanilla", "Honey",
  ];
  const ROASTS = ["Light", "Medium", "Medium-Dark", "Dark"];
  const pastryCatId = categories.find(
    (c) => c.name === "Pastries & Baked Goods",
  )?.id;
  const metaProducts = await prisma.product.findMany();
  for (const p of metaProducts) {
    if (p.type === "DRINK") {
      await prisma.product.update({
        where: { id: p.id },
        data: {
          roastLevel: pick(ROASTS),
          calories: rand(90, 320),
          caffeineMg: rand(60, 180),
          prepMinutes: rand(3, 7),
          tastingNotes: [...NOTE_POOL]
            .sort(() => Math.random() - 0.5)
            .slice(0, 3),
        },
      });
    } else if (p.type === "BEANS") {
      await prisma.product.update({
        where: { id: p.id },
        data: {
          roastLevel: pick(ROASTS),
          tastingNotes: [...NOTE_POOL]
            .sort(() => Math.random() - 0.5)
            .slice(0, 3),
        },
      });
    } else if (p.categoryId === pastryCatId) {
      // Pastries are MERCH but edible — show calories + a short warm/serve time.
      await prisma.product.update({
        where: { id: p.id },
        data: { calories: rand(240, 450), prepMinutes: rand(1, 3) },
      });
    }
    // Other MERCH (mugs, tote, etc.): no nutrition metadata.
  }

  // ── 3. Admin user ─────────────────────────────────────────────────────────
  console.log("   Creating admin user…");
  await prisma.user.upsert({
    where: { firebaseUid: "seed-admin-uid" },
    update: {},
    create: {
      firebaseUid: "seed-admin-uid",
      email: "admin@brewphoria.com",
      displayName: "BrewPhoria Admin",
      role: "ADMIN",
      loyaltyAccount: {
        create: { currentPoints: 2500, lifetimePoints: 5000, tier: "PLATINUM" },
      },
    },
  });

  // ── 4. Regular users ──────────────────────────────────────────────────────
  console.log("   Creating regular users…");
  const USERS: {
    uid: string;
    email: string;
    name: string;
    points: number;
    lifetime: number;
    tier: LoyaltyTier;
  }[] = [
    {
      uid: "seed-user-1",
      email: "alice@example.com",
      name: "Alice Johnson",
      points: 850,
      lifetime: 1200,
      tier: "GOLD",
    },
    {
      uid: "seed-user-2",
      email: "bob@example.com",
      name: "Bob Martinez",
      points: 340,
      lifetime: 600,
      tier: "SILVER",
    },
    {
      uid: "seed-user-3",
      email: "carol@example.com",
      name: "Carol Williams",
      points: 120,
      lifetime: 120,
      tier: "BRONZE",
    },
    {
      uid: "seed-user-4",
      email: "david@example.com",
      name: "David Kim",
      points: 1600,
      lifetime: 3200,
      tier: "GOLD",
    },
    {
      uid: "seed-user-5",
      email: "emma@example.com",
      name: "Emma Thompson",
      points: 50,
      lifetime: 50,
      tier: "BRONZE",
    },
  ];

  const createdUsers: {
    id: string;
    uid: string;
    email: string;
    name: string;
  }[] = [];
  for (const u of USERS) {
    const user = await prisma.user.upsert({
      where: { firebaseUid: u.uid },
      update: {},
      create: {
        firebaseUid: u.uid,
        email: u.email,
        displayName: u.name,
        role: "USER",
        loyaltyAccount: {
          create: {
            currentPoints: u.points,
            lifetimePoints: u.lifetime,
            tier: u.tier,
          },
        },
      },
    });
    createdUsers.push({
      id: user.id,
      uid: u.uid,
      email: u.email,
      name: u.name,
    });
  }

  // ── 5. Addresses ──────────────────────────────────────────────────────────
  console.log("   Creating addresses…");
  const userAddressMap: Record<string, string> = {};
  for (const u of createdUsers) {
    const cityInfo = pick(CITY_DATA);
    const address = await prisma.address.create({
      data: {
        userId: u.id,
        label: "Home",
        fullName: u.name,
        phone: `555-${rand(1000, 9999)}`,
        street: `${rand(100, 999)} ${pick(["Maple", "Oak", "Pine", "Coffee", "Brew"])} St`,
        city: cityInfo.city,
        state: cityInfo.state,
        postalCode: cityInfo.postalCode,
        country: "US",
        isDefault: true,
      },
    });
    userAddressMap[u.id] = address.id;
    if (Math.random() > 0.5) {
      const c2 = pick(CITY_DATA);
      await prisma.address.create({
        data: {
          userId: u.id,
          label: "Work",
          fullName: u.name,
          phone: `555-${rand(1000, 9999)}`,
          street: `${rand(1, 50)} Business Ave Suite ${rand(100, 500)}`,
          city: c2.city,
          state: c2.state,
          postalCode: c2.postalCode,
          country: "US",
          isDefault: false,
        },
      });
    }
  }

  // ── 6. Orders, reviews, loyalty txns, notifications ───────────────────────
  console.log(
    "   Creating orders, reviews, loyalty transactions, and notifications…",
  );
  const ORDER_STATUSES: OrderStatus[] = [
    "DELIVERED",
    "DELIVERED",
    "DELIVERED",
    "CONFIRMED",
    "PREPARING",
    "OUT_FOR_DELIVERY",
    "CANCELLED",
  ];
  const reviewedOrderItemIds = new Set<string>();

  for (const u of createdUsers) {
    const loyaltyAccount = await prisma.loyaltyAccount.findUnique({
      where: { userId: u.id },
    });
    if (!loyaltyAccount) continue;

    const numOrders = rand(3, 6);
    for (let o = 0; o < numOrders; o++) {
      const numItems = rand(1, 4);
      const orderProducts = [...allProducts]
        .sort(() => Math.random() - 0.5)
        .slice(0, numItems);
      const status = pick(ORDER_STATUSES);

      const itemsData = orderProducts.map((p) => {
        const qty = rand(1, 3);
        return {
          productId: p.id,
          productName: p.name,
          productImage: p.images[0],
          unitPrice: p.price,
          quantity: qty,
          subtotal: p.price * qty,
        };
      });

      const subtotal = itemsData.reduce((s, i) => s + i.subtotal, 0);
      const deliveryFee = 3.99;
      const total = subtotal + deliveryFee;
      const pointsEarned = status === "CANCELLED" ? 0 : Math.floor(total);

      const order = await prisma.order.create({
        data: {
          userId: u.id,
          addressId: userAddressMap[u.id]!,
          status,
          subtotal,
          deliveryFee,
          total,
          pointsEarned,
          paymentMethod: pick(["COD", "CARD", "WALLET"]),
          items: { create: itemsData },
          createdAt: new Date(Date.now() - rand(1, 90) * 86400000),
        },
        include: { items: true },
      });

      if (pointsEarned > 0) {
        await prisma.loyaltyTransaction.create({
          data: {
            accountId: loyaltyAccount.id,
            orderId: order.id,
            type: "EARNED",
            points: pointsEarned,
            description: `Points earned on order #${order.id.slice(-6).toUpperCase()}`,
          },
        });
      }

      if (status !== "CANCELLED") {
        await prisma.notification.create({
          data: {
            userId: u.id,
            type: "ORDER_STATUS_CHANGED" as NotificationType,
            title:
              status === "DELIVERED"
                ? "Order Delivered!"
                : "Order Status Update",
            body: `Your order #${order.id.slice(-6).toUpperCase()} is now ${status}.`,
            isRead: status === "DELIVERED",
            data: { orderId: order.id },
          },
        });
      }

      // Reviews for delivered orders
      if (status === "DELIVERED") {
        for (const item of order.items) {
          if (!reviewedOrderItemIds.has(item.id) && Math.random() > 0.35) {
            const rating = pick([3, 4, 4, 4, 5, 5, 5]);
            try {
              await prisma.review.create({
                data: {
                  userId: u.id,
                  productId: item.productId,
                  orderItemId: item.id,
                  rating,
                  comment: pick(REVIEW_COMMENTS),
                  isVisible: true,
                },
              });
              reviewedOrderItemIds.add(item.id);
              const reviews = await prisma.review.findMany({
                where: { productId: item.productId },
              });
              const avg =
                reviews.reduce((s, r) => s + r.rating, 0) / reviews.length;
              await prisma.product.update({
                where: { id: item.productId },
                data: {
                  avgRating: Math.round(avg * 100) / 100,
                  reviewCount: reviews.length,
                },
              });
            } catch {
              /* skip duplicate */
            }
          }
        }
      }
    }
  }

  // ── 7. Active cart items ──────────────────────────────────────────────────
  console.log("   Creating cart items…");
  for (const u of createdUsers.slice(0, 3)) {
    const cart = await prisma.cart.upsert({
      where: { userId: u.id },
      update: {},
      create: { userId: u.id },
    });
    await prisma.cartItem.deleteMany({ where: { cartId: cart.id } });
    const cartProducts = [...allProducts]
      .sort(() => Math.random() - 0.5)
      .slice(0, rand(1, 3));
    for (const p of cartProducts) {
      await prisma.cartItem.create({
        data: {
          cartId: cart.id,
          productId: p.id,
          quantity: rand(1, 3),
          unitPrice: p.price,
        },
      });
    }
  }

  // ── 8. Loyalty tier-up notifications ─────────────────────────────────────
  for (const u of createdUsers.filter(
    (_, i) => USERS[i]!.tier === "GOLD" || USERS[i]!.tier === "PLATINUM",
  )) {
    await prisma.notification.create({
      data: {
        userId: u.id,
        type: "LOYALTY_TIER_UP" as NotificationType,
        title: "🎉 You've reached a new tier!",
        body: "Congratulations! You've unlocked exclusive rewards.",
        isRead: false,
      },
    });
  }

  // ── Summary ───────────────────────────────────────────────────────────────
  const [cats, prods, users, orders, revs, notifs, cartItems, addrs] =
    await Promise.all([
      prisma.category.count(),
      prisma.product.count(),
      prisma.user.count(),
      prisma.order.count(),
      prisma.review.count(),
      prisma.notification.count(),
      prisma.cartItem.count(),
      prisma.address.count(),
    ]);

  console.log("\n✅  Seed completed!");
  console.log(`   Categories    : ${cats}`);
  console.log(`   Products      : ${prods}`);
  console.log(`   Users         : ${users} (1 admin + ${users - 1} customers)`);
  console.log(`   Orders        : ${orders}`);
  console.log(`   Reviews       : ${revs}`);
  console.log(`   Notifications : ${notifs}`);
  console.log(`   Cart items    : ${cartItems}`);
  console.log(`   Addresses     : ${addrs}`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
