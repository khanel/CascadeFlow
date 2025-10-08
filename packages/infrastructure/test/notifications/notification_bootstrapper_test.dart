import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  test(
    'notification bootstrapper requests permissions, registers channels, '
    'and configures background handlers in order',
    () async {
      // ARRANGE
      final callOrder = <String>[];
      Future<void> permissions() async => callOrder.add('permissions');
      Future<void> channels() async => callOrder.add('channels');
      Future<void> background() async => callOrder.add('background');

      final container = ProviderContainer(
        overrides: [
          notificationPermissionInitializerProvider.overrideWithValue(
            permissions,
          ),
          notificationChannelInitializerProvider.overrideWithValue(channels),
          notificationBackgroundInitializerProvider.overrideWithValue(
            background,
          ),
        ],
      );

      // ACT
      final bootstrapper = container.read(notificationBootstrapperProvider);
      await bootstrapper();

      // ASSERT
      expect(callOrder, ['permissions', 'channels', 'background']);

      container.dispose();
    },
  );
}
