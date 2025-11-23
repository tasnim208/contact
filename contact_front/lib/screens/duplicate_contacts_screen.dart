import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import '../widgets/contact_card.dart';
import '../utils/constants.dart';

class DuplicateContactsScreen extends StatefulWidget {
  @override
  _DuplicateContactsScreenState createState() => _DuplicateContactsScreenState();
}

class _DuplicateContactsScreenState extends State<DuplicateContactsScreen> {
  final ContactService _contactService = ContactService();
  List<Contact> _duplicates = [];
  bool _isLoading = true;
  bool _isMerging = false;

  @override
  void initState() {
    super.initState();
    _loadDuplicates();
  }

  Future<void> _loadDuplicates() async {
    setState(() => _isLoading = true);
    try {
      _duplicates = await _contactService.findDuplicateContacts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des doublons: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _mergeDuplicates() async {
    setState(() => _isMerging = true);
    try {
      await _contactService.mergeDuplicateContacts(_duplicates);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Doublons fusionnés avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la fusion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isMerging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: Text(
          'Doublons de Contacts',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(AppConstants.textColor),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: Color(AppConstants.primaryColor)),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(AppConstants.primaryColor)),
        ),
      )
          : Column(
        children: [
          // En-tête avec statistiques
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Doublons', _duplicates.length.toString(), Icons.warning),
                _buildStatItem('Groupes', '${_duplicates.length ~/ 2}', Icons.group),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Bouton de fusion
          if (_duplicates.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
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
                  onPressed: _isMerging ? null : _mergeDuplicates,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isMerging
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
                      Icon(Icons.merge, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Fusionner les doublons',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SizedBox(height: 16),

          // Liste des doublons
          Expanded(
            child: _duplicates.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Aucun doublon trouvé',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textColor),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tous vos contacts sont uniques',
                    style: TextStyle(
                      color: Color(AppConstants.accentColor),
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _duplicates.length,
              itemBuilder: (context, index) {
                final contact = _duplicates[index];
                return ContactCard(
                  contact: contact,
                  onEdit: () {}, // Vide car pas d'édition dans cet écran
                  onDelete: () {}, // Vide car pas de suppression dans cet écran
                  showDeleteButton: false, // Cache le bouton supprimer
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFE6F2FF),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Color(AppConstants.primaryColor), size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(AppConstants.textColor),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(AppConstants.accentColor),
          ),
        ),
      ],
    );
  }
}