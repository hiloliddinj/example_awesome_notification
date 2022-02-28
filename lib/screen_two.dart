import 'package:flutter/material.dart';

class ScreenTwo extends StatelessWidget {
  static const String route = 'ScreenTwo';
  const ScreenTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Screen Two"),),
      body: const Center(
        child: Text("Screen Two"),
      ),
    );
  }
}