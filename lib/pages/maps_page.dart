

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_launcher/maps_launcher.dart';

class HomePage extends StatefulWidget{
  HomePage({Key? key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
Position? _localizacaoAtual;
final _controller = TextEditingController();

String get _textoLocalizacao => _localizacaoAtual == null ? '' :
    'Latitude: ${_localizacaoAtual!.latitude}  |  Longetude: ${_localizacaoAtual!.longitude}';

  Widget build (BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('Testando Mapas')),
      body: _criarBody(),
    );
  }

  Widget _criarBody() => ListView(
    children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
        child: ElevatedButton(
          child: Text('Obter Localização Atual'),
          onPressed: _obterLocalizacaoAtual,
        ),
      ),
      if(_localizacaoAtual != null)
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                  child: Text(_textoLocalizacao),
              ),
              ElevatedButton(
                  onPressed: _abrirCoordenadasNoMapaExterno,
                  child: Icon(Icons.map)
              ),
            ],
          ),
        ),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Endereço ou ponto de referencia',
            suffixIcon: IconButton(
              icon: Icon(Icons.map),
              tooltip: 'Abrir no mapa',
              onPressed: _abrirNoMapaExterno,
            )
          ),
        ),
      )
    ],
  );

  void _obterLocalizacaoAtual() async {
    bool servicoHabilitado = await _servicoHabilitado();
    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _permissoesPermitidas();
    if(!permissoesPermitidas){
      return;
    }
    _localizacaoAtual = await Geolocator.getCurrentPosition();
    setState(() {

    });
  }

  void _abrirNoMapaExterno(){
    if(_controller.text.trim().isEmpty){
      return;
    }
    MapsLauncher.launchQuery(_controller.text);
  }

  void _abrirCoordenadasNoMapaExterno(){
    if(_localizacaoAtual == null){
      return;
    }
    MapsLauncher.launchCoordinates(_localizacaoAtual!.latitude, _localizacaoAtual!.longitude);
  }

  Future<bool> _servicoHabilitado() async {
    bool servicoHabilotado = await Geolocator.isLocationServiceEnabled();
    if(!servicoHabilotado){
      await _mostrarMensagemDialog('Para utilizar esse recurso, você deverá habilitar o serviço de localização '
          'no dispositivo');
      Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  Future<bool> _permissoesPermitidas() async {
    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        _mostrarMensagem('Não será possível utilizar o recusro por falta de permissão');
        return false;
      }
    }
    if(permissao == LocationPermission.deniedForever){
      await _mostrarMensagemDialog(
          'Para utilizar esse recurso, você deverá acessar as configurações '
              'do appe permitir a utilização do serviço de localização');
      Geolocator.openAppSettings();
      return false;
    }
    return true;

  }
  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _mostrarMensagemDialog(String mensagem) async{
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Atenção'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}