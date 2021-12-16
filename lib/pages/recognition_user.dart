import 'package:camera/camera.dart';
import 'package:facial_recognation/controllers/recognition_user_controller.dart';
import 'package:facial_recognation/services/camera_service.dart';
import 'package:facial_recognation/services/database_service.dart';
import 'package:facial_recognation/services/face_net_service.dart';
import 'package:facial_recognation/services/ml_kit_service.dart';
import 'package:facial_recognation/widgets/face_marker_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class RecognationUser extends StatefulWidget {
  const RecognationUser({Key? key}) : super(key: key);

  @override
  State<RecognationUser> createState() => _RecognationUserState();
}

class _RecognationUserState extends State<RecognationUser> {
  final _recognationUserController = RecognationUserController(
      cameraService: CameraService(),
      dataBaseService: DataBaseService(),
      faceNetService: FaceNetService(),
      mlKitService: MLKitService());

  @override
  void dispose() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // Dispose of the controller when the widget is disposed.
      _recognationUserController.cameraService.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    /// starts the camera & start framing faces
    _recognationUserController.initializeControllerFuture =
        _recognationUserController.startCameraService();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _recognationUserController.verifyUser(context: context);
        },
        child: const Icon(Icons.camera_alt_outlined),
      ),
      appBar: AppBar(
        title: const Text('Recognation User'),
      ),
      body: SizedBox(
        child: FutureBuilder(
          future: _recognationUserController.initializeControllerFuture,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                width: width,
                height: height,
                child: ValueListenableBuilder<Face?>(
                  valueListenable: _recognationUserController.faceDetected,
                  builder: (context,value,child) {
                    return Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CameraPreview(_recognationUserController
                            .cameraService.cameraController),
                        if (value != null)
                          CustomPaint(
                            size: Size(width, height),
                            painter: FacePainter(
                                face: value,
                                imageSize: _recognationUserController.imageSize),
                          ),
                      ],
                    );
                  }
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }


}
