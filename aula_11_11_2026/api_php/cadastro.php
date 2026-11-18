<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$nome = $_POST['nome'];
$email = $_POST['email'];
$senha = $_POST['senha'];

$comando = $conexao->prepare('SELECT id FROM usuarios WHERE email = ?');
$comando->bind_param('s', $email);
$comando->execute();
$resultado = $comando->get_result();

if ($resultado->num_rows > 0) {
  echo json_encode(['ok' => false, 'mensagem' => 'E-mail já cadastrado']);
  exit;
}

$hash = password_hash($senha, PASSWORD_DEFAULT);

$comando = $conexao->prepare('INSERT INTO usuarios (nome, email, senha) VALUES (?, ?, ?)');
$comando->bind_param('sss', $nome, $email, $hash);
$comando->execute();

echo json_encode(['ok' => true, 'mensagem' => 'Cadastrado com sucesso!']);