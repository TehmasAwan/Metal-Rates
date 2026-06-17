import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  static const String _keyCurrency = 'currency_preference';
  static const String _keyCountry = 'country_preference';
  static const String _keyUnit = 'unit_preference';
  static const String _keyDarkMode = 'dark_mode_preference';
  static const String _keyTargetPrice = 'target_price_preference';
  static const String _keyPriceAlertEnabled = 'price_alert_enabled_preference';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Getters
  String getCurrency() {
    return _prefs.getString(_keyCurrency) ?? 'PKR';
  }

  String getCountry() {
    return _prefs.getString(_keyCountry) ?? 'Pakistan';
  }

  String getUnit() {
    return _prefs.getString(_keyUnit) ?? 'Tola';
  }

  bool getDarkMode() {
    return _prefs.getBool(_keyDarkMode) ?? true;
  }

  double getTargetPrice() {
    return _prefs.getDouble(_keyTargetPrice) ?? 2350.0;
  }

  bool getPriceAlertEnabled() {
    return _prefs.getBool(_keyPriceAlertEnabled) ?? false;
  }

  // Setters
  Future<bool> saveCurrency(String currency) async {
    return await _prefs.setString(_keyCurrency, currency);
  }

  Future<bool> saveCountry(String country) async {
    return await _prefs.setString(_keyCountry, country);
  }

  Future<bool> saveUnit(String unit) async {
    return await _prefs.setString(_keyUnit, unit);
  }

  Future<bool> saveDarkMode(bool isDark) async {
    return await _prefs.setBool(_keyDarkMode, isDark);
  }

  Future<bool> saveTargetPrice(double price) async {
    return await _prefs.setDouble(_keyTargetPrice, price);
  }

  Future<bool> savePriceAlertEnabled(bool enabled) async {
    return await _prefs.setBool(_keyPriceAlertEnabled, enabled);
  }
}

