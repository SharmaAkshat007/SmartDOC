import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_new/src/logic/cubit/image_picker_cubit/image_picker_cubit.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../widgets/appbar.dart';
import '../../widgets/wrapper.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loader = false;
  String _readabilityStatus = 'Pending', _verificationStatus = 'Pending';
  late Timer _timer;
  late StreamController<int> _readScoreRequest,
      _verifyExtract,
      _extractedDetails;
  late XFile _imgFile;
  late Map<String, dynamic> _data;
  Timer _startTimer(StreamController _controller) {
    int _start = 0;
    Duration time = const Duration(milliseconds: 1);
    return _timer = Timer.periodic(
      time,
      (Timer timer) {
        if (_start == 99) {
          _controller.add(_start);
          timer.cancel();
          _start = 0;
        } else {
          _start = 99 * timer.tick ~/ 2000;
          _controller.add(_start);
        }
      },
    );
  }

  @override
  void dispose() {
    _extractedDetails.close();
    _verifyExtract.close();
    _readScoreRequest.close();
    super.dispose();
  }

  @override
  void initState() {
    _extractedDetails = StreamController.broadcast();
    _verifyExtract = StreamController.broadcast();
    _readScoreRequest = StreamController.broadcast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImagePickerCubit>(
      create: (context) => ImagePickerCubit(ImagePicker()),
      child: Builder(builder: (context) {
        return Wrapper(
          child: Scaffold(
            appBar: appbar(context),
            backgroundColor: Colors.white,
            body: WillPopScope(
              onWillPop: () => Future.value(false),
              child: BlocConsumer<ImagePickerCubit, ImagePickerState>(
                listener: (context, state) {
                  if (state is ImagePickerLoading) {
                    _loader = true;
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) =>
                            const Center(child: CircularProgressIndicator()));
                  } else if (state is ImagePickerDone) {
                    if (_loader) {
                      _loader = false;
                      Navigator.of(context).pop();
                    }
                    _imgFile = state.imageFile;
                    context
                        .read<ImagePickerCubit>()
                        .getQuality(state.imageFile);
                  } else if (state is ImageQualityCheckRequest) {
                    _startTimer(_readScoreRequest);
                  } else if (state is ImageQualityCheckDone) {
                    _timer.cancel();
                    _readScoreRequest
                        .add(100); //score recieved, quality loader to 100%
                    if (jsonDecode(state.res.body)['score'] > 3.0) {
                      _startTimer(_verifyExtract);
                      _readabilityStatus = 'Passed';
                      context.read<ImagePickerCubit>().verifyExtract(_imgFile);
                    } else {
                      _readabilityStatus = 'Failed';
                      _verifyExtract.add(-100); //take another image coz blur
                    }
                  } else if (state is ImageVerifyExtractDone) {
                    _timer.cancel();
                    _verifyExtract.add(
                        100); //image verify and extract request recieved, verification loader to 100%
                    final _res = jsonDecode(state.res.body);
                    if (_res['verified']) {
                      _verificationStatus = 'Passed';
                      _data = _res['data'];
                      Future.delayed(const Duration(seconds: 1), () {
                        _extractedDetails.add(1);
                      }); // Details extracted so next screen
                    } else {
                      _verificationStatus = 'Failed';
                      _verifyExtract.add(-100); //Not verified, Take other Image
                    }
                  } else if (state is ImageQualityCheckFail) {
                    _timer.cancel();
                    _readScoreRequest
                        .add(404); //404 retry btn coz error from server
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else if (state is ImageVerifyExtractFail) {
                    _timer.cancel();
                    _verifyExtract
                        .add(404); //404 retry btn coz error from server
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          state.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  } else {
                    if (_loader) {
                      _loader = false;
                      Navigator.of(context).pop();
                    }
                    if (state is ImagePickerError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }
                  }
                },
                buildWhen: (_prev, _current) =>
                    _current is ImagePickerDone ||
                    _current is ImagePickerInitial,
                builder: (context, state) {
                  if (state is ImagePickerDone) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            StreamBuilder<int>(
                                stream: _extractedDetails.stream,
                                initialData: 0,
                                builder: (context, snapshot) {
                                  return Center(
                                    child: Text(
                                      snapshot.data == 0
                                          ? 'CHECKING DOCUMENTS'
                                          : 'DATA EXTRACTED',
                                      style: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 22,
                                          color: const Color(0xff10294C)),
                                    ),
                                  );
                                }),
                            const SizedBox(
                              height: 10,
                            ),
                            Flexible(
                              child: Image.file(
                                File(state.imageFile.path),
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            StreamBuilder(
                              stream: _extractedDetails.stream,
                              initialData: 0,
                              builder: (context, snapshot2) {
                                if (snapshot2.data == 0) {
                                  return Column(
                                    children: [
                                      StreamBuilder<int>(
                                        stream: _readScoreRequest.stream,
                                        initialData: -1,
                                        builder: (context, snapshot) {
                                          if (snapshot.data == -1) {
                                            return Container();
                                          } else if (snapshot.data == 404) {
                                            return const Text(
                                                'Retry'); //retry btn
                                          } else {
                                            final double percent =
                                                snapshot.data?.toDouble() ?? 25;
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20),
                                                  child: LinearPercentIndicator(
                                                    padding: EdgeInsets.zero,
                                                    animation: true,
                                                    lineHeight: 35.0,
                                                    animationDuration: 500,
                                                    percent: percent / 100,
                                                    animateFromLastPercent:
                                                        true,
                                                    center: Text(
                                                      "$percent%",
                                                      style: GoogleFonts
                                                          .publicSans(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    progressColor: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'Readability Check Status: $_readabilityStatus',
                                                  style: GoogleFonts.publicSans(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      StreamBuilder<int>(
                                        stream: _verifyExtract.stream,
                                        initialData: -1,
                                        builder: (context, snapshot) {
                                          if (snapshot.data == -1) {
                                            return Container();
                                          } else if (snapshot.data == 404) {
                                            return const Text(
                                                'Retry'); //retry btn
                                          } else if (snapshot.data == -100) {
                                            return TextButton(
                                                onPressed: () {
                                                  _readabilityStatus =
                                                      'Pending';
                                                  context
                                                      .read<ImagePickerCubit>()
                                                      .emit(
                                                          ImagePickerInitial());
                                                },
                                                child: const Text(
                                                    'Take Other Image'));
                                          } else {
                                            final double percent =
                                                snapshot.data?.toDouble() ?? 25;
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20),
                                                  child: LinearPercentIndicator(
                                                    padding: EdgeInsets.zero,
                                                    animation: true,
                                                    lineHeight: 35.0,
                                                    animationDuration: 500,
                                                    percent: percent / 100,
                                                    animateFromLastPercent:
                                                        true,
                                                    center: Text(
                                                      "$percent%",
                                                      style: GoogleFonts
                                                          .publicSans(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                    ),
                                                    progressColor: Colors.blue,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  'Verification Check Status: $_verificationStatus',
                                                  style: GoogleFonts.publicSans(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                )
                                              ],
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      Card(
                                        shape: RoundedRectangleBorder(
                                            side: const BorderSide(),
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Center(
                                                child: Text(
                                                  'Extracted Details',
                                                  style: GoogleFonts.publicSans(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 18,
                                                      color: const Color(
                                                          0xff10294C)),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                  'Number of Faces Detected: ${_data['num_faces']}'),
                                              _data['num_faces'] > 0
                                                  ? GridView.builder(
                                                      shrinkWrap: true,
                                                      itemCount:
                                                          _data['num_faces'],
                                                      itemBuilder:
                                                          (context, index) {
                                                        final _str =
                                                            _data['faces']
                                                                    [index]
                                                                .toString();
                                                        return Image.memory(
                                                            base64Decode(
                                                                _str.substring(
                                                                    2,
                                                                    _str.length -
                                                                        1)));
                                                      },
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount: 5,
                                                              crossAxisSpacing:
                                                                  4,
                                                              mainAxisSpacing:
                                                                  4),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                          onPressed: () {
                                            context
                                                .read<ImagePickerCubit>()
                                                .emit(ImagePickerInitial());
                                          },
                                          child: const Text(
                                              'Upload Any Other File'))
                                    ],
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Center(
                            child: Text(
                              'UPLOADING DOCUMENTS',
                              style: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                  color: const Color(0xff10294C)),
                            ),
                          ),
                          const ImgUploadBtn(
                            text1: 'Upload from Media',
                            text2: 'Browse',
                            text3: 'Upload your files here',
                            source: ImageSource.gallery,
                            icon: Icons.cloud_upload_outlined,
                          ),
                          const ImgUploadBtn(
                            text1: 'Upload using Camera',
                            text2: 'Open',
                            text3: 'Take a clean and clear snapshot',
                            source: ImageSource.camera,
                            icon: Icons.add_a_photo_outlined,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ImgUploadBtn extends StatelessWidget {
  final String text1, text2, text3;
  final IconData icon;
  final ImageSource source;
  const ImgUploadBtn({
    Key? key,
    required this.text2,
    required this.text1,
    required this.source,
    required this.text3,
    required this.icon,
  }) : super(key: key);

  void _takeImage(ImageSource source, BuildContext ctx) {
    ctx.read<ImagePickerCubit>().pickImage(source);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _takeImage(source, context);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(text1,
                    style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: const Color(0xff10294C))),
              ),
              const SizedBox(
                height: 20,
              ),
              DottedBorder(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xffEEF3F8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 32,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: Text(
                            text2,
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: const Color(0xff1976D2)),
                      ),
                      Center(
                        child: Text(
                          text3,
                          style: GoogleFonts.publicSans(
                              fontSize: 10,
                              color: const Color(0xff494949),
                              fontWeight: FontWeight.w400),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
