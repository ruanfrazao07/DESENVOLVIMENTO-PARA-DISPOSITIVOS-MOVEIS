// lib/pergunta.dart
class Pergunta {
  const Pergunta(this.textoPergunta, this.respostas);
  final String textoPergunta;
  final List<String> respostas;

  List<String> embaralha() {
    return List.of(respostas)..shuffle();
  }
}
