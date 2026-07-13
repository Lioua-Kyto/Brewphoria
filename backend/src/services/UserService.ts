import { User, Address } from "@prisma/client";
import { UserRepository } from "../repositories/UserRepository";
import { NotFoundError, ForbiddenError } from "../utils/errors";

const userRepo = new UserRepository();

function deriveNamesFromDisplayName(displayName: string): {
  firstName: string | null;
  lastName: string | null;
} {
  const cap = (s: string) => s.charAt(0).toUpperCase() + s.slice(1);
  const parts = displayName.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return { firstName: null, lastName: null };
  return {
    firstName: cap(parts[0]!),
    lastName: parts.length > 1 ? parts.slice(1).map(cap).join(" ") : null,
  };
}

export class UserService {
  async getProfile(userId: string): Promise<User> {
    const user = await userRepo.findById(userId);
    if (!user) throw new NotFoundError("User");
    return user;
  }

  async updateProfile(
    userId: string,
    data: { displayName?: string; avatarUrl?: string },
  ): Promise<User> {
    const user = await userRepo.findById(userId);
    if (!user) throw new NotFoundError("User");

    // Keep firstName/lastName (used for the app greeting) in sync with the
    // edited display name.
    const nameFields =
      data.displayName !== undefined
        ? deriveNamesFromDisplayName(data.displayName)
        : {};

    return userRepo.updateById(userId, {
      ...(data.displayName !== undefined
        ? { displayName: data.displayName }
        : {}),
      ...nameFields,
      ...(data.avatarUrl !== undefined ? { avatarUrl: data.avatarUrl } : {}),
    });
  }

  async getAddresses(userId: string): Promise<Address[]> {
    return userRepo.findAddresses(userId);
  }

  async addAddress(
    userId: string,
    data: {
      label: string;
      fullName: string;
      phone: string;
      street: string;
      city: string;
      state: string;
      postalCode: string;
      country: string;
      isDefault: boolean;
    },
  ): Promise<Address> {
    return userRepo.createAddress(userId, { ...data });
  }

  async updateAddress(
    userId: string,
    addressId: string,
    data: Partial<{
      label: string;
      fullName: string;
      phone: string;
      street: string;
      city: string;
      state: string;
      postalCode: string;
      country: string;
      isDefault: boolean;
    }>,
  ): Promise<Address> {
    const address = await userRepo.findAddressById(addressId);
    if (!address) throw new NotFoundError("Address");
    if (address.userId !== userId) throw new ForbiddenError("Not your address");

    if (data.isDefault === true) {
      await userRepo.setDefaultAddress(userId, addressId);
    }

    return userRepo.updateAddress(addressId, data);
  }

  async deleteAddress(userId: string, addressId: string): Promise<void> {
    const address = await userRepo.findAddressById(addressId);
    if (!address) throw new NotFoundError("Address");
    if (address.userId !== userId) throw new ForbiddenError("Not your address");
    await userRepo.deleteAddress(addressId);
  }
}
