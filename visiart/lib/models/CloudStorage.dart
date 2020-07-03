import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CloudStorageService {
  Future<CloudStorageResult> uploadImage({
    @required File imageToUpload,
    @required String idUser,
  }) async {

    var imageFileName = "IMG_" + idUser + DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference = FirebaseStorage().ref().child(imageFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(imageToUpload);
    StorageTaskSnapshot snapshot = await storageUploadTask.onComplete;

    var downloadUrl = await snapshot.ref.getDownloadURL();

    if(storageUploadTask.isComplete) {
      var url = downloadUrl.toString();
      return CloudStorageResult(imageUrl: url, imageFileName: imageFileName);
    }

    return null;
  }
}

class CloudStorageResult {
  final String imageUrl;
  final String imageFileName;
  CloudStorageResult({this.imageUrl, this.imageFileName});
}