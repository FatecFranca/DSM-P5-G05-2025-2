import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String text;

  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding inside
      padding: const EdgeInsets.all(25.0),

      decoration: BoxDecoration(
        // color
        color: Theme.of(context).colorScheme.secondary,
      ),

      width: double.infinity,

      child: Text(
        text.isNotEmpty ? text : "Empty bio..",
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
