import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:torch_mobile/torch_mobile.dart';
import 'package:torch_mobile/model.dart';
import 'package:torch_mobile/enums/dtype.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Model _imageModel, _customModel;
  
  String _imagePrediction;
  List _prediction;
  File _image;

  @override
  void initState() {
    super.initState();
    //load your model
    try {
      TorchMobile.loadModel("assets/models/resnet.pt")
          .then((model) => _imageModel = model);
      TorchMobile.loadModel("assets/models/custom_model.pt")
          .then((model) => _customModel = model);
    } on PlatformException {
      print("only supported for android so far");
    }

  }

  //run an image model
  Future runImageModel() async {
    //pick a random image
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, maxHeight: 224, maxWidth: 224);
    //get prediction
    //labels are 1000 random english words for show purposes
    _imagePrediction = await _imageModel.getImagePrediction(
        image, 224, 224, "assets/labels/labels.csv");
    
    setState(() {
      _image = image;
    });
  }
  
  //run a custom made model with number inputs
  Future runCustomModel() async {
    _prediction = await _customModel
        .getPrediction([1, 2, 3, 4], [1, 2, 2], DType.float32);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pytorch Mobile Example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null ? Text('No image selected.') : Image.file(_image),
            Center(
              child: Visibility(
                visible: _imagePrediction != null,
                child: Text("$_imagePrediction"),
              ),
            ),
            Center(
              child: FlatButton(
                onPressed: runImageModel,
                child: Icon(Icons.add_a_photo),
              ),
            ),
            FlatButton(
              onPressed: runCustomModel,
              color: Colors.blue,
              child: Text(
                "Run custom model",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Visibility(
                visible: _prediction != null,
                child: Text("${_prediction[0]}"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
