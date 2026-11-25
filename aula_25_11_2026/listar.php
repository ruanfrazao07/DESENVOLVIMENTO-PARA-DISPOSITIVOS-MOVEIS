<?php

$conexao = new mysqli('localhost', 'root', '', 'atividades');

$mes = $_GET['mes'];

if (!preg_match('/^\d{4}-\d{2}$/', $mes)) {
  echo json_encode([]);
  exit;
}

$inicio = $mes . '-01';
$fim = (new DateTime($inicio))->modify('+1 month')->format('Y-m-d');

$comando = $conexao->prepare(
  'SELECT id, dia, atividade FROM atividades WHERE dia >= ? AND dia < ? ORDER BY dia, id'
);
$comando->bind_param('ss', $inicio, $fim);
$comando->execute();
$resultado = $comando->get_result();

$lista = [];
while ($linha = $resultado->fetch_assoc()) {
  $lista[] = $linha;
}

echo json_encode($lista);