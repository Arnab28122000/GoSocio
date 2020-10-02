import 'package:GoSocio/pages/edit_profile.dart';
import 'package:GoSocio/widgets/header.dart';
import 'package:GoSocio/widgets/post.dart';
import 'package:GoSocio/widgets/post_tile.dart';
import 'package:GoSocio/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:GoSocio/pages/home.dart' as home;
import 'package:GoSocio/models/user.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = home.currentUser?.id;
  String postOrientation = "grid";
  bool isLoading = false;
  bool isFollowing = false;
  int followerCount=0;
  int followingCount=0;
  int postCount =0;
  List<Post> posts = [];

  @override
  void initState(){
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  checkIfFollowing() async{
    DocumentSnapshot doc =await home.followersRef
    .doc(widget.profileId)
    .collection('userFollowers')
    .doc(currentUserId)
    .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async{
    QuerySnapshot snapshot =await home.followersRef
    .doc(widget.profileId)
    .collection('userFollowers')
    .get();
    setState(() {
      followerCount=snapshot.docs.length;
    });
  }

  getFollowing() async{
    QuerySnapshot snapshot =await home.followingRef
    .doc(widget.profileId)
    .collection('userFollowing')
    .get();
    setState(() {
      followingCount=snapshot.docs.length;
    });
  }

  getProfilePosts() async{
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await home.postsRef.doc(widget.profileId)
    .collection('userPosts')
    .orderBy('timestamp', descending: true)
    .get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });

  }

  editProfile(){
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => EditProfile(currentUserId: currentUserId)
    ));
  }

  Container buildButton({String text, Function function}){
    return Container(
      padding: EdgeInsets.only(top:2.0),
      child:FlatButton(
        onPressed: function, 
        child: Container(
          width: 237.0,
          height: 27.0,
          child: Text(
            text,
            style: TextStyle(
              color:isFollowing ? Colors.black: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          decoration: BoxDecoration(
            color: isFollowing? Colors.white : Colors.blue,
            border: Border.all(
              color:isFollowing? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          alignment: Alignment.center,
        ),
        ) ,
    );
  }

  buildProfileButton(){
    // viewing your own profile we should show => the Edit Profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner){
      return buildButton(
        text: "Edit Profile",
        function: editProfile
      );
    }else if(isFollowing){
      return buildButton(
        text: "Unfollow",
        function: handleUnfollowUser
      );
    }else if(!isFollowing){
      return buildButton(
        text: "Follow",
        function: handleFollowUser
      );
    }
  }

  handleUnfollowUser(){
    setState(() {
      isFollowing = false;
    });
    //remove follower
    home.followersRef
    .doc(widget.profileId)
    .collection('userFollowers')
    .doc(currentUserId)
    .get().then((doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
    //remove following
    home.followingRef
    .doc(currentUserId)
    .collection('userFollowing')
    .doc(widget.profileId)
    .get().then((doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
    // delete activity feed item for them
    home.activityFeedRef
    .doc(widget.profileId)
    .collection('feedItems')
    .doc(currentUserId)
    .get().then((doc) {
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }

  handleFollowUser(){
    setState(() {
      isFollowing = true;
    });
    //making auth user follower of that user (update their followers collection)
    home.followersRef
    .doc(widget.profileId)
    .collection('userFollowers')
    .doc(currentUserId)
    .set({});
    //putting that user on our following collection (updating our following collection)
    home.followingRef
    .doc(currentUserId)
    .collection('userFollowing')
    .doc(widget.profileId)
    .set({});
    // add activity feed item for that user to notify about new follower
    home.activityFeedRef
    .doc(widget.profileId)
    .collection('feedItems')
    .doc(currentUserId)
    .set({
      "type":"follow",
      "ownerId":widget.profileId,
      "username":home.currentUser.username,
      "userId":currentUserId,
      "userProfileImg":home.currentUser.photoUrl,
      "timestamp": home.timestamp,
    });
  }

  

  buildCountColumn(String label, int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top:4.0),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          ),
      ],
    );
  }

  buildProfileHeader(){
    return FutureBuilder(
      future: home.usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex:1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                           buildCountColumn("posts", postCount), 
                           buildCountColumn("followers", followerCount),
                           buildCountColumn("following", followingCount),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        ),
                      ],
                    ),
                    ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top:12.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top:4.0),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top:2.0),
                child: Text(
                  user.bio,
                  // style: TextStyle(
                  //   fontWeight: FontWeight.bold,
                  // ),
                ),
              ),
            ],
            ),
          padding: EdgeInsets.all(16.0),
          );
      },
      );
  }

  buildProfilePosts(){
    if(isLoading){
      return circularProgress();
    }else if(posts.isEmpty){
      return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/no_content.svg', height:260.0),
          Padding(
            padding: EdgeInsets.only(top:20.0),
            child:  Text("No Posts", style: TextStyle(
                color: Colors.redAccent,
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
        ],
      ),
    );
    }
    else if(postOrientation == "grid"){
      List<GridTile> gridTiles = [];
    posts.forEach((post) {
      gridTiles.add(
        GridTile(
          child: PostTile(post),
          ),
          );
    });
    return GridView.count(
      crossAxisCount:3 ,
      childAspectRatio: 1.0,
      mainAxisSpacing: 1.5,
      crossAxisSpacing: 1.5,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: gridTiles,
      );
    }else if(postOrientation == "list"){
      return Column(
      children: posts,
    );
    }
  }

  setPostOrientation(String postOrientation){
    setState(() {
      this.postOrientation=postOrientation;
    });
  }

  buildTogglePostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid"? Theme.of(context).primaryColor: Colors.grey, 
          onPressed: () => setPostOrientation("grid"),
          ),
          IconButton(
          icon: Icon(Icons.list), 
          onPressed: () => setPostOrientation("list"),
          color: postOrientation == "list"? Theme.of(context).primaryColor: Colors.grey, 
          ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOrientation(),
          Divider(
            height: 0.0,
          ),
          buildProfilePosts(),
        ],
      ),
    );
  }
}
