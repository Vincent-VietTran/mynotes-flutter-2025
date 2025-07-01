import 'dart:developer';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';

void showDeligtfulToast(String message, BuildContext context) {
    log(message);
    DelightToastBar(
      builder: (context) => ToastCard(
        leading: const Icon(
          Icons.flutter_dash,
          size: 28,
        ),
        title: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      autoDismiss: true,
    ).show(context);
  }