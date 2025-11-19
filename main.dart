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
    return const MaterialApp(home: Primeira());
  }
}

class Primeira extends StatefulWidget {
  const Primeira({super.key});

  @override
  State<Primeira> createState() => _PrimeiraState();
}

class _PrimeiraState extends State<Primeira> {
  TextEditingController controlador = TextEditingController();
  String cidade = '';
  double? temperatura;
  double? umidade;
  double? vento;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clima por cidade')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controlador,
              decoration: InputDecoration(
                labelText: 'Digite o nome da cidade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                cidade = controlador.text;
                await buscarClima(cidade);
              },
              child: const Text('Buscar Clima'),
            ),
            const SizedBox(height: 20),
            if (temperatura != null)
              Text('Temperatura: ${temperatura?.toStringAsFixed(1)} °C'),
            if (umidade != null)
              Text('Umidade: ${umidade?.toStringAsFixed(0)} %'),
            if (vento != null)
              Text('Velocidade do vento: ${vento?.toStringAsFixed(1)} m/s'),
          ],
        ),
      ),
    );
  }

  Future<void> buscarClima(String nomeCidade) async {
    try {
      // 1️⃣ Buscar latitude e longitude
      final geoUrl =
          'https://geocoding-api.open-meteo.com/v1/search?name=$nomeCidade&count=1';
      final geoResponse = await http.get(Uri.parse(geoUrl));
      final geoData = json.decode(geoResponse.body);

      if (geoData['results'] == null || geoData['results'].isEmpty) return;

      double latitude = geoData['results'][0]['latitude'];
      double longitude = geoData['results'][0]['longitude'];

      // 2️⃣ Buscar clima
      final climaUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true';
      final climaResponse = await http.get(Uri.parse(climaUrl));
      final climaData = json.decode(climaResponse.body);

      setState(() {
        temperatura = climaData['current_weather']['temperature'];
        vento = climaData['current_weather']['windspeed'];
        umidade = climaData['current_weather']['humidity'] ??
            0; // Open-Meteo nem sempre fornece
      });
    } catch (e) {
      print('Erro ao buscar clima: $e');
    }
  }
}
