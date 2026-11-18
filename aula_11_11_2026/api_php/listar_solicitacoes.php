<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$usuario_id = $_GET['usuario_id'];

$comando = $conexao->prepare(
  "SELECT amizades.id, usuarios.nome
   FROM amizades
   JOIN usuarios ON usuarios.id = amizades.solicitante_id
   WHERE amizades.destinatario_id = ? AND amizades.status = 'pendente'"
);
$comando->bind_param('i', $usuario_id);
$comando->execute();
$resultado = $comando->get_result();

$lista = [];
while ($linha = $resultado->fetch_assoc()) {
  $lista[] = $linha;
}

echo json_encode($lista);