import 'package:flutter/material.dart';
import '../services/contact_service.dart';
import '../models/contact.dart';
import '../widgets/contact_card.dart';
import '../widgets/voice_search_button.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';
import 'duplicate_contacts_screen.dart';
import '../utils/constants.dart';

class ContactListScreen extends StatefulWidget {
  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final ContactService _contactService = ContactService();
  final TextEditingController _searchController = TextEditingController();

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  bool _isSearching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      contacts = await _contactService.getContacts();
      filteredContacts = List.from(contacts);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        filteredContacts = List.from(contacts);
        _isSearching = false;
      });
    } else {
      _searchContacts(_searchController.text);
    }
  }

  Future<void> _searchContacts(String query) async {
    setState(() => _isSearching = true);
    try {
      final results = await _contactService.searchContacts(query);
      setState(() => filteredContacts = results);
    } catch (e) {
      setState(() => filteredContacts = []);
    }
  }

  void _onVoiceTextRecognized(String text) {
    _searchController.text = text;
  }

  void _onVoiceError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _deleteContact(int id) async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce contact ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _contactService.deleteContact(id);
        await _loadContacts(); // Recharger la liste
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text(AppConstants.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(AppConstants.primaryColor)),
            child: Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _contactService.logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _showDuplicateContacts() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DuplicateContactsScreen()),
    );

    if (result == true) {
      await _loadContacts(); // Rafraîchir si des doublons ont été fusionnés
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppConstants.backgroundColor),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppConstants.searchHint,
            border: InputBorder.none,
            hintStyle: TextStyle(color: Color(0xFF99C2FF)),
          ),
          style: TextStyle(color: Color(AppConstants.textColor)),
        )
            : Text(
          'Mes Contacts',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(AppConstants.textColor),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_isSearching) ...[
            VoiceSearchButton(
              onTextRecognized: _onVoiceTextRecognized,
              onError: _onVoiceError,
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.clear, color: Color(AppConstants.primaryColor)),
              onPressed: () {
                _searchController.clear();
                setState(() => _isSearching = false);
              },
            ),
          ] else ...[
            IconButton(
              icon: Icon(Icons.merge, color: Color(AppConstants.primaryColor)),
              onPressed: _showDuplicateContacts,
              tooltip: 'Vérifier les doublons',
            ),
            IconButton(
              icon: Icon(Icons.search, color: Color(AppConstants.primaryColor)),
              onPressed: () => setState(() => _isSearching = true),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Color(AppConstants.primaryColor)),
              onSelected: (value) {
                if (value == 'logout') _logout();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Text('Déconnexion'),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Statistiques
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', contacts.length, Icons.contacts),
                _buildStatItem('Trouvés', filteredContacts.length, Icons.search),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Indicateur de recherche vocale
          if (_isSearching && _searchController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              color: Color(0xFFE6F2FF),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: Color(AppConstants.primaryColor)),
                  SizedBox(width: 8),
                  Text(
                    '${filteredContacts.length} contact(s) trouvé(s)',
                    style: TextStyle(color: Color(AppConstants.primaryColor)),
                  ),
                ],
              ),
            ),

          // Liste des contacts
          Expanded(
            child: filteredContacts.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadContacts,
              child: ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  return ContactCard(
                    contact: contact,
                    onEdit: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditContactScreen(
                          contact: contact,
                          refresh: _loadContacts,
                        ),
                      ),
                    ),
                    onDelete: () => _deleteContact(contact.id!),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddContactScreen(refresh: _loadContacts),
          ),
        ),
        backgroundColor: Color(AppConstants.primaryColor),
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFE6F2FF),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: Color(AppConstants.primaryColor)),
        ),
        SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isSearching ? Icons.search_off : Icons.contacts_outlined,
            size: 80,
            color: Color(AppConstants.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            _isSearching ? 'Aucun contact trouvé' : AppConstants.noContacts,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            _isSearching ? 'Essayez avec d\'autres termes' : 'Ajoutez votre premier contact',
            style: TextStyle(color: Color(AppConstants.accentColor)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}