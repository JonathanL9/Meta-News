import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      return userCredential.user;
    }
  } catch (e) {
    print("Google Sign-In Error: $e");
  }
  return null;
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Navigate to home page after successful login
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: GoogleFonts.lato(textStyle: TextStyle(color: Colors.white)),
        ),
        backgroundColor: const Color.fromARGB(221, 8, 8, 8),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            constraints:
                BoxConstraints(minWidth: 200, maxWidth: 450, maxHeight: 550),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.hedvigLettersSans(
                      textStyle: TextStyle(fontSize: 40)),
                ),
                Padding(padding: EdgeInsets.all(10)),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: loginWithEmail,
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w300),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, '/forgotpassword');
                      },
                      child: Text(
                        "Forgot Password?",
                        style: GoogleFonts.robotoFlex(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
