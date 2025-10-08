import 'package:flutter/material.dart';

/// Generates semantic keys for branch placeholders so tests stay descriptive.
abstract final class PresentationScaffoldKeys {
  /// Key used for branch root placeholder screens.
  static ValueKey<String> root(String branchId) =>
      ValueKey<String>('branch-$branchId-root');

  /// Key used for branch detail placeholder screens.
  static ValueKey<String> detail(String branchId) =>
      ValueKey<String>('branch-$branchId-detail');
}

/// Centralises placeholder copy so UI/tests share the same messaging.
abstract final class PresentationScaffoldMessages {
  /// Message describing the forthcoming workspace for a branch.
  static String workspace(String branchLabel) =>
      '$branchLabel workspace coming soon';

  /// Message describing the forthcoming detail view for a branch.
  static String detail(String branchLabel) =>
      '$branchLabel details coming soon';

  /// Title displayed on workspace placeholders.
  static String workspaceTitle(String branchLabel) => '$branchLabel workspace';

  /// Title displayed on detail placeholders.
  static String detailTitle(String branchLabel) => '$branchLabel details';
}

/// Shared placeholder presentation widgets used until real flows are wired.
class PresentationScaffold extends StatelessWidget {
  /// Creates a scaffold placeholder for a specific branch screen.
  const PresentationScaffold({
    required this.branchId,
    required this.title,
    required this.message,
    required this.isDetail,
    super.key,
  });

  /// Identifier for the branch the scaffold represents.
  final String branchId;

  /// App bar title presented for the scaffold.
  final String title;

  /// Body message describing placeholder intent.
  final String message;

  /// Whether this scaffold represents a detail screen.
  final bool isDetail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: isDetail
          ? PresentationScaffoldKeys.detail(branchId)
          : PresentationScaffoldKeys.root(branchId),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(message),
      ),
    );
  }
}

/// Factory helpers for presenting root/detail placeholders per branch.
class PresentationScaffoldFactory {
  /// Creates a factory bound to static placeholder messaging.
  const PresentationScaffoldFactory();

  /// Builds the root placeholder for a navigation branch.
  Widget buildRoot({
    required String branchId,
    required String branchLabel,
  }) {
    return PresentationScaffold(
      branchId: branchId,
      title: PresentationScaffoldMessages.workspaceTitle(branchLabel),
      message: PresentationScaffoldMessages.workspace(branchLabel),
      isDetail: false,
    );
  }

  /// Builds the detail placeholder for a navigation branch.
  Widget buildDetail({
    required String branchId,
    required String branchLabel,
  }) {
    return PresentationScaffold(
      branchId: branchId,
      title: PresentationScaffoldMessages.detailTitle(branchLabel),
      message: PresentationScaffoldMessages.detail(branchLabel),
      isDetail: true,
    );
  }
}
