import 'package:flutter/material.dart';
import 'package:meta_news/pages/Home.dart';
import 'package:meta_news/pages/Loading.dart';
import 'package:meta_news/pages/Login.dart';
import 'package:meta_news/pages/NewsDetail.dart';
import 'package:meta_news/pages/Signup.dart';
import 'package:meta_news/pages/Topic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meta_news/pages/Account.dart';
import 'package:meta_news/pages/check.dart';
import 'firebase_options.dart';

// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meta News',
      debugShowCheckedModeBanner: false,
      initialRoute: '/Signup',
      routes: {
        '/': (context) => Loading(),
        '/home': (context) => Home(),
        '/topic': (context) => Topic(),
        '/Signup': (context) => Signup(),
        '/Login': (context) => Login(),
        '/NewsDetail': (context) => NewsDetail(article: {},),
        '/AccountSettings': (context) => AccountSettingsScreen(),
        '/forgotpassword':(context)=>Check(),
      },
    );
  }
}
