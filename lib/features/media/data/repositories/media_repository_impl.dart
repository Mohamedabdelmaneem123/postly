import 'dart:io';
import '../../domain/entities/media_file.dart';
import '../../domain/repositories/media_repository.dart';
import '../datasources/media_remote_datasource.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource _remoteDataSource;

  MediaRepositoryImpl(this._remoteDataSource);

  @override
  Future<MediaFile> uploadMedia({
    required File file,
    required String companyId,
    required String userId,
    required String type,
  }) {
    return _remoteDataSource.uploadFile(
      file: file,
      companyId: companyId,
      userId: userId,
      type: type,
    );
  }

  @override
  Future<void> deleteMedia(String companyId, String mediaId, String storagePath) {
    return _remoteDataSource.deleteFile(companyId, mediaId, storagePath);
  }

  @override
  Future<List<MediaFile>> getCompanyMedia(String companyId) {
    return _remoteDataSource.fetchCompanyMedia(companyId);
  }
}
