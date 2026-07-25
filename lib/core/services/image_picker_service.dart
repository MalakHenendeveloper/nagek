import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// اختيار صورة مفردة من الكاميرا أو المعرض مع تطبيق أبعاد قصوى وجودة ضغط متوازنة
  static Future<XFile?> pickImage({required ImageSource source}) {
    return _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
  }

  /// اختيار صور متعددة مع تطبيق أبعاد قصوى وجودة ضغط متوازنة
  static Future<List<XFile>> pickMultiImage() {
    return _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
  }
}
