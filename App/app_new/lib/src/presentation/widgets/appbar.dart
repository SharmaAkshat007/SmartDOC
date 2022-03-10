import 'package:app_new/src/logic/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

AppBar appbar(BuildContext context) {
  return AppBar(
    actions: [
      if (context.read<AuthBloc>().state is Authenticated)
        IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
            icon: const Icon(Icons.logout_sharp))
    ],
    centerTitle: true,
    title: const Text('Verify Doc'),
  );
}
