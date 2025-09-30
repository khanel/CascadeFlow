# Infrastructure Provider Registry

This package exposes a small set of Riverpod providers that the feature slices can rely on while the real platform integrations are still in development. Each provider resolves to the same in-memory stub used throughout the integration tests, keeping behaviour predictable between the app and tests.

## Available providers

### `loggerProvider`
- **Type:** `Provider<PrintLogger>`
- **Implementation:** returns a singleton `PrintLogger` instance using `debug`, `info`, `warning`, and `error` helpers.
- **Usage:** Read it when you need lightweight console logging inside application layers while more advanced logging is still being designed.

### `hiveInitializerProvider`
- **Type:** `Provider<InMemoryHiveInitializer>`
- **Implementation:** wraps the in-memory Hive initializer stub used in tests. It guarantees `initialize()` is idempotent and that each named box is only created once.
- **Usage:** Call `initialize()` during app bootstrap, then resolve encrypted boxes for repositories and data sources.

### `secureStorageProvider`
- **Type:** `Provider<InMemorySecureStorage>`
- **Implementation:** uses an in-memory map to simulate secure key-value storage.
- **Usage:** Prototype flows that need to persist API tokens or Hive encryption keys. Replace with the production secure storage once native integrations land.

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
