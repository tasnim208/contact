import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/contact.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'contact_pro.db');

    // Supprimer l'ancienne base pour éviter les problèmes
    await deleteDatabase(path);

    final database = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
    );

    return database;
  }

  Future<void> _onCreate(Database db, int version) async {
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

    // Table contacts avec champ image_path
    await db.execute('''
      CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nom TEXT NOT NULL,
        numero TEXT NOT NULL,
        user_id INTEGER,
        image_path TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Index pour la recherche
    await db.execute('''
      CREATE INDEX idx_contacts_user_id ON contacts(user_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_contacts_search ON contacts(nom, numero)
    ''');
  }

  // === MÉTHODES UTILISATEURS ===
  Future<int> registerUser(String username, String email, String password) async {
    final db = await database;

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

    return await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // === MÉTHODES CONTACTS ===
  Future<int> addContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getContacts(int userId) async {
    final db = await database;
    final contacts = await db.query(
      'contacts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'nom ASC',
    );
    return contacts.map((map) => Contact.fromMap(map)).toList();
  }

  Future<List<Contact>> searchContacts(String query, int userId) async {
    final db = await database;
    final contacts = await db.query(
      'contacts',
      where: 'user_id = ? AND (nom LIKE ? OR numero LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
      orderBy: 'nom ASC',
    );
    return contacts.map((map) => Contact.fromMap(map)).toList();
  }

  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MÉTHODE DE RÉINITIALISATION
  Future<void> forceRecreateDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _database = await _initDatabase();
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}