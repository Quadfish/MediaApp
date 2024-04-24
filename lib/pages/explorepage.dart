import 'package:flutter/services.dart';
import 'package:media_app/components/post.dart';
import 'package:media_app/components/textfield.dart';
import 'package:media_app/pages/homepage.dart';

import '../auth/authpage.dart';
import '../components/drawer.dart';
import '../components/imports.dart';
import '../settings/profile.dart';
import '../settings/settings.dart';


class ExplorePage extends StatefulWidget {

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}
class _ExplorePageState extends State<ExplorePage> {

    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    String? currentUserID = FirebaseAuth.instance.currentUser?.uid;

    final textController = TextEditingController();


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
  
  Future<void> postMessage () async {

    if (textController.text.isNotEmpty) {
      if (currentUserID != null) {
        DocumentSnapshot profileSnapshot = await _firestore.collection('profiles').doc(currentUserID).get();
        FirebaseFirestore.instance
        .collection("User Posts")
        .add({
          'userID': currentUserID,
          'displayName': profileSnapshot['displayName'],
          'message': textController.text,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
      });
    }}
    setState(() {
      textController.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Text('Explore'),
        backgroundColor: Colors.white,
      ),
      drawer: MyDrawer(
        onExploreTap: () => goToExplore(context),
        onProfileTap: () => goToProfile(context),
        onSettingTap: () => goToSetting(context),
        onSignOut: () => signOut(context),
        onHomeTap:() => goToHome(context),
      ),
      body: Center(
        child: 
          Column(
            children: [
             Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                .collection("User Posts")
                .orderBy(
                  "TimeStamp",
                  descending: false,
                )
                .snapshots(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return Post(
                        message: post['message'], 
                        user: post['displayName'], 
                        postId: post.id, 
                        likes: List<String>.from(post['Likes'] ?? []), 
                       );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error:${snapshot.error}'
                      ),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              ),
             ),
           ),

            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                 children: [
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: 'Post something on Explore . . .', 
                      obscureText: false,
                    ),
                  ),
                  IconButton(
                    onPressed: postMessage, 
                    icon: const Icon(Icons.arrow_circle_up),
                    )
                 ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
