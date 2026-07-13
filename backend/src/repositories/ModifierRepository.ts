import { prisma } from "../config/database";
import { ModifierGroup, ModifierOption } from "@prisma/client";

export type GroupWithOptions = ModifierGroup & { options: ModifierOption[] };

export class ModifierRepository {
  async findGroupsByCategory(categoryId: string): Promise<GroupWithOptions[]> {
    return prisma.modifierGroup.findMany({
      where: { categoryId },
      orderBy: { sortOrder: "asc" },
      include: { options: { orderBy: { sortOrder: "asc" } } },
    });
  }

  async findOptionsByIds(
    ids: string[],
  ): Promise<(ModifierOption & { group: ModifierGroup })[]> {
    if (ids.length === 0) return [];
    return prisma.modifierOption.findMany({
      where: { id: { in: ids } },
      include: { group: true },
    });
  }
}
