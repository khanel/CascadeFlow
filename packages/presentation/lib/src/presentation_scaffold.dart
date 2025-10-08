import 'package:flutter/material.dart';

/// Shared placeholder presentation widgets used until real flows are wired.
class PresentationScaffold extends StatelessWidget {
  const PresentationScaffold({
    super.key,
    required this.branchId,
    required this.title,
    required this.message,
    required this.isDetail,
  });

  final String branchId;
  final String title;
  final String message;
  final bool isDetail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(message),
      ),
    );
  }

  Key get _scaffoldKey => ValueKey(
        'branch-$branchId-${isDetail ? 'detail' : 'root'}',
      );
}

/// Factory helpers for presenting root/detail placeholders per branch.
class PresentationScaffoldFactory {
  const PresentationScaffoldFactory();

  Widget buildRoot({
    required String branchId,
    required String branchLabel,
  }) {
    return PresentationScaffold(
      branchId: branchId,
      title: '$branchLabel workspace',
      message: '$branchLabel workspace coming soon',
      isDetail: false,
    );
  }

  Widget buildDetail({
    required String branchId,
    required String branchLabel,
  }) {
    return PresentationScaffold(
      branchId: branchId,
      title: '$branchLabel details',
      message: '$branchLabel details coming soon',
      isDetail: true,
    );
  }
}
