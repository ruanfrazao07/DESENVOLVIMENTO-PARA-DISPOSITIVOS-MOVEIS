// main.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// emulador Android: 10.0.2.2 | celular de verdade: IP do computador
const String servidor = 'http://10.0.2.2/api/uploads';

void main() {
  runApp(const Janela());
}

class Janela extends StatelessWidget {
  const Janela({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Enviar(),
    );
  }
}

// ---------- Janela 1: tira a foto e envia ----------

class Enviar extends StatefulWidget {
  const Enviar({super.key});

  @override
  State<Enviar> createState() => _EnviarState();
}

class _EnviarState extends State<Enviar> {
  final ImagePicker picker = ImagePicker();
  XFile? foto;
  TextEditingController descricao = TextEditingController();

  void tirarFoto() async {
    final XFile? imagem = await picker.pickImage(source: ImageSource.camera);

    if (imagem != null) {
      setState(() {
        foto = imagem;
      });
    }
  }

  void enviar() async {
    if (foto == null) return;

    try {
      final pedido = http.MultipartRequest(
        'POST',
        Uri.parse('$servidor/salvar_foto.php'),
      );
      pedido.fields['descricao'] = descricao.text;
      pedido.files.add(await http.MultipartFile.fromPath('foto', foto!.path));

      final resposta = await pedido.send();
      final corpo = await resposta.stream.bytesToString();
      print('ENVIO: ${resposta.statusCode} $corpo');

      if (!mounted) return;
      setState(() {
        foto = null;
      });
      descricao.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto enviada!')),
      );
    } catch (e) {
      print('ERRO: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enviar foto')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (foto != null)
              Image.file(File(foto!.path), height: 300)
            else
              const Text('Nenhuma foto tirada'),
            ElevatedButton(
              onPressed: tirarFoto,
              child: const Text('Tirar foto'),
            ),
            TextField(
              controller: descricao,
              decoration: const InputDecoration(labelText: 'Descrição'),
            ),
            ElevatedButton(
              onPressed: enviar,
              child: const Text('Enviar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Mostrar()),
                );
              },
              child: const Text('Ver fotos'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Janela 2: mostra uma foto por vez ----------

class Mostrar extends StatefulWidget {
  const Mostrar({super.key});

  @override
  State<Mostrar> createState() => _MostrarState();
}

class _MostrarState extends State<Mostrar> {
  int idAtual = 0;
  String arquivo = '';
  String descricao = '';

  @override
  void initState() {
    super.initState();
    proximo();
  }

  void proximo() async {
    try {
      final resposta = await http.get(
        Uri.parse('$servidor/proximo_foto.php?id=$idAtual'),
      );

      final dados = jsonDecode(resposta.body);

      // acabaram as fotos: volta para a primeira
      if (dados['id'] == 0 && idAtual != 0) {
        idAtual = 0;
        proximo();
        return;
      }

      setState(() {
        idAtual = dados['id'];
        arquivo = dados['arquivo'];
        descricao = dados['descricao'];
      });
    } catch (e) {
      print('ERRO: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fotos')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (arquivo != '')
            Image.network('$servidor/$arquivo', height: 400)
          else
            const Text('Nenhuma foto'),
          Text(descricao, style: const TextStyle(fontSize: 24)),
          ElevatedButton(
            onPressed: proximo,
            child: const Text('Próxima'),
          ),
        ],
      ),
    );
  }
}
