import 'package:app_new/src/presentation/widgets/appbar.dart';
import 'package:app_new/src/presentation/widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../logic/bloc/auth_bloc.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  void _signIn() => BlocProvider.of<AuthBloc>(context).add(
        GoogleSignInRequested(),
      );
  @override
  Widget build(BuildContext context) {
    return Wrapper(
      child: Scaffold(
        appBar: appbar(context),
        body: WillPopScope(
          onWillPop: () => Future.value(false),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                // Displaying the error message if the user is not authenticated
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(state.error)));
              }
            },
            builder: (context, state) {
              if (state is Loading) {
                // Displaying the loading indicator while the user is signing up
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UnAuthenticated) {
                // Displaying the sign up form if the user is not authenticated
                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Image.asset(
                          'assets/image 11.png',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'You are almost there!',
                        style: GoogleFonts.publicSans(
                            color: const Color(0xff10294C),
                            fontSize: 26,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Sign in so that we are able to fetch  your documents for scanning.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.publicSans(
                            color: const Color(0xff5C5C5C),
                            fontWeight: FontWeight.w400,
                            fontSize: 18),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: _signIn,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xff5C5C5C), width: 2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: const Image(
                                image: AssetImage('assets/google_icon.png'),
                                height: 38.0,
                              ),
                            ),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.publicSans(
                                  color: const Color(0xff333333),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }
}
