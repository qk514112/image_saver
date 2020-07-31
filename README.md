# all code is from https://github.com/CarnegieTechnologies/gallery_saver
# image_saver for Flutter ios

Saves images and videos from temporary file to album. 
Both images and videos will be visible in iOS Photos.

## Installation

First, add `image_saver` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### iOS

Add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

* `NSPhotoLibraryUsageDescription` - describe why your app needs permission for the photo library. This is called _Privacy - Photo Library Usage Description_ in the visual editor.

### Example

``` dart
import 'package:flutter/material.dart';
import 'package:image_saver/image_saver.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save image to gallery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Save image to gallery"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 15),
              child: RaisedButton(
                onPressed: _saveGif,
                child: Text("Save Gif to gallery"),
              ),
              width: 200,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }

  _saveGif() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.gif";
    String fileUrl = "https://hyjdoc.oss-cn-beijing.aliyuncs.com/hyj-doc-flutter-demo-run.gif";
    await Dio().download(fileUrl, savePath);
    final result = await ImageSaver.saveImage(savePath);
    print(result);
  }
}
```
