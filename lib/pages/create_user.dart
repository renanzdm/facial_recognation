import 'package:camera/camera.dart';
import 'package:facial_recognation/controllers/create_user_controller.dart';
import 'package:facial_recognation/services/camera_service.dart';
import 'package:facial_recognation/services/database_service.dart';
import 'package:facial_recognation/services/face_net_service.dart';
import 'package:facial_recognation/services/ml_kit_service.dart';
import 'package:facial_recognation/widgets/face_marker_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({Key? key}) : super(key: key);

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  final CreateUserController _createUserController = CreateUserController(
      cameraService: CameraService(),
      dataBaseService: DataBaseService(),
      faceNetService: FaceNetService(),
      mlKitService: MLKitService());

  @override
  void dispose() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _createUserController.cameraService.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _createUserController.initializeControllerFuture =
        _createUserController.startCameraService();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _createUserController.createUser(context);
        },
        child: const Icon(Icons.camera_alt_outlined),
      ),
      appBar: AppBar(
        title: const Text('Create User'),
      ),
      body: SizedBox(
        child: FutureBuilder(
          future: _createUserController.initializeControllerFuture,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return SizedBox(
                width: width,
                height: height,
                child: ValueListenableBuilder<Face?>(
                  valueListenable: _createUserController.faceDetected,
                  builder: (context,value,widget) {
                    return Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        CameraPreview(
                            _createUserController.cameraService.cameraController),
                        if (value != null)
                          CustomPaint(
                            size: Size(width, height),
                            painter: FacePainter(
                                face: value,
                                imageSize: _createUserController.imageSize),
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

    Color getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return Colors.red;
      }
      return Colors.blue;
    }
  
}
