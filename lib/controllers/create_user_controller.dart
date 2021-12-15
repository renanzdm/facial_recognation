import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:facial_recognation/services/camera_service.dart';
import 'package:facial_recognation/services/database_service.dart';
import 'package:facial_recognation/services/face_net_service.dart';
import 'package:facial_recognation/services/ml_kit_service.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CreateUserController {
  CreateUserController(
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
  String? imagePath;
  Future<void>? initializeControllerFuture;

  Future<void> startCameraService() async {
    await faceNetService.loadModel();
    mlKitService.initialize();
    await dataBaseService.loadDB();
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription _selectCamera = cameras.firstWhere(
        (element) => element.lensDirection == CameraLensDirection.front);
    await cameraService.startService(_selectCamera);
    await _frameFaces();
  }

  Future<void> _frameFaces() async {
    imageSize = cameraService.getImageSize();
    await cameraService.cameraController.startImageStream((image) async {
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

  Future createUser(context) async {
    if (faceDetected.value == null) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );
    } else {
      saving = true;
      await Future.delayed(const Duration(milliseconds: 500));
      await cameraService.cameraController.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 200));
      XFile file = await cameraService.takePicture();
      imagePath = file.path;
      List predictedData = faceNetService.predictedData;
      await dataBaseService.saveData(dataImage: predictedData);
      faceNetService.clearPredicatedDate();
      Navigator.pop(context);
    }
  }
}
