import '../../../../core/api/api_manager.dart';
import '../../../../core/api/endpoints.dart';
import '../models/login_response.dart';
import '../models/delegate_register_request_model.dart';
import '../models/delegate_login_response_model.dart';

import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String phone,
    required String password,
  });

  Future<LoginResponseModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  });

  Future<void> registerDelegate({
    required DelegateRegisterRequestModel request,
  });

  Future<DelegateLoginResponseModel> delegateLogin({
    required String phone,
    required String password,
  });
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiManager _apiManager;

  AuthRemoteDataSourceImpl(this._apiManager);

  @override
  Future<LoginResponseModel> login({
    required String phone,
    required String password,
  }) async {
    final response = await _apiManager.PostDate(
      Endpoints.login,
      body: {
        'phone': phone,
        'password': password,
      },
    );

    if (response.data != null) {
      return LoginResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في الاتصال بالخادم');
    }
  }

  @override
  Future<LoginResponseModel> register({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await _apiManager.PostDate(
      Endpoints.register,
      body: {
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
      },
    );

    if (response.data != null) {
      return LoginResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في إنشاء الحساب');
    }
  }

  @override
  Future<void> registerDelegate({
    required DelegateRegisterRequestModel request,
  }) async {
    final response = await _apiManager.PostDate(
      Endpoints.registerDelegate,
      body: request.toJson(),
    );

    final data = response.data;
    if (data != null && data['success'] == true) {
      return;
    } else {
      final message = data != null ? data['message'] : null;
      throw Exception(message ?? 'حدث خطأ أثناء تقديم طلب المندوب');
    }
  }

  @override
  Future<DelegateLoginResponseModel> delegateLogin({
    required String phone,
    required String password,
  }) async {
    final response = await _apiManager.PostDate(
      Endpoints.delegateLogin,
      body: {
        'phone': phone,
        'password': password,
      },
    );

    if (response.data != null) {
      return DelegateLoginResponseModel.fromJson(response.data);
    } else {
      throw Exception('فشل في تسجيل الدخول كمندوب');
    }
  }
}
