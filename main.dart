import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Dicionario());
  }
}

class Dicionario extends StatefulWidget {
  const Dicionario({super.key});

  @override
  State<Dicionario> createState() => _DicionarioState();
}

class _DicionarioState extends State<Dicionario> {
  TextEditingController controlador = TextEditingController();
  String? definicao;
  bool carregando = false;
  String? erro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dicionário de Inglês')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controlador,
              decoration: const InputDecoration(
                labelText: 'Digite uma palavra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: buscarDefinicao,
              child: const Text('Buscar Definição'),
            ),
            const SizedBox(height: 20),
            if (carregando) const CircularProgressIndicator(),
            if (definicao != null)
              Text(
                'Definição: $definicao',
                style: const TextStyle(fontSize: 18),
              ),
            if (erro != null)
              Text(
                'Erro: $erro',
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> buscarDefinicao() async {
    setState(() {
      carregando = true;
      definicao = null;
      erro = null;
    });

    String palavra = controlador.text.trim();
    if (palavra.isEmpty) {
      setState(() {
        erro = 'Digite uma palavra!';
        carregando = false;
      });
      return;
    }

    final url = 'https://api.dictionaryapi.dev/api/v2/entries/en/$palavra';

    try {
      final resposta = await http.get(Uri.parse(url));

      if (resposta.statusCode == 200) {
        final dados = json.decode(resposta.body);

        // Pegando a primeira definição
        final primeiraDefinicao =
            dados[0]['meanings'][0]['definitions'][0]['definition'];

        setState(() {
          definicao = primeiraDefinicao;
          carregando = false;
        });
      } else {
        setState(() {
          erro = 'Palavra não encontrada!';
          carregando = false;
        });
      }
    } catch (e) {
      setState(() {
        erro = 'Erro ao buscar a definição';
        carregando = false;
      });
    }
  }
}
