import 'package:flutter/material.dart';

class EchoLinkZButton extends StatelessWidget {
  const EchoLinkZButton(
      {super.key,
      required this.title,
      required this.onPressed,
      this.isLoading = false,
      this.isEnable = true});
  final String title;
  final void Function() onPressed;
  final bool isEnable;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        disabledBackgroundColor:
            Theme.of(context).colorScheme.onSecondary.withOpacity(0.3),
      ),
      onPressed: isEnable ? onPressed : null,
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary),
              ),
            )
          : Text(title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              )),
    );
  }
}
