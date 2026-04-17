import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kazumi/pages/my/my_controller.dart';
import 'package:kazumi/tv/pages/settings/widgets/tv_app_info_card.dart';
import 'package:kazumi/tv/core/widgets/tv_button.dart';
import 'package:kazumi/bean/dialog/dialog_helper.dart';

class TVAboutPage extends StatefulWidget {
  final FocusNode? firstItemFocusNode;
  final VoidCallback? onExitUp;
  final VoidCallback? onExitLeft;

  const TVAboutPage({
    super.key,
    this.firstItemFocusNode,
    this.onExitUp,
    this.onExitLeft,
  });

  @override
  State<TVAboutPage> createState() => _TVAboutPageState();
}

class _TVAboutPageState extends State<TVAboutPage> {
  final MyController myController = Modular.get<MyController>();
  bool checkingUpdate = false;

  Future<void> _handleCheckUpdate() async {
    if (checkingUpdate) return;

    setState(() {
      checkingUpdate = true;
    });

    try {
      await myController.checkUpdate();
    } catch (e) {
      KazumiDialog.showToast(message: '检查更新失败');
    } finally {
      setState(() {
        checkingUpdate = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const Expanded(
            child: TVAppInfoCard(),
          ),
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                TVButton(
                  onTap: checkingUpdate ? () {} : _handleCheckUpdate,
                  focusNode: widget.firstItemFocusNode,
                  onUp: widget.onExitUp,
                  onLeft: widget.onExitLeft,
                  child: Text(checkingUpdate ? '检查中...' : '检查更新'),
                ),
                const SizedBox(height: 16),
                Text(
                  '当前版本已是最新',
                  style: TextStyle(
                    color: Colors.white.withAlpha(120),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
