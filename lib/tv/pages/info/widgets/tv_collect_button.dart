import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import '../../../core/widgets/tv_button.dart';
import 'tv_collect_dialog.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/pages/collect/collect_controller.dart';

/// TV 追番按钮
class TVCollectButton extends StatefulWidget {
  final BangumiItem bangumiItem;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;

  const TVCollectButton({
    super.key,
    required this.bangumiItem,
    this.autofocus = false,
    this.focusNode,
    this.onUp,
    this.onDown,
    this.onLeft,
    this.onRight,
  });

  @override
  State<TVCollectButton> createState() => _TVCollectButtonState();
}

class _TVCollectButtonState extends State<TVCollectButton> {
  final CollectController _collectController = Modular.get<CollectController>();
  late int _collectType;

  @override
  void initState() {
    super.initState();
    _collectType = _collectController.getCollectType(widget.bangumiItem);
  }

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

  void _showCollectDialog() {
    showDialog(
      context: context,
      builder: (context) => TVCollectDialog(
        currentType: _collectType,
        onSelected: (type) {
          _collectController.addCollect(widget.bangumiItem, type: type);
          setState(() {
            _collectType = type;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.4 - 48,
      height: 50,
      child: TVButton(
        onTap: _showCollectDialog,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        onUp: widget.onUp,
        onDown: widget.onDown,
        onLeft: widget.onLeft,
        onRight: widget.onRight,
        child: Center(
          child: Text(_getTypeString(_collectType)),
        ),
      ),
    );
  }
}
