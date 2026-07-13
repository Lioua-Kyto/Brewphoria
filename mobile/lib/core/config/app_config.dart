/// App-wide configuration flags.
class AppConfig {
  AppConfig._();

  /// ┌──────────────────────────────────────────────────────────────────────┐
  /// │  OFFLINE DEMO MODE                                                     │
  /// │                                                                        │
  /// │  true  → the app runs 100% offline on realistic FAKE data (no backend, │
  /// │          no Firebase). Products, reviews, cart, orders, loyalty, the   │
  /// │          AI barista — everything is served in-app from lib/core/mock.  │
  /// │          Sign in with ANY email + password (or "Browse as a guest").   │
  /// │          This is what you ship as a standalone showcase .apk.          │
  /// │                                                                        │
  /// │  false → the app talks to the real backend + Firebase (normal dev).    │
  /// │                                                                        │
  /// │  To switch: flip this one line and rebuild. You can also override it   │
  /// │  at build time without editing the file:                              │
  /// │      flutter run   --dart-define=MOCK=false     (use real backend)     │
  /// │      flutter build apk --dart-define=MOCK=true  (offline demo apk)     │
  /// └──────────────────────────────────────────────────────────────────────┘
  static const bool useMockData = bool.fromEnvironment('MOCK', defaultValue: true);
}
