import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone2/core/constants/firebase_constants.dart';
import 'package:reddit_clone2/core/enums/enums.dart';
import 'package:reddit_clone2/core/failure.dart';
import 'package:reddit_clone2/core/providers/firebase_providers.dart';
import 'package:reddit_clone2/core/type_defs.dart';
import 'package:reddit_clone2/model/post_model.dart';
import 'package:reddit_clone2/model/user_model.dart';

final userProfileRepositoryProvider = Provider((ref) {
  return UserProfileRepository(firestore: ref.watch(firestoreProvider));
});

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  UserProfileRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  FutureVoid editProfile(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update(user.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getUserPost(String uid) {
    return _post.where('uid', isEqualTo: uid).orderBy('createdAt', descending: true).snapshots().map(
          (e) => e.docs
              .map(
                (sanpshot) => Post.fromMap(sanpshot.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  FutureVoid updateUserKarma(UserModel user) async {
    try {
      return right(_users.doc(user.uid).update({
        'karma': user.karma,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _post => _firestore.collection(FirebaseConstants.postsCollection);
}
