import 'package:flutter/material.dart';

/// 焦点退出方向
enum TvExitDirection {
  up,
  down,
  left,
  right,
}

/// TV 焦点作用域管理器
///
/// 统一管理页面内的焦点节点生命周期和焦点关系。
/// 使用声明式方式定义焦点链路，便于调试和维护。
class TvFocusScopeManager {
  TvFocusScopeManager({
    this.debugLabel,
  });

  final String? debugLabel;

  final Map<String, FocusNode> _nodes = {};
  final Map<String, _FocusEdge> _edges = {};
  bool _disposed = false;

  FocusNode registerNode(
    String name, {
    bool autofocus = false,
    String? debugLabel,
  }) {
    if (_disposed) {
      throw StateError('TvFocusScopeManager has been disposed');
    }

    if (_nodes.containsKey(name)) {
      throw ArgumentError('Focus node "$name" already registered');
    }

    final node = FocusNode(
      debugLabel: debugLabel ?? '${this.debugLabel ?? 'scope'}_$name',
    );

    _nodes[name] = node;

    return node;
  }

  Map<String, FocusNode> registerNodes(
    List<String> names, {
    String? autofocusName,
  }) {
    final result = <String, FocusNode>{};

    for (final name in names) {
      result[name] = registerNode(
        name,
        autofocus: name == autofocusName,
      );
    }

    return result;
  }

  void defineExit(
    String from,
    TvExitDirection direction,
    String to, {
    _ExitCondition? condition,
  }) {
    if (_disposed) {
      throw StateError('TvFocusScopeManager has been disposed');
    }

    final key = '$from.${direction.name}';
    _edges[key] = _FocusEdge(
      from: from,
      direction: direction,
      to: to,
      condition: condition,
    );
  }

  void defineEdges(List<TvFocusEdgeDefinition> edges) {
    for (final edge in edges) {
      defineExit(
        edge.from,
        edge.direction,
        edge.to,
        condition: edge.condition,
      );
    }
  }

  FocusNode getNode(String name) {
    final node = _nodes[name];
    if (node == null) {
      throw ArgumentError('Focus node "$name" not registered');
    }
    return node;
  }

  bool handleExit(
    String fromName,
    TvExitDirection direction, {
    VoidCallback? customHandler,
  }) {
    if (customHandler != null) {
      customHandler();
      return true;
    }

    final key = '$fromName.${direction.name}';
    final edge = _edges[key];

    if (edge == null) {
      return false;
    }

    if (edge.condition != null && !edge.condition!.evaluate()) {
      return false;
    }

    final targetNode = _nodes[edge.to];
    if (targetNode != null) {
      targetNode.requestFocus();
      return true;
    }

    return false;
  }

  void requestFocus(String name) {
    getNode(name).requestFocus();
  }

  String? getCurrentFocusName() {
    for (final entry in _nodes.entries) {
      if (entry.value.hasFocus) {
        return entry.key;
      }
    }
    return null;
  }

  void dispose() {
    if (_disposed) return;

    for (final node in _nodes.values) {
      node.dispose();
    }

    _nodes.clear();
    _edges.clear();
    _disposed = true;
  }

  Map<String, dynamic> getFocusGraph() {
    return {
      'nodes': _nodes.keys.toList(),
      'edges': _edges.entries
          .map((e) => {
                'key': e.key,
                'from': e.value.from,
                'direction': e.value.direction.name,
                'to': e.value.to,
                'hasCondition': e.value.condition != null,
              })
          .toList(),
    };
  }

  void printFocusGraph() {
    debugPrint('=== Focus Graph: ${debugLabel ?? 'unknown'} ===');
    debugPrint('Nodes: ${_nodes.keys.join(', ')}');

    for (final entry in _edges.entries) {
      final edge = entry.value;
      debugPrint('${edge.from}.${edge.direction.name} -> ${edge.to}');
    }
  }
}

class _FocusEdge {
  _FocusEdge({
    required this.from,
    required this.direction,
    required this.to,
    this.condition,
  });

  final String from;
  final TvExitDirection direction;
  final String to;
  final _ExitCondition? condition;
}

abstract class _ExitCondition {
  bool evaluate();
}

/// 网格边界条件
class TvGridBoundaryCondition extends _ExitCondition {
  TvGridBoundaryCondition({
    required this.index,
    required this.crossAxisCount,
    required this.totalItems,
    required this.requiredBoundary,
  });

  final int index;
  final int crossAxisCount;
  final int totalItems;
  final TvGridBoundaryType requiredBoundary;

  @override
  bool evaluate() {
    final row = index ~/ crossAxisCount;
    final column = index % crossAxisCount;
    final totalRows = (totalItems / crossAxisCount).ceil();

    switch (requiredBoundary) {
      case TvGridBoundaryType.firstRow:
        return row == 0;
      case TvGridBoundaryType.firstColumn:
        return column == 0;
      case TvGridBoundaryType.lastRow:
        return row >= totalRows - 1;
      case TvGridBoundaryType.lastColumn:
        return column >= crossAxisCount - 1;
    }
  }
}

enum TvGridBoundaryType {
  firstRow,
  firstColumn,
  lastRow,
  lastColumn,
}

/// 焦点关系定义
class TvFocusEdgeDefinition {
  TvFocusEdgeDefinition({
    required this.from,
    required this.direction,
    required this.to,
    this.condition,
  });

  final String from;
  final TvExitDirection direction;
  final String to;
  final _ExitCondition? condition;
}
