import 'package:flutter/material.dart';
import 'package:flutter_application_1/questoes.dart';
import 'package:flutter_application_1/pergunta.dart';

class Janela2 extends StatefulWidget {
  const Janela2(
    this.volta, {
    super.key,
  });

  final Function() volta;

  @override
  State<Janela2> createState() => _Janela2State();
}

class _Janela2State extends State<Janela2> {
  int indiceAtual = 0;
  String resultado = 'Responda as perguntas abaixo:';
  late List<String> respostasEmbaralhadas = questoes[indiceAtual].embaralha();

  void responder(String respostaEscolhida) {
    Pergunta perguntaAtual = questoes[indiceAtual];
    String respostaCerta = perguntaAtual.respostas[0];

    setState(() {
      if (respostaEscolhida == respostaCerta) {
        resultado = 'Acertou!';
      } else {
        resultado = 'Errou! Resposta certa: $respostaCerta';
      }

      if (indiceAtual < questoes.length - 1) {
        indiceAtual++;
        respostasEmbaralhadas = questoes[indiceAtual].embaralha();
      } else {
        widget.volta();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Pergunta perguntaAtual = questoes[indiceAtual];

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                resultado,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                perguntaAtual.textoPergunta,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...respostasEmbaralhadas.map(
                    (resposta) => ElevatedButton(
                      onPressed: () => responder(resposta),
                      child: Text(resposta),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.arrow_right_alt,
                    ),
                    onPressed: () {
                      print('Voltando...');
                      widget.volta();
                    },
                    label: const Text('Voltar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
