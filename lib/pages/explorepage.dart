import '../components/imports.dart';
import 'imports.dart';
import '../settings/imports.dart';
import '../auth/authpage.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? currentUserID = FirebaseAuth.instance.currentUser?.uid;

  // Navigation methods for different pages
  void signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  void goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void goToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  void goToHome(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  void goToCreatePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreatePost()), // Navigate to the new "Post" page
    );
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
        onProfileTap: () => goToProfile(context),
        onSettingTap: () => goToSettings(context),
        onSignOut: () => signOut(context),
        onHomeTap: () => goToHome(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToCreatePost(context), // Trigger navigation to the "Create Post" page
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          // StreamBuilder to display all user posts
          Expanded(
            child: StreamBuilder(
              stream: _firestore.collection("User Posts").orderBy("TimeStamp", descending: true).snapshots(),
              builder: (context, snapshot) {
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
                        image: post['image'] ?? null,
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          // Text input and post button
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Expanded(
                  child: MyTextField(
                    controller: textController,
                    hintText: 'Post something on Explore...',
                    obscureText: false,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    goToCreatePost(context); // Directs to new "Create Post" page
                  },
                  icon: const Icon(Icons.arrow_circle_up),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
