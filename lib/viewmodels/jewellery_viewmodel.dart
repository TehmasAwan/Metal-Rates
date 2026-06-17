import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_viewmodel.dart';
import 'settings_viewmodel.dart';
import '../core/utils/calculator.dart';
import '../core/utils/formatter.dart';

class JewelleryViewModel extends GetxController {
  final HomeViewModel _homeVm = Get.find<HomeViewModel>();
  final SettingsViewModel _settingsVm = Get.find<SettingsViewModel>();

  // Input Controllers
  final TextEditingController weightController = TextEditingController();
  final TextEditingController makingChargesController = TextEditingController();
  final TextEditingController taxController = TextEditingController();

  final RxString selectedCarat = '22K'.obs; // 24K, 22K, 21K, 18K
  final RxString selectedWeightUnit = 'Gram (g)'.obs; // Gram (g), Tola
  final RxBool isMakingChargesPercentage = true.obs; // true for %, false for flat fee

  final RxDouble rawMetalPrice = 0.0.obs;
  final RxDouble estimatedTotalPrice = 0.0.obs;

  final List<String> caratsList = ['24K', '22K', '21K', '18K'];

  @override
  void onInit() {
    super.onInit();
    weightController.text = '10';
    makingChargesController.text = '8'; // 8% by default
    taxController.text = '3'; // 3% GST/tax by default
    
    if (_settingsVm.selectedUnit.value.startsWith('Tola')) {
      selectedWeightUnit.value = 'Tola';
    } else {
      selectedWeightUnit.value = 'Gram (g)';
    }

    calculate();
  }

  void calculate() {
    double weightInput = double.tryParse(weightController.text) ?? 0.0;
    double makingValue = double.tryParse(makingChargesController.text) ?? 0.0;
    double taxPercent = double.tryParse(taxController.text) ?? 0.0;

    // Convert to grams for core calculator
    double weightInGrams = selectedWeightUnit.value == 'Tola' ? weightInput * 11.6638 : weightInput;

    double basePricePerGram24K = _homeVm.getPricePerGram24K('XAU');

    // Calculate purity factor
    double purity = 1.0;
    switch (selectedCarat.value) {
      case '22K': purity = 22 / 24; break;
      case '21K': purity = 21 / 24; break;
      case '18K': purity = 18 / 24; break;
      case '24K': default: purity = 1.0; break;
    }

    rawMetalPrice.value = basePricePerGram24K * purity * weightInGrams;

    estimatedTotalPrice.value = AppCalculator.calculateJewelleryPrice(
      basePricePerGram24K: basePricePerGram24K,
      weight: weightInGrams,
      carat: selectedCarat.value,
      makingChargesValue: makingValue,
      isMakingChargesPercentage: isMakingChargesPercentage.value,
      taxPercentage: taxPercent,
    );
  }

  void updateCarat(String carat) {
    selectedCarat.value = carat;
    calculate();
  }

  void toggleWeightUnit(String unit) {
    selectedWeightUnit.value = unit;
    calculate();
  }

  void toggleMakingChargesType(bool isPercent) {
    isMakingChargesPercentage.value = isPercent;
    makingChargesController.text = isPercent ? '8' : '5000';
    calculate();
  }

  String formatCurrency(double val) {
    return AppFormatter.formatCurrency(val, _settingsVm.selectedCurrency.value);
  }

  @override
  void onClose() {
    weightController.dispose();
    makingChargesController.dispose();
    taxController.dispose();
    super.onClose();
  }
}
