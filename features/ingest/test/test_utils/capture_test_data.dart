import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';

CaptureItem buildTestCaptureItem({
  required String id,
  CaptureStatus status = CaptureStatus.inbox,
  CaptureSource source = CaptureSource.quickCapture,
  String content = 'Capture content',
  String channel = 'quick_sheet',
  int createdMicros = 0,
  int updatedMicros = 0,
  Map<String, String> metadata = const <String, String>{},
}) {
  return CaptureItem.create(
    id: EntityId(id),
    content: content,
    context: CaptureContext(
      source: source,
      channel: channel,
    ),
    status: status,
    createdAt: Timestamp(
      DateTime.fromMicrosecondsSinceEpoch(createdMicros, isUtc: true),
    ),
    updatedAt: Timestamp(
      DateTime.fromMicrosecondsSinceEpoch(updatedMicros, isUtc: true),
    ),
    metadata: metadata,
  );
}
