abstract class RegisterDelegateState {}

class RegisterDelegateInitial extends RegisterDelegateState {}

class RegisterDelegateFilesSelected extends RegisterDelegateState {
  final String? nationalIdFrontPath;
  final String? nationalIdBackPath;
  final String? drivingLicensePath;
  final String? motorcycleLicensePath;

  RegisterDelegateFilesSelected({
    this.nationalIdFrontPath,
    this.nationalIdBackPath,
    this.drivingLicensePath,
    this.motorcycleLicensePath,
  });
}

class RegisterDelegateUploadingImages extends RegisterDelegateState {
  final double progress; // Overall progress from 0.0 to 1.0
  final String currentUploadingField;

  RegisterDelegateUploadingImages({
    required this.progress,
    required this.currentUploadingField,
  });
}

class RegisterDelegateLoading extends RegisterDelegateState {}

class RegisterDelegateSuccess extends RegisterDelegateState {
  final String message;
  RegisterDelegateSuccess(this.message);
}

class RegisterDelegateError extends RegisterDelegateState {
  final String message;
  RegisterDelegateError(this.message);
}
