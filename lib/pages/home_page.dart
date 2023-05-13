import 'dart:async';
import 'package:cartaoponto/model/ponto_eletronico.dart';
import 'package:cartaoponto/pages/detalhes_pe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import '../dao/registro_dao.dart';

class HomePage extends StatefulWidget{
  HomePage({Key? key}) : super(key: key);


  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final _registros = <PontoEletronico>[];
  final _dateFormat = DateFormat('dd/MM/yyyy - H:m:s');
  final _dao = RegistroDao();
  var _carregando = false;
  static const acaoVisualizar = 'visualizar';
  static const acaoMapa = 'mapa';
  String formattedTime = DateFormat('Hms').format(DateTime.now());
  String hour = DateFormat('a').format(DateTime.now());
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) => _update());
    _atualizarLista();
  }

  void _update() {
    setState(() {
      formattedTime = DateFormat('Hms').format(DateTime.now());
      hour = DateFormat('a').format(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: _criarAppBar(),
      body: _criarBody(),
    );
  }
  AppBar _criarAppBar(){
    return AppBar(
      centerTitle: true, // Adicionando essa propriedade para centralizar o título
      title: Text("Registro de Ponto"),
    );
  }


  Widget _criarBody() => Padding(
    padding: EdgeInsets.all(2),
    child: Column(
      children: [
        Text(formattedTime,
          style: TextStyle(
            fontSize: 30
          ),
        ),
        ElevatedButton(
          onPressed: _obterLocalizacaoAtual,
          child: Text('Registrar'),
        ),
        Divider(),
        Expanded(
            child: ListView.separated(
                shrinkWrap: true,
                itemCount: _registros.length,
                itemBuilder: (BuildContext context, int index){
                  final registro = _registros[index];
                  return PopupMenuButton<String>(
                    child: ListTile(
                      leading: Text('${registro.id}'),
                      title: Text('${registro.data}'),
                      subtitle: Text('Lat: ${registro.latitude} '
                          'Long: ${registro.longitude}'),
                    ),
                    itemBuilder: (_) => _criarItensMenuPopup(),
                    onSelected: (String valorSelecionado) {
                      if (valorSelecionado == acaoVisualizar) {
                        _abrirPaginaDetalhes(registro);
                      }else if (valorSelecionado == acaoMapa) {
                        _abrirCoordenadasMapaExterno(
                            registro.latitude!,
                            registro.longitude!
                        );
                      }
                    },
                  );
                },
                separatorBuilder: (_, __) => Divider(),
            )
        )
      ],
    ),
  );

  List<PopupMenuEntry<String>> _criarItensMenuPopup() => [
    PopupMenuItem(
      value: acaoVisualizar,
      child: Row(
        children: const [
          Icon(Icons.info, color: Colors.blue),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Detalhes'),
          ),
        ],
      ),
    ),
    PopupMenuItem(
      value: acaoMapa,
      child: Row(
        children: const [
          Icon(Icons.map, color: Colors.green),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text('Abrir no Mapa'),
          ),
        ],
      ),
    ),
  ];

  void _abrirPaginaDetalhes(PontoEletronico pe) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetalhesPEPage(
            pe: pe,
          ),
        ));
  }

  void _abrirCoordenadasMapaExterno(String lat, String long){
    if(lat == 'null' || long == 'null'){
      return;
    }
    MapsLauncher.launchCoordinates(
        double.parse(lat),
        double.parse(long)
    );
  }

  void _atualizarLista() async {
    setState(() {
      _carregando = true;
    });
    final reg = await _dao.listar();
    setState(() {
      _carregando = false;
      _registros.clear();
      if (reg.isNotEmpty) {
        _registros.addAll(reg);
      }
    });
  }

  void _obterLocalizacaoAtual() async{
    bool servicoHabilitado = await _servicoHabilitado();

    if(!servicoHabilitado){
      return;
    }
    bool permissoesPermitidas = await _verificaPermissoes();
    if(!permissoesPermitidas){
      return;
    }
    Position posicao = await Geolocator.getCurrentPosition();
    PontoEletronico registro = PontoEletronico(id: 0);
    registro.data = _dateFormat.format(DateTime.now());
    if(posicao == null){
      _dao.salvar(registro);
    }else{
      registro.latitude = '${posicao.latitude}';
      registro.longitude = '${posicao.longitude}';
      _dao.salvar(registro);
    }
    setState(() {
      _atualizarLista();
    });
  }

  Future<bool> _servicoHabilitado() async{
    bool servicoHabilitado = await Geolocator.isLocationServiceEnabled();
    if(!servicoHabilitado){
      await _mostrarMensagemDialog(
          'Para utilizar este recurso, é necessário acessar as configurações '
              'do dispositivo e permitir a utilização do serviço de localização.'
      );
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  Future<bool> _verificaPermissoes() async{
    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
      if(permissao == LocationPermission.denied){
        _mostrarMensagem('Não foi possível utilizar o recurso por falta de permissão');
        return false;
      }
    }
    if(permissao == LocationPermission.deniedForever){
      await _mostrarMensagemDialog(
          'Para utilizar este recurso, é necessário acessar as configurações '
              'do dispositivo e permitir a utilização do serviço de localização.'
      );
      Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  void _mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(mensagem)
        )
    );
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
                child: Text('OK')
            )
          ],
        )
    );
  }

}