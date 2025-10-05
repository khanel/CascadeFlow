# Notification Facade Design

## Objectives
- Provide a single entrypoint that feature slices can use to schedule, cancel, and manage notifications without depending on platform APIs.
- Support the initial roadmap channels: focus timers, schedule reminders, habit nudges, review prompts, and insights.
- Keep the infrastructure package testable by decoupling orchestration logic from the concrete `flutter_local_notifications` plugin.
- Establish naming, payload, and lifecycle conventions so downstream features can build against predictable contracts.

## Context
A lightweight facade (`NotificationFacade`) and supporting abstractions already exist in `packages/infrastructure/lib/src/notifications/notification_facade.dart`. The next implementation pass must wire that facade to a concrete scheduler, expose Riverpod providers, and document how feature slices should supply IDs and payloads. This outline provides the shape of that work so infrastructure and feature teams can proceed in parallel.

## Architecture Overview
- `NotificationFacade`: Thin orchestration layer offering high-level methods (`schedule`, `cancel`, `clearAll`). It never touches platform APIs directly.
- `NotificationScheduler`: Interface responsible for translating `NotificationRequest` values into platform calls. The default implementation will be `FlutterLocalNotificationsScheduler` backed by `flutter_local_notifications` + `timezone`.
- `NotificationChannel`: Enum describing the logical audience; mapped to platform channels/categories (`focus`, `schedule`, `habits`, `review`, `insights`).
- `NotificationPayload`: Free-form `Map<String, Object?>` stored on `NotificationRequest`. Payload keys are namespaced per channel (e.g., `focus.sessionId`, `schedule.blockId`).
- Riverpod providers:
  - `notificationSchedulerProvider`: Resolves the platform-specific scheduler (stub for tests, plugin-backed for app runtime).
  - `notificationFacadeProvider`: Wraps the scheduler in a singleton facade that features consume.
- Auxiliary helpers (planned):
  - `NotificationIdFactory`: Utility to generate stable, namespaced IDs (e.g., `focus:session:<uuid>`, `habit:nudge:<date>`).
  - `NotificationChannelConfig`: Static configuration describing channel metadata (Android channel ID, iOS category, default importance/sound).

## Scheduler Implementation Plan
1. **Plugin bootstrap**
   - Create `FlutterLocalNotificationsScheduler` implementing `NotificationScheduler`.
   - Hold an instance of `FlutterLocalNotificationsPlugin` and initialize it with channel/category definitions from `NotificationChannelConfig`.
   - Depend on `timezone` to convert the UTC `triggerAt` values from `NotificationRequest` into `TZDateTime` instances.
2. **Channel mapping**
   - Create a lookup that maps `NotificationChannel` → platform channel ID + description.
   - Ensure Android channels are created once during initialization; iOS categories registered during bootstrap.
3. **Scheduling flow**
   - Accept a `NotificationRequest`, resolve the corresponding platform channel configuration, and call `zonedSchedule` (or `show` for immediate notifications).
   - Attach payload as JSON string in `payload` for deep links; supply title/body via request metadata (future extension).
4. **Cancellation**
   - `cancel(notificationId)` invokes `cancel(int.parse(idHash))` or maintains a lookup table translating friendly IDs to plugin integer IDs.
   - `clearAll()` delegates to `cancelAll()` on the plugin.
5. **Error handling**
   - Wrap plugin calls in `Result.guardAsync` helpers already provided in `core` to bubble failures back to callers when needed. The facade itself remains `Future<void>` but infrastructure tests can assert failures through injected schedulers.

## Facade API Surface
Planned methods exposed to features (facade stays generic; helper extensions live in feature packages):

```dart
abstract class NotificationFacade {
  Future<void> schedule(NotificationRequest request);
  Future<void> cancel(String notificationId);
  Future<void> clearAll();
}

extension FocusNotifications on NotificationFacade {
  Future<void> scheduleFocusSession({
    required String sessionId,
    required DateTime startAt,
    required Duration duration,
  }) {
    return schedule(
      NotificationRequest(
        id: NotificationIdFactory.focusSession(sessionId),
        channel: NotificationChannel.focus,
        payload: {
          'focus.sessionId': sessionId,
          'focus.durationMinutes': duration.inMinutes,
        },
        triggerAt: startAt,
      ),
    );
  }
}
```

Feature slices (Ingest, Focus, Habits, etc.) add their own domain-specific helpers so the shared facade stays unopinionated.

## Channel Profiles
- **Focus:** start/break/end timers; payload seeds UI to resume sessions. Requires exact scheduling and support for repeating patterns (Pomodoro loops).
- **Schedule:** reminders tied to calendar blocks; should respect user-selected lead times and allow snooze actions.
- **Habits:** cadence nudges; typically daily/weekly repeating notifications with streak metadata in payload.
- **Review:** weekly/monthly prompts with deep links into review flows.
- **Insights:** event-driven nudges triggered by analytics; payload carries insight identifier to fetch contextual data.

Each channel defines:
- Default importance/priority (Android) and interruption level (iOS).
- Sound/vibration policy (initially default; expose configuration hooks later).
- Payload schema (documented under `docs/features/<slice>/notifications.md` once features adopt it).

## Provider Wiring
- Add provider definitions in `packages/infrastructure/lib/src/providers/providers.dart`:
  - `notificationSchedulerProvider = Provider<NotificationScheduler>((ref) => FlutterLocalNotificationsScheduler(...));`
  - `notificationFacadeProvider = Provider<NotificationFacade>((ref) => NotificationFacade(scheduler: ref.watch(notificationSchedulerProvider)));`
- Update `packages/infrastructure/lib/cascade_flow_infrastructure.dart` to export these providers alongside logging/storage.
- The app bootstrap reads `notificationSchedulerProvider` during initialization to ensure channels are registered before scheduling begins.
- Feature packages depend on `notificationFacadeProvider` for scheduling and cancellation, keeping their tests decoupled by overriding the provider with in-memory stubs.

## Testing Strategy
- **Unit tests:** Provide a `FakeNotificationScheduler` that records `NotificationRequest` instances. Verify IDs, channels, and payload structure for each helper function.
- **Integration tests:** Use `flutter_local_notifications` with the in-memory zone (`timezone`) setup to validate scheduling, cancellation, and payload serialization.
- **Provider overrides:** Riverpod `ProviderContainer` overrides allow features to substitute stub schedulers, ensuring slices can test flows without touching platform channels.
- **Failure modes:** Validate that scheduler exceptions propagate (or are logged) via `Result.guardAsync` wrappers.

## Work Breakdown
1. Create `NotificationChannelConfig` and `NotificationIdFactory` utilities.
2. Implement `FlutterLocalNotificationsScheduler` with initialization, scheduling, cancellation, and clearing logic.
3. Define Riverpod providers and export them from the infrastructure package.
4. Document channel payload schemas as they solidify in each feature slice.
5. Add unit and integration tests covering the scheduler and facade helpers.

Completing these steps will unblock downstream tasks in Milestone 3 and enable Focus/Habits feature work to integrate notifications safely.
