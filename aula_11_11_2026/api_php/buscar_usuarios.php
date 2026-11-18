<?php

$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$uid = (int) $_GET['usuario_id'];
$nome = '%' . $_GET['nome'] . '%';

$comando = $conexao->prepare(
  "SELECT usuarios.id, usuarios.nome,
    (SELECT status FROM amizades
      WHERE (solicitante_id = ? AND destinatario_id = usuarios.id)
         OR (solicitante_id = usuarios.id AND destinatario_id = ?) LIMIT 1) AS status,
    (SELECT solicitante_id FROM amizades
      WHERE (solicitante_id = ? AND destinatario_id = usuarios.id)
         OR (solicitante_id = usuarios.id AND destinatario_id = ?) LIMIT 1) AS solicitante
   FROM usuarios
   WHERE usuarios.nome LIKE ? AND usuarios.id != ?
   ORDER BY usuarios.nome"
);
$comando->bind_param('iiiisi', $uid, $uid, $uid, $uid, $nome, $uid);
$comando->execute();
$resultado = $comando->get_result();

$lista = [];
while ($linha = $resultado->fetch_assoc()) {
  if ($linha['status'] == 'aprovada') {
    $amizade = 'amigos';
  } else if ($linha['status'] == 'pendente') {
    $amizade = ($linha['solicitante'] == $uid) ? 'enviada' : 'recebida';
  } else {
    $amizade = 'nenhuma';
  }

  $lista[] = [
    'id' => (int) $linha['id'],
    'nome' => $linha['nome'],
    'amizade' => $amizade,
  ];
}

echo json_encode($lista);