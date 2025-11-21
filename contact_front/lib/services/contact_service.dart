import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

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
    final userId = prefs.getInt('current_user_id');
    print('👤 ID utilisateur actuel: $userId');
    return userId;
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await _prefs;
    await prefs.setInt('current_user_id', userId);
    print('💾 ID utilisateur sauvegardé: $userId');
  }

  // === MÉTHODES CONTACTS ===
  Future<int> addContact(String nom, String numero) async {
    print('➕ Tentative d\'ajout contact: $nom');

    final userId = await getCurrentUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final result = await _dbHelper.addContact(nom, numero, userId);
      print('✅ Contact ajouté avec ID: $result');
      return result;
    } catch (e) {
      print('❌ Erreur lors de l\'ajout: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    print('📋 Récupération des contacts');

    final userId = await getCurrentUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    try {
      final contacts = await _dbHelper.getContacts(userId);
      print('✅ ${contacts.length} contacts récupérés');
      return contacts;
    } catch (e) {
      print('❌ Erreur lors de la récupération: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchContacts(String query) async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    return await _dbHelper.searchContacts(query, userId);
  }

  Future<int> updateContact(int id, String nom, String numero) async {
    print('✏️ Modification contact ID: $id');

    try {
      final result = await _dbHelper.updateContact(id, nom, numero);
      print('✅ Contact modifié, lignes affectées: $result');
      return result;
    } catch (e) {
      print('❌ Erreur lors de la modification: $e');
      rethrow;
    }
  }

  Future<int> deleteContact(int id) async {
    print('🗑️ Suppression contact ID: $id');

    try {
      final result = await _dbHelper.deleteContact(id);

      if (result > 0) {
        print('🎉🎉🎉 SUPPRESSION RÉUSSIE 🎉🎉🎉');
      } else {
        print('⚠️ Aucun contact trouvé avec ID: $id');
      }

      return result;

    } catch (e) {
      print('❌❌❌ ERREUR CRITIQUE LORS DE LA SUPPRESSION: $e');

      // RÉINITIALISER AUTOMATIQUEMENT EN CAS D'ERREUR READ-ONLY
      if (e.toString().contains('read-only') || e.toString().contains('réinitialisée')) {
        print('🔄🔄🔄 RÉINITIALISATION AUTOMATIQUE 🔄🔄🔄');
        await _dbHelper.forceRecreateDatabase();
        throw Exception('Base de données réinitialisée. Veuillez réessayer l\'opération.');
      }

      rethrow;
    }
  }

  // MÉTHODE POUR FORCER LA RÉINITIALISATION
  Future<void> forceResetDatabase() async {
    print('🔄 Réinitialisation forcée demandée...');
    await _dbHelper.forceRecreateDatabase();
  }
}