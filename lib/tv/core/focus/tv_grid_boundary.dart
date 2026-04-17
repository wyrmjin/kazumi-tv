/// 网格边界状态计算器
///
/// 根据网格项的索引、列数和总项数计算边界状态。
/// 用于 TvGridItem 判断是否应该在某个方向触发退出行为。
class TvGridBoundary {
  TvGridBoundary({
    required this.index,
    required this.crossAxisCount,
    required this.totalItems,
  });

  final int index;
  final int crossAxisCount;
  final int totalItems;

  bool get isFirstRow => index < crossAxisCount;

  bool get isFirstColumn => index % crossAxisCount == 0;

  bool get isLastRow {
    final totalRows = (totalItems / crossAxisCount).ceil();
    return index >= (totalRows - 1) * crossAxisCount;
  }

  bool get isLastColumn {
    final column = index % crossAxisCount;
    if (column == crossAxisCount - 1) {
      return true;
    }
    if (isLastRow) {
      final itemsInLastRow = totalItems % crossAxisCount;
      final actualLastRowItems =
          itemsInLastRow == 0 ? crossAxisCount : itemsInLastRow;
      return column >= actualLastRowItems - 1;
    }
    return false;
  }

  bool shouldExitUp() => isFirstRow;

  bool shouldExitDown() => isLastRow;

  bool shouldExitLeft() => isFirstColumn;

  bool shouldExitRight() => isLastColumn;
}
