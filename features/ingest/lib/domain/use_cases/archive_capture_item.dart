import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';

/// Supplies the current time for archiving operations.
typedef ArchiveCaptureItemClock = Timestamp Function();

/// Publishes domain events emitted by the archive use case.
typedef ArchiveCaptureItemEventPublisher = void Function(DomainEvent event);

/// Request payload describing the capture item to archive.
class ArchiveCaptureItemRequest {
  /// Creates a request wrapping the [item] that should be archived.
  const ArchiveCaptureItemRequest({required this.item});

  /// The capture item that should transition to the archived status.
  final CaptureItem item;
}

/// Use case responsible for archiving a capture item.
class ArchiveCaptureItem {
  /// Creates a use case that archives capture items.
  ArchiveCaptureItem({
    required ArchiveCaptureItemClock nowProvider,
    required ArchiveCaptureItemEventPublisher publishEvent,
  }) : _nowProvider = nowProvider,
       _publishEvent = publishEvent;

  final ArchiveCaptureItemClock _nowProvider;
  final ArchiveCaptureItemEventPublisher _publishEvent;

  /// Executes the use case and returns a `Result` describing the outcome.
  Result<CaptureItem, Failure> call({
    required ArchiveCaptureItemRequest request,
  }) {
    return Result.guard<CaptureItem, Failure>(
      body: () {
        final item = request.item;
        if (item.isArchived) {
          throw const DomainFailure(message: 'Capture item already archived');
        }

        final timestamp = _nowProvider();
        final archived = item.copyWith(
          status: CaptureStatus.archived,
          updatedAt: timestamp,
        );

        _publishEvent(
          CaptureItemArchived(
            captureId: item.id,
            summary: archived.content,
            occurredOn: timestamp,
          ),
        );

        return archived;
      },
      onError: (error, stackTrace) {
        if (error is Failure) {
          return error;
        }
        return DomainFailure(
          message: 'Unable to archive capture item',
          cause: error,
          stackTrace: stackTrace,
        );
      },
    );
  }
}
