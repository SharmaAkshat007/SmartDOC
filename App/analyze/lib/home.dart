import 'dart:io';
import 'package:analyze/services/imagePicker.dart';
import 'package:analyze/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  PickImage _imagePicker = PickImage();
  Map<dynamic, dynamic> _output;
  bool _isPredicted;

  @override
  void initState() {
    super.initState();
    loadModel().then((val) {
      setState(() {});
    });
    _isPredicted = false;
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  void imagePickerHandler() async {
    setState(() {
      _isPredicted = false;
    });
    try {
      File image = await _imagePicker.captureImage();

      setState(() {
        _image = image;
      });
    } catch (err) {
      print(err);
    }
  }

  loadModel() async {
    try {
      await Tflite.loadModel(
          model: 'assets/model.tflite', labels: 'assets/labels.txt');
    } catch (err) {
      print(err);
    }
  }

  classifyImage(File image) async {
    try {
      var output = await Tflite.runModelOnImage(
          path: image.path,
          numResults: 7,
          threshold: 0.5,
          imageMean: 0,
          imageStd: 255.0);

      setState(() {
        this._output = output[0];
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _deviceHeight = MediaQuery.of(context).size.height;
    final _deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.blue,
          elevation: 1.0,
        ),
        body: Container(
          child: _image != null
              ? SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: _deviceHeight * 0.05,
                      ),
                      Center(
                        child: Image.file(
                          _image,
                          height: _deviceHeight * 0.5,
                        ),
                      ),
                      SizedBox(
                        height: _deviceHeight * 0.04,
                      ),
                      Container(
                          child: _isPredicted == true && _output != null
                              ? Column(
                                  children: [
                                    Text(
                                      'Screenshot belongs to ' +
                                          _output['label'] +
                                          ' class',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      'Confidence level ' +
                                          (_output['confidence'] * 100)
                                              .toString() +
                                          ' %',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue),
                                    ),
                                  ],
                                )
                              : Text('')),
                      SizedBox(
                        height: _deviceHeight * 0.04,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Button(
                            text: "Next Screenshot",
                            onPressed: imagePickerHandler,
                          ),
                          Button(
                            text: "Predict",
                            onPressed: () {
                              if (_image != null) {
                                classifyImage(this._image);
                                setState(() {
                                  this._isPredicted = true;
                                });
                              }
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                )
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    width: _deviceWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          splashColor: Colors.blue[100],
                          icon: Icon(
                            Icons.add,
                            size: 28,
                          ),
                          onPressed: imagePickerHandler,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'Add Screenshot',
                          style: TextStyle(fontSize: 20, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ]),
        ),
      ),
    );
  }
}
