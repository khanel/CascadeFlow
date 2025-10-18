import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:hive_ce/hive.dart';

/// Hive persistence model for `CaptureItem`.
class CaptureItemHiveModel {
  /// Creates a Hive model that mirrors the domain entity.
  CaptureItemHiveModel({
    required this.id,
    required this.content,
    required this.source,
    required this.channel,
    required this.createdAtMicros,
    required this.updatedAtMicros,
    required this.status,
    required this.metadata,
  });

  /// Builds a persistence model from the given domain entity.
  factory CaptureItemHiveModel.fromDomain(CaptureItem item) {
    return CaptureItemHiveModel(
      id: item.id.value,
      content: item.content,
      source: item.context.source.name,
      channel: item.context.channel,
      createdAtMicros: item.createdAt.value.microsecondsSinceEpoch,
      updatedAtMicros: item.updatedAt.value.microsecondsSinceEpoch,
      status: item.status.name,
      metadata: Map<String, String>.from(item.metadata),
    );
  }

  /// Identifier persisted with the Hive record.
  final String id;

  /// Primary content string captured by the user.
  final String content;

  /// Source enum value serialized as a string.
  final String source;

  /// Channel identifier stored alongside the capture.
  final String channel;

  /// UTC microseconds when the item was created.
  final int createdAtMicros;

  /// UTC microseconds when the item was last updated.
  final int updatedAtMicros;

  /// Serialized capture status.
  final String status;

  /// Arbitrary metadata stored with the capture item.
  final Map<String, String> metadata;

  /// Converts this Hive model back into a domain entity.
  CaptureItem toDomain() {
    final createdAt = Timestamp(
      DateTime.fromMicrosecondsSinceEpoch(createdAtMicros, isUtc: true),
    );
    final updatedAt = Timestamp(
      DateTime.fromMicrosecondsSinceEpoch(updatedAtMicros, isUtc: true),
    );
    final resolvedSource = CaptureSource.values.firstWhere(
      (value) => value.name == source,
      orElse: () => CaptureSource.quickCapture,
    );
    final resolvedStatus = CaptureStatus.values.firstWhere(
      (value) => value.name == status,
      orElse: () => CaptureStatus.inbox,
    );

    return CaptureItem.create(
      id: EntityId(id),
      content: content,
      context: CaptureContext(
        source: resolvedSource,
        channel: channel,
      ),
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: resolvedStatus,
      metadata: Map<String, String>.from(metadata),
    );
  }
}

/// Unique Hive type identifier assigned to [CaptureItemHiveModelAdapter].
const int captureItemHiveModelTypeId = 0;

/// Hive `TypeAdapter` for serializing [CaptureItemHiveModel] instances.
class CaptureItemHiveModelAdapter extends TypeAdapter<CaptureItemHiveModel> {
  @override
  int get typeId => captureItemHiveModelTypeId;

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
    writer
      ..writeString(obj.id)
      ..writeString(obj.content)
      ..writeString(obj.source)
      ..writeString(obj.channel)
      ..writeInt(obj.createdAtMicros)
      ..writeInt(obj.updatedAtMicros)
      ..writeString(obj.status)
      ..writeMap(obj.metadata);
  }
}

bool _captureItemAdapterRegistered = false;

/// Ensures the capture item adapter is registered exactly once with Hive.
Future<void> registerCaptureItemHiveAdapter() async {
  if (_captureItemAdapterRegistered) {
    return;
  }
  if (!Hive.isAdapterRegistered(captureItemHiveModelTypeId)) {
    Hive.registerAdapter(CaptureItemHiveModelAdapter());
  }
  _captureItemAdapterRegistered = true;
}
