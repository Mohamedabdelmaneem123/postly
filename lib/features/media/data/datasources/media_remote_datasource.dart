import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/media_file.dart';

abstract class MediaRemoteDataSource {
  Future<MediaFile> uploadFile({
    required File file,
    required String companyId,
    required String userId,
    required String type,
  });
  
  Future<void> deleteFile(String companyId, String mediaId, String storagePath);
  Future<List<MediaFile>> fetchCompanyMedia(String companyId);
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<MediaFile> uploadFile({
    required File file,
    required String companyId,
    required String userId,
    required String type,
  }) async {
    final fileId = DateTime.now().millisecondsSinceEpoch.toString();
    final extension = file.path.split('.').last;
    final storagePath = 'companies/$companyId/media/$fileId.$extension';
    
    // 1. Upload to Storage
    final ref = _storage.ref().child(storagePath);
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    // 2. Save metadata to Firestore Subcollection
    final mediaFile = MediaFile(
      id: fileId,
      companyId: companyId,
      userId: userId,
      url: url,
      type: type,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('media_library')
        .doc(fileId)
        .set({
      'id': mediaFile.id,
      'userId': mediaFile.userId,
      'url': mediaFile.url,
      'type': mediaFile.type,
      'createdAt': mediaFile.createdAt.toIso8601String(),
      'storagePath': storagePath,
    });

    return mediaFile;
  }

  @override
  Future<void> deleteFile(String companyId, String mediaId, String storagePath) async {
    await _storage.ref().child(storagePath).delete();
    await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('media_library')
        .doc(mediaId)
        .delete();
  }

  @override
  Future<List<MediaFile>> fetchCompanyMedia(String companyId) async {
    final snapshot = await _firestore
        .collection('companies')
        .doc(companyId)
        .collection('media_library')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MediaFile(
        id: doc.id,
        companyId: companyId,
        userId: data['userId'],
        url: data['url'],
        type: data['type'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    }).toList();
  }
}
