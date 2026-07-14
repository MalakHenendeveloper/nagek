// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/admin/data/data_sources/admin_remote_data_source.dart'
    as _i299;
import '../../features/admin/data/repositories/admin_repository_impl.dart'
    as _i335;
import '../../features/admin/domain/repositories/admin_repository.dart'
    as _i583;
import '../../features/admin/domain/use_cases/approve_delegate_application_use_case.dart'
    as _i78;
import '../../features/admin/domain/use_cases/create_center_use_case.dart'
    as _i232;
import '../../features/admin/domain/use_cases/delete_admin_delegate_use_case.dart'
    as _i671;
import '../../features/admin/domain/use_cases/delete_admin_user_use_case.dart'
    as _i604;
import '../../features/admin/domain/use_cases/get_admin_center_details_use_case.dart'
    as _i257;
import '../../features/admin/domain/use_cases/get_admin_centers_use_case.dart'
    as _i367;
import '../../features/admin/domain/use_cases/get_admin_delegate_applications_use_case.dart'
    as _i13;
import '../../features/admin/domain/use_cases/get_admin_delegates_use_case.dart'
    as _i499;
import '../../features/admin/domain/use_cases/get_admin_order_details_use_case.dart'
    as _i977;
import '../../features/admin/domain/use_cases/get_admin_orders_use_case.dart'
    as _i687;
import '../../features/admin/domain/use_cases/get_admin_user_details_use_case.dart'
    as _i191;
import '../../features/admin/domain/use_cases/get_admin_users_use_case.dart'
    as _i767;
import '../../features/admin/domain/use_cases/get_delegate_application_details_use_case.dart'
    as _i385;
import '../../features/admin/domain/use_cases/reject_delegate_application_use_case.dart'
    as _i379;
import '../../features/admin/domain/use_cases/update_admin_center_status_use_case.dart'
    as _i360;
import '../../features/admin/domain/use_cases/update_admin_user_status_use_case.dart'
    as _i114;
import '../../features/admin/presentation/cubit/admin_center_details_cubit.dart'
    as _i150;
import '../../features/admin/presentation/cubit/admin_centers_cubit.dart'
    as _i1001;
import '../../features/admin/presentation/cubit/admin_create_center_cubit.dart'
    as _i319;
import '../../features/admin/presentation/cubit/admin_dashboard_cubit.dart'
    as _i122;
import '../../features/admin/presentation/cubit/admin_delegate_applications_cubit.dart'
    as _i792;
import '../../features/admin/presentation/cubit/admin_delegates_cubit.dart'
    as _i413;
import '../../features/admin/presentation/cubit/admin_order_details_cubit.dart'
    as _i883;
import '../../features/admin/presentation/cubit/admin_orders_cubit.dart'
    as _i415;
import '../../features/admin/presentation/cubit/admin_user_details_cubit.dart'
    as _i608;
import '../../features/admin/presentation/cubit/admin_users_cubit.dart'
    as _i1041;
import '../../features/admin/presentation/cubit/delegate_application_details_cubit.dart'
    as _i559;
import '../../features/auth/data/data_sources/auth_remote_data_source.dart'
    as _i25;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/use_cases/delegate_login_use_case.dart'
    as _i1005;
import '../../features/auth/domain/use_cases/login_use_case.dart' as _i1038;
import '../../features/auth/domain/use_cases/register_delegate_use_case.dart'
    as _i335;
import '../../features/auth/domain/use_cases/register_use_case.dart' as _i1010;
import '../../features/auth/presentation/cubit/delegate_login_cubit.dart'
    as _i871;
import '../../features/auth/presentation/cubit/login_cubit.dart' as _i69;
import '../../features/auth/presentation/cubit/register_cubit.dart' as _i759;
import '../../features/auth/presentation/cubit/register_delegate_cubit.dart'
    as _i1041;
import '../../features/centers/data/data_sources/centers_remote_data_source.dart'
    as _i93;
import '../../features/centers/data/repositories/centers_repository_impl.dart'
    as _i371;
import '../../features/centers/domain/repositories/centers_repository.dart'
    as _i105;
import '../../features/centers/domain/use_cases/get_center_details_use_case.dart'
    as _i825;
import '../../features/centers/domain/use_cases/get_center_services_use_case.dart'
    as _i101;
import '../../features/centers/domain/use_cases/get_centers_use_case.dart'
    as _i235;
import '../../features/centers/presentation/cubit/center_details_cubit.dart'
    as _i1060;
import '../../features/centers/presentation/cubit/centers_cubit.dart' as _i997;
import '../../features/orders/data/data_sources/device_local_data_source.dart'
    as _i468;
import '../../features/orders/data/data_sources/orders_remote_data_source.dart'
    as _i310;
import '../../features/orders/data/repositories/device_repository_impl.dart'
    as _i153;
import '../../features/orders/data/repositories/orders_repository_impl.dart'
    as _i368;
import '../../features/orders/domain/repositories/device_repository.dart'
    as _i850;
import '../../features/orders/domain/repositories/orders_repository.dart'
    as _i992;
import '../../features/orders/domain/use_cases/approve_price_offer_use_case.dart'
    as _i171;
import '../../features/orders/domain/use_cases/create_order_use_case.dart'
    as _i945;
import '../../features/orders/domain/use_cases/get_inspection_report_use_case.dart'
    as _i282;
import '../../features/orders/domain/use_cases/get_order_details_use_case.dart'
    as _i452;
import '../../features/orders/domain/use_cases/get_order_tracking_use_case.dart'
    as _i11;
import '../../features/orders/domain/use_cases/get_orders_use_case.dart'
    as _i755;
import '../../features/orders/domain/use_cases/get_price_offer_use_case.dart'
    as _i994;
import '../../features/orders/presentation/cubit/create_order_cubit.dart'
    as _i743;
import '../../features/orders/presentation/cubit/device_selection_cubit.dart'
    as _i490;
import '../../features/orders/presentation/cubit/order_tracking_cubit.dart'
    as _i934;
import '../../features/orders/presentation/cubit/orders_cubit.dart' as _i1028;
import '../../features/profile/data/data_sources/profile_remote_data_source.dart'
    as _i1012;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/use_cases/get_profile_use_case.dart'
    as _i110;
import '../../features/profile/presentation/cubit/profile_cubit.dart' as _i36;
import '../api/api_manager.dart' as _i1047;
import '../storage/secure_storage_service.dart' as _i666;
import '../upload/data/repositories/upload_repository_impl.dart' as _i1033;
import '../upload/data/services/cloudinary_service.dart' as _i402;
import '../upload/domain/repositories/upload_repository.dart' as _i328;
import '../upload/domain/use_cases/upload_image_use_case.dart' as _i1047;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i402.CloudinaryService>(
      () => _i402.CloudinaryService(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i468.DeviceLocalDataSource>(
      () => _i468.DeviceLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i328.UploadRepository>(
      () => _i1033.UploadRepositoryImpl(gh<_i402.CloudinaryService>()),
    );
    gh.lazySingleton<_i1047.UploadImageUseCase>(
      () => _i1047.UploadImageUseCase(gh<_i328.UploadRepository>()),
    );
    gh.lazySingleton<_i850.DeviceRepository>(
      () => _i153.DeviceRepositoryImpl(gh<_i468.DeviceLocalDataSource>()),
    );
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.factory<_i490.DeviceSelectionCubit>(
      () => _i490.DeviceSelectionCubit(gh<_i850.DeviceRepository>()),
    );
    gh.lazySingleton<_i1047.ApiManager>(
      () =>
          _i1047.ApiManager(gh<_i361.Dio>(), gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i299.AdminRemoteDataSource>(
      () => _i299.AdminRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.lazySingleton<_i310.OrdersRemoteDataSource>(
      () => _i310.OrdersRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.lazySingleton<_i25.AuthRemoteDataSource>(
      () => _i25.AuthRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i25.AuthRemoteDataSource>(),
        gh<_i666.SecureStorageService>(),
      ),
    );
    gh.lazySingleton<_i1012.ProfileRemoteDataSource>(
      () => _i1012.ProfileRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.lazySingleton<_i1038.LoginUseCase>(
      () => _i1038.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i992.OrdersRepository>(
      () => _i368.OrdersRepositoryImpl(gh<_i310.OrdersRemoteDataSource>()),
    );
    gh.factory<_i69.LoginCubit>(
      () => _i69.LoginCubit(gh<_i1038.LoginUseCase>()),
    );
    gh.lazySingleton<_i583.AdminRepository>(
      () => _i335.AdminRepositoryImpl(gh<_i299.AdminRemoteDataSource>()),
    );
    gh.lazySingleton<_i1005.DelegateLoginUseCase>(
      () => _i1005.DelegateLoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i335.RegisterDelegateUseCase>(
      () => _i335.RegisterDelegateUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i1010.RegisterUseCase>(
      () => _i1010.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i93.CentersRemoteDataSource>(
      () => _i93.CentersRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.lazySingleton<_i171.ApprovePriceOfferUseCase>(
      () => _i171.ApprovePriceOfferUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i945.CreateOrderUseCase>(
      () => _i945.CreateOrderUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i282.GetInspectionReportUseCase>(
      () => _i282.GetInspectionReportUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i452.GetOrderDetailsUseCase>(
      () => _i452.GetOrderDetailsUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i11.GetOrderTrackingUseCase>(
      () => _i11.GetOrderTrackingUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i755.GetOrdersUseCase>(
      () => _i755.GetOrdersUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i994.GetPriceOfferUseCase>(
      () => _i994.GetPriceOfferUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i1012.ProfileRemoteDataSource>()),
    );
    gh.factory<_i759.RegisterCubit>(
      () => _i759.RegisterCubit(gh<_i1010.RegisterUseCase>()),
    );
    gh.factory<_i934.OrderTrackingCubit>(
      () => _i934.OrderTrackingCubit(
        gh<_i452.GetOrderDetailsUseCase>(),
        gh<_i11.GetOrderTrackingUseCase>(),
        gh<_i282.GetInspectionReportUseCase>(),
        gh<_i994.GetPriceOfferUseCase>(),
        gh<_i171.ApprovePriceOfferUseCase>(),
      ),
    );
    gh.lazySingleton<_i110.GetProfileUseCase>(
      () => _i110.GetProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i871.DelegateLoginCubit>(
      () => _i871.DelegateLoginCubit(gh<_i1005.DelegateLoginUseCase>()),
    );
    gh.factory<_i1028.OrdersCubit>(
      () => _i1028.OrdersCubit(gh<_i755.GetOrdersUseCase>()),
    );
    gh.factory<_i743.CreateOrderCubit>(
      () => _i743.CreateOrderCubit(gh<_i945.CreateOrderUseCase>()),
    );
    gh.factory<_i232.CreateCenterUseCase>(
      () => _i232.CreateCenterUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i671.DeleteAdminDelegateUseCase>(
      () => _i671.DeleteAdminDelegateUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i604.DeleteAdminUserUseCase>(
      () => _i604.DeleteAdminUserUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i257.GetAdminCenterDetailsUseCase>(
      () => _i257.GetAdminCenterDetailsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i367.GetAdminCentersUseCase>(
      () => _i367.GetAdminCentersUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i499.GetAdminDelegatesUseCase>(
      () => _i499.GetAdminDelegatesUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i977.GetAdminOrderDetailsUseCase>(
      () => _i977.GetAdminOrderDetailsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i687.GetAdminOrdersUseCase>(
      () => _i687.GetAdminOrdersUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i191.GetAdminUserDetailsUseCase>(
      () => _i191.GetAdminUserDetailsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i767.GetAdminUsersUseCase>(
      () => _i767.GetAdminUsersUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i360.UpdateAdminCenterStatusUseCase>(
      () => _i360.UpdateAdminCenterStatusUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i114.UpdateAdminUserStatusUseCase>(
      () => _i114.UpdateAdminUserStatusUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i78.ApproveDelegateApplicationUseCase>(
      () => _i78.ApproveDelegateApplicationUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i13.GetAdminDelegateApplicationsUseCase>(
      () =>
          _i13.GetAdminDelegateApplicationsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i385.GetDelegateApplicationDetailsUseCase>(
      () => _i385.GetDelegateApplicationDetailsUseCase(
        gh<_i583.AdminRepository>(),
      ),
    );
    gh.lazySingleton<_i379.RejectDelegateApplicationUseCase>(
      () => _i379.RejectDelegateApplicationUseCase(gh<_i583.AdminRepository>()),
    );
    gh.factory<_i150.AdminCenterDetailsCubit>(
      () => _i150.AdminCenterDetailsCubit(
        gh<_i257.GetAdminCenterDetailsUseCase>(),
        gh<_i360.UpdateAdminCenterStatusUseCase>(),
      ),
    );
    gh.factory<_i413.AdminDelegatesCubit>(
      () => _i413.AdminDelegatesCubit(gh<_i499.GetAdminDelegatesUseCase>()),
    );
    gh.factory<_i1041.RegisterDelegateCubit>(
      () => _i1041.RegisterDelegateCubit(
        gh<_i1047.UploadImageUseCase>(),
        gh<_i335.RegisterDelegateUseCase>(),
      ),
    );
    gh.factory<_i792.AdminDelegateApplicationsCubit>(
      () => _i792.AdminDelegateApplicationsCubit(
        gh<_i13.GetAdminDelegateApplicationsUseCase>(),
      ),
    );
    gh.factory<_i559.DelegateApplicationDetailsCubit>(
      () => _i559.DelegateApplicationDetailsCubit(
        gh<_i385.GetDelegateApplicationDetailsUseCase>(),
        gh<_i78.ApproveDelegateApplicationUseCase>(),
        gh<_i379.RejectDelegateApplicationUseCase>(),
      ),
    );
    gh.factory<_i122.AdminDashboardCubit>(
      () => _i122.AdminDashboardCubit(
        gh<_i767.GetAdminUsersUseCase>(),
        gh<_i499.GetAdminDelegatesUseCase>(),
        gh<_i367.GetAdminCentersUseCase>(),
      ),
    );
    gh.lazySingleton<_i105.CentersRepository>(
      () => _i371.CentersRepositoryImpl(gh<_i93.CentersRemoteDataSource>()),
    );
    gh.factory<_i319.AdminCreateCenterCubit>(
      () => _i319.AdminCreateCenterCubit(gh<_i232.CreateCenterUseCase>()),
    );
    gh.factory<_i1001.AdminCentersCubit>(
      () => _i1001.AdminCentersCubit(gh<_i367.GetAdminCentersUseCase>()),
    );
    gh.factory<_i36.ProfileCubit>(
      () => _i36.ProfileCubit(
        gh<_i110.GetProfileUseCase>(),
        gh<_i894.ProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i825.GetCenterDetailsUseCase>(
      () => _i825.GetCenterDetailsUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i101.GetCenterServicesUseCase>(
      () => _i101.GetCenterServicesUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i235.GetCentersUseCase>(
      () => _i235.GetCentersUseCase(gh<_i105.CentersRepository>()),
    );
    gh.factory<_i415.AdminOrdersCubit>(
      () => _i415.AdminOrdersCubit(gh<_i687.GetAdminOrdersUseCase>()),
    );
    gh.factory<_i883.AdminOrderDetailsCubit>(
      () =>
          _i883.AdminOrderDetailsCubit(gh<_i977.GetAdminOrderDetailsUseCase>()),
    );
    gh.factory<_i608.AdminUserDetailsCubit>(
      () => _i608.AdminUserDetailsCubit(
        gh<_i191.GetAdminUserDetailsUseCase>(),
        gh<_i604.DeleteAdminUserUseCase>(),
        gh<_i671.DeleteAdminDelegateUseCase>(),
        gh<_i114.UpdateAdminUserStatusUseCase>(),
      ),
    );
    gh.factory<_i1041.AdminUsersCubit>(
      () => _i1041.AdminUsersCubit(gh<_i767.GetAdminUsersUseCase>()),
    );
    gh.factory<_i1060.CenterDetailsCubit>(
      () => _i1060.CenterDetailsCubit(
        gh<_i825.GetCenterDetailsUseCase>(),
        gh<_i101.GetCenterServicesUseCase>(),
      ),
    );
    gh.factory<_i997.CentersCubit>(
      () => _i997.CentersCubit(gh<_i235.GetCentersUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
