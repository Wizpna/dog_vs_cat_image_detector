import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dog vs Cat Image Detector',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _loading = true;
  File _image;
  List _output;
  final _picker = ImagePicker();

  @override
  void initState() {
    loadModel().then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path.toString(),
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
        asynch: true);

    setState(() {
      _output = output;
      _loading = false;
    });
  }

  Future loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  pickCameraImage() async {
    var image = await _picker.getImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image);
  }

  pickGalleryImage() async {
    var image = await _picker.getImage(source: ImageSource.gallery);
    print('----------- ${image.path}');
    if (image == null) {
      return null;
    }

    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff101010),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 85),
            Text(
              'Image recognition app',
              style: TextStyle(color: Color(0xffeeda28), fontSize: 28),
            ),
            SizedBox(
              height: 6,
            ),
            Text(
              'Detect Dogs and Cats',
              style: TextStyle(
                  color: Color(0xffe99600),
                  fontWeight: FontWeight.w500,
                  fontSize: 24),
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Center(
                          child: Column(
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white,
                            size: 150,
                          ),
                          Text(
                            'No Image selected',
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          ),
                        ],
                      )),
                    )
                  : Container(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            child: Image.file(_image),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          _output != null
                              ? Text(
                                  'Name of image detected is ${_output[0]['label']}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )
                              : Container(),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => pickCameraImage(),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 120,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Color(0xffe99600),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Capture an Image',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => pickGalleryImage(),
                    child: Container(
                      width: MediaQuery.of(context).size.width - 120,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                        color: Color(0xffe99600),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Select Image from Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
