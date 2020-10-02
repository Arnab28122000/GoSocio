import 'package:GoSocio/models/user.dart';
import 'package:GoSocio/pages/home.dart';
import 'package:GoSocio/widgets/header.dart';
import 'package:GoSocio/widgets/post.dart';
import 'package:GoSocio/widgets/progress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


final usersRef = FirebaseFirestore.instance.collection('users');
class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<dynamic> users=[];

  @override
  void initState() {
    //getUsers();
    //getUserById();
    //createUser();
    //updateUser();
    //deleteUser();
    super.initState();
    getTimeline();
  }
  getTimeline() async{
    QuerySnapshot snapshot = await timelineRef
    .doc(widget.currentUser.id)
    .collection('timelinePosts')
    .orderBy('timestamp', descending: true)
    .get();

    List<Post> posts = snapshot.docs.map((doc) => Post.fromDocument(doc))
    .toList();
    setState(() {
      this.posts = posts;
    });
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

  buildTimeline(){
    if(posts == null){
      return circularProgress();
    }else if(posts.isEmpty){
      return Text('No posts to be displayed');
    }else{
      return ListView(children: posts,);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body:RefreshIndicator(
        child: buildTimeline(), 
        onRefresh: () => getTimeline(),
        ),
    );
  }
}
