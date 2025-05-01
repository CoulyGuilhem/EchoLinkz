import 'package:flutter/material.dart';
import 'package:echolinkz/utils/shared_prefs_manager.dart';

class EchoLinkZAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const EchoLinkZAppBar({Key? key, required this.title, this.actions}) : super(key: key);

  @override
  State<EchoLinkZAppBar> createState() => _EchoLinkZAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _EchoLinkZAppBarState extends State<EchoLinkZAppBar> {
  late bool _isLogged;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoginStatus();
  }

  Future<void> _loadLoginStatus() async {
    _isLogged = await SharedPreferencesManager.isUserLoggedIn();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // default actions from auth status
    final defaultActions = <Widget>[];
    if (_isLoading) {
      defaultActions.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: cs.onPrimary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    } else if (_isLogged) {
      defaultActions.add(
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await SharedPreferencesManager.logoutUser();
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            }
          },
        ),
      );
    }

    final allActions = <Widget>[...?widget.actions, ...defaultActions];

    return AppBar(
      centerTitle: true,
      backgroundColor: cs.primary,
      title: Text(
        widget.title,
        style: TextStyle(color: cs.onPrimary),
      ),
      iconTheme: IconThemeData(color: cs.onPrimary),
      actions: allActions,
    );
  }
}