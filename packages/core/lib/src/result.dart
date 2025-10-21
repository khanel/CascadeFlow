import 'dart:async';

import 'package:cascade_flow_core/src/failure.dart';

/// Represents the outcome of a computation that can succeed or fail.
typedef FailureBuilder<F extends Failure> =
    F Function(
      Object error,
      StackTrace stackTrace,
    );

/// Discriminated union that wraps either a value or a failure.
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
  }) => switch (this) {
    SuccessResult<T, F>(value: final value) => onSuccess(value),
    FailureResult<T, F>(failure: final failure) => onFailure(failure),
  };

  /// Applies a transformation to the successful value while
  /// preserving failures.
  Result<R, F> map<R>(R Function(T value) transform) => switch (this) {
    SuccessResult<T, F>(value: final value) => SuccessResult<R, F>(
      transform(value),
    ),
    FailureResult<T, F>(failure: final failure) => FailureResult<R, F>(failure),
  };

  /// Applies a transformation that returns another [Result].
  Result<R, F> flatMap<R>(Result<R, F> Function(T value) transform) =>
      switch (this) {
        SuccessResult<T, F>(value: final value) => transform(value),
        FailureResult<T, F>(failure: final failure) => FailureResult<R, F>(
          failure,
        ),
      };

  /// Helper to convert a nullable value into a [Result].
  static Result<T, Failure> fromNullable<T>(
    T? value,
    Failure Function() onNull,
  ) => value == null
      ? FailureResult<T, Failure>(onNull())
      : SuccessResult<T, Failure>(value);

  /// Executes [body] and captures any thrown error into a [FailureResult].
  static Result<T, F> guard<T, F extends Failure>({
    required T Function() body,
    required FailureBuilder<F> onError,
  }) {
    try {
      return SuccessResult<T, F>(body());
    } on Object catch (error, stackTrace) {
      return _failure(onError, error, stackTrace);
    }
  }

  /// Executes async [body] and captures any thrown error into a
  /// [FailureResult].
  static Future<Result<T, F>> guardAsync<T, F extends Failure>({
    required FutureOr<T> Function() body,
    required FailureBuilder<F> onError,
  }) async {
    try {
      final value = await Future<T>.sync(body);
      return SuccessResult<T, F>(value);
    } on Object catch (error, stackTrace) {
      return _failure(onError, error, stackTrace);
    }
  }

  static Result<T, F> _failure<T, F extends Failure>(
    FailureBuilder<F> onError,
    Object error,
    StackTrace stackTrace,
  ) {
    return FailureResult<T, F>(onError(error, stackTrace));
  }
}

/// Successful branch containing a value of type [T].
class SuccessResult<T, F extends Failure> extends Result<T, F> {
  /// Creates a result that carries a successful [value].
  const SuccessResult(this.value);

  /// Value produced by the successful computation.
  final T value;
}

/// Failed branch containing a [Failure].
class FailureResult<T, F extends Failure> extends Result<T, F> {
  /// Creates a result that carries a [failure].
  const FailureResult(this.failure);

  /// Failure describing why the computation did not succeed.
  final F failure;
}
