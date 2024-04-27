import '../components/imports.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  final String? image;
  final String? profilePic;

  const Post({
    super.key, 
    required this.message, 
    required this.user, 
    required this.postId, 
    required this.likes, 
    this.image,
    required this.profilePic,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  String? currentUserID = FirebaseAuth.instance.currentUser?.uid;
  bool isLiked = false;
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUserID);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    
    DocumentReference postRef =
      FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUserID])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUserID])
        });
      }
    }

  void addComment(String commentText) async {
      DocumentSnapshot snap = await FirebaseFirestore.instance.collection('profiles').doc(currentUserID).get();
      FirebaseFirestore.instance
      .collection("User Posts")
      .doc(widget.postId)
      .collection("Comments")
      .add({
        "CommentText" : commentText,
        "CommentedBy" : snap['displayName'],
        "CommentTime" : formatDate(Timestamp.now())
      });
    }
    
void showCommentDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Comments"),
        content: Container(
          constraints: BoxConstraints(
            maxHeight: 300, 
          ),
          child: Column(
            children: [
              Expanded( 
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .orderBy("CommentTime", descending: true)
                    .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    }

                    final comments = snapshot.data?.docs ?? [];

                    return SingleChildScrollView(
                      child: Column(
                        children: comments.map((doc) {
                          final commentData = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(commentData["CommentText"]),
                            subtitle: Text(
                              "By: ${commentData["CommentedBy"]} at ${commentData["CommentTime"]}",
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              TextField( 
                controller: _commentTextController,
                decoration: InputDecoration(hintText: "Write a comment..."),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);
              _commentTextController.clear(); 
            },
            child: Text("Post"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        ),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.image != "")
                Image.network(widget.image!, height: 200, fit: BoxFit.cover),
              Text(widget.message),
              const SizedBox(height: 10),
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[500]),
                ),
            ],
          ),
          const SizedBox(width: 20,),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: widget.profilePic == null
                  ? const AssetImage('assets/Default_pfp.png') as ImageProvider // Default if no profile picture
                  : NetworkImage(widget.profilePic!), // Display profile picture
              ),
              Column(
                children: [
                  LikeButton(
                    isLiked: isLiked, 
                    onTap: toggleLike,
                  ),
              
                  const SizedBox(height: 5),
                  Text(
                  widget.likes.length.toString(),
                  style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

            const SizedBox(width: 10),
            
            Column(
            children: [
              CommentButton(onTap: showCommentDialog),

              const SizedBox(height: 5),
              StreamBuilder<QuerySnapshot>( // Stream the comments
                stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .snapshots(), // Listen to changes in comments
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading...", style: TextStyle(color: Colors.grey)); // Placeholder while loading
                  }

                  if (snapshot.hasError) {
                    return Text("Error", style: TextStyle(color: Colors.red)); // Error handling
                  }

                  final commentCount = snapshot.data?.docs.length ?? 0; // Get the count of comments

                  return Text(
                    commentCount.toString(), // Display the comment count
                    style: TextStyle(color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}