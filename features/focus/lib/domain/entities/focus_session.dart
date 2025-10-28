import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:clock/clock.dart';
import 'package:meta/meta.dart';

/// Status of a focus session
enum FocusSessionStatus {
  /// Session is scheduled but not yet started
  scheduled,

  /// Session is currently active and running
  active,

  /// Session is paused
  paused,

  /// Session has been completed
  completed,

  /// Session was cancelled before completion
  cancelled,
}

/// Represents a time-blocked focus session for deep work
@immutable
class FocusSession {
  /// Creates a focus session with the given parameters
  const FocusSession({
    required this.id,
    required this.title,
    this.durationMinutes = 90,
    this.status = FocusSessionStatus.scheduled,
    this.startedAt,
    this.pausedAt,
    this.completedAt,
    this.cancelledAt,
    int? totalPausedMinutes,
  }) : totalPausedMinutes = totalPausedMinutes ?? 0,
       assert(durationMinutes > 0, 'Duration must be positive');

  /// Unique identifier for the session
  final EntityId id;

  /// Title/description of the focus session
  final String title;

  /// Total duration of the session in minutes (default: 90 minutes)
  final int durationMinutes;

  /// Current status of the session
  final FocusSessionStatus status;

  /// When the session was started
  final DateTime? startedAt;

  /// When the session was last paused
  final DateTime? pausedAt;

  /// When the session was completed
  final DateTime? completedAt;

  /// When the session was cancelled
  final DateTime? cancelledAt;

  /// Total minutes the session has been paused
  final int totalPausedMinutes;

  /// Starts the focus session
  FocusSession start() {
    _validateState('start', [FocusSessionStatus.scheduled]);
    return copyWith(
      status: FocusSessionStatus.active,
      startedAt: clock.now(),
    );
  }

  /// Pauses the active session
  FocusSession pause() {
    _validateState('pause', [FocusSessionStatus.active]);
    return copyWith(
      status: FocusSessionStatus.paused,
      pausedAt: clock.now(),
    );
  }

  /// Resumes a paused session
  FocusSession resume() {
    _validateState('resume', [FocusSessionStatus.paused]);
    final pausedDuration = clock.now().difference(pausedAt!);
    return copyWith(
      status: FocusSessionStatus.active,
      totalPausedMinutes: totalPausedMinutes + pausedDuration.inMinutes,
    );
  }

  /// Completes the session
  FocusSession complete() {
    _validateState('complete', [FocusSessionStatus.active]);
    return copyWith(
      status: FocusSessionStatus.completed,
      completedAt: clock.now(),
    );
  }

  /// Cancels the session
  FocusSession cancel() {
    _validateState('cancel', [
      FocusSessionStatus.scheduled,
      FocusSessionStatus.active,
      FocusSessionStatus.paused,
    ]);
    return copyWith(
      status: FocusSessionStatus.cancelled,
      cancelledAt: clock.now(),
    );
  }

  /// Calculates remaining minutes based on current status and elapsed time
  int get remainingMinutes {
    switch (status) {
      case FocusSessionStatus.scheduled:
        return durationMinutes;
      case FocusSessionStatus.active:
        if (startedAt == null) return durationMinutes;
        final elapsed = clock.now().difference(startedAt!);
        final elapsedMinutes = elapsed.inMinutes - totalPausedMinutes;
        return (durationMinutes - elapsedMinutes).clamp(0, durationMinutes);
      case FocusSessionStatus.paused:
        if (startedAt == null) return durationMinutes;
        // When paused, calculate based on time when paused occurred
        final elapsed = pausedAt!.difference(startedAt!);
        final elapsedMinutes = elapsed.inMinutes - totalPausedMinutes;
        return (durationMinutes - elapsedMinutes).clamp(0, durationMinutes);
      case FocusSessionStatus.completed:
      case FocusSessionStatus.cancelled:
        return 0;
    }
  }

  /// Creates a copy with modified fields
  FocusSession copyWith({
    EntityId? id,
    String? title,
    int? durationMinutes,
    FocusSessionStatus? status,
    DateTime? startedAt,
    DateTime? pausedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    int? totalPausedMinutes,
  }) {
    return FocusSession(
      id: id ?? this.id,
      title: title ?? this.title,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      pausedAt: pausedAt ?? this.pausedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      totalPausedMinutes: totalPausedMinutes ?? this.totalPausedMinutes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FocusSession &&
        other.id == id &&
        other.title == title &&
        other.durationMinutes == durationMinutes &&
        other.status == status &&
        other.startedAt == startedAt &&
        other.pausedAt == pausedAt &&
        other.completedAt == completedAt &&
        other.cancelledAt == cancelledAt &&
        other.totalPausedMinutes == totalPausedMinutes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      durationMinutes,
      status,
      startedAt,
      pausedAt,
      completedAt,
      cancelledAt,
      totalPausedMinutes,
    );
  }

  @override
  String toString() {
    return 'FocusSession(id: $id, title: $title, '
        'duration: ${durationMinutes}min, status: $status)';
  }

  void _validateState(String action, List<FocusSessionStatus> expectedStates) {
    if (!expectedStates.contains(status)) {
      throw StateError(
        'Cannot $action a session with status $status. '
        'Expected one of: $expectedStates',
      );
    }
  }
}
