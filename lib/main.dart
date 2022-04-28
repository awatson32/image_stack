import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Image Stack Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  File? driversLicense;
  File? insuranceCard;
  String? base;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
            child: Stack(alignment: Alignment.topCenter, children: [
              Positioned(
                top: 50,
                child: insuranceCard == null
                    ? _buildDefaultCard('Insurance Card')
                    : _imageCard('insurance-card', 'Insurance Card',
                        _buildInsuranceCard()),
              ),
              Positioned(
                  top: 120,
                  child: driversLicense == null
                      ? _buildDefaultCard('Driver\'s License')
                      : _imageCard('drivers-license', 'Driver\'s License',
                          _buildDriversLicense())),
            ]),
          )),
    );
  }

  Widget _buildDefaultCard(String title) {
    return Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue.shade900, width: 1),
            borderRadius: BorderRadius.circular(20)),
        width: 330,
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: ListTile(
            onTap: () {
              _buildImageSourceActionSheet(context, title);
            },
            iconColor: Colors.blue.shade900,
            textColor: Colors.blue.shade900,
            title: Text(title),
            minLeadingWidth: 6,
            trailing: const Icon(Icons.add),
          ),
        ));
  }

  Widget _imageCard(String tag, String title, Widget child) {
    return GestureDetector(
      onTap: () => showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              contentPadding: EdgeInsets.zero,
              insetPadding: EdgeInsets.zero,
              elevation: 0,
              backgroundColor: Colors.transparent,
              children: [
                Hero(tag: tag, child: child),
                Center(
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue.shade900)),
                    child: Text('Edit',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1!
                            .copyWith(color: Colors.white, fontSize: 17)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _buildImageSourceActionSheet(context, title);
                    },
                  ),
                )
              ],
            );
          }),
      child: child,
    );
  }

  Widget _buildInsuranceCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: Image.file(
        File(insuranceCard!.path),
        width: MediaQuery.of(context).size.width - 20,
        height: 250,
      ),
    );
  }

  Widget _buildDriversLicense() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      child: Image.file(
        File(driversLicense!.path),
        width: MediaQuery.of(context).size.width - 20,
        height: 250,
      ),
    );
  }

  void _selectImage(source, title) async {
    final XFile? _image =
        await _picker.pickImage(source: source, maxHeight: 250, maxWidth: 300);
    if (_image != null) {
      setState(() {
        if (title == 'Insurance Card') {
          insuranceCard = File(_image.path);
        } else {
          driversLicense = File(_image.path);
        }
        final List<int> bytes = driversLicense!.readAsBytesSync();
        base = base64Encode(bytes);
      });
    }
  }

  void _buildImageSourceActionSheet(BuildContext context, String title) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
                title: Text(title),
                cancelButton: CupertinoActionSheetAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                        _selectImage(ImageSource.camera, title);
                      },
                      child: const Text('Camera')),
                  CupertinoActionSheetAction(
                      onPressed: () {
                        Navigator.pop(context);
                        _selectImage(ImageSource.gallery, title);
                      },
                      child: const Text('Gallery'))
                ],
              ));
    } else {
      showModalBottomSheet(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15))),
          context: context,
          builder: (context) => Wrap(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      _selectImage(ImageSource.camera, title);
                    },
                    contentPadding: const EdgeInsets.only(top: 10, left: 16),
                    leading: const Icon(Icons.camera),
                    title: const Text('Camera'),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: .75,
                  ),
                  ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        _selectImage(ImageSource.gallery, title);
                      },
                      contentPadding:
                          const EdgeInsets.only(left: 16, bottom: 10),
                      leading: const Icon(Icons.collections),
                      title: const Text('Gallery')),
                  ListTile(
                      onTap: () => Navigator.pop(context),
                      tileColor: Colors.grey,
                      title: const Text('Cancel', textAlign: TextAlign.center)),
                ],
              ));
    }
  }
}
