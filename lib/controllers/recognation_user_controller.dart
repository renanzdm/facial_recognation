import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:facial_recognation/services/camera_service.dart';
import 'package:facial_recognation/services/database_service.dart';
import 'package:facial_recognation/services/face_net_service.dart';
import 'package:facial_recognation/services/ml_kit_service.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class RecognationUserController {
  RecognationUserController(
      {required this.mlKitService,
      required this.cameraService,
      required this.faceNetService,
      required this.dataBaseService});

  final MLKitService mlKitService;
  final CameraService cameraService;
  final FaceNetService faceNetService;
  final DataBaseService dataBaseService;

  Size imageSize = const Size(0.0, 0.0);
  bool detectingFaces = false;
  ValueNotifier<Face?> faceDetected = ValueNotifier(null);
  bool saving = false;
  Future<void>? initializeControllerFuture;

  Future<void> startCameraService() async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription _selectCamera = cameras.firstWhere(
        (element) => element.lensDirection == CameraLensDirection.front);
    await cameraService.startService(_selectCamera);
    _frameFaces();
  }

  Future<void> _frameFaces() async {
    imageSize = cameraService.getImageSize();
    cameraService.cameraController.startImageStream((image) async {
      if (detectingFaces) return;
      detectingFaces = true;
      try {
        List<Face> faces = await mlKitService.getFacesFromImage(image);
        if (faces.isNotEmpty) {
          faceDetected.value = faces[0];
          if (saving) {
            faceNetService.setCurrentPrediction(image, faceDetected.value!);
            saving = false;
          }
        } else {
          faceDetected.value = null;
        }
        detectingFaces = false;
      } catch (e) {
        detectingFaces = false;
        log(e.toString());
        log(e.toString());
      }
    });
  }

  Future verifyUser({required BuildContext context}) async {
    saving = true;
    await Future.delayed(const Duration(milliseconds: 2000));
    List? valid = faceNetService.predict();
    if (valid != null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Colors.green,
            content: Text('User Authenticated'),
          );
        },
      );
    } else {
      saving = true;
      faceNetService.clearPredicatedDate();

      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            backgroundColor: Colors.red,
            content: Text('User is not Authenticate'),
          );
        },
      );
    }
  }
}
