import '../components/imports.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  late String _currentUserID;
  late Future<DocumentSnapshot> _profileFuture;
  
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchUserProfile();
  }

  Future<DocumentSnapshot> _fetchUserProfile() async {
    _currentUserID = FirebaseAuth.instance.currentUser!.uid;
    return _firestore.collection('profiles').doc(_currentUserID).get();
  }

  Future<void> _updateProfilePicture() async {
    if (_profileImage == null) return;

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('profile_pictures/$_currentUserID.jpg');
    await imageRef.putFile(_profileImage!);
    final imageUrl = await imageRef.getDownloadURL();

    await _firestore.collection('profiles').doc(_currentUserID).update({
      'profilePic': imageUrl,
    });

    setState(() {
      _profileFuture = _fetchUserProfile();
    });
  }

  Future<void> _selectProfilePicture() async {
    final pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });

      await _updateProfilePicture(); // Upload and update the profile picture
    }
  }

  Future<void> _updateProfile() async {
    try {
      await _firestore.collection('profiles').doc(_currentUserID).update({
        'displayName': _displayNameController.text,
        'bio': _bioController.text,
      });

      setState(() {
        _profileFuture = _fetchUserProfile();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated!')));
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profileData = snapshot.data?.data() as Map<String, dynamic>;
          final profilePic = profileData['profilePic'] ?? '';
          final displayName = _displayNameController.text = profileData['displayName'] ?? '';
          final bio = _bioController.text = profileData['bio'] ?? '';

          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _selectProfilePicture, // Select a new profile picture
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePic.isEmpty
                      ? AssetImage('assets/Default_pfp.png') as ImageProvider // Default if no picture
                      : NetworkImage(profilePic), // Load from Firestore
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    labelText: 'Display Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  decoration: InputDecoration(
                    labelText: 'Bio',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text('Update Profile'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
