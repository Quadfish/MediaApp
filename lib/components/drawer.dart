import 'package:media_app/components/tiles.dart';

import '../components/imports.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  final void Function()? onSettingTap;
  final void Function()? onExploreTap;
  final void Function()? onHomeTap;

  const MyDrawer({
    Key? key,
    this.onProfileTap,
    this.onSignOut,
    this.onSettingTap,
    this.onExploreTap, 
    this.onHomeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.lightBlue,
      child: Column(
        children: [
          const DrawerHeader(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 64,
            ),
          ),
          MyListTile(
            icon: Icons.home,
            text: 'H O M E',
            onTap: onHomeTap,
          ),
          MyListTile(
            icon: Icons.explore,
            text: 'E X P L O R E',
            onTap: onExploreTap,
          ),
          MyListTile(
            icon: Icons.person,
            text: 'P R O F I L E',
            onTap: onProfileTap,
          ),
          MyListTile(
            icon: Icons.settings,
            text: 'S E T T I N G S',
            onTap: onSettingTap,
          ),
          MyListTile(
            icon: Icons.logout,
            text: 'L O G O U T',
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}