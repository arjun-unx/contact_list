import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/contact.dart';
import 'contact_form_screen.dart';
import '../services/contact_service.dart';

class ContactDetailsScreen extends StatefulWidget {
  final Contact contact;

  ContactDetailsScreen({required this.contact});

  @override
  _ContactDetailsScreenState createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends State<ContactDetailsScreen> {
  bool showAllLogs = false;
  final ContactService _contactService = ContactService();
  List<Map<String, String>> callLogs = [
    {
      'date': '4/15/24',
      'time': '10:30 AM',
      'type': 'Incoming',
      'duration': '2 min',
      'phone': '+91 8838308061',
    },
    {
      'date': '6/6/24',
      'time': '3:45 PM',
      'type': 'Outgoing',
      'duration': '5 min',
      'phone': '+91 8838308061',
    },
    {
      'date': '6/5/24',
      'time': '8:00 PM',
      'type': 'Incoming',
      'duration': '30 sec',
      'phone': '+91 8838308061',
    },
    {
      'date': '4/6/24',
      'time': '12:15 PM',
      'type': 'Outgoing',
      'duration': '10 min',
      'phone': '+91 8838308061',
    },
  ];

  void _deleteContact() async {
    await _contactService.deleteContact(widget.contact.id!);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        toolbarHeight: 90,
        backgroundColor: Colors.black12,
        title: Text('Contact Details',style: TextStyle(color: Colors.white),),
        iconTheme: IconThemeData(
          color: Colors.white, // <= You can change your color here.
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete,color: Colors.red,),
            onPressed: _deleteContact,
          ),
          IconButton(
            icon: Icon(Icons.more_vert_outlined,color: Colors.white),
            onPressed: (){},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 50,
                child: widget.contact.profilePhoto != null && widget.contact.profilePhoto!.isNotEmpty
                    ? ClipOval(
                  child: Image.memory(
                    base64Decode(widget.contact.profilePhoto!),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                )
                    : Text(
                  widget.contact.firstName!.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              '${widget.contact.firstName} ${widget.contact.lastName}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CircleAvatar(backgroundColor: Colors.black45.withOpacity(0.5),radius: 25, child: Icon(Icons.phone_in_talk_outlined, color: Colors.white)),
                    SizedBox(height: 10,),
                    Text('Call',style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  ],
                ),
                SizedBox(width: 16),
                Column(
                  children: [
                    CircleAvatar(backgroundColor: Colors.black45.withOpacity(0.5),radius: 25, child: Icon(Icons.message_outlined, color: Colors.white)),
                    SizedBox(height: 10,),
                    Text('Message',style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  ],
                ),
                SizedBox(width: 16),
                Column(
                  children: [
                    CircleAvatar(backgroundColor: Colors.black45.withOpacity(0.5),radius: 25, child: Icon(Icons.video_camera_back, color: Colors.white)),
                    SizedBox(height: 10,),
                    Text('Video',style: TextStyle(color: Colors.white.withOpacity(0.6))),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Stack(
              children: [
                Row(
                  children: [
                    Icon(Icons.local_phone_outlined, color: Colors.white),
                    SizedBox(width: 8),
                    Text('+91 ${widget.contact.phoneNumber}',style: TextStyle(color: Colors.white.withOpacity(0.9),letterSpacing: 1)),
                    Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.black45.withOpacity(0.5),
                      radius: 25,
                      child: IconButton(
                        icon: Icon(Icons.message_outlined),
                        color: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 0, 0),
                  child: Row(
                    children: [
                      Text('Mobile | India',style: TextStyle(color: Colors.white.withOpacity(0.5),fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Stack(
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                    SizedBox(width: 15),
                    Text('WhatsApp',style: TextStyle(color: Colors.green.withOpacity(0.9),letterSpacing: 1)),
                    Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.black45.withOpacity(0.5),
                      radius: 25,
                      child: IconButton(
                        icon: Icon(Icons.video_camera_back),
                        color: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 0, 0),
                  child: Row(
                    children: [
                      Text('+91 ${widget.contact.phoneNumber}',style: TextStyle(color: Colors.white.withOpacity(0.5),fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Stack(
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.telegram, color: Colors.lightBlueAccent),
                    SizedBox(width: 15),
                    Text('Telegram',style: TextStyle(color: Colors.lightBlueAccent.withOpacity(0.9),letterSpacing: 1)),
                    Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.black45.withOpacity(0.5),
                      radius: 25,
                      child: IconButton(
                        icon: Icon(Icons.video_camera_back),
                        color: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 0, 0),
                  child: Row(
                    children: [
                      Text('+91 ${widget.contact.phoneNumber}',style: TextStyle(color: Colors.white.withOpacity(0.5),fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Stack(
              children: [
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.google, color: Colors.redAccent,),
                    SizedBox(width: 15),
                    Text('Google',style: TextStyle(color: Colors.white.withOpacity(0.9),letterSpacing: 1)),
                    Spacer(),
                    CircleAvatar(
                      backgroundColor: Colors.black45.withOpacity(0.5),
                      radius: 25,
                      child: IconButton(
                        icon: Icon(Icons.mail_outline_rounded),
                        color: Colors.white,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 0, 0),
                  child: Row(
                    children: [
                      Text('${widget.contact.email}',style: TextStyle(color: Colors.white.withOpacity(0.5),fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 25),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Call Logs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9),),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: showAllLogs ? callLogs.length : (callLogs.length > 3 ? 3 : callLogs.length),
                itemBuilder: (context, index) {
                  final log = callLogs[index];
                  return ListTile(
                    title: Text('${log['date']} ${log['time']}',style: TextStyle(color: Colors.white.withOpacity(0.9))),
                    subtitle: Text('${log['type']} ${log['phone']}', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                    trailing: Text('${log['duration']}', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                  );
                },
              ),
            ),
            if (callLogs.length > 3)
              TextButton(
                onPressed: () {
                  setState(() {
                    showAllLogs = !showAllLogs;
                  });
                },
                child: Text(showAllLogs ? 'Show Less' : 'View All'),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactFormScreen(contact: widget.contact),
          ),
        ),
        child: Icon(Icons.edit),
      ),
    );
  }
}
