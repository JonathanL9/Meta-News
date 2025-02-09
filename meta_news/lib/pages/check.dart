import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Check extends StatefulWidget {
  const Check({super.key});

  @override
  State<Check> createState() => _CheckState();
}

class _CheckState extends State<Check> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  void sendPasswordResetLink(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Password reset link sent to $email"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: GoogleFonts.lato(
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(221, 8, 8, 8),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/login.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 200,
              maxWidth: 450,
              maxHeight: 300,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Enter your email",
                    border: OutlineInputBorder(),
                  ),
              
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => sendPasswordResetLink(
                    _emailController.text.trim(),
                  ),
                  child: const Text("Send Password Reset Link"),
                ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushReplacementNamed(context, '/Login');
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.hedvigLettersSans(fontSize: 15,fontWeight: FontWeight.w300,color: Colors.blue,decoration: TextDecoration.underline),

                      ),
                     )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
