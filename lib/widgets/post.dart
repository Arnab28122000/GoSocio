import 'dart:async';

import 'package:GoSocio/models/user.dart';
import 'package:GoSocio/pages/comments.dart';
import 'package:animator/animator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:GoSocio/widgets/custom_image.dart';
import 'package:GoSocio/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:GoSocio/pages/home.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  final dynamic likes;

  Post({
  this.postId,
  this.ownerId,
  this.username,
  this.location,
  this.description,
  this.mediaUrl,
  this.likes,
  });

  factory Post.fromDocument(QueryDocumentSnapshot doc){
    return Post(
      postId: doc.get('postId'),
      ownerId: doc.get('ownerId'),
      username: doc.get('username'),
      location: doc.get('location'),
      description: doc.get('description'),
      mediaUrl: doc.get('mediaUrl'),
      likes: doc.get('likes'),
    );
  }

  int getLikeCount(likes){
    //if no likes, return 0
    if(likes == null){
      return 0;
    }
    int count =0;
    //if the new key is absoluty
    likes.values.forEach((val){
      if(val == true){
        count+=1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    location: this.location,
    description: this.description,
    mediaUrl: this.mediaUrl,
    likes: this.likes,
    likeCount: getLikeCount(this.likes),
  );
}

class _PostState extends State<Post> {
  final String currentUserId = currentUser?.id;

  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

  _PostState({
  this.postId,
  this.ownerId,
  this.username,
  this.location,
  this.description,
  this.mediaUrl,
  this.likes,
  this.likeCount,
  });

  buildPostHeader(){
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => print("Showing Profile"),
            child: Text(
              user.username,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                ),
              ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            onPressed: () => print('deleting post'),
            icon: Icon(Icons.more_vert),
            ),
        );
      },
      );
  }

  handleLikePost(){
    bool _isLiked = likes[currentUserId] == true;

    if(_isLiked){
      postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
        'likes.$currentUserId' : false,
      });
      setState(() {
        likeCount-=1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    }else if(!_isLiked){
      postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
        'likes.$currentUserId' : true,
      });
      setState(() {
        likeCount+=1;
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), (){
        setState(() {
          showHeart = false;
        });
      });
    }
  }
  buildPostImage(){
    return GestureDetector(
      onDoubleTap: handleLikePost,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          cachedNetworkImage(mediaUrl),
          showHeart ? Animator(
            duration: Duration(milliseconds: 300),
            tween: Tween(begin: 0.7, end:1.3),
            curve: Curves.elasticOut,
            cycles: 0,
            builder: (_,anim,_n) => Transform.scale(
              scale:anim.value,
              child: Icon(
                Icons.favorite, size:80.0, color: Colors.redAccent,
              ),
              ),
          ): Text(""),
          //showHeart ? Icon(Icons.favorite, size:80.0, color: Colors.red,): Text(""),
        ],
      ),
    );
  }

  buildPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top:40.0, left: 20.0)),
            GestureDetector(
              onTap:handleLikePost,
              child: Icon(
                isLiked ? Icons.favorite:Icons.favorite_border,
                size: 28.0,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20.0)),
             GestureDetector(
              onTap:() => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
              child: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
            ),
          ],
          ),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  "$likeCount likes",
                  style: TextStyle(color: Colors.black,
                  fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20.0),
                child: Text(
                  "$username",
                  style: TextStyle(color: Colors.black,
                  fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Text(description)),
            ],
          ),
      ],
      );
  }
  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId] == true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
  }
}

showComments(BuildContext context, {String postId, String ownerId, String mediaUrl}){
  Navigator.push(context, MaterialPageRoute(builder: (context){
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
