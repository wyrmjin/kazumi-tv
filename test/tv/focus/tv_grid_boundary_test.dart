import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/tv/core/focus/tv_grid_boundary.dart';

void main() {
  group('TvGridBoundary', () {
    group('第一行判断', () {
      test('索引 0 是第一行', () {
        final boundary =
            TvGridBoundary(index: 0, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isFirstRow, true);
        expect(boundary.shouldExitUp(), true);
      });

      test('索引 4 是第一行', () {
        final boundary =
            TvGridBoundary(index: 4, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isFirstRow, true);
        expect(boundary.shouldExitUp(), true);
      });

      test('索引 5 不是第一行', () {
        final boundary =
            TvGridBoundary(index: 5, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isFirstRow, false);
        expect(boundary.shouldExitUp(), false);
      });
    });

    group('第一列判断', () {
      test('索引 0 是第一列', () {
        final boundary =
            TvGridBoundary(index: 0, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isFirstColumn, true);
        expect(boundary.shouldExitLeft(), true);
      });

      test('索引 5 是第一列', () {
        final boundary =
            TvGridBoundary(index: 5, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isFirstColumn, true);
        expect(boundary.shouldExitLeft(), true);
      });

      test('索引 10 是第一列', () {
        final boundary =
            TvGridBoundary(index: 10, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isFirstColumn, true);
        expect(boundary.shouldExitLeft(), true);
      });

      test('索引 1 不是第一列', () {
        final boundary =
            TvGridBoundary(index: 1, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isFirstColumn, false);
        expect(boundary.shouldExitLeft(), false);
      });
    });

    group('最后一行判断', () {
      test('索引 10 是最后一行', () {
        // 网格: 5列 x 3行 = 15 格子, 但只有 12 项
        // [0-4]   第0行
        // [5-9]   第1行
        // [10-11] 第2行 (最后一行)
        final boundary =
            TvGridBoundary(index: 10, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isLastRow, true);
        expect(boundary.shouldExitDown(), true);
      });

      test('索引 11 是最后一行', () {
        final boundary =
            TvGridBoundary(index: 11, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isLastRow, true);
        expect(boundary.shouldExitDown(), true);
      });

      test('索引 9 不是最后一行', () {
        final boundary =
            TvGridBoundary(index: 9, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isLastRow, false);
        expect(boundary.shouldExitDown(), false);
      });
    });

    group('最后一列判断', () {
      test('索引 4 是最后一列', () {
        final boundary =
            TvGridBoundary(index: 4, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isLastColumn, true);
        expect(boundary.shouldExitRight(), true);
      });

      test('索引 9 是最后一列', () {
        final boundary =
            TvGridBoundary(index: 9, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isLastColumn, true);
        expect(boundary.shouldExitRight(), true);
      });

      test('索引 11 是最后一列（最后一行最后一个）', () {
        // 最后一行只有 2 项: [10, 11]
        // 所以 11 是最后一列
        final boundary =
            TvGridBoundary(index: 11, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isLastColumn, true);
        expect(boundary.shouldExitRight(), true);
      });

      test('索引 10 不是最后一列', () {
        // 最后一行: [10, 11]
        // 10 是最后一行的第一个，不是最后一列
        final boundary =
            TvGridBoundary(index: 10, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isLastColumn, false);
        expect(boundary.shouldExitRight(), false);
      });

      test('索引 3 不是最后一列', () {
        final boundary =
            TvGridBoundary(index: 3, crossAxisCount: 5, totalItems: 12);
        expect(boundary.isLastColumn, false);
        expect(boundary.shouldExitRight(), false);
      });
    });

    group('完整网格布局测试', () {
      test('5列12项网格边界矩阵', () {
        // 网格布局:
        // [0]  [1]  [2]  [3]  [4]   <- 第一行
        // [5]  [6]  [7]  [8]  [9]   <- 中间行
        // [10] [11] [  ] [  ] [  ]  <- 最后一行（只有2项）

        const crossAxisCount = 5;
        const totalItems = 12;

        // 检查每个位置的边界状态
        final expectations = {
          0: (up: true, down: false, left: true, right: false), // 第一行第一列
          4: (up: true, down: false, left: false, right: true), // 第一行最后一列
          5: (up: false, down: false, left: true, right: false), // 中间行第一列
          9: (up: false, down: false, left: false, right: true), // 中间行最后一列
          10: (up: false, down: true, left: true, right: false), // 最后一行第一列
          11: (up: false, down: true, left: false, right: true), // 最后一行最后一列
        };

        expectations.forEach((index, expected) {
          final boundary = TvGridBoundary(
            index: index,
            crossAxisCount: crossAxisCount,
            totalItems: totalItems,
          );

          expect(boundary.shouldExitUp(), expected.up,
              reason: 'Index $index: shouldExitUp should be ${expected.up}');
          expect(boundary.shouldExitDown(), expected.down,
              reason:
                  'Index $index: shouldExitDown should be ${expected.down}');
          expect(boundary.shouldExitLeft(), expected.left,
              reason:
                  'Index $index: shouldExitLeft should be ${expected.left}');
          expect(boundary.shouldExitRight(), expected.right,
              reason:
                  'Index $index: shouldExitRight should be ${expected.right}');
        });
      });

      test('4列8项网格边界矩阵', () {
        // 网格布局:
        // [0] [1] [2] [3]  <- 第一行
        // [4] [5] [6] [7]  <- 最后一行

        const crossAxisCount = 4;
        const totalItems = 8;

        final expectations = {
          0: (up: true, down: false, left: true, right: false),
          3: (up: true, down: false, left: false, right: true),
          4: (up: false, down: true, left: true, right: false),
          7: (up: false, down: true, left: false, right: true),
        };

        expectations.forEach((index, expected) {
          final boundary = TvGridBoundary(
            index: index,
            crossAxisCount: crossAxisCount,
            totalItems: totalItems,
          );

          expect(boundary.shouldExitUp(), expected.up,
              reason: 'Index $index: shouldExitUp');
          expect(boundary.shouldExitDown(), expected.down,
              reason: 'Index $index: shouldExitDown');
          expect(boundary.shouldExitLeft(), expected.left,
              reason: 'Index $index: shouldExitLeft');
          expect(boundary.shouldExitRight(), expected.right,
              reason: 'Index $index: shouldExitRight');
        });
      });
    });

    group('边界条件测试', () {
      test('单项网格', () {
        final boundary =
            TvGridBoundary(index: 0, crossAxisCount: 1, totalItems: 1);
        expect(boundary.isFirstRow, true);
        expect(boundary.isFirstColumn, true);
        expect(boundary.isLastRow, true);
        expect(boundary.isLastColumn, true);
      });

      test('正好填满的网格', () {
        // 5列10项 = 2行正好填满
        final boundary =
            TvGridBoundary(index: 9, crossAxisCount: 5, totalItems: 10);
        expect(boundary.isLastRow, true);
        expect(boundary.isLastColumn, true);
      });
    });
  });
}
