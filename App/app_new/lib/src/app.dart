import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/constants/strings.dart';
import 'data/repositories/auth_repository.dart';
import 'logic/bloc/auth_bloc.dart';
import 'logic/cubit/internet_cubit/internet_cubit.dart';
import 'presentation/router/app_router.dart';

class App extends StatelessWidget {
  final AppRouter appRouter;
  final Connectivity connectivity;
  final http.Client httpClient;
  const App(
      {Key? key,
      required this.appRouter,
      required this.connectivity,
      required this.httpClient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<http.Client>(
          create: (context) => httpClient,
        )
      ],
      child: RepositoryProvider(
        create: (context) => AuthRepository(),
        child: MultiBlocProvider(
            providers: [
              BlocProvider<InternetCubit>(
                create: (context) => InternetCubit(connectivity: connectivity),
              ),
              BlocProvider<AuthBloc>(
                create: (context) => AuthBloc(
                  authRepository:
                      RepositoryProvider.of<AuthRepository>(context),
                ),
              ),
            ],
            child: LayoutBuilder(
              builder: (context, constraints) {
                return MaterialApp(
                  restorationScopeId: 'app',
                  title: Strings.appTitle,
                  debugShowCheckedModeBanner: false,
                  onGenerateRoute: appRouter.onGenerateRoute,
                  initialRoute: Strings.splash,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en', ''), // English, no country code
                  ],
                );
              },
            )),
      ),
    );
  }
}
