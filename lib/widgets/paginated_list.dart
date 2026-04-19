import 'package:flutter/material.dart';
import 'shimmer_card.dart';

/// Generic paginated list view with lazy loading support.
/// Auto-triggers loadMore when scrolled to 80% threshold.
class PaginatedListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final bool isInitialLoading;
  final int shimmerCount;
  final Widget? emptyWidget;
  final Widget? headerWidget;
  final EdgeInsets padding;
  final Future<void> Function()? onRefresh;

  const PaginatedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.isInitialLoading = false,
    this.shimmerCount = 6,
    this.emptyWidget,
    this.headerWidget,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.onRefresh,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom && !widget.hasReachedMax && !widget.isLoadingMore) {
      widget.onLoadMore?.call();
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= maxScroll * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    // Initial shimmer loading
    if (widget.isInitialLoading) {
      return ListView.builder(
        padding: widget.padding,
        itemCount: widget.shimmerCount,
        itemBuilder: (context, index) => const ShimmerCard(),
      );
    }

    // Empty state
    if (widget.items.isEmpty) {
      return widget.emptyWidget ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada data',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
    }

    final itemCount = widget.items.length +
        (widget.isLoadingMore ? 1 : 0) +
        (widget.headerWidget != null ? 1 : 0);

    Widget listView = ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Header
        if (widget.headerWidget != null && index == 0) {
          return widget.headerWidget!;
        }

        final adjustedIndex =
            widget.headerWidget != null ? index - 1 : index;

        // Loading indicator at bottom
        if (adjustedIndex >= widget.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return widget.itemBuilder(
            context, widget.items[adjustedIndex], adjustedIndex);
      },
    );

    if (widget.onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: listView,
      );
    }

    return listView;
  }
}
