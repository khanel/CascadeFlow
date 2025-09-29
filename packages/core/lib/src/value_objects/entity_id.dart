import 'dart:math';

import '../failure.dart';

/// Strongly typed wrapper for entity identifiers.
class EntityId {
  EntityId(String value) : value = _validate(value);

  EntityId._(this.value);

  static const int _defaultLength = 24;
  static const String _charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
  static final Random _secureRandom = Random.secure();
  static final RegExp _validationPattern = RegExp(r'^[a-zA-Z0-9_-]+$');

  /// Generates a random identifier using cryptographically secure randomness.
  factory EntityId.generate() => EntityId._(_generate());

  /// Raw identifier string.
  final String value;

  /// Ensures the identifier is not empty and contains safe characters.
  static String _validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw ValidationFailure(message: 'EntityId cannot be empty');
    }
    if (!_validationPattern.hasMatch(trimmed)) {
      throw ValidationFailure(
        message: 'EntityId contains unsupported characters: $value',
      );
    }
    return trimmed;
  }

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
