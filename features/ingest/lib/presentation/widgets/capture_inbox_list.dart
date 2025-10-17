import 'dart:async';
import 'dart:collection';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/archive_capture_item.dart';
import 'package:cascade_flow_ingest/domain/use_cases/file_capture_item.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_filter.dart';
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

  /// Key applied to the filtered empty state placeholder.
  static const Key filteredEmptyState = Key('captureInbox_filteredEmpty');

  /// Generates a key for a specific inbox list tile.
  static Key itemTile(String id) => Key('captureInbox_item_$id');
}

/// Keys referenced by widget tests interacting with the filter bar.
abstract final class CaptureInboxFilterBarKeys {
  /// Key applied to the filter presets button.
  static const Key presetsButton = Key('captureInbox_presetsButton');
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
    final filter = ref.watch(captureInboxFilterProvider);
    final filteredItems = filter.apply(state.items).toList(growable: false);
    final channelOptions = _buildChannelOptions(state.items, filter);
    final filterBar = _CaptureInboxFilterBar(
      filter: filter,
      channelOptions: channelOptions,
    );

    final body = filteredItems.isEmpty
        ? (filter.isFiltering
              ? const _CaptureInboxFilteredEmptyState()
              : const _CaptureInboxEmptyState())
        : _CaptureInboxListContent(
            items: filteredItems,
            paginationState: state,
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        filterBar,
        const SizedBox(height: 12),
        Expanded(child: body),
      ],
    );
  }

  List<_CaptureInboxChannelOption> _buildChannelOptions(
    List<CaptureItem> items,
    CaptureInboxFilter filter,
  ) {
    final channels = SplayTreeSet<String>();
    for (final item in items) {
      channels.add(item.context.channel);
    }
    final selectedChannel = filter.channel;
    if (selectedChannel != null && selectedChannel.isNotEmpty) {
      channels.add(selectedChannel);
    }
    return channels
        .map(
          (channel) => _CaptureInboxChannelOption(
            value: channel,
            isSelected: filter.isChannelSelected(channel),
          ),
        )
        .toList(growable: false);
  }
}

class _CaptureInboxListContent extends ConsumerWidget {
  const _CaptureInboxListContent({
    required this.items,
    required this.paginationState,
  });

  final List<CaptureItem> items;
  final CaptureInboxPaginationState paginationState;

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
        itemCount: items.length + (paginationState.isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const _CaptureInboxLoadingMore();
          }
          final item = items[index];
          final actions = _CaptureInboxActions(context: context, ref: ref);
          return Dismissible(
            key: Key('captureInbox_dismiss_${item.id.value}'),
            background: const _ArchiveBackground(),
            secondaryBackground: const _DeleteBackground(),
            confirmDismiss: (direction) => actions.confirmDismiss(
              direction,
              item,
            ),
            child: GestureDetector(
              onLongPress: () => actions.file(item),
              child: ListTile(
                key: CaptureInboxListKeys.itemTile(item.id.value),
                title: Text(item.content),
                subtitle: Text(_subtitleFor(context, item)),
                leading: const Icon(Icons.inbox),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _shouldRequestNext(ScrollNotification notification) {
    if (!paginationState.hasMore || paginationState.isLoadingMore) {
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

class _CaptureInboxFilterBar extends ConsumerWidget {
  const _CaptureInboxFilterBar({
    required this.filter,
    required this.channelOptions,
  });

  final CaptureInboxFilter filter;
  final List<_CaptureInboxChannelOption> channelOptions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(captureInboxFilterProvider.notifier);
    final presetsAsync = ref.watch(captureFilterPresetProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            ChoiceChip(
              label: const Text('All sources'),
              selected: filter.source == null,
              onSelected: (_) => notifier.setSource(null),
            ),
            for (final source in CaptureSource.values)
              ChoiceChip(
                label: Text(_sourceLabel(source)),
                selected: filter.isSourceSelected(source),
                onSelected: (selected) =>
                    notifier.setSource(selected ? source : null),
              ),
            PopupMenuButton<CaptureFilterPreset>(
              key: CaptureInboxFilterBarKeys.presetsButton,
              onSelected: (preset) => _applyPreset(preset, ref, notifier),
              itemBuilder: (context) => _buildPresetMenuItems(presetsAsync),
              child: TextButton.icon(
                label: const Text('Presets'),
                icon: const Icon(Icons.arrow_drop_down),
                onPressed: null,
              ),
            ),
          ],
        ),
        if (channelOptions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ChoiceChip(
                label: const Text('All channels'),
                selected: filter.channel == null,
                onSelected: (_) => notifier.setChannel(null),
              ),
              for (final option in channelOptions)
                ChoiceChip(
                  label: Text(option.value),
                  selected: option.isSelected,
                  onSelected: (selected) =>
                      notifier.setChannel(selected ? option.value : null),
                ),
            ],
          ),
        ],
      ],
    );
  }

  void _applyPreset(
    CaptureFilterPreset preset,
    WidgetRef ref,
    CaptureInboxFilterController notifier,
  ) {
    notifier.applyFilter(preset.filter);
  }

  List<PopupMenuEntry<CaptureFilterPreset>> _buildPresetMenuItems(
    AsyncValue<List<CaptureFilterPreset>> presetsAsync,
  ) {
    return presetsAsync.maybeWhen(
      data: (presets) => presets
          .map(
            (preset) => PopupMenuItem(
              value: preset,
              child: Text(preset.name),
            ),
          )
          .toList(),
      orElse: () => [],
    );
  }
}

class _CaptureInboxChannelOption {
  const _CaptureInboxChannelOption({
    required this.value,
    required this.isSelected,
  });

  final String value;
  final bool isSelected;
}

String _sourceLabel(CaptureSource source) {
  switch (source) {
    case CaptureSource.quickCapture:
      return 'Quick capture';
    case CaptureSource.automation:
      return 'Automation';
    case CaptureSource.voice:
      return 'Voice';
    case CaptureSource.shareSheet:
      return 'Share sheet';
    case CaptureSource.import:
      return 'Import';
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

class _CaptureInboxFilteredEmptyState extends StatelessWidget {
  const _CaptureInboxFilteredEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: CaptureInboxListKeys.filteredEmptyState,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.filter_alt_off, size: 40),
          SizedBox(height: 12),
          Text('No captures match the current filters.'),
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

class _CaptureInboxActions {
  _CaptureInboxActions({
    required this.context,
    required WidgetRef ref,
  }) : _archiveUseCase = ref.read(archiveCaptureItemUseCaseProvider),
       _fileUseCase = ref.read(fileCaptureItemUseCaseProvider),
       _repository = ref.read(captureRepositoryProvider),
       _container = ref.container;

  final BuildContext context;
  final ArchiveCaptureItem _archiveUseCase;
  final FileCaptureItem _fileUseCase;
  final CaptureRepository _repository;
  final ProviderContainer _container;

  ScaffoldMessengerState get _messenger => ScaffoldMessenger.of(context);

  Future<void> file(CaptureItem item) async {
    final filed =
        await showDialog<bool>(
          context: context,
          builder: (context) => SimpleDialog(
            title: Text(item.content),
            children: [
              SimpleDialogOption(
                child: const Text('File'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;

    if (!filed) {
      return;
    }

    final result = _fileUseCase(
      request: FileCaptureItemRequest(item: item),
    );

    switch (result) {
      case SuccessResult<CaptureItem, Failure>(value: final filed):
        await saveAndRefresh(filed, 'filed');
      case FailureResult<CaptureItem, Failure>(failure: final failure):
        showMessage('Failed to file capture: ${failure.message}');
    }
  }

  Future<bool> confirmDismiss(
    DismissDirection direction,
    CaptureItem item,
  ) {
    return switch (direction) {
      DismissDirection.startToEnd => archive(item),
      DismissDirection.endToStart => confirmDelete(item),
      DismissDirection.horizontal ||
      DismissDirection.vertical ||
      DismissDirection.up ||
      DismissDirection.down ||
      DismissDirection.none => Future.value(false),
    };
  }

  Future<bool> archive(CaptureItem item) async {
    final result = _archiveUseCase(
      request: ArchiveCaptureItemRequest(item: item),
    );

    switch (result) {
      case SuccessResult<CaptureItem, Failure>(value: final archived):
        await _repository.save(archived);
        _refreshInbox();
        showMessage(
          'Capture "${item.content}" archived',
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => unawaited(_undoArchive(item)),
          ),
        );
        return true;
      case FailureResult<CaptureItem, Failure>(failure: final failure):
        showMessage('Failed to archive capture: ${failure.message}');
        return false;
    }
  }

  Future<void> saveAndRefresh(CaptureItem item, String action) async {
    await _repository.save(item);
    _refreshInbox();
    showMessage('Capture "${item.content}" $action');
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
      showMessage('Delete failed: $error');
      return false;
    }
  }

  void showMessage(
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
