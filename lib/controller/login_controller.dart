import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:globalchat/screens/splash_screen.dart';

class LoginController {
  static Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return SplashScreen();
          },
        ),
        (Route) {
          return false;
        },
      );
      print("Account created successfully!");
    } catch (e) {
      SnackBar messagesnackbar = SnackBar(
        backgroundColor: Colors.red,
        content: Text(e.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(messagesnackbar);
      print(e);
    }
  }
}
