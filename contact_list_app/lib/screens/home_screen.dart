import 'package:alphabet_list_scroll_view/alphabet_list_scroll_view.dart';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';
import 'contact_details_screen.dart';
import 'contact_form_screen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ContactService _contactService = ContactService();
  List<Contact> _contacts = [];
  List<Contact> _filteredContacts = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadContacts() async {
    try {
      var contacts = await _contactService.getContacts();
      contacts.sort((a, b) => a.firstName!.compareTo(b.firstName!));
      setState(() {
        _contacts = contacts;
        _filteredContacts = contacts;
      });
    } catch (e) {
      print("Failed to load contacts: $e");
    }
  }

  void _onSearchChanged() {
    var query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        return contact.firstName!.toLowerCase().contains(query) ||
            contact.lastName!.toLowerCase().contains(query) ||
            contact.phoneNumber!.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        title: Text('Contacts',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert_outlined,color: Colors.white), onPressed: () {  },
          ),
        ],
        backgroundColor: Colors.black54,
        centerTitle: true,
        toolbarHeight: 180,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.black54,
              decoration: InputDecoration(
                hintText: 'Search by name or phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none
                ),
                filled: true,
                hintStyle: TextStyle(color: Colors.black45),
                fillColor: Colors.white54,
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _onSearchChanged();
                  },
                ),
              ),
              onChanged: (text) {
                _onSearchChanged();
              },
            ),
          ),
        ),
      ),
      body: AlphabetListScrollView(
        strList: _filteredContacts.map((e) => e.firstName!).toList(),
        highlightTextStyle: TextStyle(color: Colors.white, fontSize: 12),
        normalTextStyle: TextStyle(color: Colors.white24, fontSize: 12),
        showPreview: true,
        itemBuilder: (_, index) {
          final contact = _filteredContacts[index];
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 10, 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue, // Choose a background color for the CircleAvatar
                radius: 25, // Adjust the size of the CircleAvatar as needed
                child: contact.profilePhoto != null && contact.profilePhoto!.isNotEmpty
                    ? ClipOval(
                  child: Image.memory(
                    base64Decode(contact.profilePhoto!),
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                )
                    : Text(
                  contact.firstName!.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text('${contact.firstName} ${contact.lastName}',style: TextStyle(color: Colors.white70),),
              subtitle: Text(contact.phoneNumber ?? '',style: TextStyle(color: Colors.white54),),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactDetailsScreen(contact: contact),
                ),
              ).then((_) => _loadContacts()),
            ),
          );
        },
        indexedHeight: (i) => 80,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContactFormScreen()),
        ).then((_) => _loadContacts()),
        child: Icon(Icons.add),
      ),
    );
  }
}
