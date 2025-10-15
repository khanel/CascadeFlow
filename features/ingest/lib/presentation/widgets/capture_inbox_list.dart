import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
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
    final pagination = ref.watch(captureInboxPaginationControllerProvider);

    return pagination.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          key: CaptureInboxListKeys.loadingIndicator,
        ),
      ),
      error: (error, stackTrace) => _CaptureInboxError(error: error),
      data: (state) => state.isEmpty
          ? const _CaptureInboxEmptyState()
          : _CaptureInboxListView(state: state),
    );
  }
}

class _CaptureInboxListView extends ConsumerWidget {
  const _CaptureInboxListView({required this.state});

  final CaptureInboxPaginationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(
      captureInboxPaginationControllerProvider.notifier,
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_shouldRequestNext(notification)) {
          unawaited(controller.loadNextPage());
        }
        return false;
      },
      child: ListView.separated(
        key: CaptureInboxListKeys.listView,
        physics: const ClampingScrollPhysics(),
        itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const _CaptureInboxLoadingMore();
          }
          final item = state.items[index];
          return Dismissible(
            key: Key('captureInbox_dismiss_${item.id.value}'),
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
      ),
    );
  }

  bool _shouldRequestNext(ScrollNotification notification) {
    if (!state.hasMore || state.isLoadingMore) {
      return false;
    }
    return notification.metrics.extentAfter < 200;
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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

class _CaptureInboxLoadingMore extends StatelessWidget {
  const _CaptureInboxLoadingMore();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator.adaptive(),
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
  final actions = _CaptureInboxActions(
    context: context,
    ref: ref,
  );

  return switch (direction) {
    DismissDirection.startToEnd => actions.archive(item),
    DismissDirection.endToStart => actions.confirmDelete(item),
    DismissDirection.horizontal ||
    DismissDirection.vertical ||
    DismissDirection.up ||
    DismissDirection.down ||
    DismissDirection.none => false,
  };
}

class _CaptureInboxActions {
  _CaptureInboxActions({
    required this.context,
    required WidgetRef ref,
  }) : _archiveUseCase = ref.read(archiveCaptureItemUseCaseProvider),
       _repository = ref.read(captureRepositoryProvider),
       _container = ref.container;

  final BuildContext context;
  final ArchiveCaptureItem _archiveUseCase;
  final CaptureRepository _repository;
  final ProviderContainer _container;

  ScaffoldMessengerState get _messenger => ScaffoldMessenger.of(context);

  Future<bool> archive(CaptureItem item) async {
    final result = _archiveUseCase(
      request: ArchiveCaptureItemRequest(item: item),
    );

    switch (result) {
      case SuccessResult<CaptureItem, Failure>(value: final archived):
        await _repository.save(archived);
        _refreshInbox();
        _showMessage(
          'Capture "${item.content}" archived',
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => unawaited(_undoArchive(item)),
          ),
        );
        return true;
      case FailureResult<CaptureItem, Failure>(failure: final failure):
        _showMessage('Failed to archive capture: ${failure.message}');
        return false;
    }
  }

  Future<bool> confirmDelete(CaptureItem item) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete capture?'),
            content: Text(
              'Deleting "${item.content}" cannot be undone.',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return false;
    }

    try {
      await _repository.delete(item.id);
      _refreshInbox();
      return true;
    } on Object catch (error) {
      _showMessage('Delete failed: $error');
      return false;
    }
  }

  void _showMessage(
    String message, {
    SnackBarAction? action,
  }) {
    _messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
        ),
      );
  }

  void _refreshInbox() {
    _container
      ..invalidate(captureInboxItemsProvider)
      ..invalidate(captureInboxPaginationControllerProvider);
  }

  Future<void> _undoArchive(CaptureItem item) async {
    await _repository.save(item);
    _refreshInbox();
  }
}
