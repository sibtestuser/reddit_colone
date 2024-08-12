import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone2/core/constants/firebase_constants.dart';
import 'package:reddit_clone2/core/failure.dart';
import 'package:reddit_clone2/core/providers/firebase_providers.dart';
import 'package:reddit_clone2/core/type_defs.dart';
import 'package:reddit_clone2/model/community_model.dart';
import 'package:reddit_clone2/model/post_model.dart';

final communityRepositoryProvider = Provider((ref) => CommunityRepository(firestore: ref.watch(firestoreProvider)));

class CommunityRepository {
  final FirebaseFirestore _firestore;

  CommunityRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw 'Community with the same name already exists!';
      }
      return right(await _communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunity(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map((event) {
      List<Community> communitis = [];
      for (var doc in event.docs) {
        communitis.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      //print('uid is ' + communitis.toString());
      return communitis;
    });
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId]),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<Community> getCommunityByName(String name) {
    return _communities.doc(name).snapshots().map((event) => Community.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid editCommunity(Community community) async {
    try {
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) + String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .snapshots()
        .map((event) {
      List<Community> communnities = [];
      for (var community in event.docs) {
        communnities.add(Community.fromMap(community.data() as Map<String, dynamic>));
      }
      return communnities;
    });
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(_communities.doc(communityName).update({
        'mods': uids,
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _posts.where('communityName', isEqualTo: name).orderBy('createdAt', descending: true).snapshots().map(
          (e) => e.docs
              .map(
                (post) => Post.fromMap(post.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  CollectionReference get _communities => _firestore.collection(FirebaseConstants.communitiesCollection);
  CollectionReference get _posts => _firestore.collection(FirebaseConstants.postsCollection);
}
