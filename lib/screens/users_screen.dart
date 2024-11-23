import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_web_app/screens/private_chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class UsersScreen extends StatelessWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Users'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('lastSeen', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Print connection state
          print('Connection state: ${snapshot.connectionState}');
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Loading users...');
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            print('No data in snapshot');
            return const Center(child: Text('No users found'));
          }

          if (snapshot.hasError) {
            print('Error in snapshot: ${snapshot.error}');
            print('Error stack trace: ${snapshot.stackTrace}');
            return const Center(child: Text('Error loading users'));
          }

          print('Number of documents: ${snapshot.data!.docs.length}');
          
          // Print all users before filtering
          snapshot.data!.docs.forEach((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('User document: id=${doc.id}, data=$data');
          });
          
          final users = snapshot.data!.docs
              .where((doc) => doc.id != currentUser?.uid)
              .toList();

          print('Current user ID: ${currentUser?.uid}');
          print('Number of other users: ${users.length}');
          
          // Print filtered users
          users.forEach((doc) {
            final data = doc.data() as Map<String, dynamic>;
            print('Filtered user: id=${doc.id}, data=$data');
          });

          if (users.isEmpty) {
            return const Center(child: Text('No other users found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final username = userData['username'] ?? 'Anonymous';
              final email = userData['email'] ?? 'No email';
              final lastSeen = userData['lastSeen'] as Timestamp?;
              final isOnline = userData['isOnline'] ?? false;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          username[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      if (isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(username),
                  subtitle: Text(email),
                  trailing: lastSeen != null
                      ? Text(
                          isOnline
                              ? 'Online'
                              : 'Last seen: ${timeago.format(lastSeen.toDate())}',
                          style: TextStyle(
                            color: isOnline ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivateChatScreen(
                          otherUserId: users[index].id,
                          otherUsername: username,
                        ),
                      ),
                    );
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
