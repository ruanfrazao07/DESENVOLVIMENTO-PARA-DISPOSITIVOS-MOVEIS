<?php

$conexao = new mysqli('localhost', 'root', '', 'atividades');

$dia = $_POST['dia'];
$atividade = trim($_POST['atividade']);

$data = DateTime::createFromFormat('Y-m-d', $dia);

if (!$data || $data->format('Y-m-d') != $dia) {
  echo json_encode(['ok' => false, 'mensagem' => 'Data inválida']);
  exit;
}

if ($atividade == '') {
  echo json_encode(['ok' => false, 'mensagem' => 'Escreva a atividade']);
  exit;
}

$comando = $conexao->prepare('INSERT INTO atividades (dia, atividade) VALUES (?, ?)');
$comando->bind_param('ss', $dia, $atividade);
$comando->execute();

echo json_encode(['ok' => true, 'mensagem' => 'Atividade salva!']);