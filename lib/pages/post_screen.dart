import 'package:GoSocio/widgets/header.dart';
import 'package:GoSocio/widgets/post.dart';
import 'package:GoSocio/widgets/progress.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:GoSocio/pages/home.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({
    this.userId,
    this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsRef
      .doc(userId)
      .collection('userPosts')
      .doc(postId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
          Post post = Post.fromDocument(snapshot.data);
          return Center(
            child: Scaffold(
              appBar: header(context, titleText: post.description),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  ),
                ],
              ),
            ),
          );
      }
      );
  }
}
