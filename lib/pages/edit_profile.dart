import 'package:GoSocio/models/user.dart';
import 'package:GoSocio/widgets/progress.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'home.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isloading = false;
  User user;
  bool _displayNameValid = true; 
  bool _bioValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async{
    setState(() {
      isloading=true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text= user.bio;
    setState(() {
      isloading = false;
    });
  }

  Column buildDisplayNameField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top:12.0),
          child: Text(
            "Display Name",
            style: TextStyle(
              color: Colors.grey,
          ),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayNameValid ? null : "Display name to short",
          ),
        ),
      ],
    );
  }

  Column buildBioField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top:12.0),
          child: Text(
            "Bio",
            style: TextStyle(
              color: Colors.grey,
          ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _bioValid ?  null: "Bio is too long",
          ),
        ),
      ],
    );
  }

  updateProfileData(){
    setState(() {
      displayNameController.text.length < 3 || displayNameController.text.isEmpty ?
      _displayNameValid = false: _displayNameValid = true;
      bioController.text.trim().length > 100 ? _bioValid = false: _bioValid = true;
    });
    if(_displayNameValid && _bioValid){
      usersRef.doc(widget.currentUserId).update({
        "displayName": displayNameController.text,
        "bio": bioController.text,
      });
      SnackBar snackbar = SnackBar(content: Text("Profile updated"),);
      _scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }
  logout() async{
     await googleSignIn.signOut();
     Navigator.push(context, MaterialPageRoute(
       builder: (context) =>Home(),
       ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color:Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            iconSize: 30,
            color: Colors.green,
            onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
      body: isloading ? circularProgress() :
      ListView(
        children:<Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top:16.0, bottom: 8.0),
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        buildDisplayNameField(),
                        buildBioField(),
                      ],
                    ),
                    ),
                    RaisedButton(
                      onPressed: updateProfileData,
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          onPressed: logout, 
                          icon: Icon(Icons.cancel, color: Colors.red,), 
                          label: Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20.0,
                            ),
                          )),
                          ),
              ],
            ),
          ),
        ]
      ),
    );
  }
}
