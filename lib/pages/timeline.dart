import 'package:GoSocio/widgets/header.dart';
import 'package:GoSocio/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


final usersRef = FirebaseFirestore.instance.collection('users');
class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<dynamic> users=[];

  @override
  void initState() {
    //getUsers();
    //getUserById();
    //createUser();
    //updateUser();
    //deleteUser();
    super.initState();
  }

  // createUser() {
  //   usersRef.doc("amsdjhvaj").set({
  //     "username":"Jeff",
  //     "postsCount":0,
  //     "isAdmin":false,
  //   });
  // }

  // updateUser() async{
  //   final doc = await usersRef.doc("3mkip39KTdSzkLa8gaCj").get();
  //   if(doc.exists){
  //     doc.reference.update({
  //     "username":"Chiratna",
  //     "postsCount":0,
  //     "isAdmin":false,
  //   });
  //   }
  // }

  // deleteUser() async{
  //   final doc = await usersRef.doc("3mkip39KTdSzkLa8gaCj").get();
  //   if(doc.exists){
  //     doc.reference.delete();
  //   }
  // }

  // getUsers() async{
  //   final QuerySnapshot snapshot = await usersRef.get();
  //   setState(() {
  //     users = snapshot.docs;
  //   });
  //       //snapshot.docs.forEach((DocumentSnapshot doc) { 
  //         // print(doc.data());
  //         // print(doc.id);
  //         // print(doc.exists);
  //       //});
    
  // }

  // getUserById() async{
  //   final String id ="4GAJENtFciV6wpchzCL3";
  //   final DocumentSnapshot doc = await usersRef.doc(id).get();
  //         print(doc.data());
  //         print(doc.id);
  //         print(doc.exists);  
    
  // }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot){
          if(!snapshot.hasData){
            return circularProgress();
          }
          final List<Text> children = snapshot.data.docs.map((doc) => Text(doc.data()['username'].toString())).toList();
          return Container(
            child:ListView(
              children: children,
            ),
          );
        },
      ),
    );
  }
}
