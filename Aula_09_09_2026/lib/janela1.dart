import 'package:flutter/material.dart';

class Janela1 extends StatelessWidget {
  const Janela1(
    this.muda, {
    super.key,
  });

  final Function() muda;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/imagens/palhaco.jpeg',
              ),
            ),
          ),
          const Text('Aperte o botão para começar:'),
          const SizedBox(
            height: 10,
          ),
          ElevatedButton.icon(
            icon: Icon(
              Icons.arrow_right_alt,
            ),
            onPressed: () {
              print('Iniciando...');
              muda();
            },
            label: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }
}
