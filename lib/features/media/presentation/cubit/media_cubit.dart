import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/media_repository.dart';
import 'media_state.dart';

class MediaCubit extends Cubit<MediaState> {
  final MediaRepository _repository;

  MediaCubit(this._repository) : super(MediaInitial());

  Future<void> loadCompanyMedia(String companyId) async {
    emit(MediaLoading());
    try {
      final media = await _repository.getCompanyMedia(companyId);
      emit(MediaLoaded(media));
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  Future<void> uploadMedia({
    required File file,
    required String companyId,
    required String userId,
    required String type,
  }) async {
    emit(MediaLoading());
    try {
      final newFile = await _repository.uploadMedia(
        file: file,
        companyId: companyId,
        userId: userId,
        type: type,
      );
      emit(MediaUploadSuccess(newFile));
      // Reload list after upload
      await loadCompanyMedia(companyId);
    } catch (e) {
      emit(MediaError(e.toString()));
    }
  }

  Future<void> deleteMedia(String companyId, String mediaId, String storagePath) async {
    final currentState = state;
    emit(MediaLoading());
    try {
      await _repository.deleteMedia(companyId, mediaId, storagePath);
      await loadCompanyMedia(companyId);
    } catch (e) {
      emit(MediaError(e.toString()));
      if (currentState is MediaLoaded) emit(currentState);
    }
  }
}
