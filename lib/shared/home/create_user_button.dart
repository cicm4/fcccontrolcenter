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
              alignment: Alignment.center,
              title: const Text('Crear Usuario',
              textAlign: TextAlign.center,),
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
                  const SizedBox(height: 20),
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
