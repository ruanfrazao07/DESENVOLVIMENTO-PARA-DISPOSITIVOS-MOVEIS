<?php
// salvar_foto.php

$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$descricao = $_POST['descricao'];

// nome único para não sobrescrever fotos
$nome = time() . '.jpg';

move_uploaded_file($_FILES['foto']['tmp_name'], __DIR__ . '/' . $nome);

$comando = $conexao->prepare('INSERT INTO fotos (arquivo, descricao) VALUES (?, ?)');
$comando->bind_param('ss', $nome, $descricao);
$comando->execute();

echo 'ok';