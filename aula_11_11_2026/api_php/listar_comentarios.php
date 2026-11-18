<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$post_id = $_GET['post_id'];

$comando = $conexao->prepare(
  'SELECT comentarios.texto, usuarios.nome
   FROM comentarios
   JOIN usuarios ON usuarios.id = comentarios.usuario_id
   WHERE comentarios.post_id = ?
   ORDER BY comentarios.id'
);
$comando->bind_param('i', $post_id);
$comando->execute();
$resultado = $comando->get_result();

$lista = [];
while ($linha = $resultado->fetch_assoc()) {
  $lista[] = $linha;
}

echo json_encode($lista);