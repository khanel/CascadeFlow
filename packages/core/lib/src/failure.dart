/// Base exception type used across CascadeFlow domain layers.
sealed class Failure implements Exception {
  const Failure({required this.message, this.cause, this.stackTrace});

  /// Human-readable summary of the failure.
  final String message;

  /// Optional underlying cause that triggered the failure.
  final Object? cause;

  /// Optional stack trace captured when the failure occurred.
  final StackTrace? stackTrace;

  @override
  String toString() {
    final causeDescription = cause != null ? ', cause: $cause' : '';
    final typeName = switch (this) {
      ValidationFailure _ => 'ValidationFailure',
      DomainFailure _ => 'DomainFailure',
      InfrastructureFailure _ => 'InfrastructureFailure',
    };
    return '$typeName(message: $message$causeDescription)';
  }
}

/// Failure triggered by invalid user or system input.
class ValidationFailure extends Failure {
  /// Creates a failure for invalid user/system input.
  const ValidationFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Failure representing broken invariants or domain rules.
class DomainFailure extends Failure {
  /// Creates a failure representing a broken domain invariant.
  const DomainFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Failure thrown when infrastructure pieces (storage, network, etc.) go wrong.
class InfrastructureFailure extends Failure {
  /// Creates a failure for infrastructure or platform errors.
  const InfrastructureFailure({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}
