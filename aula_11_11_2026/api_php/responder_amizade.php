<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$id = $_POST['id'];
$usuario_id = $_POST['usuario_id'];
$aceitar = $_POST['aceitar'];

if ($aceitar == '1') {
  $comando = $conexao->prepare(
    "UPDATE amizades SET status = 'aprovada' WHERE id = ? AND destinatario_id = ?"
  );
} else {
  $comando = $conexao->prepare(
    'DELETE FROM amizades WHERE id = ? AND destinatario_id = ?'
  );
}
$comando->bind_param('ii', $id, $usuario_id);
$comando->execute();

echo json_encode(['ok' => true]);