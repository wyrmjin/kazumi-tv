import 'package:flutter/material.dart';
import 'package:kazumi/utils/storage.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_settings_group_header.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_settings_toggle_row.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_settings_slider_row.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_settings_dropdown_row.dart';
import 'package:hive_ce/hive.dart';

class TVPlayerSettingsPage extends StatefulWidget {
  final FocusNode? firstItemFocusNode;
  final VoidCallback? onExitUp;
  final VoidCallback? onExitLeft;
  final FocusNode? sidebarFocusNode;

  const TVPlayerSettingsPage({
    super.key,
    this.firstItemFocusNode,
    this.onExitUp,
    this.onExitLeft,
    this.sidebarFocusNode,
  });

  @override
  State<TVPlayerSettingsPage> createState() => _TVPlayerSettingsPageState();
}

class _TVPlayerSettingsPageState extends State<TVPlayerSettingsPage> {
  Box setting = GStorage.setting;
  late bool hAenable;
  late bool lowMemoryMode;
  late double defaultPlaySpeed;
  late int defaultAspectRatioType;

  @override
  void initState() {
    super.initState();
    hAenable = setting.get(SettingBoxKey.hAenable, defaultValue: true);
    lowMemoryMode =
        setting.get(SettingBoxKey.lowMemoryMode, defaultValue: false);
    defaultPlaySpeed =
        setting.get(SettingBoxKey.defaultPlaySpeed, defaultValue: 1.0);
    defaultAspectRatioType =
        setting.get(SettingBoxKey.defaultAspectRatioType, defaultValue: 1);
  }

  void updateHAenable(bool value) {
    setting.put(SettingBoxKey.hAenable, value);
    setState(() {
      hAenable = value;
    });
  }

  void updateLowMemoryMode(bool value) {
    setting.put(SettingBoxKey.lowMemoryMode, value);
    setState(() {
      lowMemoryMode = value;
    });
  }

  void updateDefaultPlaySpeed(double value) {
    setting.put(SettingBoxKey.defaultPlaySpeed, value);
    setState(() {
      defaultPlaySpeed = value;
    });
  }

  void updateDefaultAspectRatioType(int value) {
    setting.put(SettingBoxKey.defaultAspectRatioType, value);
    setState(() {
      defaultAspectRatioType = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        const TVSettingsGroupHeader(title: '播放器设置'),
        TVSettingsToggleRow(
          label: '硬件解码',
          subtitle: '使用硬件加速解码视频',
          value: hAenable,
          onChanged: updateHAenable,
          isFirst: true,
          focusNode: widget.firstItemFocusNode,
          onMoveUp: widget.onExitUp,
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsToggleRow(
          label: '低内存模式',
          subtitle: '减少内存占用，可能降低性能',
          value: lowMemoryMode,
          onChanged: updateLowMemoryMode,
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsSliderRow(
          label: '默认播放速度',
          subtitle: '视频播放的默认速度',
          value: defaultPlaySpeed,
          min: 0.25,
          max: 3.0,
          divisions: 11,
          onChanged: updateDefaultPlaySpeed,
          valueLabel: '${defaultPlaySpeed.toStringAsFixed(2)}x',
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
        TVSettingsDropdownRow<int>(
          label: '默认画面比例',
          subtitle: '视频画面的默认显示比例',
          value: defaultAspectRatioType,
          items: aspectRatioTypeMap.keys.toList(),
          itemLabel: (type) => aspectRatioTypeMap[type] ?? '自动',
          onChanged: (value) {
            if (value != null) {
              updateDefaultAspectRatioType(value);
            }
          },
          isLast: true,
          onMoveLeft: widget.onExitLeft,
          sidebarFocusNode: widget.sidebarFocusNode,
        ),
      ],
    );
  }
}
