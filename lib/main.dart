import 'package:flutter/material.dart';
import 'package:money/app.dart';
import 'package:money/services/connectivity_service.dart';
import 'package:money/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConnectivityService().initialize();

  SyncService().startListening();

  runApp(const MyApp());
}
