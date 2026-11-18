<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$post_id = $_POST['post_id'];
$usuario_id = $_POST['usuario_id'];
$texto = $_POST['texto'];

$comando = $conexao->prepare('SELECT usuario_id FROM posts WHERE id = ?');
$comando->bind_param('i', $post_id);
$comando->execute();
$post = $comando->get_result()->fetch_assoc();

if (!$post) {
  echo json_encode(['ok' => false, 'mensagem' => 'Postagem não encontrada']);
  exit;
}

$autor_id = $post['usuario_id'];

if ($autor_id != $usuario_id) {
  $comando = $conexao->prepare(
    "SELECT id FROM amizades
     WHERE status = 'aprovada'
       AND ((solicitante_id = ? AND destinatario_id = ?)
         OR (solicitante_id = ? AND destinatario_id = ?))"
  );
  $comando->bind_param('iiii', $usuario_id, $autor_id, $autor_id, $usuario_id);
  $comando->execute();

  if ($comando->get_result()->num_rows == 0) {
    echo json_encode(['ok' => false, 'mensagem' => 'Só amigos podem comentar']);
    exit;
  }
}

$comando = $conexao->prepare('INSERT INTO comentarios (post_id, usuario_id, texto) VALUES (?, ?, ?)');
$comando->bind_param('iis', $post_id, $usuario_id, $texto);
$comando->execute();

echo json_encode(['ok' => true]);