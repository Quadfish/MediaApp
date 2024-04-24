import 'package:media_app/components/drawer.dart';

import '../auth/authpage.dart';
import '../components/imports.dart';
import '../settings/profile.dart';
import '../settings/settings.dart';
import 'messageboard.dart';
import 'explorepage.dart';

class HomePage extends StatelessWidget {
  final List<String> messageBoards = [
    'Games',
    'Business',
    'Public Health',
    'Study',
  ];

  static final Map<String, String> messageBoardImages = {
    'Games': 'assets/Games.png',
    'Business': 'assets/Business.png',
    'Public Health': 'assets/Public_health.png',
    'Study': 'assets/Study.png',
  };

 void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AuthPage(),
      ),
    );
  }


  void goToExplore(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ExplorePage()),
    );
  }

  void goToProfile(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  void goToSetting(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(),
      ),
    );
  }

  void goToHome(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Boards'),
        backgroundColor: Colors.lightBlue,
      ),
      drawer: MyDrawer(
        onExploreTap: () => goToExplore(context),
        onProfileTap: () => goToProfile(context),
        onSettingTap: () => goToSetting(context),
        onSignOut: () => signOut(context),
        onHomeTap: () => goToHome(context),
      ),
      body: ListView.builder(
        itemCount: messageBoards.length,
        itemBuilder: (context, index) {
          final messageBoard = messageBoards[index];
          final imagePath = messageBoardImages[messageBoard];
          return ListTile(
            title: Text(messageBoard, style: TextStyle(fontSize: 20)),
            leading: imagePath != null ? Image.asset(imagePath) : null,
            onTap: () {
              // Navigate to the message board page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MessageBoardPage(messageBoard), // Pass message board title
                ),
              );
            },
          );
        },
      ),
    );
  }
}
