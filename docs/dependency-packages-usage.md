# Dependency Usage Notes

Quick-start snippets for each selected package. All code targets Dart 3.9 and Flutter 3.24+.

## `fpdart`
Models fallible async flows with `TaskEither`.

```dart
import 'package:fpdart/fpdart.dart';

typedef Failure = String; // replace with your domain Failure type

typedef SaveCaptureItem = TaskEither<Failure, void>;

SaveCaptureItem saveCaptureItem(CaptureItem item) => TaskEither.tryCatch(
      () async => repository.save(item),
      (error, stackTrace) => Failure('$error'),
    );
```

## `hive_ce` & `hive_ce_flutter`
Initialise Hive with encrypted boxes. Pair with `flutter_secure_storage` and `path_provider`.

```dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> bootstrapHive() async {
  await Hive.initFlutter();

  final secureStorage = const FlutterSecureStorage();
  final storedKey = await secureStorage.read(key: 'capture_box_key');
  final keyBytes = storedKey != null
      ? base64Decode(storedKey)
      : Hive.generateSecureKey();

  if (storedKey == null) {
    await secureStorage.write(
      key: 'capture_box_key',
      value: base64Encode(keyBytes),
    );
  }

  Hive.registerAdapter(CaptureItemAdapter());
  await Hive.openBox<CaptureItem>(
    'capture_items',
    encryptionCipher: HiveAesCipher(keyBytes),
  );
}
```

`CaptureItemAdapter` is the generated `TypeAdapter` for the feature slice.

## `path_provider`
Use when Hive boxes need a deterministic filesystem root outside Flutter bindings (e.g., background isolates).

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Directory> hiveRoot() async {
  final dir = await getApplicationSupportDirectory();
  return Directory('${dir.path}/cascade_flow');
}
```

## `flutter_secure_storage`
Store secrets such as Hive AES keys.

```dart
const secureStorage = FlutterSecureStorage();

Future<void> cacheToken(String token) =>
    secureStorage.write(key: 'api_token', value: token);
```

## `logger`
Lightweight structured logging for infrastructure and feature layers.

```dart
import 'package:logger/logger.dart';

final logger = Logger(
  printer: PrettyPrinter(methodCount: 0, colors: false),
);

void logDbWarmup(DateTime startedAt) {
  logger.i('Hive ready in ${DateTime.now().difference(startedAt).inMilliseconds} ms');
}
```

## Riverpod stack (`riverpod`, `flutter_riverpod`, `riverpod_annotation`)
Generate strongly-typed providers and expose them to Flutter.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'capture_controller.g.dart';

@riverpod
CaptureController captureController(CaptureControllerRef ref) {
  final repo = ref.watch(captureRepositoryProvider);
  return CaptureController(repo);
}

class CaptureScope extends ConsumerWidget {
  const CaptureScope({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(captureControllerProvider);
    return CaptureScreen(controller: controller);
  }
}
```

Run `dart run build_runner watch --delete-conflicting-outputs` in the feature package to keep generated files in sync.

## `go_router`
Compose navigation with `StatefulShellRoute` to preserve tab stacks.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => ShellScaffold(shell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/ingest', builder: (c, s) => const IngestScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/focus', builder: (c, s) => const FocusScreen())],
        ),
      ],
    ),
  ],
);
```

## `intl`
Locale-aware formatting for reviews and schedules.

```dart
import 'package:intl/intl.dart';

final reviewDateLabel = DateFormat.yMMMMEEEEd().format(DateTime.now());
```

## `flex_color_scheme`
Apply Material 3 themes with consistent surface blends.

```dart
import 'package:flex_color_scheme/flex_color_scheme.dart';

final lightTheme = FlexThemeData.light(
  scheme: FlexScheme.mandyRed,
  useMaterial3: true,
);

final darkTheme = FlexThemeData.dark(
  scheme: FlexScheme.mandyRed,
  useMaterial3: true,
);
```

## `flutter_local_notifications`
Schedule focus session reminders.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notifications = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await notifications.initialize(settings);
}

Future<void> scheduleFocusStart(TimeOfDay time) async {
  await notifications.zonedSchedule(
    1,
    'Focus block',
    'Time to start your planned focus session',
    _nextInstanceOf(time),
    const NotificationDetails(
      android: AndroidNotificationDetails('focus', 'Focus Blocks'),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
```

`_nextInstanceOf` should convert the requested `TimeOfDay` into a `tz.TZDateTime` in the user’s locale; add the `timezone` package if wall-clock accuracy is required.

These snippets assume the corresponding adapters, providers, and routing shells are defined inside their feature packages per the architecture guide.
