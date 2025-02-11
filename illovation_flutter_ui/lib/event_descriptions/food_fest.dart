import 'package:flutter/material.dart';

class FoodFestivalPage extends StatelessWidget {
  const FoodFestivalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iloilo Food Festival')),
      body: const Center(
        child: Text(
          'Details about the Iloilo Food Festival.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

