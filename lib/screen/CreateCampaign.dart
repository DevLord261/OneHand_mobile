import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Campaign extends StatefulWidget {
  const Campaign({super.key});

  @override
  State<StatefulWidget> createState() => _campaign();
}

class _campaign extends State<Campaign> {
  File? _image; // To store selected image

  final TextEditingController _textController =
      TextEditingController(); // Controller for TextField

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path); // Store selected image
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create campaign")),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage, // Trigger image picker on tap
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  image:
                      _image == null
                          ? null
                          : DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                ),
                child:
                    _image == null
                        ? Center(
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 50,
                          ),
                        )
                        : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {}, // Call the confirm function when pressed
                child: const Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
