import '../components/imports.dart';
import '../auth/authpage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetch user's email and date of birth from settings
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    String userID = _auth.currentUser!.uid;
    DocumentSnapshot settingsSnapshot = await _firestore.collection('settings').doc(userID).get();
    setState(() {
      _emailController.text = settingsSnapshot['email'] ?? '';
      _dobController.text = settingsSnapshot['dateOfBirth'] ?? '';
    });
  }

  Future<void> _updateEmailAndPassword() async {
    try {
      // Update email
      await _auth.currentUser!.updateEmail(_emailController.text);
      // Update password
      await _auth.currentUser!.updatePassword(_passwordController.text);
      // Update email in settings
      String userID = _auth.currentUser!.uid;
      await _firestore.collection('settings').doc(userID).update({
        'email': _emailController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email and password updated')));
    } catch (e) {
      print('Error updating email and password: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update email and password')));
    }
  }

  Future<void> _updateDateOfBirth() async {
    try {
      String userID = _auth.currentUser!.uid;
      await _firestore.collection('settings').doc(userID).update({
        'dateOfBirth': _dobController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Date of birth updated')));
    } catch (e) {
      print('Error updating date of birth: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update date of birth')));
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => AuthPage(),
        ),
      (route) => false, // Remove all routes in the navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateEmailAndPassword,
              child: Text('Update Email & Password'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _dobController,
              decoration: InputDecoration(labelText: 'Date of Birth'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _updateDateOfBirth,
              child: Text('Update Date of Birth'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logout,
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
