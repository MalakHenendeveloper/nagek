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
import '../../features/admin/domain/use_cases/get_admin_dashboard_use_case.dart'
    as _i202;
import '../../features/admin/domain/use_cases/get_admin_delegate_applications_use_case.dart'
    as _i13;
import '../../features/admin/domain/use_cases/get_admin_delegates_use_case.dart'
    as _i499;
import '../../features/admin/domain/use_cases/get_admin_order_details_use_case.dart'
    as _i977;
import '../../features/admin/domain/use_cases/get_admin_orders_use_case.dart'
    as _i687;
import '../../features/admin/domain/use_cases/get_admin_payments_use_case.dart'
    as _i803;
import '../../features/admin/domain/use_cases/get_admin_user_details_use_case.dart'
    as _i191;
import '../../features/admin/domain/use_cases/get_admin_users_use_case.dart'
    as _i767;
import '../../features/admin/domain/use_cases/get_delegate_application_details_use_case.dart'
    as _i385;
import '../../features/admin/domain/use_cases/get_financial_settings_use_case.dart'
    as _i108;
import '../../features/admin/domain/use_cases/get_payment_settings_use_case.dart'
    as _i114;
import '../../features/admin/domain/use_cases/reject_delegate_application_use_case.dart'
    as _i379;
import '../../features/admin/domain/use_cases/review_admin_payment_use_case.dart'
    as _i723;
import '../../features/admin/domain/use_cases/update_admin_center_status_use_case.dart'
    as _i360;
import '../../features/admin/domain/use_cases/update_admin_user_status_use_case.dart'
    as _i114;
import '../../features/admin/domain/use_cases/update_financial_settings_use_case.dart'
    as _i335;
import '../../features/admin/domain/use_cases/update_payment_settings_use_case.dart'
    as _i908;
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
import '../../features/admin/presentation/cubit/admin_financial_settings_cubit.dart'
    as _i130;
import '../../features/admin/presentation/cubit/admin_order_details_cubit.dart'
    as _i883;
import '../../features/admin/presentation/cubit/admin_orders_cubit.dart'
    as _i415;
import '../../features/admin/presentation/cubit/admin_payment_settings_cubit.dart'
    as _i108;
import '../../features/admin/presentation/cubit/admin_payments_cubit.dart'
    as _i1017;
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
import '../../features/centers/domain/use_cases/add_center_service_use_case.dart'
    as _i847;
import '../../features/centers/domain/use_cases/get_center_dashboard_order_details_use_case.dart'
    as _i581;
import '../../features/centers/domain/use_cases/get_center_dashboard_orders_use_case.dart'
    as _i175;
import '../../features/centers/domain/use_cases/get_center_dashboard_use_case.dart'
    as _i417;
import '../../features/centers/domain/use_cases/get_center_details_use_case.dart'
    as _i825;
import '../../features/centers/domain/use_cases/get_center_service_details_use_case.dart'
    as _i775;
import '../../features/centers/domain/use_cases/get_center_services_use_case.dart'
    as _i101;
import '../../features/centers/domain/use_cases/get_centers_use_case.dart'
    as _i235;
import '../../features/centers/domain/use_cases/get_my_center_services_use_case.dart'
    as _i293;
import '../../features/centers/domain/use_cases/submit_inspection_use_case.dart'
    as _i727;
import '../../features/centers/domain/use_cases/submit_price_offer_use_case.dart'
    as _i294;
import '../../features/centers/domain/use_cases/update_center_order_status_use_case.dart'
    as _i390;
import '../../features/centers/domain/use_cases/update_center_profile_use_case.dart'
    as _i781;
import '../../features/centers/domain/use_cases/update_center_service_use_case.dart'
    as _i1012;
import '../../features/centers/presentation/cubit/add_center_service_cubit.dart'
    as _i903;
import '../../features/centers/presentation/cubit/center_dashboard_cubit.dart'
    as _i71;
import '../../features/centers/presentation/cubit/center_dashboard_orders_cubit.dart'
    as _i297;
import '../../features/centers/presentation/cubit/center_details_cubit.dart'
    as _i1060;
import '../../features/centers/presentation/cubit/center_order_details_cubit.dart'
    as _i547;
import '../../features/centers/presentation/cubit/center_service_details_cubit.dart'
    as _i435;
import '../../features/centers/presentation/cubit/centers_cubit.dart' as _i997;
import '../../features/centers/presentation/cubit/my_center_services_cubit.dart'
    as _i1037;
import '../../features/centers/presentation/cubit/submit_inspection_cubit.dart'
    as _i684;
import '../../features/centers/presentation/cubit/submit_price_offer_cubit.dart'
    as _i843;
import '../../features/centers/presentation/cubit/update_center_profile_cubit.dart'
    as _i347;
import '../../features/centers/presentation/cubit/update_center_service_cubit.dart'
    as _i361;
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
import '../../features/orders/domain/use_cases/accept_delivery_use_case.dart'
    as _i230;
import '../../features/orders/domain/use_cases/accept_pickup_use_case.dart'
    as _i539;
import '../../features/orders/domain/use_cases/approve_price_offer_use_case.dart'
    as _i171;
import '../../features/orders/domain/use_cases/confirm_delivery_use_case.dart'
    as _i675;
import '../../features/orders/domain/use_cases/confirm_drop_center_use_case.dart'
    as _i663;
import '../../features/orders/domain/use_cases/confirm_pickup_center_use_case.dart'
    as _i363;
import '../../features/orders/domain/use_cases/confirm_pickup_use_case.dart'
    as _i628;
import '../../features/orders/domain/use_cases/create_order_use_case.dart'
    as _i945;
import '../../features/orders/domain/use_cases/get_available_delivery_orders_use_case.dart'
    as _i23;
import '../../features/orders/domain/use_cases/get_available_pickup_orders_use_case.dart'
    as _i679;
import '../../features/orders/domain/use_cases/get_delegate_dashboard_use_case.dart'
    as _i1018;
import '../../features/orders/domain/use_cases/get_delegate_orders_use_case.dart'
    as _i279;
import '../../features/orders/domain/use_cases/get_inspection_report_use_case.dart'
    as _i282;
import '../../features/orders/domain/use_cases/get_order_details_use_case.dart'
    as _i452;
import '../../features/orders/domain/use_cases/get_order_payment_details_use_case.dart'
    as _i203;
import '../../features/orders/domain/use_cases/get_order_tracking_use_case.dart'
    as _i11;
import '../../features/orders/domain/use_cases/get_orders_use_case.dart'
    as _i755;
import '../../features/orders/domain/use_cases/get_price_offer_use_case.dart'
    as _i994;
import '../../features/orders/domain/use_cases/submit_payment_proof_use_case.dart'
    as _i519;
import '../../features/orders/domain/use_cases/upload_pickup_photos_use_case.dart'
    as _i898;
import '../../features/orders/presentation/cubit/available_pickup_orders_cubit.dart'
    as _i731;
import '../../features/orders/presentation/cubit/create_order_cubit.dart'
    as _i743;
import '../../features/orders/presentation/cubit/delegate_dashboard_cubit.dart'
    as _i178;
import '../../features/orders/presentation/cubit/delegate_orders_cubit.dart'
    as _i705;
import '../../features/orders/presentation/cubit/device_selection_cubit.dart'
    as _i490;
import '../../features/orders/presentation/cubit/order_payment_cubit.dart'
    as _i12;
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
    gh.lazySingleton<_i230.AcceptDeliveryUseCase>(
      () => _i230.AcceptDeliveryUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i539.AcceptPickupUseCase>(
      () => _i539.AcceptPickupUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i171.ApprovePriceOfferUseCase>(
      () => _i171.ApprovePriceOfferUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i675.ConfirmDeliveryUseCase>(
      () => _i675.ConfirmDeliveryUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i663.ConfirmDropCenterUseCase>(
      () => _i663.ConfirmDropCenterUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i363.ConfirmPickupCenterUseCase>(
      () => _i363.ConfirmPickupCenterUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i628.ConfirmPickupUseCase>(
      () => _i628.ConfirmPickupUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i945.CreateOrderUseCase>(
      () => _i945.CreateOrderUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i23.GetAvailableDeliveryOrdersUseCase>(
      () =>
          _i23.GetAvailableDeliveryOrdersUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i679.GetAvailablePickupOrdersUseCase>(
      () => _i679.GetAvailablePickupOrdersUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i1018.GetDelegateDashboardUseCase>(
      () => _i1018.GetDelegateDashboardUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i279.GetDelegateOrdersUseCase>(
      () => _i279.GetDelegateOrdersUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i282.GetInspectionReportUseCase>(
      () => _i282.GetInspectionReportUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i452.GetOrderDetailsUseCase>(
      () => _i452.GetOrderDetailsUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i203.GetOrderPaymentDetailsUseCase>(
      () => _i203.GetOrderPaymentDetailsUseCase(gh<_i992.OrdersRepository>()),
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
    gh.lazySingleton<_i519.SubmitPaymentProofUseCase>(
      () => _i519.SubmitPaymentProofUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i898.UploadPickupPhotosUseCase>(
      () => _i898.UploadPickupPhotosUseCase(gh<_i992.OrdersRepository>()),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i1012.ProfileRemoteDataSource>()),
    );
    gh.factory<_i178.DelegateDashboardCubit>(
      () => _i178.DelegateDashboardCubit(
        gh<_i1018.GetDelegateDashboardUseCase>(),
      ),
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
    gh.factory<_i12.OrderPaymentCubit>(
      () => _i12.OrderPaymentCubit(
        gh<_i203.GetOrderPaymentDetailsUseCase>(),
        gh<_i519.SubmitPaymentProofUseCase>(),
      ),
    );
    gh.lazySingleton<_i110.GetProfileUseCase>(
      () => _i110.GetProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i871.DelegateLoginCubit>(
      () => _i871.DelegateLoginCubit(gh<_i1005.DelegateLoginUseCase>()),
    );
    gh.factory<_i731.AvailablePickupOrdersCubit>(
      () => _i731.AvailablePickupOrdersCubit(
        gh<_i679.GetAvailablePickupOrdersUseCase>(),
        gh<_i23.GetAvailableDeliveryOrdersUseCase>(),
        gh<_i539.AcceptPickupUseCase>(),
        gh<_i230.AcceptDeliveryUseCase>(),
        gh<_i898.UploadPickupPhotosUseCase>(),
        gh<_i628.ConfirmPickupUseCase>(),
      ),
    );
    gh.factory<_i705.DelegateOrdersCubit>(
      () => _i705.DelegateOrdersCubit(
        gh<_i279.GetDelegateOrdersUseCase>(),
        gh<_i898.UploadPickupPhotosUseCase>(),
        gh<_i628.ConfirmPickupUseCase>(),
        gh<_i663.ConfirmDropCenterUseCase>(),
        gh<_i363.ConfirmPickupCenterUseCase>(),
        gh<_i675.ConfirmDeliveryUseCase>(),
      ),
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
    gh.factory<_i803.GetAdminPaymentsUseCase>(
      () => _i803.GetAdminPaymentsUseCase(gh<_i583.AdminRepository>()),
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
    gh.lazySingleton<_i202.GetAdminDashboardUseCase>(
      () => _i202.GetAdminDashboardUseCase(gh<_i583.AdminRepository>()),
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
    gh.lazySingleton<_i108.GetFinancialSettingsUseCase>(
      () => _i108.GetFinancialSettingsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i114.GetPaymentSettingsUseCase>(
      () => _i114.GetPaymentSettingsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i379.RejectDelegateApplicationUseCase>(
      () => _i379.RejectDelegateApplicationUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i723.ReviewAdminPaymentUseCase>(
      () => _i723.ReviewAdminPaymentUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i335.UpdateFinancialSettingsUseCase>(
      () => _i335.UpdateFinancialSettingsUseCase(gh<_i583.AdminRepository>()),
    );
    gh.lazySingleton<_i908.UpdatePaymentSettingsUseCase>(
      () => _i908.UpdatePaymentSettingsUseCase(gh<_i583.AdminRepository>()),
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
    gh.factory<_i130.AdminFinancialSettingsCubit>(
      () => _i130.AdminFinancialSettingsCubit(
        gh<_i108.GetFinancialSettingsUseCase>(),
        gh<_i335.UpdateFinancialSettingsUseCase>(),
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
      () => _i122.AdminDashboardCubit(gh<_i202.GetAdminDashboardUseCase>()),
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
    gh.factory<_i1017.AdminPaymentsCubit>(
      () => _i1017.AdminPaymentsCubit(
        gh<_i803.GetAdminPaymentsUseCase>(),
        gh<_i723.ReviewAdminPaymentUseCase>(),
      ),
    );
    gh.factory<_i108.AdminPaymentSettingsCubit>(
      () => _i108.AdminPaymentSettingsCubit(
        gh<_i114.GetPaymentSettingsUseCase>(),
        gh<_i908.UpdatePaymentSettingsUseCase>(),
      ),
    );
    gh.factory<_i36.ProfileCubit>(
      () => _i36.ProfileCubit(
        gh<_i110.GetProfileUseCase>(),
        gh<_i894.ProfileRepository>(),
      ),
    );
    gh.lazySingleton<_i847.AddCenterServiceUseCase>(
      () => _i847.AddCenterServiceUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i581.GetCenterDashboardOrderDetailsUseCase>(
      () => _i581.GetCenterDashboardOrderDetailsUseCase(
        gh<_i105.CentersRepository>(),
      ),
    );
    gh.lazySingleton<_i175.GetCenterDashboardOrdersUseCase>(
      () =>
          _i175.GetCenterDashboardOrdersUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i417.GetCenterDashboardUseCase>(
      () => _i417.GetCenterDashboardUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i825.GetCenterDetailsUseCase>(
      () => _i825.GetCenterDetailsUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i775.GetCenterServiceDetailsUseCase>(
      () => _i775.GetCenterServiceDetailsUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i101.GetCenterServicesUseCase>(
      () => _i101.GetCenterServicesUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i235.GetCentersUseCase>(
      () => _i235.GetCentersUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i293.GetMyCenterServicesUseCase>(
      () => _i293.GetMyCenterServicesUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i727.SubmitInspectionUseCase>(
      () => _i727.SubmitInspectionUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i294.SubmitPriceOfferUseCase>(
      () => _i294.SubmitPriceOfferUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i390.UpdateCenterOrderStatusUseCase>(
      () => _i390.UpdateCenterOrderStatusUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i781.UpdateCenterProfileUseCase>(
      () => _i781.UpdateCenterProfileUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i1012.UpdateCenterServiceUseCase>(
      () => _i1012.UpdateCenterServiceUseCase(gh<_i105.CentersRepository>()),
    );
    gh.factory<_i547.CenterOrderDetailsCubit>(
      () => _i547.CenterOrderDetailsCubit(
        gh<_i581.GetCenterDashboardOrderDetailsUseCase>(),
        gh<_i390.UpdateCenterOrderStatusUseCase>(),
      ),
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
    gh.factory<_i347.UpdateCenterProfileCubit>(
      () => _i347.UpdateCenterProfileCubit(
        gh<_i781.UpdateCenterProfileUseCase>(),
      ),
    );
    gh.factory<_i361.UpdateCenterServiceCubit>(
      () => _i361.UpdateCenterServiceCubit(
        gh<_i1012.UpdateCenterServiceUseCase>(),
      ),
    );
    gh.factory<_i1041.AdminUsersCubit>(
      () => _i1041.AdminUsersCubit(gh<_i767.GetAdminUsersUseCase>()),
    );
    gh.factory<_i297.CenterDashboardOrdersCubit>(
      () => _i297.CenterDashboardOrdersCubit(
        gh<_i175.GetCenterDashboardOrdersUseCase>(),
      ),
    );
    gh.factory<_i71.CenterDashboardCubit>(
      () => _i71.CenterDashboardCubit(gh<_i417.GetCenterDashboardUseCase>()),
    );
    gh.factory<_i1060.CenterDetailsCubit>(
      () => _i1060.CenterDetailsCubit(
        gh<_i825.GetCenterDetailsUseCase>(),
        gh<_i101.GetCenterServicesUseCase>(),
      ),
    );
    gh.factory<_i684.SubmitInspectionCubit>(
      () => _i684.SubmitInspectionCubit(gh<_i727.SubmitInspectionUseCase>()),
    );
    gh.factory<_i435.CenterServiceDetailsCubit>(
      () => _i435.CenterServiceDetailsCubit(
        gh<_i775.GetCenterServiceDetailsUseCase>(),
      ),
    );
    gh.factory<_i997.CentersCubit>(
      () => _i997.CentersCubit(gh<_i235.GetCentersUseCase>()),
    );
    gh.factory<_i843.SubmitPriceOfferCubit>(
      () => _i843.SubmitPriceOfferCubit(gh<_i294.SubmitPriceOfferUseCase>()),
    );
    gh.factory<_i903.AddCenterServiceCubit>(
      () => _i903.AddCenterServiceCubit(gh<_i847.AddCenterServiceUseCase>()),
    );
    gh.factory<_i1037.MyCenterServicesCubit>(
      () =>
          _i1037.MyCenterServicesCubit(gh<_i293.GetMyCenterServicesUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
