import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:welecome_login_out/generated/l10n.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    Key? key,
    required this.onPickImage,
  }) : super(key: key);

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  void _pickImage(ImageSource source) async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: source,
      maxWidth: 150,
      imageQuality: 50,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return Column(
      children: [
        CircleAvatar(
          radius: isDesktop ? 80 : 60,
          backgroundColor: Approved.LightColor,
          foregroundImage:
              _pickedImageFile == null ? null : FileImage(_pickedImageFile!),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt, color: Approved.TextColor),
              label: Text(
                S.of(context).Camera,
                style:  TextStyle(
                  color: Approved.TextColor,
                  fontSize:  isDesktop ? 24 : 16,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.image, color: Approved.TextColor),
              label: Text(
                S.of(context).UploadImage,
                style:  TextStyle(
                  color: Approved.TextColor,
                  fontSize:  isDesktop ? 24 : 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
