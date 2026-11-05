-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 05/11/2026 às 02:12
-- Versão do servidor: 10.4.32-MariaDB
-- Versão do PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `devmobile`
--
CREATE DATABASE IF NOT EXISTS `devmobile` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `devmobile`;

-- --------------------------------------------------------

--
-- Estrutura para tabela `fotos`
--

CREATE TABLE `fotos` (
  `id` int(11) NOT NULL,
  `arquivo` varchar(200) NOT NULL,
  `descricao` varchar(300) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `fotos`
--

INSERT INTO `fotos` (`id`, `arquivo`, `descricao`) VALUES
(1, '1793840266.jpg', ''),
(2, '1793840272.jpg', ''),
(3, '1793840277.jpg', ''),
(4, '1793840478.jpg', 'Teste 1'),
(5, '1793840787.jpg', 'Teste1'),
(6, '1793840890.jpg', 'Teste 1'),
(7, '1793841057.jpg', 'Teste 2');

-- --------------------------------------------------------

--
-- Estrutura para tabela `textos`
--

CREATE TABLE `textos` (
  `id` int(11) NOT NULL,
  `texto` varchar(500) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Despejando dados para a tabela `textos`
--

INSERT INTO `textos` (`id`, `texto`) VALUES
(1, 'teste1'),
(2, 'Bom dia'),
(3, 'Boa tarde'),
(4, 'Teste2'),
(5, 'Jg'),
(6, 'Maurão');

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `fotos`
--
ALTER TABLE `fotos`
  ADD PRIMARY KEY (`id`);

--
-- Índices de tabela `textos`
--
ALTER TABLE `textos`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `fotos`
--
ALTER TABLE `fotos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de tabela `textos`
--
ALTER TABLE `textos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
