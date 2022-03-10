part of 'image_picker_cubit.dart';

abstract class ImagePickerState extends Equatable {
  const ImagePickerState();

  @override
  List<Object> get props => [];
}

class ImagePickerInitial extends ImagePickerState {}

class ImagePickerLoading extends ImagePickerState {}

class ImagePickerDone extends ImagePickerState {
  final XFile imageFile;
  const ImagePickerDone({
    required this.imageFile,
  });

  @override
  List<Object> get props => [imageFile];
}

class ImagePickerError extends ImagePickerState {
  final String error;

  const ImagePickerError({required this.error});

  @override
  List<Object> get props => [error];
}

class ImageQualityCheckRequest extends ImagePickerState {}

class ImageQualityCheckDone extends ImagePickerState {
  final http.Response res;
  const ImageQualityCheckDone({required this.res});
}

class ImageQualityCheckFail extends ImagePickerState {
  final String error;

  const ImageQualityCheckFail({required this.error});
}

class ImageVerifyExtractDone extends ImagePickerState {
  final http.Response res;
  const ImageVerifyExtractDone({required this.res});
}

class ImageVerifyExtractFail extends ImagePickerState {
  final String error;

  const ImageVerifyExtractFail({required this.error});
}
