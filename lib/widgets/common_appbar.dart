import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenu;

  const CommonAppBar({
    super.key,
    this.showMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 143, 219, 147),
      centerTitle: true,
      elevation: 0,
      leading: showMenu
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      title: Image.asset(
        "assets/ecogurd.png",
        height: 210,
        width: 210,
        alignment: Alignment.center,
        
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
