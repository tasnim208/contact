import 'package:flutter/material.dart';
import '../services/contact_service.dart';
import '../models/contact.dart';
import '../widgets/contact_card.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';

class ContactListScreen extends StatefulWidget {
  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  final ContactService _contactService = ContactService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> contacts = [];
  List<Map<String, dynamic>> filteredContacts = [];
  bool _isSearching = false;
  bool _isLoading = true;

  void fetchContacts() async {
    print('🔄 Chargement des contacts...');
    setState(() => _isLoading = true);

    try {
      contacts = await _contactService.getContacts();
      filteredContacts = List.from(contacts);
      print('✅ ${contacts.length} contacts chargés avec succès');
    } catch (e) {
      print('❌ Erreur lors du chargement des contacts: $e');
      contacts = [];
      filteredContacts = [];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void searchContacts(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredContacts = List.from(contacts);
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _contactService.searchContacts(query);
      setState(() => filteredContacts = results);
    } catch (e) {
      print('❌ Erreur lors de la recherche: $e');
      setState(() => filteredContacts = []);
    }
  }

  void clearSearch() {
    _searchController.clear();
    setState(() {
      filteredContacts = List.from(contacts);
      _isSearching = false;
    });
  }

  void deleteContact(int id) async {
    print('🗑️ Suppression contact ID: $id');

    try {
      // VÉRIFIER D'ABORD SI LE CONTACT EXISTE
      final currentContacts = await _contactService.getContacts();
      final contactExists = currentContacts.any((contact) => contact['id'] == id);

      if (!contactExists) {
        print('❌ Contact ID $id non trouvé dans la base');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact non trouvé'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // DEMANDE DE CONFIRMATION
      final confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirmer la suppression'),
            ],
          ),
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

      if (confirm != true) {
        print('❌ Suppression annulée par l\'utilisateur');
        return;
      }

      // SUPPRESSION RÉELLE
      final rowsAffected = await _contactService.deleteContact(id);

      if (rowsAffected > 0) {
        print('✅ Suppression réussie, lignes affectées: $rowsAffected');

        // Mise à jour de l'interface
        setState(() {
          contacts.removeWhere((contact) => contact['id'] == id);
          filteredContacts = List.from(contacts);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Contact supprimé avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        print('⚠️ Aucune ligne affectée - contact peut-être déjà supprimé');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le contact n\'a pas été trouvé'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la suppression: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0066CC)),
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

  @override
  void initState() {
    super.initState();
    print('🚀 Initialisation de ContactListScreen');
    fetchContacts();
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        searchContacts(_searchController.text);
      } else {
        setState(() {
          filteredContacts = List.from(contacts);
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
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Rechercher un contact...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Color(0xFF99C2FF)),
          ),
          style: TextStyle(color: Color(0xFF003366)),
        )
            : Text(
          'Mes Contacts',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF003366),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.clear, color: Color(0xFF0066CC)),
              onPressed: clearSearch,
            )
          else
            IconButton(
              icon: Icon(Icons.search, color: Color(0xFF0066CC)),
              onPressed: () {
                setState(() => _isSearching = true);
              },
            ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Color(0xFF0066CC)),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Déconnexion': 'logout'}.entries.map((entry) {
                return PopupMenuItem<String>(
                  value: entry.value,
                  child: Text(entry.key),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Color(0xFF0066CC)),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des contacts...',
              style: TextStyle(color: Color(0xFF6699CC)),
            ),
          ],
        ),
      )
          : Column(
        children: [
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
                _buildStatItem('Total', contacts.length.toString(), Icons.contacts),
                _buildStatItem('Trouvés', filteredContacts.length.toString(), Icons.search),
              ],
            ),
          ),
          SizedBox(height: 8),
          if (_isSearching && _searchController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFE6F2FF),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFCCE5FF)),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, size: 16, color: Color(0xFF0066CC)),
                  SizedBox(width: 8),
                  Text(
                    '${filteredContacts.length} contact(s) trouvé(s) pour "${_searchController.text}"',
                    style: TextStyle(color: Color(0xFF0066CC), fontSize: 12),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filteredContacts.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: () async => fetchContacts(),
              backgroundColor: Colors.white,
              color: Color(0xFF0066CC),
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = filteredContacts[index];
                  return ContactCard(
                    contact: Contact(
                      id: contact['id'],
                      nom: contact['nom'],
                      numero: contact['numero'],
                      userId: contact['user_id'],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditContactScreen(
                          contact: Contact(
                            id: contact['id'],
                            nom: contact['nom'],
                            numero: contact['numero'],
                            userId: contact['user_id'],
                          ),
                          refresh: fetchContacts,
                        ),
                      ),
                    ),
                    onDelete: () => deleteContact(contact['id']),
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
            builder: (context) => AddContactScreen(refresh: fetchContacts),
          ),
        ),
        backgroundColor: Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 4,
        child: Icon(Icons.add, size: 28),
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
          child: Icon(icon, color: Color(0xFF0066CC), size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF003366),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6699CC),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFFE6F2FF),
                borderRadius: BorderRadius.circular(60),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0066CC).withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                _isSearching && _searchController.text.isNotEmpty
                    ? Icons.search_off
                    : Icons.contacts_outlined,
                size: 50,
                color: Color(0xFF0066CC),
              ),
            ),
            SizedBox(height: 24),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Aucun contact trouvé'
                  : 'Aucun contact',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF003366),
              ),
            ),
            SizedBox(height: 8),
            Text(
              _isSearching && _searchController.text.isNotEmpty
                  ? 'Essayez avec d\'autres termes de recherche'
                  : 'Commencez par ajouter votre premier contact',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6699CC),
              ),
            ),
            SizedBox(height: 24),
            if (!_isSearching)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Color(0xFF0066CC), Color(0xFF00A8FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF0066CC).withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddContactScreen(refresh: fetchContacts),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Ajouter un contact',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}