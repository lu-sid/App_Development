class ApiService {
  Future<String> fetchSubscriptionStatus() async {
    await Future.delayed(const Duration(seconds: 1));
    return 'Active';
  }
}
