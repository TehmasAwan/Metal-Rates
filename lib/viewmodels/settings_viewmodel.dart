import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/services/storage_service.dart';
import '../data/services/api_service.dart';

class SettingsViewModel extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiService _apiService = Get.find<ApiService>();

  final RxString selectedCurrency = 'PKR'.obs;
  final RxString selectedCountry = 'Pakistan'.obs;
  final RxString selectedUnit = 'Tola'.obs;
  final RxBool isDarkMode = true.obs;

  // Notification and Alert Preferences
  final RxBool priceAlertEnabled = false.obs;
  final RxDouble targetPrice = 2350.0.obs;

  final List<String> availableCurrencies = ['PKR', 'USD', 'INR', 'AED'];
  final List<String> availableCountries = [
    'Pakistan',
    'United States',
    'India',
    'United Arab Emirates',
  ];
  final List<String> availableUnits = ['Gram (g)', 'Tola', 'Ounce (oz)'];

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
    _syncAlertWithBackend();
  }

  void loadPreferences() {
    selectedCurrency.value = _storageService.getCurrency();
    selectedCountry.value = _storageService.getCountry();
    selectedUnit.value = _storageService.getUnit();
    isDarkMode.value = _storageService.getDarkMode();
    targetPrice.value = _storageService.getTargetPrice();
    priceAlertEnabled.value = _storageService.getPriceAlertEnabled();
  }

  String _calculateCondition() {
    final currentGoldPrice = (_apiService.rates['XAU']?.priceUsd ?? ApiService.baseGold) *
        (_apiService.exchangeRates[selectedCurrency.value] ?? 1.0);
    return targetPrice.value >= currentGoldPrice ? 'above' : 'below';
  }

  Future<void> _syncAlertWithBackend() async {
    if (priceAlertEnabled.value) {
      await _apiService.unsubscribeAlerts();
      final condition = _calculateCondition();
      final success = await _apiService.subscribeAlert(
        metal: 'gold',
        currency: selectedCurrency.value,
        target: targetPrice.value,
        condition: condition,
      );
      if (success) {
        Get.log('Alert synced successfully: ${selectedCurrency.value} ${targetPrice.value} ($condition)');
      } else {
        Get.log('Alert sync failed.');
      }
    } else {
      await _apiService.unsubscribeAlerts();
      Get.log('Alerts unsubscribed from backend.');
    }
  }

  void updateCurrency(String val) async {
    final oldCurrency = selectedCurrency.value;
    if (oldCurrency == val) return;

    final oldExchangeRate = _apiService.exchangeRates[oldCurrency] ?? 1.0;
    final newExchangeRate = _apiService.exchangeRates[val] ?? 1.0;

    selectedCurrency.value = val;
    await _storageService.saveCurrency(val);

    // Automatically match country for convenience if they switch currencies
    if (val == 'PKR') {
      selectedCountry.value = 'Pakistan';
    } else if (val == 'USD') {
      selectedCountry.value = 'United States';
    } else if (val == 'INR') {
      selectedCountry.value = 'India';
    } else if (val == 'AED') {
      selectedCountry.value = 'United Arab Emirates';
    }
    await _storageService.saveCountry(selectedCountry.value);

    // Update target price currency scaling
    if (oldExchangeRate > 0) {
      final newPrice = (targetPrice.value / oldExchangeRate) * newExchangeRate;
      targetPrice.value = newPrice;
      await _storageService.saveTargetPrice(newPrice);
    }

    if (priceAlertEnabled.value) {
      await _syncAlertWithBackend();
    }
  }

  void updateCountry(String val) async {
    final oldCurrency = selectedCurrency.value;
    selectedCountry.value = val;
    await _storageService.saveCountry(val);

    // Automatically match currency
    String newCurrency = selectedCurrency.value;
    if (val == 'Pakistan') {
      newCurrency = 'PKR';
    } else if (val == 'United States') {
      newCurrency = 'USD';
    } else if (val == 'India') {
      newCurrency = 'INR';
    } else if (val == 'United Arab Emirates') {
      newCurrency = 'AED';
    }

    if (oldCurrency != newCurrency) {
      final oldExchangeRate = _apiService.exchangeRates[oldCurrency] ?? 1.0;
      final newExchangeRate = _apiService.exchangeRates[newCurrency] ?? 1.0;

      selectedCurrency.value = newCurrency;
      await _storageService.saveCurrency(newCurrency);

      // Update target price currency scaling
      if (oldExchangeRate > 0) {
        final newPrice = (targetPrice.value / oldExchangeRate) * newExchangeRate;
        targetPrice.value = newPrice;
        await _storageService.saveTargetPrice(newPrice);
      }

      if (priceAlertEnabled.value) {
        await _syncAlertWithBackend();
      }
    }
  }

  void updateUnit(String val) {
    selectedUnit.value = val;
    _storageService.saveUnit(val);
  }

  void toggleDarkMode(bool val) {
    isDarkMode.value = val;
    _storageService.saveDarkMode(val);
    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
  }

  void togglePriceAlert(bool val) async {
    priceAlertEnabled.value = val;
    await _storageService.savePriceAlertEnabled(val);

    if (val) {
      final condition = _calculateCondition();
      final success = await _apiService.subscribeAlert(
        metal: 'gold',
        currency: selectedCurrency.value,
        target: targetPrice.value,
        condition: condition,
      );
      if (success) {
        Get.snackbar(
          'Alert Enabled',
          'You will be notified when gold goes $condition ${selectedCurrency.value} ${targetPrice.value.toStringAsFixed(0)}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Sync Failed',
          'Could not enable alert on server, preference saved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } else {
      final success = await _apiService.unsubscribeAlerts();
      if (success) {
        Get.snackbar(
          'Alert Disabled',
          'Price alerts have been turned off.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Sync Failed',
          'Could not disable alert on server, preference saved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    }
  }

  void updateTargetPrice(double val) async {
    targetPrice.value = val;
    await _storageService.saveTargetPrice(val);

    if (priceAlertEnabled.value) {
      await _apiService.unsubscribeAlerts();
      final condition = _calculateCondition();
      final success = await _apiService.subscribeAlert(
        metal: 'gold',
        currency: selectedCurrency.value,
        target: val,
        condition: condition,
      );
      if (success) {
        Get.snackbar(
          'Target Updated',
          'Target price updated to ${selectedCurrency.value} ${val.toStringAsFixed(0)} ($condition)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Sync Failed',
          'Target updated locally but failed to update on server.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    }
  }
}

