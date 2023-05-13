import 'package:cartaoponto/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const PontoEletronico());
}


class PontoEletronico extends StatelessWidget {
  const PontoEletronico({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartão Ponto',

      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: HomePage(),
    );
  }
}