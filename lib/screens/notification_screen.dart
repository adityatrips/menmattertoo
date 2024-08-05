import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Center(
          child: ListView(
            children: [
              const SizedBox(height: 20),
              _notificationList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationList() {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .doc("users/${FirebaseAuth.instance.currentUser!.uid}")
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data as DocumentSnapshot;
          final notifications = data.get('notifications') as List<dynamic>;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _notificationCard(
                snapshot.data!['notifications'][index]['notification'],
                snapshot.data!['notifications'][index]['timestamp'],
              );
            },
          );
        });
  }

  Widget _notificationCard(
    String title,
    String timestamp,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(timestamp),
        trailing: const Icon(Icons.notifications_rounded),
      ),
    );
  }
}
