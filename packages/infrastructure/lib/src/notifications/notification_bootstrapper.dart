/// Coordinates notification setup before UI renders.
typedef NotificationBootstrapper = Future<void> Function();

/// Requests notification permissions from the operating system.
typedef NotificationPermissionInitializer = Future<void> Function();

/// Configures notification channels/categories on supported platforms.
typedef NotificationChannelInitializer = Future<void> Function();

/// Registers background handlers required for notification processing.
typedef NotificationBackgroundInitializer = Future<void> Function();

/// Builds a bootstrapper that executes the supplied initializers in order.
NotificationBootstrapper createNotificationBootstrapper({
  required NotificationPermissionInitializer requestPermissions,
  required NotificationChannelInitializer configureChannels,
  required NotificationBackgroundInitializer configureBackgroundHandlers,
}) {
  return () async {
    await requestPermissions();
    await configureChannels();
    await configureBackgroundHandlers();
  };
}

/// Placeholder initializer used while platform integrations are in-flight.
Future<void> noopNotificationInitializer() async {}

/// Placeholder bootstrapper used until platform integrations land.
Future<void> noopNotificationBootstrapper() async {}
