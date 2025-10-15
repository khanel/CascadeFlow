import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';

/// Supplies the current time for filing operations.
typedef FileCaptureItemClock = Timestamp Function();

/// Publishes domain events emitted by the file use case.
typedef FileCaptureItemEventPublisher = void Function(DomainEvent event);

/// Request payload describing the capture item to file.
class FileCaptureItemRequest {
  /// Creates a request wrapping the [item] that should be filed.
  const FileCaptureItemRequest({required this.item});

  /// The capture item that should transition to the filed status.
  final CaptureItem item;
}

/// Use case responsible for filing a capture item.
class FileCaptureItem {
  /// Creates a use case that files capture items.
  FileCaptureItem({
    required FileCaptureItemClock nowProvider,
    required FileCaptureItemEventPublisher publishEvent,
  }) : _nowProvider = nowProvider,
       _publishEvent = publishEvent;

  final FileCaptureItemClock _nowProvider;
  final FileCaptureItemEventPublisher _publishEvent;

  /// Executes the use case and returns a `Result` describing the outcome.
  Result<CaptureItem, Failure> call({
    required FileCaptureItemRequest request,
  }) {
    return Result.guard<CaptureItem, Failure>(
      body: () {
        final item = request.item;
        if (item.isFiled) {
          throw const DomainFailure(
            message: 'Capture item already filed',
          );
        }

        final timestamp = _nowProvider();
        final filed = item.copyWith(
          status: CaptureStatus.filed,
          updatedAt: timestamp,
        );

        _publishEvent(
          CaptureItemFiled(
            captureId: item.id,
            summary: filed.content,
            occurredOn: timestamp,
          ),
        );

        return filed;
      },
      onError: (error, stackTrace) {
        if (error is Failure) {
          return error;
        }
        return DomainFailure(
          message: 'Unable to file capture item',
          cause: error,
          stackTrace: stackTrace,
        );
      },
    );
  }
}
