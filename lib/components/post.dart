import 'dart:collection';
import 'dart:html';

import 'package:media_app/components/commentfield.dart';
import 'package:media_app/components/like.dart';

import '../components/imports.dart';

class Post extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;

  const Post({
    super.key, 
    required this.message, 
    required this.user, 
    required this.postId, 
    required this.likes, 
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

  void addComment(String commentText) {
      FirebaseFirestore.instance
      .collection("User Posts")
      .doc(widget.postId)
      .collection("Comments")
      .add({
        "CommentText" : commentText,
        "CommentedBy" : currentUserID,
        "CommentTime" : Timestamp.now()
      });
    }
    
  void showCommentDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Add Comment"),
          content: TextField(
            controller: _commentTextController,
            decoration: InputDecoration(hintText: "Write a comment. . ."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addComment(_commentTextController.text);
                Navigator.pop(context);
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
        ),
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
              Text(widget.message),
              const SizedBox(height: 5),
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[500]),
                ),
            ],
          ),
          const SizedBox(width: 20,),
          Row(
            children: [
              Column(
                children: [
                  LikeButton(
                    isLiked: true, 
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
              const Text(
              '0',
              style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
            .collection("User Posts")
            .doc(widget.postId)
            .collection("Comments")
            .orderBy("CommentTime", descending: true)
            .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  
                  final commentData = doc.data() as Map<String, dynamic>;

                  return Comment(
                    text: commentData["CommentText"],
                    user: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}