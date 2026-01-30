import 'package:flutter/material.dart';
import 'package:money/utils/app_urls.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Name: ${widget.user['name']}'),
            Text('Email: ${widget.user['email']}'),
            widget.user['picture'] != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(
                      '${AppUrls.baseUrl}/${widget.user['picture']}',
                    ),
                    radius: 50,
                  )
                : CircleAvatar(radius: 50, child: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}
