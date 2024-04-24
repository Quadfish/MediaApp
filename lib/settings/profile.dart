import '../components/imports.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _currentUserID;
  late Future<DocumentSnapshot> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchUserProfile();
    _profileFuture.then((snapshot) {
        setState(() {
        _displayNameController.text = snapshot['displayName'] ?? '';
        _bioController.text = snapshot['bio'] ?? '';
        });
      });
  }

  Future<DocumentSnapshot> _fetchUserProfile() async {
    // Get the current user's ID from Firebase Authentication
    _currentUserID = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the user's profile from Firestore
    return _firestore.collection('profiles').doc(_currentUserID).get();
  }

  Future<void> _updateProfile() async {
    try {
      // Update the profile in Firestore
      await _firestore.collection('profiles').doc(_currentUserID).update({
        'displayName': _displayNameController.text,
        'bio': _bioController.text,
      });
      // Fetch the updated profile
      setState(() {
        _profileFuture = _fetchUserProfile();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile Updated!')));
    } catch (e) {
      print('Error updating profile: $e');
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
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Fetch the profile data
            String firstName = snapshot.data!['firstName'];
            String lastName = snapshot.data!['lastName'];
            String email = snapshot.data!['email'];
            Timestamp registrationTime = snapshot.data!['registrationTime'];
            String displayName = _displayNameController.text;
            String bio = _bioController.text;

            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Name: $firstName',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Last Name: $lastName',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: $email',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Registration Time: ${registrationTime.toDate()}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _displayNameController..text = displayName,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController..text = bio,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Bio',
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: Text('Update Profile'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}