import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_web_app/screens/private_chat_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Users'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final userData = 
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final username = userData['username'] ?? 'Anonymous';
              final email = userData['email'] ?? 'No email';
              final lastSeen = userData['lastSeen'] as Timestamp?;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      username[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(username),
                  subtitle: Text(email),
                  trailing: lastSeen != null
                      ? Text(
                          'Last seen:\n${lastSeen.toDate().toString().split('.')[0]}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
                        )
                      : null,
                  onTap: () {
                    // Don't allow chat with yourself
                    if (snapshot.data!.docs[index].id != FirebaseAuth.instance.currentUser?.uid) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivateChatScreen(
                            otherUserId: snapshot.data!.docs[index].id,
                            otherUsername: username,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
