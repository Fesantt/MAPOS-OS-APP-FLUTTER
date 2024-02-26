import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mapos_app/pages/clients/clients_screen.dart';
import '../main.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Mostrar o diálogo de confirmação ao pressionar o botão de voltar no dispositivo
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirmação"),
              content: Text("Deseja Fechar o APP"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Fecha o diálogo
                  },
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    // Remova o token e outras informações de autenticação
                    removeTokenAndNavigateToLogin(context);
                  },
                  child: Text("Sair"),
                ),
              ],
            );
          },
        );

        // Retorna false para indicar que o pop não é tratado aqui
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                // Exibir o mesmo diálogo ao pressionar o botão de logout
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Confirmação"),
                      content: Text("Deseja realmente sair?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Fecha o diálogo
                          },
                          child: Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () {
                            // Remova o token e outras informações de autenticação
                            removeTokenAndNavigateToLogin(context);
                          },
                          child: Text("Sair"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Center(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else {
                  String ciKey = snapshot.data?['ci_key'];
                  String permissoes = snapshot.data?['permissoes'];
                  bool temPermissaoCliente = permissoes.contains('vCliente');
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Valor de ci_key: $ciKey',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Permissões: $permissoes',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      SizedBox(height: 20),
                      Visibility(
                        visible: temPermissaoCliente,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ClientesScreen()),
                            );
                          },
                          child: Text('Acesso a Clientes'),
                        ),
                      ),
                    ],
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ciKey = prefs.getString('token') ?? '';
    String permissoes = prefs.getString('permissoes') ?? '';
    return {'ci_key': ciKey, 'permissoes': permissoes};
  }
}

void removeTokenAndNavigateToLogin(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Remova o token e outras informações de autenticação
  await prefs.remove('token');
  await prefs.remove('permissoes');

  // Navegue de volta para a tela de login
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()), // Substitua LoginScreen pela tela de login apropriada
        (Route<dynamic> route) => false,
  );
}