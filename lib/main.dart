import 'package:flutter/material.dart';
import 'package:cashflow/app.dart';
import 'package:cashflow/services/connectivity_service.dart';
import 'package:cashflow/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ConnectivityService().initialize();

  SyncService().startListening();

  runApp(const MyApp());
}
