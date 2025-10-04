import 'dart:math';

import 'package:cascade_flow_core/src/failure.dart';
import 'package:meta/meta.dart';

/// Strongly typed wrapper for entity identifiers.
@immutable
class EntityId {
  /// Creates an identifier from a raw [value], validating its structure.
  EntityId(String value) : value = _validate(value);

  /// Generates a random identifier using cryptographically secure randomness.
  factory EntityId.generate() => EntityId._(_generate());

  EntityId._(this.value);

  static const int _defaultLength = 24;
  static const String _charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _secureRandom = Random.secure();
  static final RegExp _validationPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

  /// Raw identifier string.
  final String value;

  /// Ensures the identifier is not empty and contains safe characters.
  static String _validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw const ValidationFailure(message: 'EntityId cannot be empty');
    }
    if (!_validationPattern.hasMatch(trimmed)) {
      throw ValidationFailure(
        message: 'EntityId contains unsupported characters: $value',
      );
    }
    return trimmed;
  }

  /// Generates a pseudo-random identifier string.
  static String _generate() {
    final buffer = StringBuffer();
    for (var i = 0; i < _defaultLength; i++) {
      final index = _secureRandom.nextInt(_charset.length);
      buffer.write(_charset[index]);
    }
    return buffer.toString();
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EntityId && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
