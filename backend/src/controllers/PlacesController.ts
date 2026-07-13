import { Request, Response } from "express";
import { z } from "zod";
import { PlacesService } from "../services/PlacesService";
import { sendSuccess } from "../utils/response";

const placesService = new PlacesService();

const autocompleteSchema = z.object({
  input: z.string().min(1).max(200),
});

const detailsSchema = z.object({
  placeId: z.string().min(1),
});

export class PlacesController {
  async autocomplete(req: Request, res: Response): Promise<void> {
    const { input } = autocompleteSchema.parse(req.query);
    const suggestions = await placesService.autocomplete(input);
    sendSuccess(res, suggestions, "Suggestions retrieved");
  }

  async details(req: Request, res: Response): Promise<void> {
    const { placeId } = detailsSchema.parse(req.params);
    const address = await placesService.details(placeId);
    sendSuccess(res, address, "Address retrieved");
  }
}
