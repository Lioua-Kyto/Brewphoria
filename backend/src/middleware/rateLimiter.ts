import rateLimit from "express-rate-limit";

export const globalRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 500,                  // ~33 req/min — plenty for normal mobile usage
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: "RATE_LIMIT_EXCEEDED",
      message: "Too many requests. Please try again later.",
    },
  },
  skip: (req) => req.path === "/health",
});

export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,                   // raised slightly — still blocks brute force
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: "RATE_LIMIT_EXCEEDED",
      message: "Too many authentication attempts. Please try again later.",
    },
  },
});

export const chatRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,                   // 2/min — enough for comfortable testing
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: {
      code: "RATE_LIMIT_EXCEEDED",
      message: "Too many chat requests. Please slow down.",
    },
  },
});
