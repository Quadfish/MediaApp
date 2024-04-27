import '../components/imports.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final TextEditingController _postTextController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _createPost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    DocumentSnapshot docSnap = await _firestore.collection('profiles').doc(currentUser?.uid).get();
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to create a post.')),
      );
      return;
    }

    final postData = {
      'Likes': [],
      'TimeStamp': Timestamp.now(),
      'displayName': docSnap['displayName'],
      'message': _postTextController.text,
      'userID': currentUser.uid,
      'profilePic': docSnap['profilePic'],
    };

    if (_selectedImage != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('posts/${currentUser.uid}/${DateTime.now()}.jpg');
      await imageRef.putFile(_selectedImage!);
      final imageUrl = await imageRef.getDownloadURL();
      postData['image'] = imageUrl;
    }

  
    final userPostsCollection = FirebaseFirestore.instance.collection('User Posts');
    DocumentReference newPostRef = await userPostsCollection.add(postData); 

    String newPostId = newPostRef.id;

    _postTextController.clear();
    _selectedImage = null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Post created successfully with ID: $newPostId')), 
    );

    Navigator.pop(context); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _postTextController,
              decoration: InputDecoration(labelText: 'What\'s on your mind?'),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Image.file(_selectedImage!),
            TextButton(
              onPressed: _pickImage,
              child: Text('Add Image'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _createPost,
              child: Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
