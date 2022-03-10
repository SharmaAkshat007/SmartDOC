import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../src/core/constants/enums.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  final Connectivity connectivity;
  late StreamSubscription connectivityStreamSubscription;

  InternetCubit({required this.connectivity}) : super(InternetLoading()) {
    monitorInternetConnection();
  }

  StreamSubscription<ConnectivityResult> monitorInternetConnection() {
    return connectivityStreamSubscription = connectivity.onConnectivityChanged
        .listen((ConnectivityResult connectivityResult) async {
      if (connectivityResult == ConnectivityResult.none) {
        emitInternetDisconnected();
      } else {
        if (await hasNetwork()) {
          if (connectivityResult == ConnectivityResult.wifi) {
            emitInternetConnected(ConnectionType.wifi);
          } else if (connectivityResult == ConnectivityResult.mobile) {
            emitInternetConnected(ConnectionType.mobile);
          }
        } else {
          emitInternetDisconnected();
        }
      }
    });
  }

  void emitInternetConnected(ConnectionType _connectionType) =>
      emit(InternetConnected(connectionType: _connectionType));
  void emitInternetDisconnected() => emit(InternetDisconnected());

  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    connectivityStreamSubscription.cancel();
    return super.close();
  }
}
