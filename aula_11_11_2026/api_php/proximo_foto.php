<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$id = $_GET['id'];

$comando = $conexao->prepare(
  'SELECT id, arquivo, descricao FROM fotos WHERE id > ? ORDER BY id LIMIT 1'
);
$comando->bind_param('i', $id);
$comando->execute();
$resultado = $comando->get_result();
$linha = $resultado->fetch_assoc();

if ($linha) {
  echo json_encode($linha);
} else {
  echo json_encode(['id' => 0, 'arquivo' => '', 'descricao' => '']);
}