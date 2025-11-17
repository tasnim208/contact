import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddContactScreen extends StatefulWidget {
  final VoidCallback refresh;
  AddContactScreen({required this.refresh});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _nomController = TextEditingController();
  final _numeroController = TextEditingController();

  void addContact() async {
    bool success = await ApiService.addContact(_nomController.text, _numeroController.text);
    if (success) {
      widget.refresh();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'ajout')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter Contact')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nomController, decoration: InputDecoration(labelText: 'Nom')),
            TextField(controller: _numeroController, decoration: InputDecoration(labelText: 'Numéro')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: addContact, child: Text('Ajouter')),
          ],
        ),
      ),
    );
  }
}
