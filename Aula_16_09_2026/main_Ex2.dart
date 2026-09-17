import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const Janela());
}

class Janela extends StatelessWidget {
  const Janela({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Tabuada()),
    );
  }
}

class Tabuada extends StatefulWidget {
  const Tabuada({super.key});

  @override
  State<Tabuada> createState() => _TabuadaState();
}

class _TabuadaState extends State<Tabuada> {
  final controlaTexto = TextEditingController();

  int numero1 = Random().nextInt(10) + 1;
  int numero2 = Random().nextInt(10) + 1;

  String resposta = '';

  void novaConta() {
    setState(() {
      numero1 = Random().nextInt(10) + 1;
      numero2 = Random().nextInt(10) + 1;
      resposta = '';
      controlaTexto.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    int respostaCorreta = numero1 * numero2;
    int? numeroDigitado = int.tryParse(resposta);
    bool acertou = numeroDigitado == respostaCorreta;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$numero1 x $numero2 = ?',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: TextField(
                  controller: controlaTexto,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      resposta = valor;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              if (resposta.isNotEmpty)
                Icon(
                  acertou ? Icons.check_circle : Icons.cancel,
                  color: acertou ? Colors.green : Colors.red,
                ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: novaConta,
            child: const Text('Nova conta'),
          ),
        ],
      ),
    );
  }
}
