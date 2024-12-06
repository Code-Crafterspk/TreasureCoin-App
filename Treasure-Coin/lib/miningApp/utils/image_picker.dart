import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(String) onImageUpload;

  const ImagePickerWidget({Key? key, required this.onImageUpload}) : super(key: key);

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _imageUrl;
  File? _localImage;
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();

  // Firebase references
  final auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.ref('user_images');
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfileImage();
  }

  Future<void> _loadUserProfileImage() async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        // Fetch the image URL from the database
        final snapshot = await databaseRef.child(user.uid).get();
        if (snapshot.exists) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          String? imageUrl = data['profilePictureUrl'] as String?;
          if (imageUrl != null) {
            setState(() {
              _imageUrl = imageUrl;
              _localImage = null; // Clear any local image when loading from URL
            });
          }
        }
      } catch (e) {
        _showErrorSnackBar('Failed to load profile image: $e');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _localImage = File(pickedFile.path);
        _imageUrl = null; // Clear the URL when a new image is picked
        _loading = true;
      });
      await _uploadImage(_localImage!);
    } else {
      _showErrorSnackBar('No image selected');
    }
  }

  Future<void> _uploadImage(File image) async {
    final user = auth.currentUser;
    if (user == null) {
      _showErrorSnackBar('User not authenticated');
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final ref = storage.ref('/user_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = ref.putFile(image);

      await uploadTask.whenComplete(() async {
        final newURL = await ref.getDownloadURL();
        await databaseRef.child(user.uid).set({
          'profilePictureUrl': newURL,
        });
        widget.onImageUpload(newURL);
        setState(() {
          _imageUrl = newURL;
          _localImage = null; // Clear the local image after successful upload
        });
        _showSuccessSnackBar('Image uploaded successfully!');
      });
    } catch (e) {
      _showErrorSnackBar('Failed to upload image: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showCustomSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    _showCustomSnackBar(message, Colors.red.shade600);
  }

  void _showSuccessSnackBar(String message) {
    _showCustomSnackBar(message, Colors.green.shade600);
  }

  Future<void> _showImageOptionsDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Display Picture'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showCurrentProfileImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Update Profile Picture'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCurrentProfileImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Current Profile Picture'),
          content: _imageUrl != null
              ? Image.network(_imageUrl!)
              : Text('No profile picture available'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageOptionsDialog, // Show dialog on tap
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _getBackgroundImage(),
            child: _showPlaceholder() ? Icon(Icons.camera_alt, color: Colors.grey.shade800, size: 50) : null,
          ),
        ),
        SizedBox(height: 15),
        if (_loading) CircularProgressIndicator(),
      ],
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (_localImage != null) {
      return FileImage(_localImage!);
    } else if (_imageUrl != null) {
      return NetworkImage(_imageUrl!);
    }
    return null;
  }

  bool _showPlaceholder() {
    return _localImage == null && _imageUrl == null;
  }
}
