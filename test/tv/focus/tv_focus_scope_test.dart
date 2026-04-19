import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/tv/core/focus/focus_pattern.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope.dart';

void main() {
  group('TvFocusScope', () {
    testWidgets('使用提供的 FocusNode', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.vertical,
            focusNode: focusNode,
            child: Container(),
          ),
        ),
      );

      expect(focusNode.parent, isNotNull);
    });

    testWidgets('autofocus 自动获取焦点', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.vertical,
            autofocus: true,
            child: Container(),
          ),
        ),
      );

      await tester.pump();

      final focusNode = Focus.of(tester.element(find.byType(Container)));
      expect(focusNode.hasFocus, true);
    });

    testWidgets('onFocusChange 回调被调用', (tester) async {
      var focused = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.vertical,
            autofocus: true,
            onFocusChange: (hasFocus) => focused = hasFocus,
            child: Container(),
          ),
        ),
      );

      await tester.pump();

      expect(focused, true);
    });

    testWidgets('vertical 模式：左右键触发退出', (tester) async {
      var exitLeftCalled = false;
      var exitRightCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.vertical,
            autofocus: true,
            onExitLeft: () => exitLeftCalled = true,
            onExitRight: () => exitRightCalled = true,
            child: Container(),
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(exitLeftCalled, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(exitRightCalled, true);
    });

    testWidgets('horizontal 模式：上下键触发退出', (tester) async {
      var exitUpCalled = false;
      var exitDownCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.horizontal,
            autofocus: true,
            onExitUp: () => exitUpCalled = true,
            onExitDown: () => exitDownCalled = true,
            child: Container(),
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(exitUpCalled, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(exitDownCalled, true);
    });

    testWidgets('grid 模式：四方向自由移动', (tester) async {
      var exitUpCalled = false;
      var exitDownCalled = false;
      var exitLeftCalled = false;
      var exitRightCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.grid,
            autofocus: true,
            onExitUp: () => exitUpCalled = true,
            onExitDown: () => exitDownCalled = true,
            onExitLeft: () => exitLeftCalled = true,
            onExitRight: () => exitRightCalled = true,
            child: Container(),
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(exitUpCalled, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(exitDownCalled, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(exitLeftCalled, true);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(exitRightCalled, true);
    });

    testWidgets('isFirst 阻止向上/向左移动', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.vertical,
            autofocus: true,
            isFirst: true,
            child: Container(),
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      final focusNode = Focus.of(tester.element(find.byType(Container)));
      expect(focusNode.hasFocus, true);
    });

    testWidgets('isLast 阻止向下/向右移动', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.vertical,
            autofocus: true,
            isLast: true,
            child: Container(),
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      final focusNode = Focus.of(tester.element(find.byType(Container)));
      expect(focusNode.hasFocus, true);
    });

    testWidgets('确认键触发 onSelect', (tester) async {
      var selectCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: TvFocusScope(
            pattern: FocusPattern.vertical,
            autofocus: true,
            onSelect: () => selectCalled = true,
            child: Container(),
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(selectCalled, true);
    });

    testWidgets('exit FocusNode 获取焦点', (tester) async {
      final exitNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              TvFocusScope(
                pattern: FocusPattern.vertical,
                autofocus: true,
                exitLeft: exitNode,
                child: Container(),
              ),
              Focus(
                focusNode: exitNode,
                child: Container(),
              ),
            ],
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(exitNode.hasFocus, true);
    });

    testWidgets('onExit 回调优先于 exit FocusNode', (tester) async {
      final exitNode = FocusNode();
      var callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              TvFocusScope(
                pattern: FocusPattern.vertical,
                autofocus: true,
                exitLeft: exitNode,
                onExitLeft: () => callbackCalled = true,
                child: Container(),
              ),
              Focus(
                focusNode: exitNode,
                child: Container(),
              ),
            ],
          ),
        ),
      );

      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();

      expect(callbackCalled, true);
      expect(exitNode.hasFocus, false);
    });
  });
}
