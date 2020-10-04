import 'package:GoSocio/pages/post_screen.dart';
import 'package:GoSocio/pages/profile.dart';
import 'package:GoSocio/widgets/header.dart';
import 'package:GoSocio/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:GoSocio/pages/home.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeed() async{
    QuerySnapshot snapshot = await activityFeedRef
    .doc(currentUser.id)
    .collection('feedItems')
    .orderBy('timestamp', descending: true)
    .limit(50).get();
    List<ActivityFeedItem> feedItems = [];
      snapshot.docs.forEach((doc) {
        feedItems.add(ActivityFeedItem.fromDocument(doc));
        //print('Activity Feed Item: ${doc.data()}');
       });
    return feedItems;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      appBar: header(context, titleText: "Activity Feed"),
      body: Container(
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context, snapshot){
            if(!snapshot.hasData){
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          },
          ),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String mediaUrl;
  final String postId;
  final String userProfileImg;
  final String commentData;
  final Timestamp timestamp;

  ActivityFeedItem({
    this.username,
    this.userId,
    this.type,
    this.mediaUrl,
    this.postId,
    this.userProfileImg,
    this.commentData,
    this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc){
    return ActivityFeedItem(
      username: doc.get('username'),
      userId: doc.get('userId'),
      type: doc.get('type'),
      mediaUrl: doc.get('mediaUrl'),
      postId: doc.get('postId'),
      userProfileImg: doc.get('userProfileImg'),
      commentData: doc.get('commentData'),
      timestamp: doc.get('timestamp'),
    );
  }

  showPost(context){
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => PostScreen(
        postId: postId,
        userId: userId,
      ),
      ),
      );
  }

  configureMdiaPreview(context){
    if(type == "like" || type == "comment"){
      mediaPreview = GestureDetector(
        onTap: () => showPost(context,),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(mediaUrl),
                  ),
              ),
            ),
            ),
        ),
      );
    }else{
      mediaPreview = Text('');
    }

    if(type == 'like'){
      activityItemText = "liked your post";
   }else if(type == 'follow'){
     activityItemText = "is following you";
   }else if(type == 'comment'){
     activityItemText = 'replied: $commentData';
   }else{
     activityItemText = "Error: Unknown type '$type'";
   }
  }

  
  @override
  Widget build(BuildContext context) {
    configureMdiaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context,profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                    TextSpan(
                      text:' $activityItemText',
                    ),
                ],
              ),
              ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
      );
  }
}

showProfile(BuildContext context, {String profileId}){
  Navigator.push(context, 
  MaterialPageRoute(
    builder: (context) => 
  Profile(profileId: profileId,)
  ),);
}
