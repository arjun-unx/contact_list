import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/contact.dart';
import '../services/contact_service.dart';

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  ContactFormScreen({this.contact});

  @override
  _ContactFormScreenState createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ContactService _contactService = ContactService();

  late String _firstName;
  late String _lastName;
  late String _phoneNumber;
  late String _email;
  late String _address;
  late String _profilePhoto;
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _firstName = widget.contact!.firstName!;
      _lastName = widget.contact!.lastName!;
      _phoneNumber = widget.contact!.phoneNumber!;
      _email = widget.contact!.email!;
      _address = widget.contact!.address!;
      _profilePhoto = widget.contact!.profilePhoto!;
    } else {
      _firstName = '';
      _lastName = '';
      _phoneNumber = '';
      _email = '';
      _address = '';
      _profilePhoto = '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _profilePhoto = base64Encode(_image!.readAsBytesSync());
      });
    }
  }

  void _saveContact() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final contact = Contact(
        id: widget.contact?.id,
        firstName: _firstName,
        lastName: _lastName,
        phoneNumber: _phoneNumber,
        email: _email,
        address: _address,
        profilePhoto: _profilePhoto,
      );
      if (widget.contact == null) {
        await _contactService.createContact(contact);
      } else {
        await _contactService.updateContact(contact);
      }
      Navigator.pop(context);
    }
  }

  void _resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      _image = null;
      _profilePhoto = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white, // <= You can change your color here.
        ),
        title: Text(widget.contact == null ? 'New Contact' : 'Edit Contact',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.clear,color: Colors.red,),
            onPressed: _resetForm,
          ),
          SizedBox(width: 10,),
          IconButton(
            icon: Icon(Icons.check,color: Colors.green,),
            onPressed: _saveContact,
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.fromLTRB(50,60,50,0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    child: _image != null
                        ? ClipOval(
                      child: Image.file(
                        _image!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                        : _profilePhoto.isNotEmpty
                        ? ClipOval(
                      child: Image.memory(
                        base64Decode(_profilePhoto),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(
                      Icons.camera_alt_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(child: Text('Add Photo',style: TextStyle(color: Colors.white,fontSize: 16))),
              SizedBox(height: 30),
              _buildFormField(
                icon: Icons.person,
                label: 'First Name',
                initialValue: _firstName,
                onSaved: (value) => _firstName = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a first name' : null,
              ),
              SizedBox(height: 20),
              _buildFormField(
                icon: Icons.person_outline,
                label: 'Last Name',
                initialValue: _lastName,
                onSaved: (value) => _lastName = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a last name' : null,
              ),
              SizedBox(height: 20),
              _buildFormField(
                icon: Icons.phone,
                label: 'Phone Number',
                initialValue: _phoneNumber,
                onSaved: (value) => _phoneNumber = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a phone number' : null,
              ),
              SizedBox(height: 20),
              _buildFormField(
                icon: Icons.email,
                label: 'Email',
                initialValue: _email,
                onSaved: (value) => _email = value!,
                validator: (value) => value == null || value.isEmpty ? 'Please enter an email' : null,
              ),
              SizedBox(height: 20),
              _buildFormField(
                icon: Icons.home,
                label: 'Address',
                initialValue: _address,
                onSaved: (value) => _address = value!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required IconData icon,
    required String label,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 15),
        Expanded(
          child: TextFormField(
            initialValue: initialValue,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            style: TextStyle(color: Colors.white),
            onSaved: onSaved,
            validator: validator,
          ),
        ),
      ],
    );
  }
}
