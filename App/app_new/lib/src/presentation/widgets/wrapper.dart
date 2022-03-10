import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/src/logic/cubit/internet_cubit/internet_cubit.dart';

class Wrapper extends StatelessWidget {
  final Widget child;
  const Wrapper({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<InternetCubit, InternetState>(
        builder: (_, internetState) {
          if (internetState is InternetLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (internetState is InternetConnected) {
            return child;
          } else {
            return const Scaffold(
              body: Text('No internet'),
            );
          }
        },
      ),
    );
  }
}
