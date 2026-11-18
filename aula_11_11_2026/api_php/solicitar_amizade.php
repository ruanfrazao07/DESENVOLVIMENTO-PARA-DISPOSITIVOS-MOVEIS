<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$usuario_id = $_POST['usuario_id'];
$amigo_id = $_POST['amigo_id'];

if ($usuario_id == $amigo_id) {
  echo json_encode(['ok' => false, 'mensagem' => 'Você não pode adicionar você mesmo']);
  exit;
}

$comando = $conexao->prepare(
  'SELECT id FROM amizades
   WHERE (solicitante_id = ? AND destinatario_id = ?)
      OR (solicitante_id = ? AND destinatario_id = ?)'
);
$comando->bind_param('iiii', $usuario_id, $amigo_id, $amigo_id, $usuario_id);
$comando->execute();

if ($comando->get_result()->num_rows > 0) {
  echo json_encode(['ok' => false, 'mensagem' => 'Já existe uma solicitação']);
  exit;
}

$comando = $conexao->prepare('INSERT INTO amizades (solicitante_id, destinatario_id) VALUES (?, ?)');
$comando->bind_param('ii', $usuario_id, $amigo_id);
$comando->execute();

echo json_encode(['ok' => true, 'mensagem' => 'Solicitação enviada!']);