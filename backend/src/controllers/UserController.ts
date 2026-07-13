import { Request, Response } from "express";
import { z } from "zod";
import { UserService } from "../services/UserService";
import { sendSuccess } from "../utils/response";

const userService = new UserService();

const updateProfileSchema = z.object({
  displayName: z.string().min(1).max(100).optional(),
  avatarUrl: z.string().url().optional(),
});

const addressSchema = z.object({
  label: z.string().min(1).max(50),
  fullName: z.string().min(1).max(100),
  phone: z.string().min(1).max(20),
  street: z.string().min(1),
  city: z.string().min(1),
  state: z.string().min(1),
  postalCode: z.string().min(1),
  country: z.string().min(1),
  isDefault: z.boolean().default(false),
});

const updateAddressSchema = addressSchema.partial();

export class UserController {
  async getMe(req: Request, res: Response): Promise<void> {
    const user = await userService.getProfile(req.user!.id);
    sendSuccess(res, user, "Profile retrieved");
  }

  async updateMe(req: Request, res: Response): Promise<void> {
    const parsed = updateProfileSchema.parse(req.body);
    const user = await userService.updateProfile(req.user!.id, parsed);
    sendSuccess(res, user, "Profile updated");
  }

  async getAddresses(req: Request, res: Response): Promise<void> {
    const addresses = await userService.getAddresses(req.user!.id);
    sendSuccess(res, addresses, "Addresses retrieved");
  }

  async addAddress(req: Request, res: Response): Promise<void> {
    const parsed = addressSchema.parse(req.body);
    const address = await userService.addAddress(req.user!.id, parsed);
    sendSuccess(res, address, "Address added", 201);
  }

  async updateAddress(req: Request, res: Response): Promise<void> {
    const parsed = updateAddressSchema.parse(req.body);
    const address = await userService.updateAddress(
      req.user!.id,
      req.params["id"]!,
      parsed,
    );
    sendSuccess(res, address, "Address updated");
  }

  async deleteAddress(req: Request, res: Response): Promise<void> {
    await userService.deleteAddress(req.user!.id, req.params["id"]!);
    sendSuccess(res, null, "Address deleted");
  }
}
