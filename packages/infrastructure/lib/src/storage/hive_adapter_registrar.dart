/// Registers Hive adapters required before encrypted boxes open.
abstract class HiveAdapterRegistrar {
  /// Apply all adapter registrations needed by the app shell.
  Future<void> registerAdapters();
}

/// Placeholder registrar used while real adapters are under development.
class NoopHiveAdapterRegistrar implements HiveAdapterRegistrar {
  /// Creates a registrar that intentionally does nothing.
  const NoopHiveAdapterRegistrar();

  @override
  Future<void> registerAdapters() async {}
}
