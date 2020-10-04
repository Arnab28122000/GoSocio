import 'package:GoSocio/models/user.dart';
import 'package:GoSocio/pages/home.dart';
import 'package:GoSocio/pages/search.dart';
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
  List<String> followingList = [];
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
    getFollowing();
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

  getFollowing() async{
    QuerySnapshot snapshot = await followingRef
    .doc(currentUser.id)
    .collection('userFollowing')
    .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
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
      return buildUsersToFollow();
    }else{
      return ListView(children: posts,);
    }
  }

  buildUsersToFollow(){
    return StreamBuilder(
      stream: usersRef.orderBy('timestamp',descending: true).limit(30).snapshots(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<UserResult> userResults=[];
        snapshot.data.documents.forEach((doc){
          User user = User.fromDocument(doc);
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);
          // removing auth user from recommended list
          if(isAuthUser){
            return;
          }else if(isFollowingUser){
            return;
          }else{
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 30.0,
                      ),
                      SizedBox(width: 8.0,),
                      Text(
                        "Users to Follow",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(children: userResults,),
              ],
            ),
            );
      },
    );
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
