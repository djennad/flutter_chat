import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_web_app/services/notification_service.dart';

class PrivateChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUsername;

  const PrivateChatScreen({
    Key? key,
    required this.otherUserId,
    required this.otherUsername,
  }) : super(key: key);

  @override
  _PrivateChatScreenState createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  String getChatRoomId() {
    // Create a unique chat room ID by combining both user IDs
    List<String> ids = [currentUser!.uid, widget.otherUserId];
    ids.sort(); // Sort to ensure same room ID regardless of who starts the chat
    return ids.join('_');
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Create a chat room ID that's the same for both users
      final users = [currentUser.uid, widget.otherUserId]..sort();
      final chatRoomId = users.join('_');

      // Add message to Firestore
      await _firestore.collection('messages').add({
        'chatRoomId': chatRoomId,
        'senderId': currentUser.uid,
        'receiverId': widget.otherUserId,
        'text': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Get receiver's online status
      final receiverDoc = await _firestore.collection('users').doc(widget.otherUserId).get();
      final isReceiverOnline = receiverDoc.data()?['isOnline'] ?? false;

      // Show notification if receiver is not online
      if (!isReceiverOnline) {
        NotificationService.showNotification(
          'New message from ${currentUser.email?.split('@')[0] ?? 'Unknown'}',
          _messageController.text.trim(),
        );
      }

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sending message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomId = getChatRoomId();

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.otherUsername}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('messages')
                  .where('chatRoomId', isEqualTo: chatRoomId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (ctx, index) {
                    final chatDoc = snapshot.data!.docs[index];
                    final chatData = chatDoc.data() as Map<String, dynamic>;
                    final isMe = chatData['senderId'] == currentUser!.uid;

                    return MessageBubble(
                      message: chatData['text'],
                      isMe: isMe,
                      senderEmail: chatData['senderId'] == currentUser!.uid
                          ? currentUser!.email ?? 'Unknown User'
                          : widget.otherUsername ?? 'Unknown User',
                      key: ValueKey(chatDoc.id),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Send a message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String senderEmail;

  const MessageBubble({
    required Key key,
    required this.message,
    required this.isMe,
    required this.senderEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe ? Colors.blue : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isMe ? 12 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 12),
            ),
          ),
          width: 140,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                senderEmail,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 10,
                ),
              ),
              Text(
                message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
                textAlign: isMe ? TextAlign.end : TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
