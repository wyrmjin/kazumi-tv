import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 平台检测工具类
class PlatformDetector {
  PlatformDetector._();

  static const _channel = MethodChannel('com.predidit.kazumi/platform');

  /// 缓存的检测结果
  static bool? _isAndroidTVCache;

  /// 检测是否为 Android TV (通过 leanback 特性)
  static Future<bool> isAndroidTV() async {
    if (_isAndroidTVCache != null) {
      return _isAndroidTVCache!;
    }

    if (!kIsWeb && Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod<bool>('isLeanback');
        _isAndroidTVCache = result ?? false;
        return _isAndroidTVCache!;
      } catch (e) {
        _isAndroidTVCache = false;
        return false;
      }
    }

    _isAndroidTVCache = false;
    return false;
  }

  /// 检测是否为桌面平台
  static bool isDesktop() {
    if (!kIsWeb) {
      return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
    }
    return false;
  }

  /// 检测是否为移动平台
  static bool isMobile() {
    if (!kIsWeb) {
      return Platform.isAndroid || Platform.isIOS;
    }
    return false;
  }

  /// 检测是否为 TV 平台
  /// 包括 Android TV 和桌面大屏
  static Future<bool> isTVPlatform() async {
    final isAndroidTVResult = await isAndroidTV();
    if (isAndroidTVResult) {
      return true;
    }

    // 桌面平台视为TV环境
    if (isDesktop()) {
      return true;
    }

    return false;
  }

  /// 清除缓存 (用于测试)
  static void clearCache() {
    _isAndroidTVCache = null;
  }
}
