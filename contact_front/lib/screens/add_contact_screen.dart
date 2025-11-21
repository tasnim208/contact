import 'package:flutter/material.dart';
import '../services/contact_service.dart';

class AddContactScreen extends StatefulWidget {
  final VoidCallback refresh;
  AddContactScreen({required this.refresh});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final ContactService _contactService = ContactService();
  final _nomController = TextEditingController();
  final _numeroController = TextEditingController();
  bool _isLoading = false;

  void addContact() async {
    if (_nomController.text.isEmpty || _numeroController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Color(0xFF0066CC),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // CORRECTION: addContact() retourne int, pas bool
      final contactId = await _contactService.addContact(
        _nomController.text,
        _numeroController.text,
      );

      if (contactId > 0) {
        widget.refresh();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact ajouté avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ajout'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(
        title: Text(
          'Nouveau Contact',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF003366),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF003366),
        elevation: 2,
        iconTheme: IconThemeData(color: Color(0xFF0066CC)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0066CC), Color(0xFF00A8FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0066CC).withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_add_alt_1,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Ajouter un nouveau contact',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF003366),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Remplissez les informations ci-dessous',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6699CC),
                ),
              ),
              SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0066CC).withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person, color: Color(0xFF0066CC)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Ex: Jean Dupont',
                    hintStyle: TextStyle(color: Color(0xFF99C2FF)),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  style: TextStyle(fontSize: 16, color: Color(0xFF003366)),
                ),
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0066CC).withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _numeroController,
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF0066CC)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Ex: 06 12 34 56 78',
                    hintStyle: TextStyle(color: Color(0xFF99C2FF)),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  keyboardType: TextInputType.phone,
                  style: TextStyle(fontSize: 16, color: Color(0xFF003366)),
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Color(0xFF0066CC), Color(0xFF00A8FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0066CC).withOpacity(0.4),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : addContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ajouter le contact',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFE6F2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFCCE5FF)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFF0066CC), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Le contact sera ajouté à votre répertoire et pourra être modifié ultérieurement.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0066CC),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _numeroController.dispose();
    super.dispose();
  }
}