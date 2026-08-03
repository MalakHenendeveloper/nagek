import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/register_delegate_screen.dart';
import '../../features/auth/presentation/screens/delegate_login_screen.dart';
import '../../features/home/presentation/screens/client_home.dart';
import '../../features/home/presentation/screens/admin_home.dart';
import '../../features/home/presentation/screens/delegate_home.dart';
import '../../features/home/presentation/screens/center_home.dart';
import '../../features/centers/presentation/screens/all_centers_screen.dart';
import '../../features/centers/presentation/screens/center_details_screen.dart';
import '../../features/orders/presentation/screens/create_order_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/my_orders_screen.dart';
import '../../features/orders/presentation/screens/available_pickup_orders_screen.dart';
import '../../features/orders/presentation/screens/delegate_tasks_screen.dart';
import '../../features/centers/presentation/screens/center_order_details_screen.dart';
import '../../features/centers/presentation/screens/submit_inspection_screen.dart';
import '../../features/centers/presentation/screens/submit_price_offer_screen.dart';
import '../../features/orders/presentation/screens/order_payment_screen.dart';
import '../../features/orders/presentation/screens/delegate_settlements_screen.dart';
import '../../features/orders/presentation/screens/delegate_earnings_screen.dart';
import '../../features/centers/presentation/screens/center_settlements_screen.dart';
import '../../features/admin/presentation/screens/admin_settlements_screen.dart';
import '../../features/admin/presentation/screens/admin_settlements_summary_screen.dart';
import '../../features/centers/presentation/screens/add_center_service_screen.dart';
import '../../features/centers/presentation/screens/center_services_screen.dart';
import '../../features/centers/presentation/screens/center_service_details_screen.dart';
import '../../features/centers/presentation/screens/edit_center_service_screen.dart';
import '../../features/centers/domain/entities/service_entity.dart';
import '../../features/map/domain/entities/map_location_entity.dart';
import '../../features/map/presentation/pages/map_picker_screen.dart';
import '../../features/map/presentation/pages/delegate_route_view_screen.dart';
import 'routes.dart';


class RouteGenerator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.registerDelegateRoute:
        return MaterialPageRoute(builder: (_) => const RegisterDelegateScreen());
      case Routes.delegateLoginRoute:
        return MaterialPageRoute(builder: (_) => const DelegateLoginScreen());
      case Routes.clientHomeRoute:
        return MaterialPageRoute(builder: (_) => const ClientHome());
      case Routes.adminHomeRoute:
        return MaterialPageRoute(builder: (_) => const AdminHome());
      case Routes.delegateHomeRoute:
        return MaterialPageRoute(builder: (_) => const DelegateHome());
      case Routes.centerHomeRoute:
        return MaterialPageRoute(builder: (_) => const CenterHome());
      case Routes.allCentersRoute:
        return MaterialPageRoute(builder: (_) => const AllCentersScreen());
      case Routes.centerDetailsRoute:
        final id = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => CenterDetailsScreen(centerId: id));
      case Routes.myOrdersRoute:
        return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
      case Routes.createOrderRoute:
        final centerId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => CreateOrderScreen(centerId: centerId));
      case Routes.orderTrackingRoute:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: orderId));
      case Routes.delegateAvailableOrdersRoute:
        return MaterialPageRoute(builder: (_) => const AvailablePickupOrdersScreen());
      case Routes.delegateTasksRoute:
        return MaterialPageRoute(builder: (_) => const DelegateTasksScreen());
      case Routes.centerOrderDetailsRoute:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => CenterOrderDetailsScreen(orderId: orderId));
      case Routes.submitInspectionRoute:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => SubmitInspectionScreen(orderId: orderId));
      case Routes.submitPriceOfferRoute:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => SubmitPriceOfferScreen(orderId: orderId));
      case Routes.orderPaymentRoute:
        final orderId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => OrderPaymentScreen(orderId: orderId));
      case Routes.delegateSettlementsRoute:
        return MaterialPageRoute(builder: (_) => const DelegateSettlementsScreen());
      case Routes.centerSettlementsRoute:
        return MaterialPageRoute(builder: (_) => const CenterSettlementsScreen());
      case Routes.adminSettlementsRoute:
        return MaterialPageRoute(builder: (_) => const AdminSettlementsScreen());
      case Routes.adminSettlementsSummaryRoute:
        return MaterialPageRoute(builder: (_) => const AdminSettlementsSummaryScreen());
      case Routes.addCenterServiceRoute:
        return MaterialPageRoute(builder: (_) => const AddCenterServiceScreen());
      case Routes.centerServicesRoute:
        return MaterialPageRoute(builder: (_) => const CenterServicesScreen());
      case Routes.centerServiceDetailsRoute:
        final serviceId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => CenterServiceDetailsScreen(serviceId: serviceId));
      case Routes.editCenterServiceRoute:
        final service = settings.arguments as ServiceEntity;
        return MaterialPageRoute(builder: (_) => EditCenterServiceScreen(service: service));
      case Routes.delegateEarningsRoute:
        return MaterialPageRoute(builder: (_) => const DelegateEarningsScreen());
      case Routes.mapPickerRoute:
        final initialLoc = settings.arguments as MapLocationEntity?;
        return MaterialPageRoute(builder: (_) => MapPickerScreen(initialLocation: initialLoc));
      case Routes.delegateRouteViewRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DelegateRouteViewScreen(
            originLat: args['originLat'] as double,
            originLng: args['originLng'] as double,
            destLat: args['destLat'] as double,
            destLng: args['destLng'] as double,
            destinationTitle: args['destinationTitle'] as String? ?? 'الموقع المستهدف',
            destinationAddress: args['destinationAddress'] as String?,
          ),
        );
      default:
        return unDefinedRoute();

    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('No Route Found'),
        ),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
}
