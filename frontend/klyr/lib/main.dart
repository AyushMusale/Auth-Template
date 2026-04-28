import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:klyr/presentation/auth/bloc/authbloc.dart';
import 'package:klyr/router/app_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => Authbloc())],
      child: MaterialApp.router(routerConfig: router),
    );
  }
}
