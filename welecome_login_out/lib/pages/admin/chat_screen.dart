import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welecome_login_out/approved.dart';
import 'package:rxdart/rxdart.dart';

class ChatScreen extends StatefulWidget {
  final String? signedInUserEmail;
  final String? toUserEmail;
  final String? toUserName;

  const ChatScreen({
    Key? key,
    this.signedInUserEmail,
    this.toUserEmail,
    this.toUserName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Approved.LightColor,
      appBar: AppBar(
        backgroundColor: Approved.PrimaryColor,
        title: Text('Chat with ${widget.toUserName ?? ""}'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ChatMessagesWidget(
                signedInUserEmail: widget.signedInUserEmail,
                toUserEmail: widget.toUserEmail,
              ),
            ),
            ChatInputWidget(
              onSendMessage: _sendMessage,
              textEditingController: _textEditingController,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final String? fromEmail = widget.signedInUserEmail;
    if (fromEmail == null || fromEmail.isEmpty) {
      print('Error: Signed-in user email is null or empty.');
      return;
    }

    try {
      await _firestore.collection('messages').add({
        'from': fromEmail,
        'to': widget.toUserEmail,
        'text': text,
        'time': FieldValue.serverTimestamp(),
      });
      _textEditingController.clear();
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

class ChatMessagesWidget extends StatelessWidget {
  final String? signedInUserEmail;
  final String? toUserEmail;

  const ChatMessagesWidget({
    Key? key,
    required this.signedInUserEmail,
    required this.toUserEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user1Stream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: signedInUserEmail)
        .where('to', isEqualTo: toUserEmail)
        .snapshots();

    final user2Stream = FirebaseFirestore.instance
        .collection('messages')
        .where('from', isEqualTo: toUserEmail)
        .where('to', isEqualTo: signedInUserEmail)
        .snapshots();

    final combinedStream = Rx.combineLatest2<QuerySnapshot, QuerySnapshot,
        List<QueryDocumentSnapshot>>(
      user1Stream,
      user2Stream,
      (user1Snapshot, user2Snapshot) {
        final combinedDocs = [...user1Snapshot.docs, ...user2Snapshot.docs];
        combinedDocs.sort((a, b) =>
            (b['time'] as Timestamp).compareTo(a['time'] as Timestamp));
        return combinedDocs;
      },
    );

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: combinedStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<MessageLine> messageLines = snapshot.data!.map((doc) {
          final String from = doc['from'];
          final String text = doc['text'];
          final bool isFromSignedInUser = from == signedInUserEmail;

          return MessageLine(
            text: text,
            isFromSignedInUser: isFromSignedInUser,
          );
        }).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: messageLines.reversed.toList(),
        );
      },
    );
  }
}

class MessageLine extends StatelessWidget {
  final String text;
  final bool isFromSignedInUser;

  const MessageLine({
    required this.text,
    required this.isFromSignedInUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isFromSignedInUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 5,
            borderRadius: isFromSignedInUser
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            color: isFromSignedInUser ? Approved.PrimaryColor : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      isFromSignedInUser ? Colors.white : Approved.PrimaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatInputWidget extends StatelessWidget {
  final Function(String) onSendMessage;
  final TextEditingController textEditingController;

  const ChatInputWidget({
    Key? key,
    required this.onSendMessage,
    required this.textEditingController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Approved.PrimaryColor,
            width: 2,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                hintText: 'Write your message here...',
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onSendMessage(textEditingController.text.trim());
              textEditingController.clear();
            },
            child: const Icon(
              Icons.send,
              color: Approved.PrimaryColor,
            ),
          )
        ],
      ),
    );
  }
}
