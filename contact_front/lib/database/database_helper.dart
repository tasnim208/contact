import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static bool _isInitialized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    print('🚀 INITIALISATION DE LA BASE DE DONNÉES');

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contact_app.db');

    print('📁 Chemin: $path');

    // ÉTAPE 1: SUPPRIMER TOUTES LES BASES EXISTANTES
    await _deleteAllDatabaseFiles(dbPath);

    // ÉTAPE 2: CRÉER UN NOUVEAU FICHIER DE BASE
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) {
        print('🔓 Base ouverte avec succès');
      },
    );

    // ÉTAPE 3: TEST D'ÉCRITURE IMMÉDIAT
    await _testDatabaseWrite(database);

    _isInitialized = true;
    return database;
  }

  Future<void> _deleteAllDatabaseFiles(String dbPath) async {
    print('🗑️ Suppression de tous les fichiers de base...');

    try {
      // Supprimer la base principale
      final mainPath = join(dbPath, 'contact_app.db');
      await deleteDatabase(mainPath);
      print('✅ contact_app.db supprimé');
    } catch (e) {
      print('ℹ️ contact_app.db déjà supprimé ou inexistant');
    }

    try {
      // Supprimer les fichiers -journal (WAL)
      final journalPath = join(dbPath, 'contact_app.db-journal');
      await deleteDatabase(journalPath);
      print('✅ Fichier journal supprimé');
    } catch (e) {
      print('ℹ️ Fichier journal déjà supprimé');
    }

    try {
      // Supprimer les fichiers -wal (WAL)
      final walPath = join(dbPath, 'contact_app.db-wal');
      await deleteDatabase(walPath);
      print('✅ Fichier WAL supprimé');
    } catch (e) {
      print('ℹ️ Fichier WAL déjà supprimé');
    }

    try {
      // Supprimer les fichiers -shm (WAL)
      final shmPath = join(dbPath, 'contact_app.db-shm');
      await deleteDatabase(shmPath);
      print('✅ Fichier SHM supprimé');
    } catch (e) {
      print('ℹ️ Fichier SHM déjà supprimé');
    }
  }

  Future<void> _testDatabaseWrite(Database db) async {
    print('🧪 Test d\'écriture de la base...');

    try {
      // Test 1: Créer une table temporaire
      await db.execute('''
        CREATE TABLE IF NOT EXISTS write_test (
          id INTEGER PRIMARY KEY,
          test_text TEXT
        )
      ''');

      // Test 2: Insérer des données
      final insertId = await db.insert('write_test', {
        'test_text': 'test_write_' + DateTime.now().millisecondsSinceEpoch.toString()
      });

      // Test 3: Lire les données
      final results = await db.query('write_test', where: 'id = ?', whereArgs: [insertId]);

      // Test 4: Supprimer les données
      await db.delete('write_test', where: 'id = ?', whereArgs: [insertId]);

      // Test 5: Supprimer la table
      await db.execute('DROP TABLE IF EXISTS write_test');

      print('✅✅✅ TEST D\'ÉCRITURE RÉUSSI ✅✅✅');
      print('✅ La base est en mode LECTURE/ÉCRITURE');

    } catch (e) {
      print('❌❌❌ ERREUR CRITIQUE: La base est en lecture seule ❌❌❌');
      print('❌ Détails: $e');
      throw Exception('BASE DE DONNÉES EN LECTURE SEULE: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    print('🔄 Création des tables...');

    // Table utilisateurs
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    print('✅ Table users créée');

    // Table contacts
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        numero TEXT NOT NULL,
        user_id INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    print('✅ Table contacts créée');

    print('🎉 TOUTES LES TABLES CRÉÉES AVEC SUCCÈS');
  }

  // === MÉTHODES UTILISATEURS ===
  Future<int> registerUser(String username, String email, String password) async {
    final db = await database;

    print('👤 Enregistrement utilisateur: $username');

    // Vérifier email
    final existingUserByEmail = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existingUserByEmail.isNotEmpty) {
      throw Exception('Un utilisateur avec cet email existe déjà');
    }

    // Vérifier username
    final existingUserByName = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existingUserByName.isNotEmpty) {
      throw Exception('Ce nom d\'utilisateur est déjà pris');
    }

    final result = await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    });

    print('✅ Utilisateur enregistré avec ID: $result');
    return result;
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;

    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (res.isNotEmpty) {
      print('✅ Utilisateur connecté: ${res.first['username']}');
      return res.first;
    }
    print('❌ Échec connexion pour: $email');
    return null;
  }

  // === MÉTHODES CONTACTS ===
  Future<int> addContact(String nom, String numero, int userId) async {
    final db = await database;

    print('➕ Ajout contact: $nom pour user: $userId');

    final result = await db.insert('contacts', {
      'nom': nom,
      'numero': numero,
      'user_id': userId,
    });

    print('✅ Contact ajouté avec ID: $result');
    return result;
  }

  Future<List<Map<String, dynamic>>> getContacts(int userId) async {
    final db = await database;

    final contacts = await db.query(
      'contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'nom ASC',
    );

    print('📋 ${contacts.length} contacts récupérés pour user: $userId');
    return contacts;
  }

  Future<List<Map<String, dynamic>>> searchContacts(String query, int userId) async {
    final db = await database;
    return await db.query(
      'contacts',
      where: 'user_id = ? AND (nom LIKE ? OR numero LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'nom ASC',
    );
  }

  Future<int> updateContact(int id, String nom, String numero) async {
    final db = await database;

    print('✏️ Modification contact ID: $id');

    final result = await db.update(
      'contacts',
      {'nom': nom, 'numero': numero},
      where: 'id = ?',
      whereArgs: [id],
    );

    print('✅ Contact modifié, lignes affectées: $result');
    return result;
  }

  Future<int> deleteContact(int id) async {
    final db = await database;

    print('🗑️ Suppression contact ID: $id');

    // TEST FINAL AVANT SUPPRESSION
    try {
      print('🧪 Test final avant suppression...');
      final testInsert = await db.rawInsert(
          'INSERT INTO contacts (nom, numero, user_id) VALUES (?, ?, ?)',
          ['test_delete', '000000', 999]
      );
      print('✅ Test insertion réussi, ID: $testInsert');

      final testDelete = await db.delete(
          'contacts',
          where: 'id = ?',
          whereArgs: [testInsert]
      );
      print('✅ Test suppression réussi, lignes: $testDelete');

    } catch (e) {
      print('❌❌❌ ERREUR: Impossible d\'écrire avant suppression: $e');
      await forceRecreateDatabase();
      throw Exception('Base réinitialisée. Veuillez réessayer la suppression.');
    }

    final result = await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result > 0) {
      print('✅✅✅ SUPPRESSION RÉUSSIE ✅✅✅');
      print('✅ Contact $id supprimé, lignes affectées: $result');
    } else {
      print('⚠️ Aucun contact trouvé avec ID: $id');
    }

    return result;
  }

  // MÉTHODE DE RÉINITIALISATION FORCÉE
  Future<void> forceRecreateDatabase() async {
    print('🔄🔄🔄 RÉINITIALISATION FORCÉE DE LA BASE 🔄🔄🔄');

    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    _isInitialized = false;
    _database = await _initDatabase();

    print('🎉 BASE DE DONNÉES COMPLÈTEMENT RÉINITIALISÉE');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('🔒 Base de données fermée');
    }
  }
}