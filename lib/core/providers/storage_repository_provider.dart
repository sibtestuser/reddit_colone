import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone2/core/failure.dart';
import 'package:reddit_clone2/core/providers/firebase_providers.dart';
import 'package:reddit_clone2/core/type_defs.dart';

final firebaseStorageProvider = Provider((ref) => StorageRepository(firebaseStrorage: ref.watch(storageProvider)));

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository({required FirebaseStorage firebaseStrorage}) : _firebaseStorage = firebaseStrorage;

  FutureEither<String> storeFile({required String path, required String id, required File? file}) async {
    try {
      //users/banner/id123
      final ref = _firebaseStorage.ref().child(path).child(id);
      UploadTask uploadTask = ref.putFile(file!);
      // uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      //   print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      // }).onError((error) {
      //   print('Error occurred: $error');
      // });
      final snapshot = await uploadTask;
      return right(await snapshot.ref.getDownloadURL());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
