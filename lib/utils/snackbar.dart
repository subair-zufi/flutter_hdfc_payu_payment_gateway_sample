import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackBarType { error, success, warning }

snackBar(String title, String message, SnackBarType type) => Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: type == SnackBarType.error
          ? Colors.redAccent
          : type == SnackBarType.success
              ? Colors.green
              : Colors.orange,
      duration: const Duration(seconds: 5),
      animationDuration: const Duration(milliseconds: 200),
      colorText: Colors.white,
      borderRadius: 8.0,
      maxWidth: 400.0,margin: const EdgeInsets.only(bottom: 12.0)
    );
