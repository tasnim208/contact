import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/contact.dart';
import '../widgets/contact_card.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';

class ContactListScreen extends StatefulWidget {
  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = true;

  void fetchContacts() async {
    setState(() {
      _isLoading = true;
    });

    contacts = await ApiService.getContacts();
    filteredContacts = contacts;

    setState(() {
      _isLoading = false;
    });
  }

  // ✅ FONCTION DE RECHERCHE
  void searchContacts(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredContacts = contacts;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Recherche côté backend
    final results = await ApiService.searchContacts(query);

    setState(() {
      filteredContacts = results;
    });
  }

  void clearSearch() {
    _searchController.clear();
    setState(() {
      filteredContacts = contacts;
      _isSearching = false;
    });
  }

  void deleteContact(String id) async {
    bool success = await ApiService.deleteContact(id);
    if (success) {
      fetchContacts(); // Recharger la liste
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contact supprimé avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchContacts();

    // Écouteur pour la recherche en temps réel
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        searchContacts(_searchController.text);
      } else {
        setState(() {
          filteredContacts = contacts;
          _isSearching = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Rechercher un contact...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
        )
            : Text('Répertoire'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: clearSearch,
            )
          else
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // ✅ INDICATEUR DE RECHERCHE
          if (_isSearching && _searchController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    '${filteredContacts.length} contact(s) trouvé(s) pour "${_searchController.text}"',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredContacts.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isSearching && _searchController.text.isNotEmpty)
                    Column(
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun contact trouvé',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Essayez avec d\'autres termes',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Icon(Icons.contacts, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun contact',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Ajoutez votre premier contact !',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddContactScreen(refresh: fetchContacts),
                            ),
                          ),
                          child: Text('Ajouter un contact'),
                        ),
                      ],
                    ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                return ContactCard(
                  contact: filteredContacts[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditContactScreen(
                        contact: filteredContacts[index],
                        refresh: fetchContacts,
                      ),
                    ),
                  ),
                  onDelete: () => deleteContact(filteredContacts[index].id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddContactScreen(refresh: fetchContacts),
          ),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}