import 'package:flutter/material.dart';

class CreateUserButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Crear Usuario'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/registrar_uno');
                    },
                    child: const Text('Registrar Uno'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, '/registrar_varios');
                    },
                    child: const Text('Registrar Varios'),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: const Text('Crear Usuario'),
    );
  }
}
