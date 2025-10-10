import 'package:cascade_flow_ingest/presentation/widgets/capture_inbox_list.dart';
import 'package:cascade_flow_ingest/presentation/widgets/capture_quick_add_sheet.dart';
import 'package:flutter/material.dart';

/// Landing page for the Capture pillar combining quick entry and inbox views.
class CaptureHomePage extends StatelessWidget {
  /// Creates a capture home page.
  const CaptureHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture')),
      body: const SafeArea(
        child: _CaptureHomeContent(),
      ),
    );
  }
}

class _CaptureHomeContent extends StatelessWidget {
  const _CaptureHomeContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        CaptureQuickAddSheet(),
        SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: CaptureInboxList(),
          ),
        ),
      ],
    );
  }
}
