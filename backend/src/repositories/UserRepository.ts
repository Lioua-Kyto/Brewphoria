import { Prisma, User, Address, Role } from "@prisma/client";
import { prisma } from "../config/database";

export class UserRepository {
  async findByFirebaseUid(firebaseUid: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { firebaseUid } });
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({ where: { email } });
  }

  async upsertByFirebaseUid(data: {
    firebaseUid: string;
    email: string;
    displayName: string;
    firstName?: string | null;
    lastName?: string | null;
    avatarUrl?: string;
  }): Promise<User> {
    return prisma.user.upsert({
      where: { firebaseUid: data.firebaseUid },
      create: {
        firebaseUid: data.firebaseUid,
        email: data.email,
        displayName: data.displayName,
        firstName: data.firstName,
        lastName: data.lastName,
        avatarUrl: data.avatarUrl,
        loyaltyAccount: {
          create: {
            currentPoints: 0,
            lifetimePoints: 0,
            tier: "BRONZE",
          },
        },
      },
      update: {
        email: data.email,
        displayName: data.displayName,
        firstName: data.firstName,
        lastName: data.lastName,
        ...(data.avatarUrl !== undefined ? { avatarUrl: data.avatarUrl } : {}),
      },
    });
  }

  async updateById(id: string, data: Prisma.UserUpdateInput): Promise<User> {
    return prisma.user.update({ where: { id }, data });
  }

  async updateFcmToken(id: string, fcmToken: string | null): Promise<User> {
    return prisma.user.update({ where: { id }, data: { fcmToken } });
  }

  async findAdmins(): Promise<User[]> {
    return prisma.user.findMany({ where: { role: Role.ADMIN } });
  }

  // Addresses
  async findAddresses(userId: string): Promise<Address[]> {
    return prisma.address.findMany({
      where: { userId },
      orderBy: [{ isDefault: "desc" }, { createdAt: "desc" }],
    });
  }

  async findAddressById(id: string): Promise<Address | null> {
    return prisma.address.findUnique({ where: { id } });
  }

  async createAddress(
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
    return prisma.$transaction(async (tx) => {
      if (data.isDefault) {
        await tx.address.updateMany({
          where: { userId, isDefault: true },
          data: { isDefault: false },
        });
      }
      return tx.address.create({
        data: { ...data, userId },
      });
    });
  }

  async updateAddress(
    id: string,
    data: Prisma.AddressUpdateInput,
  ): Promise<Address> {
    return prisma.address.update({ where: { id }, data });
  }

  async deleteAddress(id: string): Promise<void> {
    await prisma.address.delete({ where: { id } });
  }

  async setDefaultAddress(userId: string, addressId: string): Promise<void> {
    await prisma.$transaction([
      prisma.address.updateMany({
        where: { userId, isDefault: true },
        data: { isDefault: false },
      }),
      prisma.address.update({
        where: { id: addressId },
        data: { isDefault: true },
      }),
    ]);
  }
}
