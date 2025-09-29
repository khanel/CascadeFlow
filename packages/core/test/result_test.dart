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
  });
}
