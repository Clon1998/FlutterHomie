import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class SnackBarHelpers {
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    String title,
    Duration duration = const Duration(seconds: 5),
  }) {
    Flushbar(
      title: title,
      message: message ?? 'Empty Message',
      icon: Icon(
        Icons.done,
        color: Colors.green,
      ),
      animationDuration: kThemeAnimationDuration,
      duration: duration,
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      flushbarStyle:  FlushbarStyle.GROUNDED,
      onTap: (flushBar) {
        flushBar.dismiss();
      },
    )..show(context);
  }

  static void showInfoSnackBar(
    BuildContext context,
    String message, {
    String title,
    Duration duration = const Duration(seconds: 5),
  }) {
    Flushbar(
      title: title,
      message: message ?? 'Empty Message',
      icon: Icon(
        Icons.info_outline,
        color: Colors.lightBlue,
      ),
      animationDuration: kThemeAnimationDuration,
      duration: duration,
      onTap: (flushBar) {
        flushBar.dismiss();
      },
    )..show(context);
  }

  //Move to own class
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    String title,
    Duration duration = const Duration(seconds: 5),
  }) {
    Flushbar(
      title: title,
      message: message ?? 'Empty Message',
      icon: Icon(
        Icons.error_outline,
        color: Colors.orangeAccent,
      ),
      animationDuration: kThemeAnimationDuration,
      leftBarIndicatorColor: Colors.orangeAccent,
      duration: duration,
      onTap: (flushBar) {
        flushBar.dismiss();
      },
    )..show(context);
  }

  //Todo: Throw error since this class is just a helper class
  SnackBarHelpers();
}
