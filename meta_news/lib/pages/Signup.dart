import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> registerWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      // Register user with Firebase
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Navigate to home page after successful registration
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = 'Registration failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up',
            style: GoogleFonts.lato(
              textStyle: TextStyle(color: Colors.white),
            )),
        backgroundColor: const Color.fromARGB(221, 8, 8, 8),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "images/signup.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              constraints: BoxConstraints(maxWidth: 450, minWidth: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create your free account',
                    style: GoogleFonts.hedvigLettersSans(
                        textStyle: TextStyle(
                      fontSize: 30,
                    )),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
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
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: registerWithEmail,
                    child: Text('Sign Up'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?",
                          style: GoogleFonts.ptSansCaption()),
                      SizedBox(width: 4),
                    Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, '/Login');
                            },
                            child: Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
