import 'package:flutter/material.dart';
import '../../../core/widgets/tv_button.dart';

/// TV 追番状态选择对话框
class TVCollectDialog extends StatelessWidget {
  final int currentType;
  final Function(int) onSelected;

  const TVCollectDialog({
    super.key,
    required this.currentType,
    required this.onSelected,
  });

  String _getTypeString(int type) {
    switch (type) {
      case 1:
        return '在看';
      case 2:
        return '想看';
      case 3:
        return '搁置';
      case 4:
        return '看过';
      case 5:
        return '抛弃';
      default:
        return '未追';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            const Text(
              '选择追番状态',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // 6个状态按钮（未追 + 5个状态）
            ...List.generate(6, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: 350,
                  height: 50,
                  child: TVButton(
                    onTap: () {
                      Navigator.of(context).pop();
                      if (index != currentType) {
                        onSelected(index);
                      }
                    },
                    autofocus: index == currentType,
                    child: Center(
                      child: Text(_getTypeString(index)),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // 取消按钮
            SizedBox(
              width: 350,
              height: 50,
              child: TVButton(
                onTap: () => Navigator.of(context).pop(),
                child: const Center(
                  child: Text('取消'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
