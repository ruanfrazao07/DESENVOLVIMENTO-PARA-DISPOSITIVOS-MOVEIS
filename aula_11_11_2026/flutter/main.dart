import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String servidor = 'http://10.0.2.2/api';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool logado = prefs.getInt('id') != null;

  runApp(Janela(logado: logado));
}

class Janela extends StatelessWidget {
  final bool logado;

  const Janela({super.key, required this.logado});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: logado ? const Feed() : const Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();

  void entrar() async {
    try {
      final resposta = await http.post(
        Uri.parse('$servidor/login.php'),
        body: {'email': email.text, 'senha': senha.text},
      );

      final dados = jsonDecode(resposta.body);

      if (!mounted) return;

      if (dados['ok'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('id', dados['id']);
        await prefs.setString('nome', dados['nome']);
        await prefs.setString('email', email.text);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Feed()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(dados['mensagem'])),
        );
      }
    } catch (e) {
      print('ERRO: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: senha,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            ElevatedButton(
              onPressed: entrar,
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Cadastro()),
                );
              },
              child: const Text('Não tem conta? Cadastre-se'),
            ),
          ],
        ),
      ),
    );
  }
}

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController nome = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();

  void cadastrar() async {
    if (nome.text == '' || email.text == '' || senha.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    try {
      final resposta = await http.post(
        Uri.parse('$servidor/cadastro.php'),
        body: {'nome': nome.text, 'email': email.text, 'senha': senha.text},
      );

      final dados = jsonDecode(resposta.body);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dados['mensagem'])),
      );

      if (dados['ok'] == true) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('ERRO: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nome,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            TextField(
              controller: senha,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Senha'),
            ),
            ElevatedButton(
              onPressed: cadastrar,
              child: const Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class Feed extends StatefulWidget {
  final String busca;

  const Feed({super.key, this.busca = ''});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  List posts = [];
  int meuId = 0;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      meuId = prefs.getInt('id') ?? 0;

      final resposta = await http.get(
        Uri.parse(
          '$servidor/listar_posts.php?usuario_id=$meuId&busca=${Uri.encodeQueryComponent(widget.busca)}',
        ),
      );

      setState(() {
        posts = jsonDecode(resposta.body);
      });
    } catch (e) {
      print('ERRO: $e');
    }
  }

  void sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  void novoPost() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NovoPost()),
    );
    carregar();
  }

  void abrirSolicitacoes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Solicitacoes()),
    );
    carregar();
  }

  void abrirBusca() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Busca()),
    );
  }

  void curtir(int postId) async {
    try {
      await http.post(
        Uri.parse('$servidor/curtir.php'),
        body: {'post_id': postId.toString(), 'usuario_id': meuId.toString()},
      );
      carregar();
    } catch (e) {
      print('ERRO: $e');
    }
  }

  void pedirAmizade(int amigoId) async {
    try {
      final resposta = await http.post(
        Uri.parse('$servidor/solicitar_amizade.php'),
        body: {
          'usuario_id': meuId.toString(),
          'amigo_id': amigoId.toString(),
        },
      );

      final dados = jsonDecode(resposta.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dados['mensagem'])),
      );
      carregar();
    } catch (e) {
      print('ERRO: $e');
    }
  }

  void abrirComentarios(Map post) async {
    final bool pode =
        post['amizade'] == 'amigos' || post['amizade'] == 'proprio';

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Comentarios(postId: post['id'], podeComentar: pode),
      ),
    );
    carregar();
  }

  Widget botaoAmizade(Map post) {
    switch (post['amizade']) {
      case 'nenhuma':
        return TextButton(
          onPressed: () {
            pedirAmizade(post['usuario_id']);
          },
          child: const Text('Adicionar amigo'),
        );
      case 'enviada':
        return const Text('Solicitação enviada');
      case 'recebida':
        return const Text('Quer ser seu amigo');
      case 'amigos':
        return const Text('Amigos');
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool buscando = widget.busca != '';

    return Scaffold(
      appBar: AppBar(
        title: Text(buscando ? 'Busca: ${widget.busca}' : 'Feed'),
        actions: buscando
            ? []
            : [
                IconButton(
                  onPressed: abrirBusca,
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: abrirSolicitacoes,
                  icon: const Icon(Icons.person_add),
                ),
                TextButton(onPressed: sair, child: const Text('Sair')),
              ],
      ),
      floatingActionButton: buscando
          ? null
          : FloatingActionButton(
              onPressed: novoPost,
              child: const Icon(Icons.add),
            ),
      body: posts.isEmpty
          ? Center(
              child: Text(
                buscando
                    ? 'Nenhuma postagem encontrada'
                    : 'Nenhuma postagem ainda',
              ),
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, indice) {
                final post = posts[indice];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post['nome'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(post['texto'],
                            style: const TextStyle(fontSize: 16)),
                        if (post['foto'] != '')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Image.network(
                              '$servidor/uploads/${post['foto']}',
                              height: 250,
                            ),
                          ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                curtir(post['id']);
                              },
                              icon: Icon(
                                post['curtiu']
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                            ),
                            Text('${post['curtidas']}'),
                            IconButton(
                              onPressed: () {
                                abrirComentarios(post);
                              },
                              icon: const Icon(Icons.comment_outlined),
                            ),
                            Text('${post['comentarios']}'),
                            const SizedBox(width: 12),
                            botaoAmizade(post),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class NovoPost extends StatefulWidget {
  const NovoPost({super.key});

  @override
  State<NovoPost> createState() => _NovoPostState();
}

class _NovoPostState extends State<NovoPost> {
  final ImagePicker picker = ImagePicker();
  TextEditingController texto = TextEditingController();
  XFile? foto;

  void tirarFoto() async {
    final XFile? imagem = await picker.pickImage(source: ImageSource.camera);

    if (imagem != null) {
      setState(() {
        foto = imagem;
      });
    }
  }

  void publicar() async {
    if (texto.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva um texto')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? id = prefs.getInt('id');

      final pedido = http.MultipartRequest(
        'POST',
        Uri.parse('$servidor/postar.php'),
      );
      pedido.fields['usuario_id'] = id.toString();
      pedido.fields['texto'] = texto.text;

      if (foto != null) {
        pedido.files.add(await http.MultipartFile.fromPath('foto', foto!.path));
      }

      final resposta = await pedido.send();
      final corpo = await resposta.stream.bytesToString();
      print('POST: ${resposta.statusCode} $corpo');

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      print('ERRO: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova postagem')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: texto,
              maxLines: 4,
              decoration:
                  const InputDecoration(labelText: 'O que está pensando?'),
            ),
            if (foto != null) Image.file(File(foto!.path), height: 250),
            ElevatedButton(
              onPressed: tirarFoto,
              child: const Text('Tirar foto (opcional)'),
            ),
            ElevatedButton(
              onPressed: publicar,
              child: const Text('Publicar'),
            ),
          ],
        ),
      ),
    );
  }
}

class Comentarios extends StatefulWidget {
  final int postId;
  final bool podeComentar;

  const Comentarios(
      {super.key, required this.postId, required this.podeComentar});

  @override
  State<Comentarios> createState() => _ComentariosState();
}

class _ComentariosState extends State<Comentarios> {
  List comentarios = [];
  TextEditingController texto = TextEditingController();

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    try {
      final resposta = await http.get(
        Uri.parse('$servidor/listar_comentarios.php?post_id=${widget.postId}'),
      );

      setState(() {
        comentarios = jsonDecode(resposta.body);
      });
    } catch (e) {
      print('ERRO: $e');
    }
  }

  void enviar() async {
    if (texto.text == '') return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final int? id = prefs.getInt('id');

      final resposta = await http.post(
        Uri.parse('$servidor/comentar.php'),
        body: {
          'post_id': widget.postId.toString(),
          'usuario_id': id.toString(),
          'texto': texto.text,
        },
      );

      final dados = jsonDecode(resposta.body);

      if (!mounted) return;

      if (dados['ok'] == true) {
        texto.clear();
        carregar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(dados['mensagem'])),
        );
      }
    } catch (e) {
      print('ERRO: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comentários')),
      body: Column(
        children: [
          Expanded(
            child: comentarios.isEmpty
                ? const Center(child: Text('Nenhum comentário'))
                : ListView.builder(
                    itemCount: comentarios.length,
                    itemBuilder: (context, indice) {
                      final comentario = comentarios[indice];

                      return ListTile(
                        title: Text(comentario['nome']),
                        subtitle: Text(comentario['texto']),
                      );
                    },
                  ),
          ),
          if (widget.podeComentar)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: texto,
                      decoration: const InputDecoration(labelText: 'Comentar'),
                    ),
                  ),
                  IconButton(onPressed: enviar, icon: const Icon(Icons.send)),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Só amigos do autor podem comentar'),
            ),
        ],
      ),
    );
  }
}

class Solicitacoes extends StatefulWidget {
  const Solicitacoes({super.key});

  @override
  State<Solicitacoes> createState() => _SolicitacoesState();
}

class _SolicitacoesState extends State<Solicitacoes> {
  List pedidos = [];
  int meuId = 0;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  void carregar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      meuId = prefs.getInt('id') ?? 0;

      final resposta = await http.get(
        Uri.parse('$servidor/listar_solicitacoes.php?usuario_id=$meuId'),
      );

      setState(() {
        pedidos = jsonDecode(resposta.body);
      });
    } catch (e) {
      print('ERRO: $e');
    }
  }

  void responder(String id, bool aceitar) async {
    try {
      await http.post(
        Uri.parse('$servidor/responder_amizade.php'),
        body: {
          'id': id,
          'usuario_id': meuId.toString(),
          'aceitar': aceitar ? '1' : '0',
        },
      );
      carregar();
    } catch (e) {
      print('ERRO: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitações de amizade')),
      body: pedidos.isEmpty
          ? const Center(child: Text('Nenhuma solicitação'))
          : ListView.builder(
              itemCount: pedidos.length,
              itemBuilder: (context, indice) {
                final pedido = pedidos[indice];

                return ListTile(
                  title: Text(pedido['nome']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          responder(pedido['id'].toString(), true);
                        },
                        icon: const Icon(Icons.check, color: Colors.green),
                      ),
                      IconButton(
                        onPressed: () {
                          responder(pedido['id'].toString(), false);
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class Busca extends StatefulWidget {
  const Busca({super.key});

  @override
  State<Busca> createState() => _BuscaState();
}

class _BuscaState extends State<Busca> {
  TextEditingController campo = TextEditingController();
  List pessoas = [];
  int meuId = 0;
  bool buscou = false;

  void buscarPessoas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      meuId = prefs.getInt('id') ?? 0;

      final resposta = await http.get(
        Uri.parse(
          '$servidor/buscar_usuarios.php?usuario_id=$meuId&nome=${Uri.encodeQueryComponent(campo.text)}',
        ),
      );

      setState(() {
        pessoas = jsonDecode(resposta.body);
        buscou = true;
      });
    } catch (e) {
      print('ERRO: $e');
    }
  }

  void buscarPostagens() {
    if (campo.text == '') return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Feed(busca: campo.text)),
    );
  }

  void pedirAmizade(int amigoId) async {
    try {
      final resposta = await http.post(
        Uri.parse('$servidor/solicitar_amizade.php'),
        body: {
          'usuario_id': meuId.toString(),
          'amigo_id': amigoId.toString(),
        },
      );

      final dados = jsonDecode(resposta.body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(dados['mensagem'])),
      );
      buscarPessoas();
    } catch (e) {
      print('ERRO: $e');
    }
  }

  Widget situacao(Map pessoa) {
    switch (pessoa['amizade']) {
      case 'nenhuma':
        return TextButton(
          onPressed: () {
            pedirAmizade(pessoa['id']);
          },
          child: const Text('Adicionar amigo'),
        );
      case 'enviada':
        return const Text('Solicitação enviada');
      case 'recebida':
        return const Text('Quer ser seu amigo');
      default:
        return const Text('Amigos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Busca')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: campo,
              decoration: const InputDecoration(labelText: 'Nome ou palavras'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: buscarPessoas,
                  child: const Text('Buscar pessoas'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: buscarPostagens,
                  child: const Text('Buscar postagens'),
                ),
              ],
            ),
            Expanded(
              child: pessoas.isEmpty
                  ? Center(
                      child: Text(buscou ? 'Nenhuma pessoa encontrada' : ''),
                    )
                  : ListView.builder(
                      itemCount: pessoas.length,
                      itemBuilder: (context, indice) {
                        final pessoa = pessoas[indice];

                        return ListTile(
                          title: Text(pessoa['nome']),
                          trailing: situacao(pessoa),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
