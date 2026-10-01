import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final cepController = TextEditingController();
  String resultado = '';

  Future<void> buscaCep() async {
    try {
      final url =
          Uri.parse('https://viacep.com.br/ws/${cepController.text}/json/');
      final resposta = await http.get(url);
      final dados = jsonDecode(resposta.body);

      if (dados['erro'] == true) {
        resultado = 'CEP não encontrado.';
      } else {
        resultado = 'Rua: ${dados['logradouro']}\n'
            'Bairro: ${dados['bairro']}\n'
            'Cidade: ${dados['localidade']}\n'
            'Estado: ${dados['estado']}';
      }
    } catch (e) {
      resultado = 'CEP inválido.';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Buscar CEP')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: cepController,
                decoration: const InputDecoration(labelText: 'Digite o CEP'),
              ),
              ElevatedButton(
                onPressed: buscaCep,
                child: const Text('Buscar'),
              ),
              Text(resultado),
            ],
          ),
        ),
      ),
    );
  }
}
