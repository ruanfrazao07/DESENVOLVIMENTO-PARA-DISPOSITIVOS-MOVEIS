import 'package:flutter/material.dart';

void main() {
  runApp(const Janela());
}

class Janela extends StatelessWidget {
  const Janela({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Galeria()),
    );
  }
}

class ImagemModelo {
  final String url;
  bool gostou;

  ImagemModelo({
    required this.url,
    this.gostou = false,
  });
}

class Galeria extends StatefulWidget {
  const Galeria({super.key});

  @override
  State<Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<Galeria> {
  final List<ImagemModelo> imagens = [
    ImagemModelo(
      url:
          'https://commons.wikimedia.org/wiki/Special:FilePath/Great_Wave_off_Kanagawa2.jpg?width=200',
    ),
    ImagemModelo(
      url:
          'https://commons.wikimedia.org/wiki/Special:FilePath/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg?width=200',
    ),
    ImagemModelo(
      url:
          'https://commons.wikimedia.org/wiki/Special:FilePath/Mona_Lisa.jpg?width=200',
    ),
    ImagemModelo(
      url:
          'https://commons.wikimedia.org/wiki/Special:FilePath/Felis_catus-cat_on_snow.jpg?width=200',
    ),
    ImagemModelo(
      url:
          'https://commons.wikimedia.org/wiki/Special:FilePath/Pieter_Bruegel_the_Elder_-_The_Tower_of_Babel_%28Vienna%29_-_Google_Art_Project_-_edited.jpg?width=200',
    ),
  ];

  int atual = 0;

  void proximaImagem() {
    setState(() {
      if (atual < imagens.length - 1) {
        atual++;
      } else {
        atual = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ImagemModelo imagemAtual = imagens[atual];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Image.network(imagemAtual.url),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                imagemAtual.gostou = !imagemAtual.gostou;
              });
            },
            child: Icon(
              imagemAtual.gostou ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: proximaImagem,
            child: const Text('Próxima'),
          ),
        ],
      ),
    );
  }
}
