import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keys exposed for widget tests interacting with the quick add sheet.
abstract final class CaptureQuickAddSheetKeys {
  /// Key used to locate the capture content text field.
  static const Key contentField = Key('captureQuickAdd_contentField');

  /// Key used to locate the submit button.
  static const Key submitButton = Key('captureQuickAdd_submitButton');
}

/// Quick-add surface for capturing inbox entries.
class CaptureQuickAddSheet extends ConsumerStatefulWidget {
  /// Creates the quick-add sheet.
  const CaptureQuickAddSheet({super.key});

  @override
  ConsumerState<CaptureQuickAddSheet> createState() =>
      _CaptureQuickAddSheetState();
}

class _CaptureQuickAddSheetState extends ConsumerState<CaptureQuickAddSheet> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CaptureQuickEntryState>(
      captureQuickEntryControllerProvider,
      (previous, next) {
        if (!mounted) return;
        switch (next.status) {
          case CaptureQuickEntryStatus.success:
            _contentController.clear();
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            final focusScope = FocusScope.of(context);
            if (focusScope.hasPrimaryFocus) {
              focusScope.unfocus();
            }
            return;
          case CaptureQuickEntryStatus.error:
            final failure = next.failure;
            if (failure != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(failure.message)),
                );
            }
            return;
          case CaptureQuickEntryStatus.idle:
          case CaptureQuickEntryStatus.submitting:
            break;
        }
      },
    );

    final entryState = ref.watch(captureQuickEntryControllerProvider);
    final isSubmitting =
        entryState.status == CaptureQuickEntryStatus.submitting;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _contentController,
        builder: (context, value, _) {
          final isInputEmpty = value.text.trim().isEmpty;
          final isSubmitDisabled = isSubmitting || isInputEmpty;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                key: CaptureQuickAddSheetKeys.contentField,
                controller: _contentController,
                textInputAction: TextInputAction.done,
                enabled: !isSubmitting,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Quick capture',
                  hintText: 'What needs attention?',
                ),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: CaptureQuickAddSheetKeys.submitButton,
                onPressed: isSubmitDisabled ? null : _submit,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final rawContent = _contentController.text.trim();
    if (rawContent.isEmpty) {
      return;
    }

    await ref
        .read(captureQuickEntryControllerProvider.notifier)
        .submit(
          request: CaptureQuickEntryRequest(rawContent: rawContent),
        );
  }
}
