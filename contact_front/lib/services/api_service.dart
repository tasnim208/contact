import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/contact.dart';

class ApiService {
  // ✅ POUR FLUTTER WEB - localhost avec le bon port
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // ✅ MÉTHODE DE RECHERCHE
  static Future<List<Contact>> searchContacts(String query) async {
    try {
      final token = await getToken();

      // Encoder le query pour les URLs
      final encodedQuery = Uri.encodeComponent(query);

      final response = await http.get(
        Uri.parse('$baseUrl/contacts/search?query=$encodedQuery'),
        headers: {
          'Authorization': token ?? '',
          'Accept': 'application/json',
        },
      );

      print('🔍 Recherche: "$query" - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final results = data.map((json) => Contact.fromJson(json)).toList();
        print('✅ ${results.length} contact(s) trouvé(s)');
        return results;
      } else {
        print('❌ Erreur recherche: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur searchContacts: $e');
      return [];
    }
  }

  // Auth avec headers complets pour CORS
  static Future<bool> login(String email, String password) async {
    try {
      print('🔄 Tentative de connexion...');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('📡 Réponse login: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveToken(data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erreur login: $e');
      return false;
    }
  }

  static Future<bool> register(String username, String email, String password) async {
    try {
      print('🔄 Tentative d\'inscription...');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );

      print('📡 Réponse register: ${response.statusCode}');
      return response.statusCode == 201;
    } catch (e) {
      print('❌ Erreur register: $e');
      return false;
    }
  }

  // Contacts avec gestion CORS
  static Future<List<Contact>> getContacts() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/contacts'),
        headers: {
          'Authorization': token ?? '',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Contact.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Erreur getContacts: $e');
      return [];
    }
  }

  static Future<bool> addContact(String nom, String numero) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/contacts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ?? '',
          'Accept': 'application/json',
        },
        body: jsonEncode({'nom': nom, 'numero': numero}),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('❌ Erreur addContact: $e');
      return false;
    }
  }

  static Future<bool> updateContact(String id, String nom, String numero) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/contacts/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ?? '',
          'Accept': 'application/json',
        },
        body: jsonEncode({'nom': nom, 'numero': numero}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur updateContact: $e');
      return false;
    }
  }

  static Future<bool> deleteContact(String id) async {
    try {
      final token = await getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/contacts/$id'),
        headers: {
          'Authorization': token ?? '',
          'Accept': 'application/json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur deleteContact: $e');
      return false;
    }
  }
}