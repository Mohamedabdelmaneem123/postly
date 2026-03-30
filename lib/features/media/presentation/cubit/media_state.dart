import 'package:equatable/equatable.dart';
import '../../domain/entities/media_file.dart';

abstract class MediaState extends Equatable {
  const MediaState();
  @override
  List<Object?> get props => [];
}

class MediaInitial extends MediaState {}

class MediaLoading extends MediaState {}

class MediaLoaded extends MediaState {
  final List<MediaFile> mediaFiles;
  const MediaLoaded(this.mediaFiles);
  @override
  List<Object?> get props => [mediaFiles];
}

class MediaError extends MediaState {
  final String message;
  const MediaError(this.message);
  @override
  List<Object?> get props => [message];
}

class MediaUploadSuccess extends MediaState {
  final MediaFile file;
  const MediaUploadSuccess(this.file);
  @override
  List<Object?> get props => [file];
}
