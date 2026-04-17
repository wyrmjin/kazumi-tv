import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/tv/core/focus/tv_focus_scope_manager.dart';

void main() {
  group('TvFocusScopeManager', () {
    group('焦点节点注册', () {
      test('注册单个焦点节点', () {
        final manager = TvFocusScopeManager(debugLabel: 'test');

        final node = manager.registerNode('tab');
        expect(node, isNotNull);
        expect(manager.getNode('tab'), same(node));

        manager.dispose();
      });

      test('注册多个焦点节点', () {
        final manager = TvFocusScopeManager();

        final nodes = manager.registerNodes(['tab', 'grid', 'menu']);

        expect(nodes.length, 3);
        expect(manager.getNode('tab'), same(nodes['tab']));
        expect(manager.getNode('grid'), same(nodes['grid']));
        expect(manager.getNode('menu'), same(nodes['menu']));

        manager.dispose();
      });

      test('重复注册抛出异常', () {
        final manager = TvFocusScopeManager();

        manager.registerNode('tab');

        expect(
          () => manager.registerNode('tab'),
          throwsArgumentError,
        );

        manager.dispose();
      });

      test('获取未注册的节点抛出异常', () {
        final manager = TvFocusScopeManager();

        expect(
          () => manager.getNode('unknown'),
          throwsArgumentError,
        );

        manager.dispose();
      });
    });

    group('焦点关系定义', () {
      test('定义单个退出关系', () {
        final manager = TvFocusScopeManager();
        manager.registerNodes(['tab', 'grid']);

        manager.defineExit('tab', TvExitDirection.down, 'grid');

        final graph = manager.getFocusGraph();
        final edges = graph['edges'] as List;
        expect(edges.length, 1);

        manager.dispose();
      });

      test('定义多个退出关系', () {
        final manager = TvFocusScopeManager();
        manager.registerNodes(['menu', 'tab', 'grid']);

        manager.defineEdges([
          TvFocusEdgeDefinition(
            from: 'menu',
            direction: TvExitDirection.right,
            to: 'tab',
          ),
          TvFocusEdgeDefinition(
            from: 'tab',
            direction: TvExitDirection.left,
            to: 'menu',
          ),
          TvFocusEdgeDefinition(
            from: 'tab',
            direction: TvExitDirection.down,
            to: 'grid',
          ),
          TvFocusEdgeDefinition(
            from: 'grid',
            direction: TvExitDirection.up,
            to: 'tab',
          ),
        ]);

        final graph = manager.getFocusGraph();
        final edges = graph['edges'] as List;
        expect(edges.length, 4);

        manager.dispose();
      });
    });

    group('退出处理', () {
      testWidgets('处理退出跳转到目标节点', (tester) async {
        final manager = TvFocusScopeManager();
        manager.registerNodes(['tab', 'grid']);
        manager.defineExit('tab', TvExitDirection.down, 'grid');

        final tabNode = manager.getNode('tab');
        final gridNode = manager.getNode('grid');

        await tester.pumpWidget(
          MaterialApp(
            home: Row(
              children: [
                Focus(focusNode: tabNode, child: Container()),
                Focus(focusNode: gridNode, child: Container()),
              ],
            ),
          ),
        );

        tabNode.requestFocus();
        await tester.pump();
        expect(tabNode.hasFocus, true);

        final handled = manager.handleExit('tab', TvExitDirection.down);
        await tester.pump();

        expect(handled, true);
        expect(gridNode.hasFocus, true);
        expect(tabNode.hasFocus, false);

        manager.dispose();
      });

      testWidgets('无退出关系时返回 false', (tester) async {
        final manager = TvFocusScopeManager();
        manager.registerNodes(['tab', 'grid']);

        final tabNode = manager.getNode('tab');

        await tester.pumpWidget(
          MaterialApp(
            home: Focus(focusNode: tabNode, child: Container()),
          ),
        );

        tabNode.requestFocus();
        await tester.pump();

        final handled = manager.handleExit('tab', TvExitDirection.down);
        await tester.pump();

        expect(handled, false);
        expect(tabNode.hasFocus, true);

        manager.dispose();
      });

      testWidgets('自定义处理器优先执行', (tester) async {
        final manager = TvFocusScopeManager();
        manager.registerNodes(['tab', 'grid']);
        manager.defineExit('tab', TvExitDirection.down, 'grid');

        final tabNode = manager.getNode('tab');
        final gridNode = manager.getNode('grid');

        var customHandlerCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Row(
              children: [
                Focus(focusNode: tabNode, child: Container()),
                Focus(focusNode: gridNode, child: Container()),
              ],
            ),
          ),
        );

        tabNode.requestFocus();
        await tester.pump();

        final handled = manager.handleExit(
          'tab',
          TvExitDirection.down,
          customHandler: () {
            customHandlerCalled = true;
          },
        );
        await tester.pump();

        expect(handled, true);
        expect(customHandlerCalled, true);
        // 自定义处理器没有调用 requestFocus，所以 grid 不应该获得焦点
        expect(gridNode.hasFocus, false);

        manager.dispose();
      });
    });

    group('生命周期管理', () {
      test('dispose 后注册节点抛出异常', () {
        final manager = TvFocusScopeManager();
        manager.dispose();

        expect(
          () => manager.registerNode('tab'),
          throwsStateError,
        );
      });

      test('dispose 后定义退出抛出异常', () {
        final manager = TvFocusScopeManager();
        manager.registerNode('tab');
        manager.dispose();

        expect(
          () => manager.defineExit('tab', TvExitDirection.down, 'grid'),
          throwsStateError,
        );
      });

      test('dispose 清理所有焦点节点', () {
        final manager = TvFocusScopeManager();
        manager.registerNodes(['tab', 'grid']);

        manager.dispose();

        // 验证管理器已标记为 disposed
        expect(() => manager.registerNode('new'), throwsStateError);
      });
    });

    group('焦点图调试', () {
      test('getFocusGraph 返回正确的结构', () {
        final manager = TvFocusScopeManager(debugLabel: 'test_page');
        manager.registerNodes(['menu', 'tab', 'grid']);
        manager.defineEdges([
          TvFocusEdgeDefinition(
            from: 'menu',
            direction: TvExitDirection.right,
            to: 'tab',
          ),
          TvFocusEdgeDefinition(
            from: 'tab',
            direction: TvExitDirection.down,
            to: 'grid',
          ),
        ]);

        final graph = manager.getFocusGraph();

        expect(graph['nodes'], isA<List>());
        final nodes = graph['nodes'] as List;
        expect(nodes.length, 3);
        expect(nodes, containsAll(['menu', 'tab', 'grid']));

        expect(graph['edges'], isA<List>());
        final edges = graph['edges'] as List;
        expect(edges.length, 2);

        manager.dispose();
      });
    });
  });
}
