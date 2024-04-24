import '../components/imports.dart';
import '../pages/homepage.dart';
import '../components/textfield.dart';
import '../components/buttonfield.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSignIn = true;

  Future<void> _authenticate() async {
    try {
      if (_isSignIn) {
        // Sign in existing user
        await _auth.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        // Register new user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        
        String userID = userCredential.user?.uid ?? ''; // Get the authentication user ID

        // Store user details in Firestore using authentication user ID
        await _firestore.collection('users').doc(userID).set({
          'userID': userID,
          'email': emailController.text,
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'role': "",
          'registrationTime': FieldValue.serverTimestamp(),
        });

        // Automatically create profile with registration details
        await _firestore.collection('profiles').doc(userID).set({
          'userID': userID,
          'email': emailController.text,
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'displayName': displayNameController.text,
          'registrationTime': FieldValue.serverTimestamp(),
          'bio': "",
        });

        // Automatically create settings page with login details and personal info
        await _firestore.collection('settings').doc(userID).set({
          'email': emailController.text,
          'dob': null,
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } catch (e) {
      // Handle authentication errors
      print('Error authenticating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const SizedBox(height: 50,),
                const Icon(
                  Icons.article,
                  color: Colors.lightBlue,
                  size: 100,
                ),
                const SizedBox(height: 25,),
                Text(
                  _isSignIn ? "Welcome to Chatter!" : "Let's help you create an account",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue,
                      ),
                ),
                const SizedBox(height: 25,),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                if (!_isSignIn) ...[
                  MyTextField(
                    controller: firstNameController,
                    hintText: 'First Name',
                    obscureText: false,
                  ),
                  MyTextField(
                    controller: lastNameController,
                    hintText: 'Last Name',
                    obscureText: false,
                  ),
                  MyTextField(
                    controller: displayNameController,
                    hintText: 'Display Name',
                    obscureText: false,
                  ),
                ],
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                MyButton(
                  onTap: _authenticate,
                  text: _isSignIn ? 'Sign In' : 'Register'
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignIn ? "Not register?" : "Already have an account?",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                      _isSignIn = !_isSignIn;
                    });
                  },
                      child: Text(
                        _isSignIn ? "Register now" : "Sign in",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
