import 'package:flutter/material.dart';
import 'package:kazumi/tv/pages/search/widgets/tv_key_button.dart';

/// TV验证码虚拟键盘（仅数字）
class TVCaptchaKeyboard extends StatelessWidget {
  final String text;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  final VoidCallback? onBack;
  final bool enabled;

  static const _digitKeys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const int _colCount = 5;

  const TVCaptchaKeyboard({
    super.key,
    required this.text,
    required this.onTextChanged,
    required this.onSubmit,
    required this.onCancel,
    this.onBack,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputDisplay(),
          const SizedBox(height: 6),
          _buildControlButtons(),
          const SizedBox(height: 4),
          ..._buildKeyboardRows(),
          const SizedBox(height: 6),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInputDisplay() {
    return Container(
      height: 38,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text.isEmpty ? '请输入验证码' : text,
              style: TextStyle(
                fontSize: 18,
                color: text.isEmpty ? Colors.white24 : Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (text.isNotEmpty)
            Text(
              '${text.length}',
              style: const TextStyle(fontSize: 12, color: Colors.white38),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1.0),
              child: TVKeyButton(
                label: '清空',
                onTap: () => onTextChanged(''),
                onBack: onBack,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1.1),
              child: TVKeyButton(
                label: '退格',
                onTap: () {
                  if (text.isNotEmpty) {
                    onTextChanged(text.substring(0, text.length - 1));
                  }
                },
                onBack: onBack,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildKeyboardRows() {
    final keys = _digitKeys;
    final rows = <Widget>[];
    for (var row = 0; row < keys.length; row += _colCount) {
      final rowKeys = <Widget>[];
      final end = (row + _colCount).clamp(0, keys.length);
      for (var col = row; col < end; col++) {
        final index = col;
        rowKeys.add(
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: col % _colCount < _colCount - 1 ? 4 : 0,
              ),
              child: FocusTraversalOrder(
                order: NumericFocusOrder(2.0 + (index * 0.01)),
                child: TVKeyButton(
                  label: keys[index],
                  onTap: enabled
                      ? () => onTextChanged(text + keys[index])
                      : () {},
                  onBack: onBack,
                  autofocus: index == 0,
                ),
              ),
            ),
          ),
        );
      }
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: row + _colCount < keys.length ? 4 : 0),
          child: SizedBox(
            height: 36,
            child: Row(children: rowKeys),
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildActionButtons() {
    return SizedBox(
      height: 38,
      child: Row(
        children: [
          Expanded(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(99.0),
              child: TVKeyButton(
                label: '取消',
                onTap: onCancel,
                onBack: onBack,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(99.1),
              child: TVKeyButton(
                label: '提交',
                onTap: enabled ? onSubmit : () {},
                onBack: onBack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
