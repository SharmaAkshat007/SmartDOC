import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

part 'image_picker_state.dart';

class ImagePickerCubit extends Cubit<ImagePickerState> {
  final ImagePicker _picker;
  ImagePickerCubit(this._picker) : super(ImagePickerInitial()) {
    _retrieveLostData();
  }

  Future<void> _retrieveLostData() async {
    emit(ImagePickerLoading());
    final LostDataResponse response = await _picker.retrieveLostData();
    if (!response.isEmpty && response.file != null) {
      final XFile? _im = response.file;
      if (response.type == RetrieveType.image && _im != null) {
        final XFile _img = _im;
        emit(ImagePickerDone(imageFile: _img));
      } else {
        emit(ImagePickerError(
            error: response.exception!.message ?? 'Unknown Error'));
        emit(ImagePickerInitial());
      }
    } else {
      emit(ImagePickerInitial());
    }
  }

  Future<void> pickImage(ImageSource source) async {
    emit(ImagePickerLoading());
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      if (pickedFile != null) {
        final XFile _img = pickedFile;
        emit(ImagePickerDone(imageFile: _img));
      } else {
        emit(const ImagePickerError(error: 'Unknown Error'));
      }
    } catch (e) {
      emit(ImagePickerError(error: e.toString()));
    }
  }

  Future<void> getQuality(XFile img) async {
    emit(ImageQualityCheckRequest());
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('http://34.131.106.96/v1/findReadability'));
      request.files.add(await http.MultipartFile.fromPath('file', img.path));
      final res = await http.Response.fromStream(await request.send());
      if (res.statusCode == 200) {
        emit(ImageQualityCheckDone(res: res));
      } else {
        emit(ImageQualityCheckFail(error: jsonDecode(res.body)['message']));
      }
    } catch (e) {
      emit(ImageQualityCheckFail(error: e.toString()));
    }
  }

  Future<void> verifyExtract(XFile img) async {
    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('http://34.131.106.96/v1/extractDetails'));
      request.files.add(await http.MultipartFile.fromPath('file', img.path));
      final res = await http.Response.fromStream(await request.send());
      if (res.statusCode == 200) {
        emit(ImageVerifyExtractDone(res: res));
      } else {
        emit(ImageVerifyExtractFail(error: jsonDecode(res.body)['message']));
      }
    } catch (e) {
      emit(ImageVerifyExtractFail(error: e.toString()));
    }
  }
}
