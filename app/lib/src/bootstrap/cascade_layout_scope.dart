import 'package:flutter/widgets.dart';

/// Named breakpoint thresholds shared throughout the app shell.
@immutable
class CascadeLayoutBreakpoints {
  /// Creates breakpoint thresholds with strictly increasing widths.
  const CascadeLayoutBreakpoints({
    required this.compact,
    required this.medium,
    required this.expanded,
  }) : assert(
         compact < medium && medium < expanded,
         'Breakpoints must increase monotonically.',
       );

  /// Maximum width before the layout is considered medium.
  final double compact;

  /// Maximum width before the layout is considered expanded.
  final double medium;

  /// Minimum width where the expanded layout is triggered.
  final double expanded;

  /// Default breakpoint configuration for CascadeFlow.
  static const CascadeLayoutBreakpoints standard = CascadeLayoutBreakpoints(
    compact: 600,
    medium: 1024,
    expanded: 1440,
  );

  /// Maps a viewport width to the corresponding layout size.
  CascadeLayoutSize resolve(double width) {
    if (width < compact) {
      return CascadeLayoutSize.compact;
    }
    if (width < medium) {
      return CascadeLayoutSize.medium;
    }
    return CascadeLayoutSize.expanded;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CascadeLayoutBreakpoints &&
        other.compact == compact &&
        other.medium == medium &&
        other.expanded == expanded;
  }

  @override
  int get hashCode => Object.hash(compact, medium, expanded);
}

/// Immutable data exposed to descendants via [CascadeLayoutScope].
@immutable
class CascadeLayoutData {
  /// Captures the resolved layout size alongside the breakpoints used.
  const CascadeLayoutData({
    required this.breakpoints,
    required this.size,
  });

  /// Breakpoint configuration used when resolving [size].
  final CascadeLayoutBreakpoints breakpoints;

  /// Currently resolved layout size for the viewport.
  final CascadeLayoutSize size;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is CascadeLayoutData &&
        other.breakpoints == breakpoints &&
        other.size == size;
  }

  @override
  int get hashCode => Object.hash(breakpoints, size);
}

/// Responsive layout sizes consumers can switch on for adaptive UI.
enum CascadeLayoutSize {
  /// Compact layouts are optimized for narrow viewports such as phones.
  compact,

  /// Medium layouts cover tablets or landscape phone widths.
  medium,

  /// Expanded layouts target desktop-class or ultra-wide screens.
  expanded,
}

/// Inherited scope that makes [CascadeLayoutData] available to descendants.
class CascadeLayoutScope extends InheritedWidget {
  /// Provides [data] to descendants while wrapping [child].
  const CascadeLayoutScope({
    required this.data,
    required super.child,
    super.key,
  });

  /// Layout data describing the current breakpoint state.
  final CascadeLayoutData data;

  /// Convenience accessor for descendants that only need breakpoints.
  CascadeLayoutBreakpoints get breakpoints => data.breakpoints;

  /// Convenience accessor for the resolved layout size.
  CascadeLayoutSize get size => data.size;

  /// Returns the nearest [CascadeLayoutScope] and registers a dependency.
  static CascadeLayoutScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CascadeLayoutScope>();
  }

  /// Looks up the nearest [CascadeLayoutScope], throwing when absent.
  static CascadeLayoutScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'CascadeLayoutScope not found in context.');
    return scope!;
  }

  @override
  bool updateShouldNotify(CascadeLayoutScope oldWidget) =>
      data != oldWidget.data;
}
