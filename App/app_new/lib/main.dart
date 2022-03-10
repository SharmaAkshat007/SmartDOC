import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '/src/logic/debug/app_bloc_observer.dart';
import '/src/presentation/router/app_router.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  BlocOverrides.runZoned(
    () => runApp(
      App(
        appRouter: AppRouter(),
        connectivity: Connectivity(),
        httpClient: http.Client(),
      ),
    ),
    blocObserver: AppBlocObserver(),
  );
}
