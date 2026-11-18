<?php

$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$uid = (int) $_GET['usuario_id'];
$busca = $conexao->real_escape_string($_GET['busca'] ?? '');

$resultado = $conexao->query(
  "SELECT posts.id, posts.usuario_id, posts.texto, posts.foto, usuarios.nome,
    (SELECT COUNT(*) FROM curtidas WHERE curtidas.post_id = posts.id) AS curtidas,
    (SELECT COUNT(*) FROM curtidas WHERE curtidas.post_id = posts.id AND curtidas.usuario_id = $uid) AS curtiu,
    (SELECT COUNT(*) FROM comentarios WHERE comentarios.post_id = posts.id) AS comentarios,
    (SELECT status FROM amizades
      WHERE (solicitante_id = $uid AND destinatario_id = posts.usuario_id)
         OR (solicitante_id = posts.usuario_id AND destinatario_id = $uid) LIMIT 1) AS status,
    (SELECT solicitante_id FROM amizades
      WHERE (solicitante_id = $uid AND destinatario_id = posts.usuario_id)
         OR (solicitante_id = posts.usuario_id AND destinatario_id = $uid) LIMIT 1) AS solicitante
   FROM posts
   JOIN usuarios ON usuarios.id = posts.usuario_id
   WHERE posts.texto LIKE '%$busca%'
   ORDER BY posts.id DESC"
);

$lista = [];
while ($linha = $resultado->fetch_assoc()) {
  if ($linha['usuario_id'] == $uid) {
    $amizade = 'proprio';
  } else if ($linha['status'] == 'aprovada') {
    $amizade = 'amigos';
  } else if ($linha['status'] == 'pendente') {
    $amizade = ($linha['solicitante'] == $uid) ? 'enviada' : 'recebida';
  } else {
    $amizade = 'nenhuma';
  }

  $lista[] = [
    'id' => (int) $linha['id'],
    'usuario_id' => (int) $linha['usuario_id'],
    'nome' => $linha['nome'],
    'texto' => $linha['texto'],
    'foto' => $linha['foto'],
    'curtidas' => (int) $linha['curtidas'],
    'curtiu' => $linha['curtiu'] > 0,
    'comentarios' => (int) $linha['comentarios'],
    'amizade' => $amizade,
  ];
}

echo json_encode($lista);