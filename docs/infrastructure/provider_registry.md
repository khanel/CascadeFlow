# Infrastructure Provider Registry

This package exposes a small set of Riverpod providers that the feature slices can rely on while the real platform integrations are still in development. Each provider resolves to the same in-memory stub used throughout the integration tests, keeping behaviour predictable between the app and tests.

## Available providers

### `loggerProvider`
- **Type:** `Provider<PrintLogger>`
- **Implementation:** returns a singleton `PrintLogger` instance using `debug`, `info`, `warning`, and `error` helpers.
- **Usage:** Read it when you need lightweight console logging inside application layers while more advanced logging is still being designed.

### `hiveInitializerProvider`
- **Type:** `Provider<HiveInitializer>`
- **Implementation:** resolves to the in-memory Hive initializer stub by default for tests and local development. Production builds override it with `RealHiveInitializer` to persist data across sessions. The initializer guarantees `initialize()` is idempotent and that each named box is only created once.
- **Usage:** Call `initialize()` during app bootstrap, then resolve encrypted boxes for repositories and data sources.

### `secureStorageProvider`
- **Type:** `Provider<SecureStorage>`
- **Implementation:** defaults to the in-memory map-backed stub. Production builds override it with `FlutterSecureStorageAdapter` so Hive encryption keys survive app restarts.
- **Usage:** Read/write sensitive configuration such as Hive encryption keys or auth tokens. Swap implementations in `ProviderScope` overrides depending on the runtime environment.

## Example usage

```dart
final container = ProviderContainer();
final logger = container.read(loggerProvider);
final hiveInitializer = container.read(hiveInitializerProvider);
final secureStorage = container.read(secureStorageProvider);

logger.info('Provider registry wired up');
await hiveInitializer.initialize();
await secureStorage.write(key: 'token', value: 'abc123');
```

When real platform implementations are available, update the provider definitions in `packages/infrastructure/lib/src/providers/providers.dart` and note the change in this document.
