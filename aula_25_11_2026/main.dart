import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String servidor = 'http://10.0.2.2/atividades';

const List<String> nomesMeses = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

String doisDigitos(int numero) {
  return numero.toString().padLeft(2, '0');
}

void main() {
  runApp(const Janela());
}

class Janela extends StatelessWidget {
  const Janela({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Atividades(),
    );
  }
}

class Atividades extends StatefulWidget {
  const Atividades({super.key});

  @override
  State<Atividades> createState() => _AtividadesState();
}

class _AtividadesState extends State<Atividades> {
  TextEditingController dia = TextEditingController();
  TextEditingController atividade = TextEditingController();
  DateTime mes = DateTime(DateTime.now().year, DateTime.now().month);
  List lista = [];

  @override
  void initState() {
    super.initState();
    final DateTime hoje = DateTime.now();
    dia.text =
        '${doisDigitos(hoje.day)}/${doisDigitos(hoje.month)}/${hoje.year}';
    carregar();
  }

  void carregar() async {
    try {
      final resposta = await http.get(
        Uri.parse(
            '$servidor/listar.php?mes=${mes.year}-${doisDigitos(mes.month)}'),
      );

      setState(() {
        lista = jsonDecode(resposta.body);
      });
    } catch (e) {
      print('ERRO: $e');
    }
  }

  DateTime? lerData(String texto) {
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(texto)) return null;

    final partes = texto.split('/');
    final int d = int.parse(partes[0]);
    final int m = int.parse(partes[1]);
    final int a = int.parse(partes[2]);

    final DateTime data = DateTime(a, m, d);

    if (data.day != d || data.month != m || data.year != a) return null;

    return data;
  }

  void salvar() async {
    final DateTime? data = lerData(dia.text);

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o dia no formato dd/mm/aaaa')),
      );
      return;
    }

    if (atividade.text.trim() == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva a atividade')),
      );
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('$servidor/salvar.php'),
        body: {
          'dia':
              '${data.year}-${doisDigitos(data.month)}-${doisDigitos(data.day)}',
          'atividade': atividade.text,
        },
      );

      final dados = jsonDecode(resposta.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dados['mensagem'])),
      );

      if (dados['ok'] == true) {
        atividade.clear();
        setState(() {
          mes = DateTime(data.year, data.month);
        });
        carregar();
      }
    } catch (e) {
      print('ERRO: $e');
    }
  }

  void mudarMes(int quantidade) {
    setState(() {
      mes = DateTime(mes.year, mes.month + quantidade);
    });
    carregar();
  }

  String formatarDia(String texto) {
    final partes = texto.split('-');
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Atividades do dia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: dia,
              keyboardType: TextInputType.datetime,
              decoration: const InputDecoration(labelText: 'Dia (dd/mm/aaaa)'),
            ),
            TextField(
              controller: atividade,
              decoration: const InputDecoration(labelText: 'Atividade'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: salvar,
              child: const Text('Salvar'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    mudarMes(-1);
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${nomesMeses[mes.month - 1]} de ${mes.year}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () {
                    mudarMes(1);
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Expanded(
              child: lista.isEmpty
                  ? const Center(child: Text('Nenhuma atividade neste mês'))
                  : ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (context, indice) {
                        final item = lista[indice];

                        return ListTile(
                          leading: Text(
                            formatarDia(item['dia']),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          title: Text(item['atividade']),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
