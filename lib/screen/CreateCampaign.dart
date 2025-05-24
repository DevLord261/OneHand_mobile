import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterproject/services/CampaignServices.dart';
import 'package:image_picker/image_picker.dart';

class Campaign extends StatefulWidget {
  const Campaign({super.key});

  @override
  State<StatefulWidget> createState() => _campaign();
}

class _campaign extends State<Campaign> {
  File? _image; // To store selected image

  // Function to pick an image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _image = File(image.path); // Store selected image
      });
    }
  }

  final TextEditingController Title = TextEditingController();
  final TextEditingController Description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              controller: Title,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: Description,
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
                onPressed: () async {
                  if (_image != null) {
                    Uint8List image = await _image!.readAsBytes();
                    var result = await Campaignservices().CreateCampaign(
                      Title.text,
                      Description.text,
                      image,
                      Category.Medical,
                      1000,
                    );
                    if (result > 0) {
                      print("succesfull");
                    } else {
                      print("something went wrong");
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                ), // Call the confirm function when pressed
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
