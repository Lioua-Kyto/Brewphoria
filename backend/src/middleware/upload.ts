import multer, { FileFilterCallback } from "multer";
import sharp from "sharp";
import path from "path";
import fs from "fs/promises";
import { Request } from "express";
import { ValidationError } from "../utils/errors";

const ALLOWED_MIME_TYPES = ["image/jpeg", "image/png", "image/webp"];
const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB

export const UPLOADS_DIR = path.join(process.cwd(), "uploads");

const storage = multer.memoryStorage();

function fileFilter(
  _req: Request,
  file: Express.Multer.File,
  cb: FileFilterCallback,
): void {
  if (ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    cb(null, true);
  } else {
    cb(new ValidationError("Only JPEG, PNG, and WebP images are allowed"));
  }
}

export const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: MAX_FILE_SIZE },
});

/**
 * Optimise an uploaded image buffer:
 *  - Resize to max 1200 × 1200 (preserving aspect ratio, no upscaling)
 *  - Convert to WebP at quality 80
 *  - Save to uploads/<subfolder>/ on disk
 *
 * Returns the public URL path (e.g. "/uploads/products/1234abc.webp")
 */
export async function processAndSaveImage(
  buffer: Buffer,
  subfolder = "products",
): Promise<string> {
  const dir = path.join(UPLOADS_DIR, subfolder);
  await fs.mkdir(dir, { recursive: true });

  const filename = `${Date.now()}-${Math.random().toString(36).slice(2)}.webp`;
  const filepath = path.join(dir, filename);

  await sharp(buffer)
    .resize({
      width: 1200,
      height: 1200,
      fit: "inside",
      withoutEnlargement: true,
    })
    .webp({ quality: 80 })
    .toFile(filepath);

  return `/uploads/${subfolder}/${filename}`;
}
