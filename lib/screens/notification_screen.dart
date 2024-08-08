import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:men_matter_too/providers/user_provider.dart';
import 'package:men_matter_too/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, user, _) {
          if (user.allNotifications == null || user.allNotifications!.isEmpty) {
            user.getAllNotifications();
          }

          return RefreshIndicator(
            onRefresh: () async {
              user.getAllNotifications();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _notificationList(user),
            ),
          );
        },
      ),
    );
  }

  Widget _notificationList(UserProvider user) {
    if (user.allNotifications == null) {
      user.getAllNotifications();
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (user.allNotifications!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Yay! You're all caught up!",
              style: TextStyle(
                fontFamily: "BN",
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            CustomButton(
              buttonText: "Refresh",
              onTap: () => user.getAllNotifications(),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: user.allNotifications!.length,
      itemBuilder: (context, index) {
        return _notificationCard(
          user,
          user.allNotifications![index].notification,
          user.allNotifications![index].timestamp,
          user.allNotifications![index].uid,
        );
      },
    );
  }

  Widget _notificationCard(
    UserProvider user,
    String title,
    int timestamp,
    String uuid,
  ) {
    return Builder(builder: (context) {
      return Card(
        color: Theme.of(context).colorScheme.tertiary,
        child: ListTile(
          title: Text(title),
          subtitle: Text(
            DateFormat.yMMMd().add_Hm().format(
                  DateTime.fromMicrosecondsSinceEpoch(
                    timestamp,
                  ),
                ),
          ),
          trailing: IconButton(
            onPressed: () {
              user.markNotificationAsRead(uuid);
              user.getAllNotifications();
            },
            icon: const Icon(Icons.delete_forever_rounded),
          ),
        ),
      );
    });
  }
}
