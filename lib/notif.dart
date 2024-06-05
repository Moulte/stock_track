import 'package:flutter/material.dart';

void displayNotif(BuildContext context, String message, {Duration duration = const Duration(seconds: 20)}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.fixed,
      duration: duration,
      content: Text(message),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      action: SnackBarAction(label: "Fermer", onPressed: () => ScaffoldMessenger.of(context).removeCurrentSnackBar()),
    ),
  );
}
