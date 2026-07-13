import { env } from "../config/env";
import { AppError, BadRequestError } from "../utils/errors";
import { logger } from "../config/logger";

const AUTOCOMPLETE_URL = "https://places.googleapis.com/v1/places:autocomplete";
const DETAILS_URL = "https://places.googleapis.com/v1/places";

export interface PlaceSuggestion {
  placeId: string;
  description: string;
  mainText: string;
  secondaryText: string;
}

export interface PlaceAddress {
  formattedAddress: string;
  street: string;
  city: string;
  state: string;
  postalCode: string;
  country: string; // short code, e.g. "US"
  latitude?: number;
  longitude?: number;
}

// Google addressComponent → our fields, matched by component type.
interface GComponent {
  longText?: string;
  shortText?: string;
  types?: string[];
}

function pick(components: GComponent[], type: string, short = false): string {
  const c = components.find((x) => x.types?.includes(type));
  return (short ? c?.shortText : c?.longText) ?? "";
}

export class PlacesService {
  private key(): string {
    if (!env.GOOGLE_MAPS_API_KEY) {
      throw new AppError(
        503,
        "PLACES_UNAVAILABLE",
        "Address lookup is not configured on the server.",
      );
    }
    return env.GOOGLE_MAPS_API_KEY;
  }

  async autocomplete(input: string): Promise<PlaceSuggestion[]> {
    const trimmed = input.trim();
    if (trimmed.length < 3) return [];

    const res = await fetch(AUTOCOMPLETE_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": this.key(),
      },
      body: JSON.stringify({ input: trimmed }),
    });

    if (!res.ok) {
      const detail = await res.text();
      logger.error(`Places autocomplete failed (${res.status}): ${detail}`);
      throw new AppError(502, "PLACES_UPSTREAM", "Address lookup failed.");
    }

    const data = (await res.json()) as {
      suggestions?: Array<{
        placePrediction?: {
          placeId?: string;
          text?: { text?: string };
          structuredFormat?: {
            mainText?: { text?: string };
            secondaryText?: { text?: string };
          };
        };
      }>;
    };

    return (data.suggestions ?? [])
      .map((s) => s.placePrediction)
      .filter((p): p is NonNullable<typeof p> => !!p?.placeId)
      .map((p) => ({
        placeId: p.placeId!,
        description: p.text?.text ?? "",
        mainText: p.structuredFormat?.mainText?.text ?? p.text?.text ?? "",
        secondaryText: p.structuredFormat?.secondaryText?.text ?? "",
      }));
  }

  async details(placeId: string): Promise<PlaceAddress> {
    if (!placeId) throw new BadRequestError("placeId is required");

    const res = await fetch(`${DETAILS_URL}/${encodeURIComponent(placeId)}`, {
      headers: {
        "X-Goog-Api-Key": this.key(),
        "X-Goog-FieldMask": "formattedAddress,addressComponents,location",
      },
    });

    if (!res.ok) {
      const detail = await res.text();
      logger.error(`Places details failed (${res.status}): ${detail}`);
      throw new AppError(502, "PLACES_UPSTREAM", "Address lookup failed.");
    }

    const data = (await res.json()) as {
      formattedAddress?: string;
      addressComponents?: GComponent[];
      location?: { latitude?: number; longitude?: number };
    };
    const comp = data.addressComponents ?? [];

    const streetNumber = pick(comp, "street_number");
    const route = pick(comp, "route");
    const city =
      pick(comp, "locality") ||
      pick(comp, "postal_town") ||
      pick(comp, "administrative_area_level_2");

    return {
      formattedAddress: data.formattedAddress ?? "",
      street: [streetNumber, route].filter(Boolean).join(" "),
      city,
      state: pick(comp, "administrative_area_level_1", true),
      postalCode: pick(comp, "postal_code"),
      country: pick(comp, "country", true),
      latitude: data.location?.latitude,
      longitude: data.location?.longitude,
    };
  }
}
