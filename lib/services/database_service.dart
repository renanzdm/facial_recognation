import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataBaseService {
  static final DataBaseService _cameraServiceService =
      DataBaseService._internal();
  factory DataBaseService() => _cameraServiceService;
  DataBaseService._internal();

  
  late File jsonFile;

  
  Map<String, dynamic> _db = {};
  Map<String, dynamic> get db => _db;

  
  Future loadDB() async {
    var tempDir = await getApplicationDocumentsDirectory();
    String _embPath = tempDir.path + '/emb.json';

    jsonFile = File(_embPath);

    if (jsonFile.existsSync()) {
      _db = json.decode(jsonFile.readAsStringSync());
      log(_db.toString());
    }
  }

  Future saveData( {required List dataImage}) async {
    _db['image'] = dataImage;
    jsonFile.writeAsStringSync(json.encode(_db));
  }

  
  cleanDB() {
    _db = {};
    jsonFile.writeAsStringSync(json.encode({}));
  }
}
