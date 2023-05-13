import 'package:flutter/material.dart';

import '../model/ponto_eletronico.dart';

class DetalhesPEPage extends StatefulWidget {
  final PontoEletronico pe;

  const DetalhesPEPage({Key? key, required this.pe}) : super(key: key);

  @override
  _DetalhesPEPageState createState() => _DetalhesPEPageState();
}

class _DetalhesPEPageState extends State<DetalhesPEPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes'),
      ),
      body: _criarBody(),
    );
  }

  Widget _criarBody() => Padding(
    padding: EdgeInsets.all(15),
    child: Column(
      children: [
        Row(
          children: [
            Campo(descricao: 'Código: '),
            Valor(valor: '${widget.pe.id}'),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Latitude: '),
            Valor(valor: widget.pe.latitude!),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Longitude: '),
            Valor(valor: widget.pe.longitude!),
          ],
        ),
        Row(
          children: [
            Campo(descricao: 'Data/Hora: '),
            Valor(valor: widget.pe.data!),
          ],
        )
      ],
    ),
  );
}

class Campo extends StatelessWidget {
  final String descricao;

  const Campo({Key? key, required this.descricao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Text(
        descricao,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class Valor extends StatelessWidget {
  final String valor;

  const Valor({Key? key, required this.valor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 4,
      child: Text(valor),
    );
  }
}
