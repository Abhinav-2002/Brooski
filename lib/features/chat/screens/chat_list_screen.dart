import 'package:flutter/material.dart';
import 'package:brooski_app/features/chat/screens/chat_thread_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = [
      ('Riya Sharma', 'Need to confirm timing', 'https://i.pravatar.cc/150?img=5'),
      ('Amit Patel', 'Please bring a ladder', 'https://i.pravatar.cc/150?img=8'),
      ('Priya Singh', 'See you at 6pm', 'https://i.pravatar.cc/150?img=15'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView.separated(
        itemCount: threads.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          final (name, last, avatar) = (threads[i].$1, threads[i].$2, threads[i].$3);
          return ListTile(
            leading: CircleAvatar(backgroundImage: NetworkImage(avatar)),
            title: Text(name),
            subtitle: Text(last, maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () {
              // Generate a stable session ID from the peer name
              final sessionId = 'dm:${name.toLowerCase().replaceAll(RegExp(r"\\s+"), "_")}';
              
              Navigator.of(context).pushNamed(
                ChatThreadScreen.routeName,
                arguments: {
                  'sessionId': sessionId,
                  'jobId': '',             // No job ID in direct messages
                  'posterId': 'poster:$name', // Fallback ID based on name
                  'workerId': '',          // Fill with current user ID if available
                  'isWorker': true,        // Adjust based on user role
                  'suggestedPrice': 0.0,
                  'suggestedEta': 15,
                },
              );
            },
          );
        },
      ),
    );
  }
}
