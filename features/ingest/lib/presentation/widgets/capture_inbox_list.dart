import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/use_cases/archive_capture_item.dart';
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

class _CaptureInboxListView extends ConsumerWidget {
  const _CaptureInboxListView({required this.items});

  final List<CaptureItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      key: CaptureInboxListKeys.listView,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 0),
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: Key('captureInbox_dismiss_${item.id.value}'),
          direction: DismissDirection.horizontal,
          background: const _ArchiveBackground(),
          secondaryBackground: const _DeleteBackground(),
          confirmDismiss: (direction) => _handleDismiss(
            context,
            ref,
            direction,
            item,
          ),
          child: ListTile(
            key: CaptureInboxListKeys.itemTile(item.id.value),
            title: Text(item.content),
            subtitle: Text(_subtitleFor(context, item)),
            leading: const Icon(Icons.inbox),
          ),
        );
      },
    );
  }

  String _subtitleFor(BuildContext context, CaptureItem item) {
    final createdAt = item.createdAt.value.toLocal();
    final formattedTime = TimeOfDay.fromDateTime(createdAt).format(context);
    return '${item.context.channel} · $formattedTime';
  }
}

class _ArchiveBackground extends StatelessWidget {
  const _ArchiveBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondaryContainer,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Icon(Icons.archive),
          SizedBox(width: 12),
          Text('Archive'),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.errorContainer,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const <Widget>[
          Text('Delete'),
          SizedBox(width: 12),
          Icon(Icons.delete),
        ],
      ),
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

Future<bool?> _handleDismiss(
  BuildContext context,
  WidgetRef ref,
  DismissDirection direction,
  CaptureItem item,
) async {
  switch (direction) {
    case DismissDirection.startToEnd:
      return _archiveItem(context, ref, item);
    case DismissDirection.endToStart:
      return _confirmDelete(context, ref, item);
    default:
      return false;
  }
}

Future<bool> _archiveItem(
  BuildContext context,
  WidgetRef ref,
  CaptureItem item,
) async {
  final archiveUseCase = ref.read(archiveCaptureItemUseCaseProvider);
  final repository = ref.read(captureRepositoryProvider);
  final container = ref.container;
  final messenger = ScaffoldMessenger.of(context);

  final result = archiveUseCase(
    request: ArchiveCaptureItemRequest(item: item),
  );

  switch (result) {
    case SuccessResult<CaptureItem, Failure>(value: final archived):
      await repository.save(archived);
      container.invalidate(captureInboxItemsProvider);

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Capture "${item.content}" archived'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                unawaited(() async {
                  await repository.save(item);
                  container.invalidate(captureInboxItemsProvider);
                }());
              },
            ),
          ),
        );
      return true;
    case FailureResult<CaptureItem, Failure>(failure: final failure):
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Failed to archive capture: ${failure.message}',
            ),
          ),
        );
      return false;
  }
}

Future<bool> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  CaptureItem item,
) async {
  final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete capture?'),
          content: Text(
            'Deleting "${item.content}" cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ) ??
      false;

  if (!confirmed) {
    return false;
  }

  final repository = ref.read(captureRepositoryProvider);
  final container = ref.container;
  final messenger = ScaffoldMessenger.of(context);

  try {
    await repository.delete(item.id);
    container.invalidate(captureInboxItemsProvider);
    return true;
  } on Object catch (error) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Delete failed: $error'),
        ),
      );
    return false;
  }
}
