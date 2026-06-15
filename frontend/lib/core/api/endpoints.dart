abstract final class Endpoints {
  static const String authRegister = '/auth/register';
  static const String authToken = '/auth/token';
  static const String authMe = '/auth/me';

  static const String categories = '/categories';
  static String category(int id) => '/categories/$id';

  static const String products = '/products';
  static String product(int id) => '/products/$id';

  static const String orders = '/orders';
  static String order(int id) => '/orders/$id';
  static String cancelOrder(int id) => '/orders/$id/cancel';
}
