import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountSettingsScreen extends StatefulWidget {
  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isEmailVerified = false;
  List<dynamic> articles = [];

  @override
  void initState() {
    super.initState();
    checkEmailVerification();
    fetchSavedArticles();
  }

  // Check email verification status
  Future<void> checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isEmailVerified = user.emailVerified;
      });
    }
  }

  // Send verification email if not verified
  Future<void> sendVerificationEmail() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Verification email sent! Please check your inbox.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending verification email: $e')),
      );
    }
  }

  // Function to update email and password
  Future<void> _updateEmailPassword() async {
    try {
      String newEmail = _newEmailController.text;
      String newPassword = _newPasswordController.text;
      String currentPassword = _currentPasswordController.text;

      // Update email
      if (newEmail.isNotEmpty) {
        await changeEmail(newEmail, currentPassword);
      }

      // Update password
      if (newPassword.isNotEmpty) {
        await changePassword(newPassword);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Change email function
  Future<void> changeEmail(String newEmail, String currentPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updateEmail(newEmail);
        await sendVerificationEmail(); // Send verification email after email change
      }
    } catch (e) {
      throw 'Error changing email: $e';
    }
  }

  // Change password function
  Future<void> changePassword(String newPassword) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw 'Error changing password: $e';
    }
  }

  Future<void> fetchSavedArticles() async {
    try {
      var userEmail = FirebaseAuth.instance.currentUser?.email ?? 'unknown';
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(userEmail).get();
      List<dynamic> fetchedArticles = snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
      setState(() {
        articles = fetchedArticles;
      });
    } catch (e) {
      print("Error fetching saved articles: $e");
    }
  }

  Future<void> removeArticle(String docId) async {
    try {
      var userEmail = FirebaseAuth.instance.currentUser?.email ?? 'unknown';
      await FirebaseFirestore.instance
          .collection(userEmail)
          .doc(docId)
          .delete();
      fetchSavedArticles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article removed successfully')),
      );
    } catch (e) {
      print("Error removing article: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Account Settings",
          style: TextStyle(
            fontFamily: 'RegularSlab',
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 4.0,
                color: Colors.black,
              ),
            ],
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/account_settings.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        backgroundColor: const Color.fromARGB(221, 8, 8, 8),
        iconTheme: IconThemeData(
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(2.0, 2.0),
              blurRadius: 4.0,
              color: Colors.black,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Update your email and password",
              style: TextStyle(
                fontFamily: 'RegularSlab',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _newEmailController,
              decoration: InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateEmailPassword,
              child: Text("Update Email and Password"),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(
                  fontFamily: 'RegularSlab',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            _isEmailVerified
                ? Text(
                    "Your email is verified",
                    style: TextStyle(
                      fontFamily: 'RegularSlab',
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your email is not verified.",
                        style: TextStyle(
                          fontFamily: 'RegularSlab',
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: sendVerificationEmail,
                        child: Text("Send Verification Email"),
                        style: ElevatedButton.styleFrom(
                          textStyle: TextStyle(
                            fontFamily: 'RegularSlab',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: 30),
            Center(
              child: Text(
                "Read Later",
                style: TextStyle(
                    fontFamily: 'RegularSlab',
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54),
              ),
            ),
            Expanded(
              child: Container(
                child: articles.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          final article = articles[index];
                          return ListTile(
                            leading: article['image_url'] != null &&
                                    article['image_url'].isNotEmpty
                                ? Image.network(
                                    article['image_url'],
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.broken_image,
                                            size: 50,
                                            color: Colors.grey),
                                  )
                                : Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                            title: Text(
                              article['title'] ?? 'No Title',
                              style: GoogleFonts.robotoSlab(
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            subtitle: Text(
                              article['description'] ?? 'No Description',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            onTap: () async {
                              final url = article['source_url'];
                              if (url != null && await canLaunch(url)) {
                                await launch(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Invalid or missing URL')),
                                );
                              }
                            },
                            trailing: IconButton(
                              icon:
                                  Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => removeArticle(article['id']),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
