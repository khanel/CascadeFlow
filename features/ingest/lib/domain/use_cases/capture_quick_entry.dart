import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';

const String _defaultChannel = 'quick_entry';

typedef CaptureQuickEntryIdGenerator = EntityId Function();
typedef CaptureQuickEntryClock = Timestamp Function();
typedef CaptureQuickEntryEventPublisher = void Function(DomainEvent event);

/// Payload describing a quick capture entry request.
class CaptureQuickEntryRequest {
  const CaptureQuickEntryRequest({
    required this.rawContent,
    this.channel,
    this.context,
    this.metadata,
  });

  final String rawContent;
  final String? channel;
  final CaptureContext? context;
  final Map<String, String>? metadata;
}

/// Use case responsible for capturing a quick entry into the inbox.
class CaptureQuickEntry {
  CaptureQuickEntry({
    required CaptureQuickEntryIdGenerator idGenerator,
    required CaptureQuickEntryClock nowProvider,
    required CaptureQuickEntryEventPublisher publishEvent,
  })  : _idGenerator = idGenerator,
        _nowProvider = nowProvider,
        _publishEvent = publishEvent;

  final CaptureQuickEntryIdGenerator _idGenerator;
  final CaptureQuickEntryClock _nowProvider;
  final CaptureQuickEntryEventPublisher _publishEvent;

  Result<CaptureItem, Failure> call({
    required CaptureQuickEntryRequest request,
  }) {
    return Result.guard<CaptureItem, Failure>(
      body: () {
        final captureId = _idGenerator();
        final timestamp = _nowProvider();
        final context = _resolveContext(request);

        final item = CaptureItem.create(
          id: captureId,
          content: request.rawContent,
          context: context,
          createdAt: timestamp,
          updatedAt: timestamp,
          metadata: request.metadata,
        );

        _publishEvent(
          CaptureItemFiled(
            captureId: captureId,
            summary: item.content,
            occurredOn: timestamp,
          ),
        );

        return item;
      },
      onError: (error, stackTrace) {
        if (error is Failure) {
          return error;
        }
        return DomainFailure(
          message: 'Unable to capture quick entry',
          cause: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  CaptureContext _resolveContext(CaptureQuickEntryRequest request) {
    final provided = request.context;
    if (provided != null) {
      return provided;
    }

    final trimmedChannel = request.channel?.trim();
    final resolvedChannel =
        trimmedChannel == null || trimmedChannel.isEmpty
            ? _defaultChannel
            : trimmedChannel;

    return CaptureContext(
      source: CaptureSource.quickCapture,
      channel: resolvedChannel,
    );
  }
}
