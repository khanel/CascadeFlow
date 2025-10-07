import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';

/// Default channel name applied when none is provided by the request.
const String _defaultChannel = 'quick_entry';

/// Generates identifiers for new capture items.
typedef CaptureQuickEntryIdGenerator = EntityId Function();

/// Supplies the current time for capture operations.
typedef CaptureQuickEntryClock = Timestamp Function();

/// Publishes domain events emitted by the use case.
typedef CaptureQuickEntryEventPublisher = void Function(DomainEvent event);

/// Payload describing a quick capture entry request.
class CaptureQuickEntryRequest {
  /// Creates a request describing the raw capture input and optional context.
  const CaptureQuickEntryRequest({
    required this.rawContent,
    this.channel,
    this.context,
    this.metadata,
  });

  /// Raw, unnormalized content supplied by the user or integration.
  final String rawContent;

  /// Optional channel that produced the capture (defaults to the shared
  /// quick-entry channel).
  final String? channel;

  /// Optional fully-specified context supplied by the caller.
  final CaptureContext? context;

  /// Optional metadata written alongside the capture item.
  final Map<String, String>? metadata;
}

/// Use case responsible for capturing a quick entry into the inbox.
class CaptureQuickEntry {
  /// Creates a use case that captures quick entries.
  CaptureQuickEntry({
    required CaptureQuickEntryIdGenerator idGenerator,
    required CaptureQuickEntryClock nowProvider,
    required CaptureQuickEntryEventPublisher publishEvent,
  }) : _idGenerator = idGenerator,
       _nowProvider = nowProvider,
       _publishEvent = publishEvent;

  final CaptureQuickEntryIdGenerator _idGenerator;
  final CaptureQuickEntryClock _nowProvider;
  final CaptureQuickEntryEventPublisher _publishEvent;

  /// Executes the use case and returns a `Result` describing the outcome.
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

  /// Resolves the context provided by the request or supplies defaults.
  CaptureContext _resolveContext(CaptureQuickEntryRequest request) {
    final provided = request.context;
    if (provided != null) {
      return provided;
    }

    final trimmedChannel = request.channel?.trim();
    final resolvedChannel = trimmedChannel == null || trimmedChannel.isEmpty
        ? _defaultChannel
        : trimmedChannel;

    return CaptureContext(
      source: CaptureSource.quickCapture,
      channel: resolvedChannel,
    );
  }
}
