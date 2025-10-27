import 'dart:async';
import 'dart:io';

import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Keys exposed for widget tests interacting with the quick add sheet.
abstract final class CaptureQuickAddSheetKeys {
  /// Key used to locate the capture content text field.
  static const Key contentField = Key('captureQuickAdd_contentField');

  /// Key used to locate the submit button.
  static const Key submitButton = Key('captureQuickAdd_submitButton');

  /// Key used to locate the voice capture button.
  static const Key voiceCaptureButton = Key(
    'captureQuickAdd_voiceCaptureButton',
  );
}

/// Intent for submitting the capture form via keyboard shortcut.
class SubmitCaptureIntent extends Intent {
  /// Creates a submit capture intent.
  const SubmitCaptureIntent();
}

/// Intent for clearing the capture form via keyboard shortcut.
class ClearCaptureIntent extends Intent {
  /// Creates a clear capture intent.
  const ClearCaptureIntent();
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
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isSpeechAvailable = false;
  bool _isLinux = false;

  @override
  void initState() {
    super.initState();
    _isLinux = Platform.isLinux;
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      if (_isLinux) {
        // Linux speech recognition not available - gracefully disable
        _isSpeechAvailable = false;
        debugPrint('Speech recognition not available on Linux');
      } else {
        _isSpeechAvailable = await _speechToText.initialize(
          onError: (error) {
            debugPrint('Speech recognition initialization error: $error');
            setState(() => _isSpeechAvailable = false);
          },
          onStatus: (status) {
            debugPrint('Speech recognition status: $status');
          },
        );
      }
      setState(() {});
    } catch (e) {
      debugPrint('Speech recognition initialization failed: $e');
      _isSpeechAvailable = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CaptureQuickEntryState>(captureQuickEntryControllerProvider, (
      previous,
      next,
    ) {
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
              ..showSnackBar(SnackBar(content: Text(failure.message)));
          }
          return;
        case CaptureQuickEntryStatus.idle:
        case CaptureQuickEntryStatus.submitting:
          break;
      }
    });

    final entryState = ref.watch(captureQuickEntryControllerProvider);
    final isSubmitting =
        entryState.status == CaptureQuickEntryStatus.submitting;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.enter):
            const SubmitCaptureIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const ClearCaptureIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SubmitCaptureIntent: CallbackAction<SubmitCaptureIntent>(
            onInvoke: (intent) => _submit(),
          ),
          ClearCaptureIntent: CallbackAction<ClearCaptureIntent>(
            onInvoke: (intent) => _clear(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Padding(
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
                    Row(
                      children: <Widget>[
                        IconButton(
                          key: CaptureQuickAddSheetKeys.voiceCaptureButton,
                          onPressed: (_isListening || !_isSpeechAvailable)
                              ? null
                              : _startListening,
                          icon: Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            color: _isSpeechAvailable
                                ? null
                                : Colors.grey.withValues(alpha: 0.5),
                          ),
                          tooltip: _isSpeechAvailable
                              ? 'Voice capture'
                              : 'Voice capture not available on this platform',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            key: CaptureQuickAddSheetKeys.submitButton,
                            onPressed: isSubmitDisabled ? null : _submit,
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Add'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
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
        .submit(request: CaptureQuickEntryRequest(rawContent: rawContent));
  }

  void _clear() {
    _contentController.clear();
  }

  Future<void> _startListening() async {
    if (!_isSpeechAvailable) {
      // Show a snackbar to inform the user that speech recognition is not available
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Speech recognition is not available on this platform',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    if (_isLinux) {
      // Linux speech recognition not available - show message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition is not available on Linux'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else if (_speechToText.isAvailable) {
      setState(() => _isListening = true);
      await _speechToText.listen(
        onResult: (result) {
          final recognizedWords = result.recognizedWords;
          if (recognizedWords.isNotEmpty) {
            final currentText = _contentController.text;
            final newText = currentText.isEmpty
                ? recognizedWords
                : '$currentText $recognizedWords';
            _contentController.text = newText;
          }
        },
      );
      setState(() => _isListening = false);
    }
  }

}
