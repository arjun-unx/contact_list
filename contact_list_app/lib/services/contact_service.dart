import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact.dart';

class ContactService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  Future<List<Contact>> getContacts() async {
    final response = await http.get(Uri.parse('$baseUrl/getcontacts'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Contact.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  Future<Contact> createContact(Contact contact) async {
    final response = await http.post(
      Uri.parse('$baseUrl/contacts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contact.toJson()),
    );

    if (response.statusCode == 201) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create contact');
    }
  }

  Future<Contact> updateContact(Contact contact) async {
    final response = await http.put(
      Uri.parse('$baseUrl/updatecontact?id=${contact.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(contact.toJson()),
    );
    if (response.statusCode == 200) {
      return Contact.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update contact');
    }
  }

  Future<void> deleteContact(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deletecontact?id=$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete contact');
    }
  }

  Future<List<Contact>> searchContacts(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/searchcontacts?query=$query'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Contact.fromJson(item)).toList();
    } else {
      throw Exception('Failed to search contacts');
    }
  }
}
