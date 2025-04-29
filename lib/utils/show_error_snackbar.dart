import 'package:flutter/material.dart';

showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
    backgroundColor: Colors.red,
  ));
}
