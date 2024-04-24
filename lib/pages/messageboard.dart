import '../components/imports.dart';

class MessageBoardPage extends StatefulWidget {
  final String messageBoardTitle;

  MessageBoardPage(this.messageBoardTitle);

  @override
  _MessageBoardPageState createState() => _MessageBoardPageState();
}

class _MessageBoardPageState extends State<MessageBoardPage> {
  final TextEditingController _postController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    String? currentUserID = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.messageBoardTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildPostList(currentUserID),
          ),
          _buildPostForm(),
        ],
      ),
    );
  }

  Widget _buildPostForm() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _postController,
              decoration: InputDecoration(
                labelText: 'Enter your post',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitPost() async {
    String postText = _postController.text.trim();
    if (postText.isNotEmpty) {
      // Retrieve currently logged-in user's UID
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        // Retrieve user's first name from Firestore
        DocumentSnapshot profileSnapshot = await _firestore.collection('profiles').doc(userId).get();
        String? uid = profileSnapshot['userID'];
        String? displayName = profileSnapshot['displayName'];
        
        // Add post to Firestore under the message board collection
        _firestore.collection('message_boards').doc(widget.messageBoardTitle).collection('posts').add({
          'text': postText,
          'timestamp': Timestamp.now(),
          'displayName': displayName,
          'uid': uid,
        });
        _postController.clear();
      }
    }
  }

  Widget _buildPostList(String? currentUserID) {
    return StreamBuilder(
      stream: _firestore
          .collection('message_boards')
          .doc(widget.messageBoardTitle)
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return ListView.builder(
          reverse: true, // Display list in reverse order
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = snapshot.data!.docs[index];
            final postText = post['text'];
            final timestamp = (post['timestamp'] as Timestamp).toDate();
            final timeText = '${timestamp.hour}:${timestamp.minute}';
            final displayName = post['displayName'];
            final postUserID = post['uid']; 

            // Check if the current user sent this message
            final isCurrentUserMessage = postUserID == currentUserID;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: isCurrentUserMessage ? Colors.green : Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        postText,
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        timeText,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}