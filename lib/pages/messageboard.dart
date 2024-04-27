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

  Future<void> _submitPost() async {
    String postText = _postController.text.trim();
    if (postText.isNotEmpty) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        DocumentSnapshot profileSnapshot = await _firestore.collection('profiles').doc(userId).get();
        String? profilePic = profileSnapshot['profilePic']; // Retrieve profile picture URL
        String? displayName = profileSnapshot['displayName'];
        
        _firestore.collection('message_boards')
          .doc(widget.messageBoardTitle)
          .collection('posts')
          .add({
            'text': postText,
            'timestamp': Timestamp.now(),
            'displayName': displayName,
            'uid': userId,
            'profilePic': profilePic, // Store profile picture URL
          });

        _postController.clear();
      }
    }
  }

  Widget _buildPostList(String? currentUserID) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
        .collection('message_boards')
        .doc(widget.messageBoardTitle)
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return ListView.builder(
          reverse: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final post = snapshot.data!.docs[index];
            final postText = post['text'];
            final timestamp = (post['timestamp'] as Timestamp).toDate();
            final timeText = '${timestamp.hour}:${timestamp.minute}';
            final displayName = post['displayName'];
            final postUserID = post['uid'];
            final profilePic = post['profilePic']; // Get the profile picture URL

            final isCurrentUserMessage = postUserID == currentUserID;

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: isCurrentUserMessage ? Colors.green : Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row( // Use Row to display profile picture and post content
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: profilePic == null
                      ? AssetImage('assets/Default_pfp.png') as ImageProvider // Default if no profile picture
                      : NetworkImage(profilePic), // Display profile picture
                  ),
                  SizedBox(width: 10), // Add spacing
                  Flexible( // Ensure text wrapping
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          postText, // Ensure text wraps
                          style: TextStyle(fontSize: 16),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            timeText, 
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
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
