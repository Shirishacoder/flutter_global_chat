import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Userprovider extends ChangeNotifier {
  String userName = "dummy";
  String useremail = "dummy";
  String id = "dummy";
  var db = FirebaseFirestore.instance;

  void getuserDetails() {
    var authuser = FirebaseAuth.instance.currentUser;
    db.collection("user").doc(authuser!.uid).get().then((dataSnapshot) {
      userName = dataSnapshot.data()?["name"] ?? "";
      useremail = dataSnapshot.data()?["email"] ?? "";
      id = dataSnapshot.data()?["id"] ?? "";
    });
  }
}
