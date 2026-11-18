<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$post_id = $_POST['post_id'];
$usuario_id = $_POST['usuario_id'];

$comando = $conexao->prepare('SELECT id FROM curtidas WHERE post_id = ? AND usuario_id = ?');
$comando->bind_param('ii', $post_id, $usuario_id);
$comando->execute();
$ja_curtiu = $comando->get_result()->num_rows > 0;

if ($ja_curtiu) {
  $comando = $conexao->prepare('DELETE FROM curtidas WHERE post_id = ? AND usuario_id = ?');
} else {
  $comando = $conexao->prepare('INSERT INTO curtidas (post_id, usuario_id) VALUES (?, ?)');
}
$comando->bind_param('ii', $post_id, $usuario_id);
$comando->execute();

echo json_encode(['ok' => true]);