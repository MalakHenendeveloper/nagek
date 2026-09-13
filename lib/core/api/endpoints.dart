// ignore_for_file: constant_identifier_names

class Endpoints {
  //Deployment

  static const String Url = 'https://3gra4rwnt-ciauy5rso-nagek.vercel.app/api';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerDelegate = '/auth/register-delegate';
  static const String delegateLogin = '/auth/delegate/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String centers = '/centers';
  static const String centerDetails = '/centers/';
  static const String centerDetailsServices = '/centers/';
  static const String orders = '/orders';
  static const String validateCoupon = '/orders/validate-coupon';
  static const String availableCoupons = '/coupons/available';
  static const String orderPayment = '/orders/';
  static const String inspection = '/inspection';
  static const String priceOffer = '/price-offer';
  static const String profile = '/users/profile';
  static const String addresses = '/users/addresses';
  static const String availablePickupOrders =
      '/delegate/orders/available-pickup';
  static const String availableDeliveryOrders =
      '/delegate/orders/available-delivery';
  static const String delegateOrders = '/delegate/orders';
  static const String delegateTasks = '/delegate/tasks';
  static const String delegateDashboard = '/delegate/dashboard';
  static const String delegateSettlements = '/delegate/settlements';
  static const String centerDashboard = '/centers/dashboard';
  static const String centerDashboardProfile = '/centers/dashboard/profile';
  static const String centerSettlements = '/centers/settlements';
  static const String centerDashboardOrders = '/centers/dashboard/orders';
  static const String centerDashboardOrderDetails =
      '/centers/dashboard/orders/';
  static const String centerDashboardInspection = '/centers/dashboard/orders/';
  static const String centerDashboardPriceOffer = '/centers/dashboard/orders/';
  static const String centerServices = '/center/services';
  static String centerServiceDetails(String serviceId) =>
      '/center/services/$serviceId';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminSettlements = '/admin/settlements';
  static const String adminSettlementsSummary = '/admin/settlements/summary';
  static String payAdminSettlement(String id) => '/admin/settlements/$id/pay';
  static String updateOrderSettlement(String orderId) =>
      '/admin/orders/$orderId/settlement';
  static const String adminDelegates = '/admin/delegates';
  static const String adminUsers = '/admin/users';
  static const String adminCenters = '/admin/centers';
  static const String adminCoupons = '/admin/coupons';
  static String adminUpdateCoupon(String id) => '/admin/coupons/$id';
  static const String adminUserDetails = '/admin/users/';
  static const String adminOrders = '/admin/orders';
  static const String adminDelegateApplications =
      '/admin/delegate-applications';
  static const String adminPayments = '/admin/payments';
  static const String adminPaymentSettings = '/admin/payment-settings';
  static const String adminFinancialSettings = '/admin/financial-settings';

  // Delegate task endpoints
  static String confirmPickupCenter(String orderId) =>
      '/delegate/tasks/$orderId/confirm-pickup-center';
  static String confirmDelivery(String orderId) =>
      '/delegate/tasks/$orderId/confirm-delivery';
  static const String delegatePushTokens = '/delegate/push-tokens';
}
