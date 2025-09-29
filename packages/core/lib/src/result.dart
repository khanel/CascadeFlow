import 'failure.dart';

/// Represents the outcome of a computation that can succeed or fail.
sealed class Result<T, F extends Failure> {
  const Result();

  /// Returns `true` when the result contains a value.
  bool get isSuccess => this is SuccessResult<T, F>;

  /// Returns `true` when the result contains a failure.
  bool get isFailure => this is FailureResult<T, F>;

  /// Maps the result to a new value depending on its state.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    final self = this;
    if (self is SuccessResult<T, F>) {
      return onSuccess(self.value);
    }
    final failed = self as FailureResult<T, F>;
    return onFailure(failed.failure);
  }

  /// Applies a transformation to the successful value while preserving failures.
  Result<R, F> map<R>(R Function(T value) transform) {
    final self = this;
    if (self is SuccessResult<T, F>) {
      return SuccessResult<R, F>(transform(self.value));
    }
    final failed = self as FailureResult<T, F>;
    return FailureResult<R, F>(failed.failure);
  }

  /// Applies a transformation that returns another [Result].
  Result<R, F> flatMap<R>(Result<R, F> Function(T value) transform) {
    final self = this;
    if (self is SuccessResult<T, F>) {
      return transform(self.value);
    }
    final failed = self as FailureResult<T, F>;
    return FailureResult<R, F>(failed.failure);
  }

  /// Helper to convert a nullable value into a [Result].
  static Result<T, Failure> fromNullable<T>(
    T? value,
    Failure Function() onNull,
  ) {
    if (value == null) {
      return FailureResult<T, Failure>(onNull());
    }
    return SuccessResult<T, Failure>(value);
  }
}

/// Successful branch containing a value of type [T].
class SuccessResult<T, F extends Failure> extends Result<T, F> {
  const SuccessResult(this.value);

  final T value;
}

/// Failed branch containing a [Failure].
class FailureResult<T, F extends Failure> extends Result<T, F> {
  const FailureResult(this.failure);

  final F failure;
}
