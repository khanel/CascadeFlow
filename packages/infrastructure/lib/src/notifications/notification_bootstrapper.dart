/// Coordinates notification setup before UI renders.
typedef NotificationBootstrapper = Future<void> Function();

/// Generic notification initializer signature.
typedef NotificationInitializer = Future<void> Function();

/// Requests notification permissions from the operating system.
typedef NotificationPermissionInitializer = NotificationInitializer;

/// Configures notification channels/categories on supported platforms.
typedef NotificationChannelInitializer = NotificationInitializer;

/// Registers background handlers required for notification processing.
typedef NotificationBackgroundInitializer = NotificationInitializer;

/// Builds a bootstrapper that executes the supplied initializers in order.
NotificationBootstrapper createNotificationBootstrapper({
  required NotificationPermissionInitializer requestPermissions,
  required NotificationChannelInitializer configureChannels,
  required NotificationBackgroundInitializer configureBackgroundHandlers,
}) {
  return () async {
    await _runSequentially(<NotificationInitializer>[
      requestPermissions,
      configureChannels,
      configureBackgroundHandlers,
    ]);
  };
}

Future<void> _runSequentially(
  Iterable<NotificationInitializer> initializers,
) async {
  for (final initializer in initializers) {
    await initializer();
  }
}

/// Placeholder initializer used while platform integrations are in-flight.
Future<void> noopNotificationInitializer() async {}

/// Placeholder bootstrapper used until platform integrations land.
Future<void> noopNotificationBootstrapper() async {}
