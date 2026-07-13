/** @type {import('ts-jest').JestConfigWithTsJest} */
export default {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/src/tests"],
  testMatch: ["**/*.test.ts"],
  transform: {
    "^.+\.tsx?$": [
      "ts-jest",
      {
        tsconfig: {
          strict: true,
        },
      },
    ],
  },
  setupFilesAfterEnv: ["<rootDir>/src/tests/testSetup.ts"],
  testTimeout: 30000,
  verbose: true,
  detectOpenHandles: true,
  forceExit: true,
  moduleNameMapper: {
    "^@/(.*)$": "<rootDir>/src/$1",
  },
};
