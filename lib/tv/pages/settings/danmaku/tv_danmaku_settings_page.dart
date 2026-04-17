import 'package:flutter/material.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_settings_group_header.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_settings_toggle_row.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_settings_slider_row.dart';
import 'package:hive_ce/hive.dart';

class TVDanmakuSettingsPage extends StatefulWidget {
  final FocusNode? firstItemFocusNode;
  final VoidCallback? onExitUp;
  final VoidCallback? onExitLeft;
  final FocusNode? sidebarFocusNode;

  const TVDanmakuSettingsPage({
    super.key,
    this.firstItemFocusNode,
    this.onExitUp,
    this.onExitLeft,
    this.sidebarFocusNode,
  });

  @override
  State<TVDanmakuSettingsPage> createState() => _TVDanmakuSettingsPageState();
}

class _TVDanmakuSettingsPageState extends State<TVDanmakuSettingsPage> {
  Box setting = GStorage.setting;
  late bool danmakuEnabled;
  late double danmakuFontSize;
  late double danmakuOpacity;
  late double danmakuArea;
  late bool danmakuTop;
  late bool danmakuBottom;
  late bool danmakuScroll;
  late bool danmakuColor;

  @override
  void initState() {
    super.initState();
    danmakuEnabled = setting.get('danmakuEnabled', defaultValue: true);
    danmakuFontSize =
        setting.get(SettingBoxKey.danmakuFontSize, defaultValue: 25.0);
    danmakuOpacity =
        setting.get(SettingBoxKey.danmakuOpacity, defaultValue: 1.0);
    danmakuArea = setting.get(SettingBoxKey.danmakuArea, defaultValue: 1.0);
    danmakuTop = setting.get(SettingBoxKey.danmakuTop, defaultValue: true);
    danmakuBottom =
        setting.get(SettingBoxKey.danmakuBottom, defaultValue: false);
    danmakuScroll =
        setting.get(SettingBoxKey.danmakuScroll, defaultValue: true);
    danmakuColor = setting.get(SettingBoxKey.danmakuColor, defaultValue: true);
  }

  void updateDanmakuEnabled(bool value) {
    setting.put('danmakuEnabled', value);
    setState(() {
      danmakuEnabled = value;
    });
  }

  void updateDanmakuFontSize(double value) {
    setting.put(SettingBoxKey.danmakuFontSize, value);
    setState(() {
      danmakuFontSize = value;
    });
  }

  void updateDanmakuOpacity(double value) {
    setting.put(SettingBoxKey.danmakuOpacity, value);
    setState(() {
      danmakuOpacity = value;
    });
  }

  void updateDanmakuArea(double value) {
    setting.put(SettingBoxKey.danmakuArea, value);
    setState(() {
      danmakuArea = value;
    });
  }

  void updateDanmakuTop(bool value) {
    setting.put(SettingBoxKey.danmakuTop, value);
    setState(() {
      danmakuTop = value;
    });
  }

  void updateDanmakuBottom(bool value) {
    setting.put(SettingBoxKey.danmakuBottom, value);
    setState(() {
      danmakuBottom = value;
    });
  }

  void updateDanmakuScroll(bool value) {
    setting.put(SettingBoxKey.danmakuScroll, value);
    setState(() {
      danmakuScroll = value;
    });
  }

  void updateDanmakuColor(bool value) {
    setting.put(SettingBoxKey.danmakuColor, value);
    setState(() {
      danmakuColor = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        const TVSettingsGroupHeader(title: '弹幕设置'),
        TVSettingsToggleRow(
          label: '弹幕开关',
          subtitle: '开启或关闭弹幕显示',
          value: danmakuEnabled,
          onChanged: updateDanmakuEnabled,
          isFirst: true,
          focusNode: widget.firstItemFocusNode,
          onMoveUp: widget.onExitUp,
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsSliderRow(
          label: '字体大小',
          subtitle: '弹幕文字大小',
          value: danmakuFontSize,
          min: 16,
          max: 40,
          divisions: 24,
          onChanged: updateDanmakuFontSize,
          valueLabel: '${danmakuFontSize.toInt()}px',
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsSliderRow(
          label: '不透明度',
          subtitle: '弹幕不透明度',
          value: danmakuOpacity,
          min: 0.5,
          max: 1.0,
          divisions: 10,
          onChanged: updateDanmakuOpacity,
          valueLabel: danmakuOpacity.toStringAsFixed(1),
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsSliderRow(
          label: '显示区域',
          subtitle: '弹幕显示区域占比',
          value: danmakuArea,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          onChanged: updateDanmakuArea,
          valueLabel: '${(danmakuArea * 100).toInt()}%',
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsToggleRow(
          label: '顶部弹幕',
          subtitle: '显示顶部位置的弹幕',
          value: danmakuTop,
          onChanged: updateDanmakuTop,
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsToggleRow(
          label: '底部弹幕',
          subtitle: '显示底部位置的弹幕',
          value: danmakuBottom,
          onChanged: updateDanmakuBottom,
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsToggleRow(
          label: '滚动弹幕',
          subtitle: '显示滚动的弹幕',
          value: danmakuScroll,
          onChanged: updateDanmakuScroll,
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsToggleRow(
          label: '彩色弹幕',
          subtitle: '显示彩色弹幕',
          value: danmakuColor,
          onChanged: updateDanmakuColor,
          isLast: true,
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
      ],
    );
  }
}
