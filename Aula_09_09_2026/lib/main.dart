import 'package:flutter/material.dart';
import 'package:flutter_application_1/janela1.dart';
import 'package:flutter_application_1/janela2.dart';

void main() {
  runApp(
    Controle(),
  );
}

class Controle extends StatefulWidget {
  const Controle({super.key});

  @override
  State<Controle> createState() => _ControleState();
}

class _ControleState extends State<Controle> {
  Widget? atual;

  @override
  void initState() {
    atual = Janela1(muda);
    super.initState();
  }

  void muda() {
    setState(() {
      atual = Janela2(volta);
    });
  }

  void volta() {
    setState(() {
      atual = Janela1(muda);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: atual,
    );
  }
}
