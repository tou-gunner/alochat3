import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

Future<File?> pickSingleImage(BuildContext context) async {
  final List<AssetEntity>? result = await AssetPicker.pickAssets(
    context,
    pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        pathThumbnailSize: ThumbnailSize.square(84),
        gridCount: 3,
        pageSize: 900,
        requestType: RequestType.image,
        textDelegate: EnglishAssetPickerTextDelegate()),
  );
  if (result != null) {
    return result.first.file;
  }
  return null;
}


Future<List<File>?> pickMultiImages(BuildContext context) async {
  final List<AssetEntity>? result = await AssetPicker.pickAssets(
    context,
    pickerConfig: AssetPickerConfig(
        maxAssets: 10,
        pathThumbnailSize: ThumbnailSize.square(84),
        gridCount: 3,
        pageSize: 900,
        requestType: RequestType.image,
        textDelegate: EnglishAssetPickerTextDelegate()),
  );
  if (result != null) {
    var list = <File>[];
    for (var asset in result) {
      var file = await asset.file;
      if (file != null) {
        list.add(file);
      }
    }
    return list;
  }
  return null;
}
