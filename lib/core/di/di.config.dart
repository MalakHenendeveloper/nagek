// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/data/data_sources/auth_remote_data_source.dart'
    as _i25;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/use_cases/login_use_case.dart' as _i1038;
import '../../features/auth/domain/use_cases/register_use_case.dart' as _i1010;
import '../../features/auth/presentation/cubit/login_cubit.dart' as _i69;
import '../../features/auth/presentation/cubit/register_cubit.dart' as _i759;
import '../../features/centers/data/data_sources/centers_remote_data_source.dart'
    as _i93;
import '../../features/centers/data/repositories/centers_repository_impl.dart'
    as _i371;
import '../../features/centers/domain/repositories/centers_repository.dart'
    as _i105;
import '../../features/centers/domain/use_cases/get_center_details_use_case.dart'
    as _i825;
import '../../features/centers/domain/use_cases/get_centers_use_case.dart'
    as _i235;
import '../../features/centers/presentation/cubit/center_details_cubit.dart'
    as _i1060;
import '../../features/centers/presentation/cubit/centers_cubit.dart' as _i997;
import '../../features/orders/data/data_sources/orders_remote_data_source.dart'
    as _i310;
import '../../features/orders/data/repositories/orders_repository_impl.dart'
    as _i368;
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
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i1047.ApiManager>(
      () => _i1047.ApiManager(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i1012.ProfileRemoteDataSource>(
      () => _i1012.ProfileRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.lazySingleton<_i93.CentersRemoteDataSource>(
      () => _i93.CentersRemoteDataSourceImpl(gh<_i1047.ApiManager>()),
    );
    gh.lazySingleton<_i894.ProfileRepository>(
      () => _i334.ProfileRepositoryImpl(gh<_i1012.ProfileRemoteDataSource>()),
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
    gh.lazySingleton<_i110.GetProfileUseCase>(
      () => _i110.GetProfileUseCase(gh<_i894.ProfileRepository>()),
    );
    gh.factory<_i36.ProfileCubit>(
      () => _i36.ProfileCubit(gh<_i110.GetProfileUseCase>()),
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
    gh.lazySingleton<_i1010.RegisterUseCase>(
      () => _i1010.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i105.CentersRepository>(
      () => _i371.CentersRepositoryImpl(gh<_i93.CentersRemoteDataSource>()),
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
    gh.lazySingleton<_i825.GetCenterDetailsUseCase>(
      () => _i825.GetCenterDetailsUseCase(gh<_i105.CentersRepository>()),
    );
    gh.lazySingleton<_i235.GetCentersUseCase>(
      () => _i235.GetCentersUseCase(gh<_i105.CentersRepository>()),
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
    gh.factory<_i1028.OrdersCubit>(
      () => _i1028.OrdersCubit(gh<_i755.GetOrdersUseCase>()),
    );
    gh.factory<_i743.CreateOrderCubit>(
      () => _i743.CreateOrderCubit(gh<_i945.CreateOrderUseCase>()),
    );
    gh.factory<_i997.CentersCubit>(
      () => _i997.CentersCubit(gh<_i235.GetCentersUseCase>()),
    );
    gh.factory<_i1060.CenterDetailsCubit>(
      () => _i1060.CenterDetailsCubit(gh<_i825.GetCenterDetailsUseCase>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
