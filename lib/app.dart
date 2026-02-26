import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashflow/bloc/auth_bloc.dart';
import 'package:cashflow/bloc/book_bloc.dart';
import 'package:cashflow/bloc/profile_bloc.dart';
import 'package:cashflow/bloc/transaction_bloc.dart';
import 'package:cashflow/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => BookBloc()),
        BlocProvider(create: (context) => TransactionBloc()),
        BlocProvider(create: (context) => ProfileBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}
