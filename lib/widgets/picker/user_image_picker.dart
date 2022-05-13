import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImg) imageFn;
  const UserImagePicker(this.imageFn);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  final picker = ImagePicker();
  File? _pickedImage;
  void _fromGallery() async {
    //final picker = ImagePicker();
    // ignore: deprecated_member_use
    final pickedImage = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      if (pickedImageFile != null) {
        _pickedImage = pickedImageFile;
      }
    });
    widget.imageFn(pickedImageFile);
  }

  void _fromCamera() async {
    //final picker = ImagePicker();
    // ignore: deprecated_member_use
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      if (pickedImageFile != null) {
        _pickedImage = pickedImageFile;
      }
    });
    widget.imageFn(pickedImageFile);
  }

  void _remove() async {
    //final picker = ImagePicker();
    // ignore: deprecated_member_use
    setState(() {
      _pickedImage = null;
    });
  }

  /*void _pickImage() async {
    final pickedImage = await picker.getImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    final pickedImageFile = File(pickedImage!.path);
    setState(() {
      if (pickedImageFile != null) {
        _pickedImage = pickedImageFile;
      }
    });
    widget.imageFn(pickedImageFile);
  }*/

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleAvatar(
          backgroundColor: Colors.grey,
          backgroundImage:
              _pickedImage == null ? null : FileImage(_pickedImage!),
          radius: 40,
        ),
        FlatButton.icon(
          textColor: Theme.of(context).primaryColor,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Wrap(
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          _fromCamera();
                        },
                        //_fromCamera,
                        leading: Icon(Icons.camera),
                        title: Text('Take a photo'),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          _fromGallery();
                        },
                        leading: Icon(Icons.image),
                        title: Text('Choose from gallery'),
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          _remove();
                        },
                        leading: Icon(Icons.delete_rounded),
                        title: Text('Remove photo'),
                      ),
                    ],
                  );
                });
          },
          icon: Icon(Icons.image),
          label: Text("Add Image"),
        ),
      ],
    );
  }
}
