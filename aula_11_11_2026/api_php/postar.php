<?php

$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$usuario_id = $_POST['usuario_id'];
$texto = $_POST['texto'];

$foto = '';
if (isset($_FILES['foto'])) {
  $foto = uniqid() . '.jpg';
  move_uploaded_file($_FILES['foto']['tmp_name'], __DIR__ . '/uploads/' . $foto);
}

$comando = $conexao->prepare('INSERT INTO posts (usuario_id, texto, foto) VALUES (?, ?, ?)');
$comando->bind_param('iss', $usuario_id, $texto, $foto);
$comando->execute();

echo json_encode(['ok' => true]);