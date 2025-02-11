import 'package:flutter/material.dart';

class ParawRegattaPage extends StatelessWidget {
  const ParawRegattaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paraw Regatta Festival')),
      body: const Center(
        child: Text(
          'Details about the Paraw Regatta Festival.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}