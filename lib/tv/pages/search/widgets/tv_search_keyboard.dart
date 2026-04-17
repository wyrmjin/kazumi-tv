import 'package:flutter/material.dart';
import 'package:kazumi/tv/pages/search/widgets/tv_key_button.dart';

/// TV虚拟键盘组件
class TVSearchKeyboard extends StatelessWidget {
  final String searchText;
  final ValueChanged<String> onTextChanged;
  final VoidCallback? onExitLeft;
  final VoidCallback? onExitRight;
  final VoidCallback? onBack;
  final FocusNode keyboardFocusNode;

  const TVSearchKeyboard({
    super.key,
    required this.searchText,
    required this.onTextChanged,

    this.onExitLeft,
    this.onExitRight,
    this.onBack,
    required this.keyboardFocusNode,
  });

  /// 字母数字键盘布局 (36个键，6列×6行)
  static const List<String> keyboardKeys = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: const Color(0xFF252525),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSearchInput(),
            const SizedBox(height: 15),
            _buildControlButtons(),
            const SizedBox(height: 10),
            _buildKeyboardGrid(),
          ],
        ),
      ),
    );
  }

  /// 搜索输入框显示
  Widget _buildSearchInput() {
    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        searchText.isEmpty ? '输入关键词搜索...' : searchText,
        style: TextStyle(
          fontSize: 22,
          color: searchText.isEmpty ? Colors.white24 : Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 清空和后退按钮
  Widget _buildControlButtons() {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1.0),
              child: TVKeyButton(
                label: '清空',
                onTap: () => onTextChanged(''),
                onMoveLeft: onExitLeft,
                onBack: onBack,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FocusTraversalOrder(
              order: const NumericFocusOrder(1.1),
              child: TVKeyButton(
                label: '后退',
                onTap: () {
                  if (searchText.isNotEmpty) {
                    onTextChanged(
                        searchText.substring(0, searchText.length - 1));
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

  /// 字母数字键盘网格
  Widget _buildKeyboardGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: keyboardKeys.length,
      itemBuilder: (context, index) {
        return FocusTraversalOrder(
          order: NumericFocusOrder(2.0 + (index * 0.001)),
          child: TVKeyButton(
            label: keyboardKeys[index],
            focusNode: index == 0 ? keyboardFocusNode : null,
            onTap: () => onTextChanged(searchText + keyboardKeys[index]),
            onMoveLeft: (index % 6 == 0) ? onExitLeft : null,
            onMoveRight: (index % 6 == 5) ? onExitRight : null,
            onMoveUp: (index < 6) ? null : null,
            onMoveDown: (index >= 30) ? null : null,
            onBack: onBack,
            autofocus: false,
          ),
        );
      },
    );
  }

}
