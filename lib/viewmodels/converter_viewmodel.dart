import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_viewmodel.dart';
import 'settings_viewmodel.dart';
import '../core/utils/formatter.dart';

class ConverterViewModel
    extends
        GetxController {
  final HomeViewModel
  _homeVm =
      Get.find<
        HomeViewModel
      >();
  final SettingsViewModel
  _settingsVm =
      Get.find<
        SettingsViewModel
      >();

  final RxString
  selectedMetal = 'XAU'
      .obs; // XAU, XAG, XPT
  final RxString
  selectedKarat = '24K'
      .obs; // 24K, 22K, 21K, 18K
  final RxString
  sourceUnit =
      'Gram (g)'
          .obs; // Gram, Tola, Ounce

  final TextEditingController
  weightController =
      TextEditingController();
  final TextEditingController
  cashController =
      TextEditingController();

  final RxDouble
  calculatedCash =
      0.0.obs;
  final RxDouble
  calculatedWeightInGrams =
      0.0.obs;
  final RxDouble
  calculatedWeightInTolas =
      0.0.obs;
  final RxDouble
  calculatedWeightInOunces =
      0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Default initial inputs
    weightController
            .text =
        '1';
    convertFromWeight(
      '1',
    );
  }

  void selectMetal(
    String val,
  ) {
    selectedMetal
            .value =
        val;
    // Recalculate
    if (weightController
        .text
        .isNotEmpty) {
      convertFromWeight(
        weightController
            .text,
      );
    }
  }

  void
  selectSourceUnit(
    String val,
  ) {
    sourceUnit
            .value =
        val;
    if (weightController
        .text
        .isNotEmpty) {
      convertFromWeight(
        weightController
            .text,
      );
    }
  }

  void updateCarat(
    String karat,
  ) {
    selectedKarat
            .value =
        karat;
    if (weightController
        .text
        .isNotEmpty) {
      convertFromWeight(
        weightController
            .text,
      );
    }
  }

  // Calculate cash cost from weight: Weight -> Grams -> Cash Cost
  void
  convertFromWeight(
    String input,
  ) {
    if (input
        .isEmpty) {
      _clearOutputs();
      return;
    }

    double weight =
        double.tryParse(
          input,
        ) ??
        0.0;
    double grams =
        0.0;

    // Convert input unit to grams
    if (sourceUnit
            .value ==
        'Gram (g)') {
      grams =
          weight;
    } else if (sourceUnit
            .value ==
        'Tola') {
      grams =
          weight *
          11.6638;
    } else {
      // Ounce
      grams =
          weight *
          31.1035;
    }

    double
    basePricePerGram24K =
        _homeVm.getPricePerGram24K(
          selectedMetal
              .value,
        );

    // Apply selected karat purity multiplier (24K baseline)
    double
    purityMultiplier =
        1.0;
    switch (selectedKarat
        .value) {
      case '22K':
        purityMultiplier =
            22 / 24;
        break;
      case '21K':
        purityMultiplier =
            21 / 24;
        break;
      case '18K':
        purityMultiplier =
            18 / 24;
        break;
      case '24K':
      default:
        purityMultiplier =
            1.0;
        break;
    }

    double
    pricePerGramSelectedKarat =
        basePricePerGram24K *
        purityMultiplier;

    double
    totalCash =
        grams *
        pricePerGramSelectedKarat;

    calculatedCash
            .value =
        totalCash;
    cashController
            .text =
        totalCash
            .toStringAsFixed(
              0,
            );

    // Compute other weights
    calculatedWeightInGrams
            .value =
        grams;
    calculatedWeightInTolas
            .value =
        grams /
        11.6638;
    calculatedWeightInOunces
            .value =
        grams /
        31.1035;
  }

  // Calculate weight from cash cost: Cash -> Grams -> Other Units
  void
  convertFromCash(
    String input,
  ) {
    if (input
        .isEmpty) {
      _clearOutputs();
      return;
    }

    double cash =
        double.tryParse(
          input,
        ) ??
        0.0;
    double
    basePricePerGram24K =
        _homeVm.getPricePerGram24K(
          selectedMetal
              .value,
        );

    double
    purityMultiplier =
        1.0;
    switch (selectedKarat
        .value) {
      case '22K':
        purityMultiplier =
            22 / 24;
        break;
      case '21K':
        purityMultiplier =
            21 / 24;
        break;
      case '18K':
        purityMultiplier =
            18 / 24;
        break;
      case '24K':
      default:
        purityMultiplier =
            1.0;
        break;
    }

    double
    pricePerGramSelectedKarat =
        basePricePerGram24K *
        purityMultiplier;

    if (pricePerGramSelectedKarat <=
        0) {
      _clearOutputs();
      return;
    }

    double grams =
        cash /
        pricePerGramSelectedKarat;

    calculatedCash
            .value =
        cash;

    // Sync weight controller
    double
    displayWeight =
        0.0;
    if (sourceUnit
            .value ==
        'Gram (g)') {
      displayWeight =
          grams;
    } else if (sourceUnit
            .value ==
        'Tola') {
      displayWeight =
          grams /
          11.664;
    } else {
      displayWeight =
          grams /
          31.1035;
    }
    weightController
            .text =
        displayWeight
            .toStringAsFixed(
              2,
            );

    calculatedWeightInGrams
            .value =
        grams;
    calculatedWeightInTolas
            .value =
        grams /
        11.6638;
    calculatedWeightInOunces
            .value =
        grams /
        31.1035;
  }

  void
  _clearOutputs() {
    calculatedCash
            .value =
        0.0;
    calculatedWeightInGrams
            .value =
        0.0;
    calculatedWeightInTolas
            .value =
        0.0;
    calculatedWeightInOunces
            .value =
        0.0;
  }

  String
  formatCurrency(
    double val,
  ) {
    return AppFormatter.formatCurrency(
      val,
      _settingsVm
          .selectedCurrency
          .value,
    );
  }

  @override
  void onClose() {
    weightController
        .dispose();
    cashController
        .dispose();
    super.onClose();
  }
}
