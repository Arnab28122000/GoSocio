import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
// import 'package:location_platform_interface/location_platform_interface.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:GoSocio/models/user.dart';
import 'package:GoSocio/widgets/progress.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:GoSocio/pages/home.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> 
//with AutomaticKeepAliveClientMixin<Upload>
{
  // Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;

  // Position _currentPosition;
  // String _currentAddress;
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  File _image;
  bool isUploading = false;
  String postId = Uuid().v4();



  handleTakePhoto() async{
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera,
     maxHeight: 675, 
     maxWidth: 960);
     setState(() {
       _image = File(pickedFile.path);
     });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
       _image = File(pickedFile.path);
     });
  }
  selectImage(parentContext){
    return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(
          title: Text("Create Post"),
          children: <Widget>[
            SimpleDialogOption(
              child: Text("Photo with Camera"),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              child: Text("Image from Gallery"),
              onPressed: handleChooseFromGallery,
            ),
            SimpleDialogOption(
              child: Text("Cancel"),
              onPressed: ()=> Navigator.pop(context),
            ),
          ],
        );
      }
      );
  }

  Container buildSplashScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset('assets/images/upload.svg', height:260.0),
          Padding(
            padding: EdgeInsets.only(top:20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text("Upload Image", style: TextStyle(
                color: Colors.white,
                fontSize: 22.0,
              ),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
              ),
            ),
        ],
      ),
    );
  }

  clearImage(){
    setState(() {
      _image = null;
    });
  }

  compressImage() async{
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsStringSync(Im.encodeJpg(imageFile, quality: 85).toString());
    setState(() {
      _image = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async{
    StorageUploadTask uploadTask = storageRef.child("post_$postId.jpg")
    .putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore({ String mediaUrl, String location, String description}){
    postsRef.doc(widget.currentUser.id)
    .collection("userPosts").doc(postId)
    .set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username":widget.currentUser.username,
      "mediaUrl":mediaUrl,
      "description":description,
      "location": location,
      "timestamp": timestamp,
      "likes":{},
    });
  }

  handleSubmit() async{
    setState(() {
      isUploading = true;
    });
    //await compressImage();
    String mediaUrl = await uploadImage(_image);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );
    captionController.clear();
    locationController.clear();
    setState(() {
      _image = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), 
          color: Colors.black,
          onPressed: clearImage,
          ),
          title: Text("Caption Post",
          style: TextStyle(color:Colors.black),
          ),
          actions: [
            FlatButton(
              onPressed: isUploading ? null : () => handleSubmit(), 
              child: Text(
                "Post", 
                style: TextStyle(color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
              ),
              ),
          ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(_image),
                      ),
                  ),
                ),
              ),
          ),
          ),
          Padding(
            padding: EdgeInsets.only(top:10.0),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ) ,
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.pin_drop, color: Colors.orange),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              onPressed: getUserLocation, 
              icon: Icon(Icons.my_location, color: Colors.white,), 
              label: Text("Use Current Location", style: TextStyle(
                color: Colors.white,
              ),),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              color: Colors.blue,
              ),
          ),
          ],
        ),
    );
  }

  getUserLocation() async{
    // Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    // List<Placemark> placemarks = await Geolocator().placemarkFromCoordinates(position.latitude,position.longitude);
    // // StreamSubscription<Position> positionStream = getPositionStream(locationOptions).listen(
    // // (Position position) {
    // //     print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
    // // });
    // Placemark placemark = placemarks[0];
    // String completeAddress = ''

    
  }
  // _getCurrentLocation() {
  //   geolocator
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //       .then((Position position) {
  //     setState(() {
  //       _currentPosition = position;
  //     });

  //     _getAddressFromLatLng();
  //   }).catchError((e) {
  //     print(e);
  //   });
  // }

  // _getAddressFromLatLng() async {
  //   try {
  //     List p = await geolocator.placemarkFromCoordinates(
  //         _currentPosition.latitude, _currentPosition.longitude);

  //     final place = p[0];

  //     setState(() {
  //       _currentAddress =
  //           "${place.locality}, ${place.postalCode}, ${place.country}";
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  
  @override
  Widget build(BuildContext context) {
    return _image == null ? buildSplashScreen() : buildUploadForm();
  }
}
