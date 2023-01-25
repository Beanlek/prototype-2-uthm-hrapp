// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'upload_image.dart';
import 'package:auto_size_text/auto_size_text.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    final houseNameController = TextEditingController();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: houseNameController
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                final houseName = houseNameController.text;

                createHouse(houseName);
              },
              
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              children: [
                Text('Upload Image'),
                IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder:
                        (context) => UploadImage()
                      )
                    );
                  }
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Expanded(
              child: StreamBuilder<List<House>>(
                stream: readHouse(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong! ${snapshot.error}');
                  }else if (snapshot.hasData) {
                    final houses = snapshot.data!;
            
                    return ListView(
                      children: houses.map(buildHouse).toList(),
                    );
                  }else {
                    return Center(child: CircularProgressIndicator(),);
                  }
                }
              ),
            )
          ],
        )
      ),
    );
  }
}

Widget buildHouse(House house) => ListTile(
  title: Text(house.houseName),
  subtitle: Row(
    children: [
      SizedBox(
        width: 100,
        child: Image.network(house.url)
      ),
      SizedBox(
        width: 180,
        child: AutoSizeText(house.id)
      ),
      Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: ElevatedButton(
              child: Icon(Icons.edit),
              onPressed: () {
                final docHouse = FirebaseFirestore.instance
                  .collection('house2')
                  .doc(house.id);

                docHouse.update({
                  'houseName': 'ni ahhh!',
                  'imageUrl': 'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/5442afd0-cca5-476e-abe9-eec312a4e8e3/dblk1e1-275264b8-34fe-464d-b502-2ca11b15036d.jpg/v1/fill/w_900,h_1162,q_75,strp/mii_miyashita_by_aoiogataartist_dblk1e1-fullview.jpg?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsIm9iaiI6W1t7ImhlaWdodCI6Ijw9MTE2MiIsInBhdGgiOiJcL2ZcLzU0NDJhZmQwLWNjYTUtNDc2ZS1hYmU5LWVlYzMxMmE0ZThlM1wvZGJsazFlMS0yNzUyNjRiOC0zNGZlLTQ2NGQtYjUwMi0yY2ExMWIxNTAzNmQuanBnIiwid2lkdGgiOiI8PTkwMCJ9XV0sImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl19.zpk1n7p2lUvVFSkkyAZlrCUkpCJeHgOVnTCT3HrjtTk'
                });
              }
            ),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: ElevatedButton(
              child: Icon(Icons.delete),
              onPressed: () {
                final docHouse = FirebaseFirestore.instance
                  .collection('house2')
                  .doc(house.id);

                docHouse.delete();
              },
            ),
          )
        ],
      )
      // Text(house.url),
    ],
  ),
);

Stream<List<House>> readHouse() => FirebaseFirestore.instance
  .collection('house2')
  .snapshots()
  .map((snapshot) => 
    snapshot.docs.map((doc) => House.fromJson(doc.data())).toList()
  );

Future createHouse(String houseName) async{
  final docHouse = FirebaseFirestore.instance.collection('house2').doc();

  final house = House(
    id: docHouse.id,
    houseName: houseName,
    url: 'url_empty'
  );
  final json = house.toJson();

  await docHouse.set(json);
}

class House {
  String id;
  String houseName;
  String url;

  House({
    this.id = '',
    required this.houseName,
    required this.url
  });

  Map<String, dynamic> toJson() => {
    'houseId': id, 
    'houseName': houseName,
    'imageUrl': url
  };

  static House fromJson(Map<String, dynamic> json) => House(
    id: json['houseId'],
    houseName: json['houseName'],
    url: json['imageUrl']
  );
}
