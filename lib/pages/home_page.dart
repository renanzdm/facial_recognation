import 'package:facial_recognation/services/database_service.dart';
import 'package:facial_recognation/services/face_net_service.dart';
import 'package:facial_recognation/services/ml_kit_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'create_user.dart';
import 'recognition_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MLKitService mlKitService = MLKitService();
  final FaceNetService faceNetService=FaceNetService();
  final DataBaseService dataBaseService=DataBaseService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback(
      (_) async {
        await faceNetService.loadModel();
        mlKitService.initialize();
        await dataBaseService.loadDB();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const CreateUser(),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(getColor),
                ),
                child: const Text('Create User'),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => const RecognationUser(),
                    ),
                  );
                },
                child: const Text('Testing Face'),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(getColor),
                ),
              ),
            ),
          ],
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
