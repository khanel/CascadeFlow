import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('fold returns success branch', () {
      // Arrange
      final result = SuccessResult<int, Failure>(42);

      // Act
      final value = result.fold(
        onSuccess: (value) => value * 2,
        onFailure: (_) => -1,
      );

      // Assert
      expect(value, 84);
    });

    test('fold returns failure branch', () {
      // Arrange
      final failure = DomainFailure(message: 'boom');
      final result = FailureResult<int, Failure>(failure);

      // Act
      final value = result.fold(
        onSuccess: (_) => 0,
        onFailure: (error) => error.message.length,
      );

      // Assert
      expect(value, failure.message.length);
    });

    test('map transforms value without touching failure', () {
      // Arrange
      final result = SuccessResult<int, Failure>(21);

      // Act
      final mapped = result.map((value) => value * 2);

      // Assert
      expect(mapped, isA<SuccessResult<int, Failure>>());
      expect((mapped as SuccessResult<int, Failure>).value, 42);
    });

    test('map keeps failure untouched', () {
      // Arrange
      final failure = DomainFailure(message: 'nope');
      final result = FailureResult<int, Failure>(failure);

      // Act
      final mapped = result.map((value) => value * 2);

      // Assert
      expect(mapped, isA<FailureResult<int, Failure>>());
      expect((mapped as FailureResult<int, Failure>).failure, failure);
    });

    test('flatMap allows chaining', () {
      // Arrange
      final result = SuccessResult<int, Failure>(2)
          .flatMap((value) => SuccessResult<int, Failure>(value * 3))
          .flatMap((value) => SuccessResult<int, Failure>(value + 1));

      // Assert
      expect(result, isA<SuccessResult<int, Failure>>());
      expect((result as SuccessResult<int, Failure>).value, 7);
    });

    test('fromNullable converts null into failure', () {
      // Act
      final result = Result.fromNullable<int>(
        null,
        () => const DomainFailure(message: 'missing'),
      );

      // Assert
      expect(result.isFailure, isTrue);
    });

    test('guard returns success when body completes', () {
      // Act
      final result = Result.guard<int, InfrastructureFailure>(
        body: () => 21,
        onError: (error, stackTrace) => InfrastructureFailure(
          message: 'Unexpected error',
          cause: error,
          stackTrace: stackTrace,
        ),
      );

      // Assert
      expect(result, isA<SuccessResult<int, InfrastructureFailure>>());
      expect((result as SuccessResult<int, InfrastructureFailure>).value, 21);
    });

    test('guard converts thrown error into failure', () {
      // Act
      final result = Result.guard<int, InfrastructureFailure>(
        body: () => throw StateError('boom'),
        onError: (error, stackTrace) => InfrastructureFailure(
          message: 'Failed to compute',
          cause: error,
          stackTrace: stackTrace,
        ),
      );

      // Assert
      expect(result, isA<FailureResult<int, InfrastructureFailure>>());
      final failure = (result as FailureResult<int, InfrastructureFailure>).failure;
      expect(failure.message, 'Failed to compute');
      expect(failure.cause, isA<StateError>());
      expect(failure.stackTrace, isNotNull);
    });

    test('guardAsync wraps successful future', () async {
      // Act
      final result = await Result.guardAsync<String, InfrastructureFailure>(
        body: () async => 'ok',
        onError: (error, stackTrace) => InfrastructureFailure(
          message: 'Async failure',
          cause: error,
          stackTrace: stackTrace,
        ),
      );

      // Assert
      expect(result, isA<SuccessResult<String, InfrastructureFailure>>());
      expect(
        (result as SuccessResult<String, InfrastructureFailure>).value,
        'ok',
      );
    });

    test('guardAsync converts errors into failures', () async {
      // Act
      final result = await Result.guardAsync<void, InfrastructureFailure>(
        body: () async {
          throw ArgumentError('invalid');
        },
        onError: (error, stackTrace) => InfrastructureFailure(
          message: 'Async failure',
          cause: error,
          stackTrace: stackTrace,
        ),
      );

      // Assert
      expect(result, isA<FailureResult<void, InfrastructureFailure>>());
      final failure =
          (result as FailureResult<void, InfrastructureFailure>).failure;
      expect(failure.message, 'Async failure');
      expect(failure.cause, isA<ArgumentError>());
      expect(failure.stackTrace, isNotNull);
    });
  });
}
