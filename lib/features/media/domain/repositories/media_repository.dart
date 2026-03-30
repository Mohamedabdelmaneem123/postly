import 'dart:io';
import '../entities/media_file.dart';

abstract class MediaRepository {
  Future<MediaFile> uploadMedia({
    required File file,
    required String companyId,
    required String userId,
    required String type,
  });
  
  Future<void> deleteMedia(String companyId, String mediaId, String storagePath);
  Future<List<MediaFile>> getCompanyMedia(String companyId);
}
