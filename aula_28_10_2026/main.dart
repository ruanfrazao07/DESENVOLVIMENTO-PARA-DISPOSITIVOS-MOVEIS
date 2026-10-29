// main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Janela());
}

class Janela extends StatelessWidget {
  const Janela({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: Principal()),
    );
  }
}

class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int fator = 2;
  int multiplicador = 1;
  bool errou = false;
  String digitado = '';

  @override
  void initState() {
    super.initState();
    carregar();
  }

  // lê a posição salva
  void carregar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fator = prefs.getInt('fator') ?? 2;
      multiplicador = prefs.getInt('multiplicador') ?? 1;
    });
  }

  // guarda a posição atual
  void salvar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fator', fator);
    await prefs.setInt('multiplicador', multiplicador);
  }

  void proximoFator() {
    if (fator < 10) {
      fator++;
    } else {
      fator = 1;
    }
    multiplicador = 1;
    errou = false;
    digitado = '';
  }

  // chamado quando o usuário aperta um botão de 0 a 9
  void digitar(int numero) {
    setState(() {
      digitado = digitado + numero.toString();
    });
  }

  // apaga tudo o que foi digitado
  void apagar() {
    setState(() {
      digitado = '';
    });
  }

  void verificar() {
    int? resposta = int.tryParse(digitado);

    setState(() {
      if (resposta == fator * multiplicador) {
        if (multiplicador < 10) {
          multiplicador++;
          digitado = '';
        } else {
          // acertou todas, muda de fator
          proximoFator();
        }
      } else {
        // errou, mostra a mensagem
        errou = true;
      }
    });

    salvar();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LinearProgressIndicator(
          value: (multiplicador - 1) / 10,
          color: Colors.green,
          backgroundColor: const Color.fromARGB(255, 54, 57, 244),
        ),
        Text('$fator x $multiplicador = ?',
            style: const TextStyle(fontSize: 32)),
        if (errou)
          GestureDetector(
            onTap: () {
              setState(() {
                proximoFator();
              });
              salvar();
            },
            child: const Text(
              'Errou, clique aqui para continuar',
              style: TextStyle(
                  fontSize: 20, color: Color.fromARGB(255, 241, 244, 54)),
            ),
          )
        else
          Column(
            children: [
              // mostra o que o usuário já digitou
              Text(digitado, style: const TextStyle(fontSize: 40)),
              // cria os botões de 0 a 9
              Wrap(
                children: List.generate(10, (numero) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: ElevatedButton(
                      onPressed: () {
                        digitar(numero);
                      },
                      child: Text('$numero'),
                    ),
                  );
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: apagar,
                    child: const Text('Apagar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: verificar,
                    child: const Text('Verificar'),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
