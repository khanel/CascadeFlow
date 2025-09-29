import 'dart:math';

import '../failure.dart';

/// Strongly typed wrapper for entity identifiers.
class EntityId {
  EntityId(String value) : value = _validate(value);

  EntityId._(this.value);

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
    final pattern = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!pattern.hasMatch(trimmed)) {
      throw ValidationFailure(
        message: 'EntityId contains unsupported characters: $value',
      );
    }
    return trimmed;
  }

  static String _generate() {
    const length = 24;
    const charset = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(charset[random.nextInt(charset.length)]);
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
