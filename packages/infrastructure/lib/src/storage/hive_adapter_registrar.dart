/// Registers Hive adapters required before encrypted boxes open.
typedef HiveAdapterRegistrar = Future<void> Function();

/// Placeholder registrar used while real adapters are under development.
Future<void> noopHiveAdapterRegistrar() async {}
