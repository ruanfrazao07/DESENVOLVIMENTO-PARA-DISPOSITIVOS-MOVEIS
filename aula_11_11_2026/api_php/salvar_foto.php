<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$descricao = $_POST['descricao'];
$nome = time() . '.jpg';

move_uploaded_file($_FILES['foto']['tmp_name'], __DIR__ . '/uploads/' . $nome);

$comando = $conexao->prepare('INSERT INTO fotos (arquivo, descricao) VALUES (?, ?)');
$comando->bind_param('ss', $nome, $descricao);
$comando->execute();

echo 'ok';