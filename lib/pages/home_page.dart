import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'create_user.dart';
import 'recognation_user.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return Colors.red;
      }
      return Colors.blue;
    }

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
                      builder: (_) =>  CreateUser(),
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
}
