// ignore_for_file: constant_identifier_names

class Endpoints {
  static const String Url = 'https://sigma-two-45.vercel.app/api';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String registerDelegate = '/auth/register-delegate';
  static const String delegateLogin = '/auth/delegate/login';
  static const String refreshToken = '/auth/refresh-token';
  static const String centers = '/centers';
  static const String centerDetails = '/centers/';
  static const String centerServices = '/centers/';
  static const String orders = '/orders';
  static const String inspection = '/inspection';
  static const String priceOffer = '/price-offer';
  static const String profile = '/users/profile';
  static const String addresses = '/users/addresses';
  
  // Admin Endpoints
  static const String adminDelegates = '/admin/delegates';
  static const String adminUsers = '/admin/users';
  static const String adminCenters = '/admin/centers';
  static const String adminUserDetails = '/admin/users/';
  static const String adminOrders = '/admin/orders';
  static const String adminDelegateApplications = '/admin/delegate-applications';
}

