# AGENTS.md - Kazumi 项目指南

本项目为 agentic coding agents 提供关键上下文。

## 项目核心

- Flutter 番剧采集与在线观看应用
- Flutter Modular + MobX + Hive 架构
- Flutter 版本: 3.41.6 (通过 `pubspec.yaml` 的 `flutter-version-file` 指定)
- Dart SDK: >=3.3.4

## 开发命令

```bash
# 依赖安装
flutter pub get

# 代码生成 (MobX + Hive) - 修改模型后必须运行
flutter pub run build_runner build --delete-conflicting-outputs

# 测试
flutter test                          # 所有测试
flutter test test/m3u8_parser_test.dart  # 单个文件

# 分析与格式化
flutter analyze
dart format .
```

## 构建命令

```bash
flutter build apk --split-per-abi     # Android
flutter build windows                 # Windows (需 JDK 18)
flutter build macos --release         # macOS
flutter build ios --release --no-codesign  # iOS
flutter build linux                   # Linux
```

## 架构要点

### 目录职责
- `lib/pages/` - 页面和 MobX 控制器，每个模块含 `*_module.dart`, `*_page.dart`, `*_controller.dart`
- `lib/modules/` - Hive 数据模型 (需 `@HiveType` 注解)
- `lib/utils/` - 工具类 (storage, m3u8_parser, logger 等)
- `lib/repositories/` - 数据仓库层
- `lib/plugins/` - 规则插件系统
- `lib/request/` - HTTP 请求封装 (使用 `Request.dio`)
- `lib/tv/` - TV 版本独立实现

### 模块注册
新页面模块需在 `lib/pages/index_module.dart` 注册路由和绑定控制器。

### MobX 模式
```dart
part 'controller.g.dart';

class Controller = _Controller with _$Controller;

abstract class _Controller with Store {
  @observable
  var items = ObservableList<Item>();
  
  @action
  void addItem(Item item) { items.add(item); }
}
```

### Hive 模型
```dart
@HiveType(typeId: 0)
class BangumiItem {
  @HiveField(0)
  int id;
  @HiveField(9, defaultValue: [])
  List<BangumiTag> tags;
}
```
新 Hive 模型需在 `lib/utils/storage.dart` 的 `GStorage.init()` 注册 adapter。

## 关键约束

### 自定义 Fork 依赖
`pubspec.yaml` 的 `dependency_overrides` 指定了自定义 fork:
- `media-kit`: `Predidit/media-kit` (所有平台)
- `webview_windows`: `Predidit/flutter-webview-windows`
- `desktop_webview_window`: `Predidit/linux_webview_window`

这些 fork 版本不可替换为官方版本。

### 平台 WebView 实现
- Windows: `webview_windows`
- Linux: `desktop_webview_window`
- 其他: `flutter_inappwebview`

### 代码风格
- 导入顺序: Dart SDK → Flutter SDK → 第三方包 → 项目内部 → 相对路径
- 中文注释和文档 (`///` 格式)
- 显式类型声明，避免 `var`
- 2 空格缩进，行宽 120

### CI/CD 要点
- Android 构建需 JDK 17
- Windows 构建需 JDK 18
- 使用 `subosito/flutter-action@v2.16.0`
- Flutter 版本由 `pubspec.yaml` 控制

## 常见任务流程

### 添加新数据模型 (需持久化)
1. 在 `lib/modules/` 创建类，添加 Hive 注解
2. 在 `storage.dart` 注册 adapter
3. 运行 `flutter pub run build_runner build --delete-conflicting-outputs`

### 添加新页面模块
1. 在 `lib/pages/<feature>/` 创建目录
2. 创建 `_module.dart`, `_page.dart`, `_controller.dart`
3. 在 `index_module.dart` 注册路由和绑定

### 修改网络请求
在 `lib/request/` 添加方法，使用 `Request.dio`，处理异常。

## 测试

- 测试文件位于 `test/`
- 使用 `flutter_test`
- 用 `group()` 组织测试套件