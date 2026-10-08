import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController controlador = TextEditingController();
  String mensagem = '';

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<String> get _pastaDocumentos async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _arquivo async {
    final caminho = await _pastaDocumentos;
    return File('$caminho/organiza.md');
  }

  Future<void> carregar() async {
    try {
      final arquivo = await _arquivo;
      if (await arquivo.exists()) {
        final conteudo = await arquivo.readAsString();
        setState(() {
          controlador.text = conteudo;
          mensagem = 'Arquivo carregado.';
        });
        print('Carregando organiza.md');
      } else {
        setState(() {
          mensagem = 'Nenhum arquivo salvo ainda.';
        });
      }
    } catch (_) {
      setState(() {
        mensagem = 'Erro ao carregar o arquivo.';
      });
    }
  }

  void salvar() async {
    try {
      final arquivo = await _arquivo;
      await arquivo.writeAsString(controlador.text);
      setState(() {
        mensagem = 'Arquivo salvo!';
      });
      print('Salvando organiza.md');
    } catch (_) {
      setState(() {
        mensagem = 'Erro ao salvar o arquivo.';
      });
    }
  }

  void apagar() async {
    try {
      final arquivo = await _arquivo;
      if (await arquivo.exists()) {
        await arquivo.delete();
      }
      setState(() {
        controlador.clear();
        mensagem = 'Arquivo apagado.';
      });
      print('Apagando organiza.md');
    } catch (_) {
      setState(() {
        mensagem = 'Erro ao apagar o arquivo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Editor de organiza.md'),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Escreva seu texto em Markdown!',
                        border: OutlineInputBorder(),
                      ),
                      controller: controlador,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ),
                Text(mensagem),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: salvar,
                        child: const Text('Salvar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: apagar,
                        child: const Text('Apagar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
