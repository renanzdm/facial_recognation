import 'dart:developer' as log;
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;
import 'database_service.dart';
import 'image_converter.dart';

class FaceNetService {
  static final FaceNetService _faceNetService = FaceNetService._internal();
  factory FaceNetService() => _faceNetService;
  FaceNetService._internal();

  final DataBaseService _dataBaseService = DataBaseService();
  late Interpreter _interpreter;
  double threshold = 1.0;
  List? _predictedData;
  List get predictedData => _predictedData??[];

  Map data = {};

  Future loadModel() async {
    Delegate? delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(options: GpuDelegateOptionsV2());
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
              allowPrecisionLoss: true,
              waitType: TFLGpuDelegateWaitType.active),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate!);

      _interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
      log.log('model loaded successfully');
    } catch (e) {
      log.log('Failed to load model.');
      log.log(e.toString());
    }
  }

  setCurrentPrediction(CameraImage cameraImage, Face face) {
    List input = _preProcess(cameraImage, face);

    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));

    _interpreter.run(input, output);
    output = output.reshape([192]);

    _predictedData = List.from(output);
  }

  List _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList;
  }

   List? predict() {
    return _searchResult(predictedData);
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img!, -90);
    return img1;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);

        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

   List? _searchResult(List predictedData) {
    Map<String, dynamic> data = _dataBaseService.db;
    if (data.isEmpty) return null;
    double minDist = 999;
    double currDist = 0.0;
    List? predRes;
    currDist = _euclideanDistance(data['image'], predictedData);
    if (currDist <= threshold && currDist < minDist) {
      minDist = currDist;
      predRes = data['image'];
    }
    return predRes;
  }

  double _euclideanDistance(List e1, List e2) {
    if (e1.isNotEmpty && e2.isNotEmpty) {
      double sum = 0.0;
      for (int i = 0; i < e1.length; i++) {
        sum += pow((e1[i] - e2[i]), 2);
      }
      return sqrt(sum);
    } else {
      return 100.0;
    }
  }

  void clearPredicatedDate() {
    _predictedData=null;
  }
}
