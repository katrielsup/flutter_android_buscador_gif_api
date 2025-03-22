import 'dart:convert';

import 'package:buscador_gif/UI/gif_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:share_plus/share_plus.dart';
import 'package:transparent_image/transparent_image.dart';

class home_page extends StatefulWidget {
  const home_page({super.key});

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  String? _search = null;

  int _offset = 0;

  Future<Map> _getGiphy() async {
    Http.Response response;

    Uri url;

    if (_search == null || _search!.isEmpty) {
      url = Uri.https("api.giphy.com", "/v1/gifs/trending", {
        "api_key": "0aSrXtCe0fQmtjo27ySy2LvUhCnYKVYo",
        "limit": "30",
        "offset": "35",
        "rating": "g",
        "bundle": "messaging_non_clips",
      });
    } else {
      url = Uri.https("api.giphy.com", "/v1/gifs/search", {
        "api_key": "0aSrXtCe0fQmtjo27ySy2LvUhCnYKVYo",
        "q": _search!,
        "limit": "30",
        "offset": "$_offset",
        "rating": "g",
        "lang": "en",
        "bundle": "messaging_non_clips",
      });
    }

    response = await Http.get(url);

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
          "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif",
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: "Pesquisa o seu GIF !",
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGiphy(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );
                  case ConnectionState.active:
                    throw UnimplementedError();
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot<Map> snapshort) {
    return // Aqui estamos criando uma GridView dinâmica, ou seja, uma grade que pode ser construída sob demanda.
    GridView.builder(
      // Adiciona um espaçamento interno (padding) de 10 em todos os lados da grade.
      padding: EdgeInsets.all(10),

      // Define como será a estrutura da grade (quantas colunas, espaçamento entre os itens, etc).
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        // Define que a grade terá 2 colunas fixas.
        crossAxisCount: 2,

        // Espaçamento horizontal entre as colunas (espaço lateral entre os itens).
        crossAxisSpacing: 10,

        // Espaçamento vertical entre as linhas (espaço superior/inferior entre os itens).
        mainAxisSpacing: 10,
      ),

      // Quantidade total de itens a serem exibidos na grade (neste caso, 4 itens).
      itemCount: _getCount(snapshort.data?["data"]),
      // Função responsável por construir cada item da grade, recebe o contexto e o índice do item.
      itemBuilder: (context, index) {
        // Cada item será um GestureDetector, ou seja, um widget que detecta toques (taps).
        if (_search == null || index < (snapshort.data?["data"]?.length ?? 0)) {
          return GestureDetector(
            onLongPress: () {
              Share.share(
                snapshort.data?["data"][index]["images"]["fixed_height"]["url"],
              );
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return GifPage(snapshort?.data?["data"][index] ?? null);
                  },
                ),
              );
            },
            child:
                snapshort.data != null
                    ? Image.network(
                      snapshort
                          .data?["data"][index]["images"]["fixed_height"]["url"],
                      height: 300.0,
                      fit: BoxFit.cover,
                    )
                    : Container(
                      height: 300.0,
                      color: Colors.grey[300],
                      child: Center(child: Text("Imagem não disponível")),
                    ),
          );
        } else {
          if (index < snapshort?.data?["data"].length) {
            // Item normal de GIF
            return GestureDetector(
              onLongPress: () {
                Share.share(
                  snapshort
                      ?.data?["data"][index]["images"]["fixed_height"]["url"],
                );
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return GifPage(snapshort?.data?["data"][index]);
                    },
                  ),
                );
              },
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image:
                    snapshort
                        ?.data?["data"][index]["images"]["fixed_height"]["url"],
                height: 300,
                fit: BoxFit.cover,
              ),
            );
          } else {
            // Item "Carregar mais dados"
            return GestureDetector(
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 70, color: Colors.white),
                    Text(
                      "Carregar mais dados !",
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          }
        }
      },
    );
  }

  int _getCount(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }
}
