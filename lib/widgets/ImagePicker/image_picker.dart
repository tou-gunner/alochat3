//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:alochat/Configs/Enum.dart';
import 'package:alochat/Configs/app_constants.dart';
import 'package:alochat/Screens/status/components/VideoPicker/VideoPicker.dart';
import 'package:alochat/Services/Providers/Observer.dart';
import 'package:alochat/Services/localization/language_constants.dart';
import 'package:alochat/Utils/open_settings.dart';
import 'package:alochat/Utils/utils.dart';
import 'package:alochat/widgets/MultiDocumentPicker/multiDocumentPicker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class SingleImagePicker extends StatefulWidget {
  SingleImagePicker(
      {Key? key,
      required this.title,
      required this.callback,
      this.profile = false})
      : super(key: key);

  final String title;
  final Function callback;
  final bool profile;

  @override
  _SingleImagePickerState createState() => new _SingleImagePickerState();
}

class _SingleImagePickerState extends State<SingleImagePicker> {
  File? _imageFile;
  bool isLoading = false;
  String? error;
  @override
  void initState() {
    super.initState();
  }

  void captureImage(ImageSource captureMode) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    error = null;
    try {
      ImagePickerPlus picker = ImagePickerPlus(context);
      var pickedImage = await (picker.pickImage(source: captureMode));
      if (pickedImage != null) {
        _imageFile = File(pickedImage.selectedFiles.first.selectedFile.path);
        setState(() {});
        if (_imageFile!.lengthSync() / 1000000 >
            observer.maxFileSizeAllowedInMB) {
          error =
              '${getTranslated(this.context, 'maxfilesize')} ${observer.maxFileSizeAllowedInMB}MB\n\n${getTranslated(this.context, 'selectedfilesize')} ${(_imageFile!.lengthSync() / 1000000).round()}MB';

          setState(() {
            _imageFile = null;
          });
        } else {
          setState(() {
            _imageFile = File(_imageFile!.path);
          });
        }
      }
    } catch (e) {}
  }

  Future<String> getFileData(File image, {int? timestamp, int? totalFiles}) async {
    // final observer = Provider.of<Observer>(this.context, listen: false);

    if (mounted) {
      setState(() {
        _imageFile = image;
      });
    }

    return Future.value('');

    // return observer.isPercentProgressShowWhileUploading
    //     ? (totalFiles == null
    //     ? uploadFileWithProgressIndicator(
    //   false,
    //   timestamp: timestamp,
    // )
    //     : totalFiles == 1
    //     ? uploadFileWithProgressIndicator(
    //   false,
    //   timestamp: timestamp,
    // )
    //     : uploadFile(false, timestamp: timestamp))
    //     : uploadFile(false, timestamp: timestamp);
  }

  void captureFile() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiDocumentPicker(
          title: getTranslated(this.context, 'takeimage'),
          callback: getFileData,
          writeMessage: (fileUrl, messageTime) async {

          },
        )
      )
    );
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      return new Image.file(_imageFile!);
    } else {
      return new Text(getTranslated(context, 'takeimage'),
          style: new TextStyle(
            fontSize: 18.0,
            color: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Fiberchat.getNTPWrappedWidget(WillPopScope(
      child: Scaffold(
        backgroundColor:
            DESIGN_TYPE == Themetype.whatsapp ? fiberchatBlack : fiberchatWhite,
        appBar: new AppBar(
            elevation: DESIGN_TYPE == Themetype.messenger ? 0.4 : 1,
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.keyboard_arrow_left,
                size: 30,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack,
              ),
            ),
            title: new Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack,
              ),
            ),
            backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatBlack
                : fiberchatWhite,
            actions: _imageFile != null
                ? <Widget>[
                    IconButton(
                        icon: Icon(
                          Icons.check,
                          color: DESIGN_TYPE == Themetype.whatsapp
                              ? fiberchatWhite
                              : fiberchatBlack,
                        ),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          widget.callback(_imageFile).then((imageUrl) {
                            Navigator.pop(context, imageUrl);
                          });
                        }),
                    SizedBox(
                      width: 8.0,
                    )
                  ]
                : []),
        body: Stack(children: [
          new Column(children: [
            new Expanded(
                child: new Center(
                    child: error != null
                        ? fileSizeErrorWidget(error!)
                        : _buildImage())),
            _buildButtons()
          ]),
          Positioned(
            child: isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(fiberchatBlue)),
                    ),
                    color: DESIGN_TYPE == Themetype.whatsapp
                        ? fiberchatBlack.withOpacity(0.8)
                        : fiberchatWhite.withOpacity(0.8),
                  )
                : Container(),
          )
        ]),
      ),
      onWillPop: () => Future.value(!isLoading),
    ));
  }

  Widget _buildButtons() {
    return new ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // _buildActionButton(new Key('storage'), Icons.file_copy, () {
              //   Fiberchat.checkAndRequestPermission(Platform.isIOS
              //       ? Permission.mediaLibrary
              //       : Permission.storage)
              //       .then((res) {
              //     if (res) {
              //       captureFile();
              //     } else {
              //       Fiberchat.showRationale(getTranslated(context, 'pgi'));
              //       Navigator.pushReplacement(
              //           context,
              //           new MaterialPageRoute(
              //               builder: (context) => OpenSettings()));
              //     }
              //   });
              // }),
              _buildActionButton(new Key('retake'), Icons.photo_library, () {
                Fiberchat.checkAndRequestPermission(Permission.photos)
                    .then((res) {
                  if (res) {
                    captureImage(ImageSource.gallery);
                  } else {
                    Fiberchat.showRationale(getTranslated(context, 'pgi'));
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings()));
                  }
                });
              }),
              _buildActionButton(new Key('upload'), Icons.photo_camera, () {
                Fiberchat.checkAndRequestPermission(Permission.camera)
                    .then((res) {
                  if (res) {
                    captureImage(ImageSource.camera);
                  } else {
                    getTranslated(context, 'pci');
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => OpenSettings()));
                  }
                });
              }),
            ]));
  }

  Widget _buildActionButton(Key key, IconData icon, Function onPressed) {
    return new Expanded(
      // ignore: deprecated_member_use
      child: new MaterialButton(
          key: key,
          child: Icon(icon, size: 30.0),
          shape: new RoundedRectangleBorder(),
          color: DESIGN_TYPE == Themetype.whatsapp
              ? fiberchatDeepGreen
              : fiberchatgreen,
          textColor: fiberchatWhite,
          onPressed: onPressed as void Function()?),
    );
  }
}
