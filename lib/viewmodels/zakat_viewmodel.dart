import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_viewmodel.dart';
import 'settings_viewmodel.dart';
import '../data/models/zakat_result.dart';
import '../core/utils/calculator.dart';
import '../core/utils/formatter.dart';

class ZakatViewModel extends GetxController {
  final HomeViewModel _homeVm = Get.find<HomeViewModel>();
  final SettingsViewModel _settingsVm = Get.find<SettingsViewModel>();

  // Text inputs
  final TextEditingController goldWeightController = TextEditingController();
  final TextEditingController silverWeightController = TextEditingController();
  final TextEditingController cashController = TextEditingController();
  final TextEditingController investmentsController = TextEditingController();
  final TextEditingController liabilitiesController = TextEditingController();

  final RxString activeWeightUnit = 'Gram (g)'.obs; // Gram (g), Tola
  final RxString activeNisabThresholdType = 'Silver'.obs; // "Silver" (recommended) or "Gold"

  final Rx<ZakatResult> result = ZakatResult.empty().obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill initial defaults
    goldWeightController.text = '0';
    silverWeightController.text = '0';
    cashController.text = '0';
    investmentsController.text = '0';
    liabilitiesController.text = '0';
    
    // Automatically bind setting unit type
    if (_settingsVm.selectedUnit.value.startsWith('Tola')) {
      activeWeightUnit.value = 'Tola';
    } else {
      activeWeightUnit.value = 'Gram (g)';
    }

    calculate();
  }

  void calculate() {
    double goldInput = double.tryParse(goldWeightController.text) ?? 0.0;
    double silverInput = double.tryParse(silverWeightController.text) ?? 0.0;
    double cash = double.tryParse(cashController.text) ?? 0.0;
    double other = double.tryParse(investmentsController.text) ?? 0.0;
    double debt = double.tryParse(liabilitiesController.text) ?? 0.0;

    // Convert inputs to grams if entered in tolas
    double goldGrams = activeWeightUnit.value == 'Tola' ? goldInput * 11.6638 : goldInput;
    double silverGrams = activeWeightUnit.value == 'Tola' ? silverInput * 11.6638 : silverInput;

    double goldPrice = _homeVm.getPricePerGram24K('XAU');
    double silverPrice = _homeVm.getPricePerGram24K('XAG');

    result.value = AppCalculator.calculateZakat(
      goldGrams: goldGrams,
      goldPricePerGram: goldPrice,
      silverGrams: silverGrams,
      silverPricePerGram: silverPrice,
      cashAmount: cash,
      otherAssets: other,
      liabilities: debt,
      nisabType: activeNisabThresholdType.value,
    );
  }

  void toggleWeightUnit(String val) {
    activeWeightUnit.value = val;
    calculate();
  }

  void toggleNisabType(String val) {
    activeNisabThresholdType.value = val;
    calculate();
  }

  String formatCurrency(double val) {
    return AppFormatter.formatCurrency(val, _settingsVm.selectedCurrency.value);
  }

  @override
  void onClose() {
    goldWeightController.dispose();
    silverWeightController.dispose();
    cashController.dispose();
    investmentsController.dispose();
    liabilitiesController.dispose();
    super.onClose();
  }
}
