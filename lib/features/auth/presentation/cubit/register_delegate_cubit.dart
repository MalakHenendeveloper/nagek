import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/upload/data/models/image_upload_response.dart';
import '../../../../core/upload/data/services/cloudinary_config.dart';
import '../../../../core/upload/domain/use_cases/upload_image_use_case.dart';
import '../../data/models/delegate_register_request_model.dart';
import '../../domain/use_cases/register_delegate_use_case.dart';
import 'register_delegate_state.dart';

@injectable
class RegisterDelegateCubit extends Cubit<RegisterDelegateState> {
  final UploadImageUseCase _uploadImageUseCase;
  final RegisterDelegateUseCase _registerDelegateUseCase;

  String? nationalIdFrontPath;
  String? nationalIdBackPath;
  String? drivingLicensePath;
  String? motorcycleLicensePath;

  RegisterDelegateCubit(
    this._uploadImageUseCase,
    this._registerDelegateUseCase,
  ) : super(RegisterDelegateInitial());

  void selectNationalIdFront(String path) {
    nationalIdFrontPath = path;
    _emitFilesSelected();
  }

  void selectNationalIdBack(String path) {
    nationalIdBackPath = path;
    _emitFilesSelected();
  }

  void selectDrivingLicense(String path) {
    drivingLicensePath = path;
    _emitFilesSelected();
  }

  void selectMotorcycleLicense(String path) {
    motorcycleLicensePath = path;
    _emitFilesSelected();
  }

  void _emitFilesSelected() {
    emit(RegisterDelegateFilesSelected(
      nationalIdFrontPath: nationalIdFrontPath,
      nationalIdBackPath: nationalIdBackPath,
      drivingLicensePath: drivingLicensePath,
      motorcycleLicensePath: motorcycleLicensePath,
    ));
  }

  Future<void> registerDelegate({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    if (nationalIdFrontPath == null ||
        nationalIdBackPath == null ||
        drivingLicensePath == null ||
        motorcycleLicensePath == null) {
      emit(RegisterDelegateError('يرجى اختيار جميع المستندات المطلوبة أولاً'));
      return;
    }

    try {
      emit(RegisterDelegateUploadingImages(
        progress: 0.0,
        currentUploadingField: 'الهوية الوطنية (الوجه)',
      ));

      // 1. Upload National ID Front
      final frontRes = await _uploadFile(
        nationalIdFrontPath!,
        'الهوية الوطنية (الوجه)',
        0.0,
        0.25,
      );

      // 2. Upload National ID Back
      final backRes = await _uploadFile(
        nationalIdBackPath!,
        'الهوية الوطنية (الخلفية)',
        0.25,
        0.25,
      );

      // 3. Upload Driving License
      final drivingRes = await _uploadFile(
        drivingLicensePath!,
        'رخصة القيادة',
        0.50,
        0.25,
      );

      // 4. Upload Motorcycle License
      final motorcycleRes = await _uploadFile(
        motorcycleLicensePath!,
        'رخصة الدراجة النارية',
        0.75,
        0.25,
      );

      // 5. Submit delegate registration JSON body
      emit(RegisterDelegateLoading());

      final request = DelegateRegisterRequestModel(
        name: name,
        phone: phone,
        email: email,
        password: password,
        nationalIdFront: frontRes,
        nationalIdBack: backRes,
        drivingLicense: drivingRes,
        motorcycleLicense: motorcycleRes,
      );

      final result = await _registerDelegateUseCase(request: request);

      result.fold(
        (failure) => emit(RegisterDelegateError(failure.message)),
        (_) => emit(RegisterDelegateSuccess('تم تقديم طلبك بنجاح وبانتظار موافقة الإدارة')),
      );
    } catch (e) {
      emit(RegisterDelegateError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<ImageUploadResponse> _uploadFile(
    String filePath,
    String fieldNameAr,
    double baseProgress,
    double progressWeight,
  ) async {
    final uploadParams = {
      'upload_preset': CloudinaryConfig.uploadPreset,
    };

    final result = await _uploadImageUseCase.call(
      filePath: filePath,
      cloudName: CloudinaryConfig.cloudName,
      uploadParams: uploadParams,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final fileProgress = sent / total;
          final overallProgress = baseProgress + (fileProgress * progressWeight);
          emit(RegisterDelegateUploadingImages(
            progress: overallProgress,
            currentUploadingField: fieldNameAr,
          ));
        }
      },
    );

    return result.fold(
      (failure) => throw Exception('فشل رفع $fieldNameAr: ${failure.message}'),
      (response) => response,
    );
  }
}
