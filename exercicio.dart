void main() {
  var nome = "camiseta ADS";
  int quantidade = 3;
  double preco = 49.90;
  bool disponivel = true;
  double imposto = 5.00;

  double resultado = (quantidade * preco) * (1 + imposto / 100);

  print("Produto: $nome");
  print("Disponível em estoque: $disponivel");
  print("Quantidade: $quantidade");
  print("Preço unitario: $preco");
  print("Valor total: $resultado");
}
