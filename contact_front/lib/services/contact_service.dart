import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/contact.dart';
import '../utils/constants.dart';

class ContactService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // === MÉTHODES AUTHENTIFICATION ===
  Future<int?> register(String username, String email, String password) async {
    try {
      final userId = await _dbHelper.registerUser(username, email, password);
      await _saveUserId(userId);
      return userId;
    } catch (e) {
      print('❌ Erreur inscription: $e');
      rethrow;
    }
  }

  Future<int?> login(String email, String password) async {
    try {
      final user = await _dbHelper.loginUser(email, password);
      if (user != null) {
        final userId = user['id'] as int;
        await _saveUserId(userId);
        return userId;
      }
      return null;
    } catch (e) {
      print('❌ Erreur connexion: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove('current_user_id');
    print('🚪 Utilisateur déconnecté');
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await _prefs;
    return prefs.getInt('current_user_id');
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await _prefs;
    await prefs.setInt('current_user_id', userId);
  }

  // === MÉTHODES CONTACTS ===
  Future<int> addContact(Contact contact) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('Utilisateur non connecté');

    final result = await _dbHelper.addContact(contact.copyWith(userId: userId));
    return result;
  }

  Future<List<Contact>> getContacts() async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('Utilisateur non connecté');

    final contacts = await _dbHelper.getContacts(userId);
    return contacts;
  }

  Future<List<Contact>> searchContacts(String query) async {
    final userId = await getCurrentUserId();
    if (userId == null) throw Exception('Utilisateur non connecté');

    return await _dbHelper.searchContacts(query, userId);
  }

  Future<int> updateContact(Contact contact) async {
    return await _dbHelper.updateContact(contact);
  }

  Future<int> deleteContact(int id) async {
    return await _dbHelper.deleteContact(id);
  }

  // === MÉTHODES DOUBLONS ===
  Future<List<Contact>> findDuplicateContacts() async {
    final contacts = await getContacts();
    final Map<String, List<Contact>> numeroGroups = {};

    // Grouper par numéro
    for (var contact in contacts) {
      final normalizedNumero = _normalizePhoneNumber(contact.numero);
      if (!numeroGroups.containsKey(normalizedNumero)) {
        numeroGroups[normalizedNumero] = [];
      }
      numeroGroups[normalizedNumero]!.add(contact);
    }

    // Retourner seulement les groupes avec doublons
    final duplicates = <Contact>[];
    for (var group in numeroGroups.values) {
      if (group.length > 1) {
        duplicates.addAll(group);
      }
    }

    return duplicates;
  }

  Future<void> mergeDuplicateContacts(List<Contact> duplicates) async {
    final Map<String, Contact> mergedContacts = {};

    for (var contact in duplicates) {
      final normalizedNumero = _normalizePhoneNumber(contact.numero);
      
      if (!mergedContacts.containsKey(normalizedNumero)) {
        // Garder le premier contact avec photo ou le plus récent
        mergedContacts[normalizedNumero] = contact;
      } else {
        final existing = mergedContacts[normalizedNumero]!;
        
        // Préférer le contact avec photo
        if (existing.imagePath == null && contact.imagePath != null) {
          mergedContacts[normalizedNumero] = contact;
        }
        
        // Supprimer le doublon
        await deleteContact(contact.id!);
      }
    }

    // Mettre à jour les contacts conservés
    for (var contact in mergedContacts.values) {
      await updateContact(contact);
    }
  }

  String _normalizePhoneNumber(String numero) {
    return numero.replaceAll(RegExp(r'[^\d+]'), '');
  }

  Future<void> forceResetDatabase() async {
    await _dbHelper.forceRecreateDatabase();
  }
}