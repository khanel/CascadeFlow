import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keys referenced by widget tests interacting with the inbox list.
abstract final class CaptureInboxListKeys {
  /// Key applied to the loading indicator.
  static const Key loadingIndicator = Key('captureInbox_loading');

  /// Key applied to the empty state placeholder.
  static const Key emptyState = Key('captureInbox_empty');

  /// Key applied to the populated inbox list view.
  static const Key listView = Key('captureInbox_listView');

  /// Generates a key for a specific inbox list tile.
  static Key itemTile(String id) => Key('captureInbox_item_$id');
}

/// Renders the capture inbox entries retrieved from persistence.
class CaptureInboxList extends ConsumerWidget {
  /// Creates an inbox list that reacts to repository updates.
  const CaptureInboxList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(captureInboxItemsProvider);

    return inbox.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          key: CaptureInboxListKeys.loadingIndicator,
        ),
      ),
      error: (error, stackTrace) => _CaptureInboxError(error: error),
      data: (items) => items.isEmpty
          ? const _CaptureInboxEmptyState()
          : _CaptureInboxListView(items: items),
    );
  }
}

class _CaptureInboxListView extends StatelessWidget {
  const _CaptureInboxListView({required this.items});

  final List<CaptureItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      key: CaptureInboxListKeys.listView,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final item = items[index];
        final createdAt = item.createdAt.value.toLocal();
        final subtitle =
            '${item.context.channel} · '
            '${TimeOfDay.fromDateTime(createdAt).format(context)}';

        return ListTile(
          key: CaptureInboxListKeys.itemTile(item.id.value),
          title: Text(item.content),
          subtitle: Text(subtitle),
          leading: const Icon(Icons.inbox),
        );
      },
    );
  }
}

class _CaptureInboxEmptyState extends StatelessWidget {
  const _CaptureInboxEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: CaptureInboxListKeys.emptyState,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.inbox_outlined, size: 40),
          SizedBox(height: 12),
          Text('Your capture inbox is clear. Enjoy the focus!'),
        ],
      ),
    );
  }
}

class _CaptureInboxError extends StatelessWidget {
  const _CaptureInboxError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text('Failed to load inbox: $error'),
        ],
      ),
    );
  }
}
