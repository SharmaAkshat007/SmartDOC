import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/bloc/auth_bloc.dart';
import '../home_screen/home_screen.dart';
import '../login_screen/login_screen.dart';

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  _RedirectState createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the snapshot has user data, then they're already signed in. So Navigating to the Dashboard.
          if (snapshot.hasData) {
            context.read<AuthBloc>().emit(Authenticated());
            return const Home();
          }
          // Otherwise, they're not signed in. Show the sign in page.
          return const Login();
        });
  }
}
