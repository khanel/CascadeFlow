import 'package:meta/meta.dart';

/// UTC timestamp used in domain primitives and events.
@immutable
class Timestamp implements Comparable<Timestamp> {
  /// Creates a timestamp from a [value], normalising it to UTC.
  Timestamp(DateTime value) : value = _toUtc(value);

  Timestamp._(this.value);

  /// Builds a timestamp from the current instant.
  factory Timestamp.now() => Timestamp._(DateTime.now().toUtc());

  /// Underlying UTC datetime.
  final DateTime value;

  /// Returns `true` if this timestamp occurs before [other].
  bool isBefore(Timestamp other) => value.isBefore(other.value);

  /// Returns `true` if this timestamp occurs after [other].
  bool isAfter(Timestamp other) => value.isAfter(other.value);

  /// Difference between this timestamp and [other].
  Duration difference(Timestamp other) => value.difference(other.value);

  static DateTime _toUtc(DateTime dateTime) =>
      dateTime.isUtc ? dateTime : dateTime.toUtc();

  @override
  int compareTo(Timestamp other) => value.compareTo(other.value);

  @override
  String toString() => value.toIso8601String();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Timestamp && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
