import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope_manager.dart';

/// TV 焦点测试辅助工具
///
/// 提供焦点行为验证的辅助方法，用于单元测试和集成测试。
class TvFocusTestHelper {
  TvFocusTestHelper._();

  /// 验证焦点退出行为
  ///
  /// [tester] - WidgetTester
  /// [sourceNode] - 源焦点节点
  /// [expectedNode] - 预期的目标焦点节点
  /// [direction] - 退出方向
  /// [shouldExit] - 是否应该成功退出
  static Future<void> verifyExit({
    required WidgetTester tester,
    required FocusNode sourceNode,
    required FocusNode expectedNode,
    required TvExitDirection direction,
    bool shouldExit = true,
  }) async {
    sourceNode.requestFocus();
    await tester.pump();

    expect(sourceNode.hasFocus, true, reason: '源节点应该有焦点');

    await _sendDirectionKeyEvent(tester, direction);
    await tester.pump();

    if (shouldExit) {
      expect(expectedNode.hasFocus, true, reason: '焦点应该转移到目标节点');
      expect(sourceNode.hasFocus, false, reason: '源节点应该失去焦点');
    } else {
      expect(sourceNode.hasFocus, true, reason: '焦点应该保持在源节点');
      expect(expectedNode.hasFocus, false, reason: '目标节点不应该获得焦点');
    }
  }

  /// 验证网格边界退出
  ///
  /// [tester] - WidgetTester
  /// [gridNode] - 网格焦点节点
  /// [expectedNode] - 预期的退出目标节点
  /// [direction] - 退出方向
  /// [index] - 当前项在网格中的索引
  /// [crossAxisCount] - 每行列数
  /// [totalItems] - 总项目数
  static Future<void> verifyGridBoundaryExit({
    required WidgetTester tester,
    required FocusNode gridNode,
    required FocusNode expectedNode,
    required TvExitDirection direction,
    required int index,
    required int crossAxisCount,
    required int totalItems,
  }) async {
    final shouldExit =
        _shouldGridExit(direction, index, crossAxisCount, totalItems);

    await verifyExit(
      tester: tester,
      sourceNode: gridNode,
      expectedNode: expectedNode,
      direction: direction,
      shouldExit: shouldExit,
    );
  }

  /// 验证焦点变化回调
  ///
  /// [tester] - WidgetTester
  /// [focusNode] - 焦点节点
  /// [expectedFocusChange] - 预期的焦点变化次数
  static Future<void> verifyFocusChange({
    required WidgetTester tester,
    required FocusNode focusNode,
    required int expectedFocusChange,
  }) async {
    var focusChangeCount = 0;

    focusNode.addListener(() {
      focusChangeCount++;
    });

    focusNode.requestFocus();
    await tester.pump();

    focusNode.unfocus();
    await tester.pump();

    expect(focusChangeCount, expectedFocusChange,
        reason: '焦点变化次数应该为 $expectedFocusChange');
  }

  /// 发送方向键事件
  static Future<void> _sendDirectionKeyEvent(
    WidgetTester tester,
    TvExitDirection direction,
  ) async {
    final key = _getLogicalKey(direction);
    await tester.sendKeyEvent(key);
  }

  /// 获取方向键的逻辑键
  static LogicalKeyboardKey _getLogicalKey(TvExitDirection direction) {
    switch (direction) {
      case TvExitDirection.up:
        return LogicalKeyboardKey.arrowUp;
      case TvExitDirection.down:
        return LogicalKeyboardKey.arrowDown;
      case TvExitDirection.left:
        return LogicalKeyboardKey.arrowLeft;
      case TvExitDirection.right:
        return LogicalKeyboardKey.arrowRight;
    }
  }

  /// 判断网格边界是否应该退出
  static bool _shouldGridExit(
    TvExitDirection direction,
    int index,
    int crossAxisCount,
    int totalItems,
  ) {
    final row = index ~/ crossAxisCount;
    final column = index % crossAxisCount;
    final totalRows = (totalItems / crossAxisCount).ceil();

    switch (direction) {
      case TvExitDirection.up:
        return row == 0;
      case TvExitDirection.down:
        return index >= (totalRows - 1) * crossAxisCount;
      case TvExitDirection.left:
        return column == 0;
      case TvExitDirection.right:
        return column == crossAxisCount - 1;
    }
  }

  /// 创建测试用的焦点节点集合
  ///
  /// [names] - 焦点节点名称列表
  static Map<String, FocusNode> createTestNodes(List<String> names) {
    final nodes = <String, FocusNode>{};
    for (final name in names) {
      nodes[name] = FocusNode(debugLabel: 'test_$name');
    }
    return nodes;
  }

  /// 清理测试焦点节点
  static void disposeTestNodes(Map<String, FocusNode> nodes) {
    for (final node in nodes.values) {
      node.dispose();
    }
  }
}
