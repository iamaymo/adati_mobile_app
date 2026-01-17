import 'package:flutter/material.dart';

class OperationsPage extends StatefulWidget {
  const OperationsPage({super.key});

  @override
  State<OperationsPage> createState() => _OperationsPageState();
}

class _OperationsPageState extends State<OperationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operations'), centerTitle: true),
      body: const Center(child: Text('This is the Operations Page')),
    );
  }
}
