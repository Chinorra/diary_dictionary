import 'package:flutter/material.dart';

class AddWordPage extends StatelessWidget {
  const AddWordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Word'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Add New Word Page',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
