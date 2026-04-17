import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/tv/core/focus/tv_key_handler_new.dart';

void main() {
  group('TvKeyHandler', () {
    group('handleNavigation', () {
      test('处理 ArrowUp 按键', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(
          event,
          onUp: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 ArrowDown 按键', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowDown,
          physicalKey: PhysicalKeyboardKey.arrowDown,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(
          event,
          onDown: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 ArrowLeft 按键', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowLeft,
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(
          event,
          onLeft: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 ArrowRight 按键', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowRight,
          physicalKey: PhysicalKeyboardKey.arrowRight,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(
          event,
          onRight: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 Enter 按键', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.enter,
          physicalKey: PhysicalKeyboardKey.enter,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(
          event,
          onEnter: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 Select 按键 (游戏手柄)', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.select,
          physicalKey: PhysicalKeyboardKey.select,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(
          event,
          onSelect: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('忽略 KeyRepeatEvent', () {
        final event = KeyRepeatEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(
          event,
          onUp: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.ignored);
      });

      test('未注册的按键返回 ignored', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          character: 'a',
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(event);

        expect(result, KeyEventResult.ignored);
      });

      test('未提供 block 时返回 ignored', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigation(event);

        expect(result, KeyEventResult.ignored);
      });
    });

    group('handleNavigationWithRepeat', () {
      test('处理 KeyDownEvent ArrowUp', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onUp: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 KeyRepeatEvent ArrowUp', () {
        final event = KeyRepeatEvent(
          logicalKey: LogicalKeyboardKey.arrowUp,
          physicalKey: PhysicalKeyboardKey.arrowUp,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onUp: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 KeyRepeatEvent ArrowDown', () {
        final event = KeyRepeatEvent(
          logicalKey: LogicalKeyboardKey.arrowDown,
          physicalKey: PhysicalKeyboardKey.arrowDown,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onDown: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 KeyRepeatEvent ArrowLeft', () {
        final event = KeyRepeatEvent(
          logicalKey: LogicalKeyboardKey.arrowLeft,
          physicalKey: PhysicalKeyboardKey.arrowLeft,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onLeft: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 KeyRepeatEvent ArrowRight', () {
        final event = KeyRepeatEvent(
          logicalKey: LogicalKeyboardKey.arrowRight,
          physicalKey: PhysicalKeyboardKey.arrowRight,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onRight: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('Enter 按键不处理 KeyRepeatEvent', () {
        final event = KeyRepeatEvent(
          logicalKey: LogicalKeyboardKey.enter,
          physicalKey: PhysicalKeyboardKey.enter,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onEnter: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.ignored);
      });

      test('Select 按键不处理 KeyRepeatEvent', () {
        final event = KeyRepeatEvent(
          logicalKey: LogicalKeyboardKey.select,
          physicalKey: PhysicalKeyboardKey.select,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onSelect: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.ignored);
      });

      test('处理 KeyDownEvent Enter', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.enter,
          physicalKey: PhysicalKeyboardKey.enter,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onEnter: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('处理 KeyDownEvent Select', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.select,
          physicalKey: PhysicalKeyboardKey.select,
          character: null,
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(
          event,
          onSelect: () => KeyEventResult.handled,
        );

        expect(result, KeyEventResult.handled);
      });

      test('未注册的按键返回 ignored', () {
        final event = KeyDownEvent(
          logicalKey: LogicalKeyboardKey.keyA,
          physicalKey: PhysicalKeyboardKey.keyA,
          character: 'a',
          timeStamp: Duration.zero,
        );

        final result = TvKeyHandler.handleNavigationWithRepeat(event);

        expect(result, KeyEventResult.ignored);
      });
    });
  });
}
