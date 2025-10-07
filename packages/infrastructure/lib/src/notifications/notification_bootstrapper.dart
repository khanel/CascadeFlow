/// Coordinates notification setup before UI renders.
typedef NotificationBootstrapper = Future<void> Function();

/// Placeholder bootstrapper used until platform integrations land.
Future<void> noopNotificationBootstrapper() async {}
