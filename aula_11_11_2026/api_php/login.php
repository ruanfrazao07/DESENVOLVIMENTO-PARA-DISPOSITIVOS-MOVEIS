<?php
$conexao = new mysqli('localhost', 'root', '', 'devmobile');

$email = $_POST['email'];
$senha = $_POST['senha'];

$comando = $conexao->prepare('SELECT id, nome, senha FROM usuarios WHERE email = ?');
$comando->bind_param('s', $email);
$comando->execute();
$resultado = $comando->get_result();
$usuario = $resultado->fetch_assoc();

if ($usuario && password_verify($senha, $usuario['senha'])) {
  echo json_encode([
    'ok' => true,
    'id' => (int) $usuario['id'],
    'nome' => $usuario['nome'],
  ]);
} else {
  echo json_encode(['ok' => false, 'mensagem' => 'E-mail ou senha incorretos']);
}