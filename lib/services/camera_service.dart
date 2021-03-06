import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CameraService {
  static final CameraService _cameraService = CameraService._internal();
  factory CameraService() => _cameraService;
  CameraService._internal();

  late CameraDescription _cameraDescription;
  late CameraController _cameraController;
  CameraController get cameraController => _cameraController;
  late InputImageRotation _cameraRotation;
  InputImageRotation get cameraRotation => _cameraRotation;

  String imagePath = '';

  Future<void> startService(CameraDescription cameraDescription) async {
    _cameraDescription = cameraDescription;
    _cameraController = CameraController(
        _cameraDescription, ResolutionPreset.high,
        enableAudio: false);

    
    _cameraRotation =
        rotationIntToImageRotation(cameraDescription.sensorOrientation);
    
    return   _cameraController.initialize();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  
  Future<XFile> takePicture() async {
    XFile file = await _cameraController.takePicture();
    imagePath = file.path;
    return file;
  }

  
  Size getImageSize() {
    return Size(
      _cameraController.value.previewSize?.height ?? 0.0,
      _cameraController.value.previewSize?.width ?? 0.0,
    );
  }

  dispose() {
    _cameraController.dispose();
  }
}
