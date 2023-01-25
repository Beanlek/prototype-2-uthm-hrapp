// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadImage extends StatefulWidget{
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage>{
  PlatformFile? pickedFile;

  Future uploadFile() async{
    final docHouse = FirebaseFirestore.instance.collection('house2').doc('y2v2JQ1HCvyjqfzQPqJ9');
    final path = ('houseImage/${pickedFile!.name}');
    final file = File(pickedFile!.path!);
    String imagePath;

    Reference ref = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);

    Future<String> getUrlImage() async{
      final snapshot = await uploadTask.whenComplete(() => null);
      final urlImage = snapshot.ref.getDownloadURL();
      return urlImage;
    }

    getUrlImage().then((String url) async{
      imagePath = url;

      final house = House(
        id: docHouse.id,
        houseName: 'Rumah Dah DiEdit',
        url: imagePath
      );
      final json = house.toJson();

      await docHouse.set(json);
    });

  }

  Future selectFile() async{
    final result = await FilePicker.platform.pickFiles();

    setState(() {
      pickedFile = result?.files.first;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Center(
        child: Column(
          children: [
            if(pickedFile != null)
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: Image.file(
                    File(pickedFile!.path!)
                  )
                )
              ),
            
            ElevatedButton(
              child: Text('Select File'),
              onPressed: () {
                // getImage();
                selectFile();
              }
            ),
            ElevatedButton(
              child: Text('Upload File'),
              onPressed: () {
                uploadFile();
              }
            ),
            SizedBox(height: 50),
            // if(urlImage != null)
            //   Text(getUrlImage)
          ],
        )
      ),
    );
  }
}