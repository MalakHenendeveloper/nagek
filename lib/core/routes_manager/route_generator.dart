import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/client_home.dart';
import '../../features/home/presentation/screens/admin_home.dart';
import '../../features/home/presentation/screens/delegate_home.dart';
import '../../features/home/presentation/screens/center_home.dart';
import '../../features/centers/presentation/screens/all_centers_screen.dart';
import '../../features/centers/presentation/screens/center_details_screen.dart';
import '../../features/orders/presentation/screens/create_order_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/my_orders_screen.dart';
import 'routes.dart';


class RouteGenerator {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
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
