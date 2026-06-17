class ApiKeys {
  // Option to enter a real API key from goldapi.io or metalpriceapi.com
  static const String
  goldApiKey = '';

  // Set to true if a real API should be called instead of the simulated engine
  static const bool
  useLiveApi = true;

  // New MetalRates API credentials
  static const String
  metalApiKey =
      'metalbk_super_secret_jwt_key_change_this_in_production';
  static const String
  metalApiBaseUrl =
      'https://www.metal.hassaanahmad.dev/api/all';
}
