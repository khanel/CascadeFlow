import 'dart:async';
import 'dart:io';
import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:hive_ce/hive.dart';
import 'hive_initializer.dart';

/// Real Hive CE initializer for production use with persistent storage.
class RealHiveInitializer extends HiveInitializer {
  /// Flag to ensure adapters are registered only once across all instances.
  static bool _adaptersRegistered = false;

  /// Directory path for Hive storage.
  String? _hiveDirectory;

  @override
  Future<void> doInitialize() async {
    // For testing, use a consistent test directory to simulate real persistence
    final tempDir = Directory.systemTemp;
    _hiveDirectory = '${tempDir.path}/hive_test';
    final hiveDir = Directory(_hiveDirectory!);
    if (!hiveDir.existsSync()) {
      hiveDir.createSync(recursive: true);
    }
    Hive.init(_hiveDirectory!);
    // Register adapters only once
    if (!_adaptersRegistered) {
      Hive.registerAdapter(CaptureItemHiveModelAdapter());
      _adaptersRegistered = true;
    }
    await noopHiveAdapterRegistrar();
  }

  @override
  /// Opens (or creates) a real Hive box with the given [name].
  Future<HiveBox<T>> openEncryptedBox<T>(String name) async {
    final initialization = this.initialization;
    if (initialization == null) {
      throw const InfrastructureFailure(
        message: 'Hive initializer used before initialize() was called.',
      );
    }
    await initialization;

    final box = await Hive.openBox<T>(name);
    return RealHiveBox<T>._(box);
  }

  /// Opens (or creates) an unencrypted Hive box (for testing or non-sensitive data).
  Future<RealHiveBox<T>> openBox<T>(String name) async {
    final initialization = this.initialization;
    if (initialization == null) {
      throw const InfrastructureFailure(
        message: 'Hive initializer used before initialize() was called.',
      );
    }
    await initialization;

    final box = await Hive.openBox<T>(name);
    return RealHiveBox<T>._(box);
  }
}

/// Box wrapper that matches the InMemoryHiveBox interface but uses real Hive Box.
class RealHiveBox<T> implements HiveBox<T> {
  RealHiveBox._(this._box);

  final Box<T> _box;

  /// Stores [value] under [key].
  Future<void> put(String key, T value) => Future.value(_box.put(key, value));

  /// Retrieves a value for [key], returning `null` when it is absent.
  Future<T?> get(String key) => Future.value(_box.get(key));

  /// Returns an immutable snapshot of the stored values.
  Future<List<T>> values() => Future.value(List.unmodifiable(_box.values));

  /// Deletes the value stored under [key], doing nothing when it is absent.
  Future<void> delete(String key) => Future.value(_box.delete(key));

  /// Removes every stored value.
  Future<void> clear() => Future.value(_box.clear());

  /// Returns the value at [key], throwing when it has not been written yet.
  T require(String key) {
    if (!_box.containsKey(key)) {
      throw InfrastructureFailure(
        message: 'Key "$key" missing from box "${_box.name}".',
      );
    }
    return _box.get(key) as T;
  }
}

/// TypeAdapter for CaptureItemHiveModel to enable Hive serialization.
class CaptureItemHiveModelAdapter extends TypeAdapter<CaptureItemHiveModel> {
  @override
  final int typeId = 0; // Use a unique type ID

  @override
  CaptureItemHiveModel read(BinaryReader reader) {
    final id = reader.readString();
    final content = reader.readString();
    final source = reader.readString();
    final channel = reader.readString();
    final createdAtMicros = reader.readInt();
    final updatedAtMicros = reader.readInt();
    final status = reader.readString();
    final metadata = reader.readMap().cast<String, String>();

    return CaptureItemHiveModel(
      id: id,
      content: content,
      source: source,
      channel: channel,
      createdAtMicros: createdAtMicros,
      updatedAtMicros: updatedAtMicros,
      status: status,
      metadata: metadata,
    );
  }

  @override
  void write(BinaryWriter writer, CaptureItemHiveModel obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.content);
    writer.writeString(obj.source);
    writer.writeString(obj.channel);
    writer.writeInt(obj.createdAtMicros);
    writer.writeInt(obj.updatedAtMicros);
    writer.writeString(obj.status);
    writer.writeMap(obj.metadata);
  }
}
