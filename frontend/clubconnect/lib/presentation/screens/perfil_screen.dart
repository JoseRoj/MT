import 'dart:io';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/transformation.dart';
import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class Perfil extends ConsumerStatefulWidget {
  const Perfil({super.key});

  @override
  PerfilState createState() => PerfilState();
}

Future<void> logout(BuildContext context) async {
  context.go('/login');
  try {
    /*final response = await http.post(
      Uri.parse('http://${dotenv.env['BASE_URL']}:5000/user/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${auth.token}',
      },
    );
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      //await auth.clearToken();
      Navigator.pushNamed(context, '/login');
    } else {}*/
  } catch (e) {
    throw Exception(e);
  } finally {
    // Oculta el indicador de carga después de la solicitud
  }
}

class PerfilState extends ConsumerState<Perfil> {
  late Future<User?> _futureuser;
  late User? user;
  final picker = ImagePicker();
  File? imagen;
  String base64Image = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureuser = ref
        .read(clubConnectProvider)
        .getUsuario(ref.read(authProvider).id!)
        .then((value) {
      user = value;
      print("User: $user");
      setState(() {});
    });
  }

  Future _pickImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imagen = File(pickedFile.path);

      base64Image = await toBase64C(pickedFile.path);
      user!.imagen = base64Image;
      await ref
          .read(clubConnectProvider)
          .updateImageUser(base64Image, ref.read(authProvider).id!);
      setState(() {});
    }
    Navigator.of(context).pop();
  }

  Future _pickImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imagen = File(pickedFile.path);
      base64Image = await toBase64C(pickedFile.path);

      setState(() {
        user!.imagen = base64Image;
      });
    }
    await ref
        .read(clubConnectProvider)
        .updateImageUser(base64Image, ref.read(authProvider).id!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    print('Perfil');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: FutureBuilder(
        future: _futureuser,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return const Center(
                    child: Text('Ha ocurrido un error al cargar los eventos'));
              } else {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            ClipOval(
                              child: InkWell(
                                child: user!.imagen == ""
                                    ? ClipOval(
                                        child: Container(
                                          color: Colors.black54,
                                          width: 130,
                                          height: 130,
                                          child: const Icon(
                                            Icons.add_a_photo,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : ClipOval(
                                        child: Image.memory(
                                          imagenFromBase64(user!.imagen!),
                                          fit: BoxFit.cover,
                                          width: 130,
                                          height: 130,
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Selecciona una imagen'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading: const Icon(Icons.photo),
                                              title: const Text('Galería'),
                                              onTap: () async {
                                                await _pickImageFromGallery();
                                              },
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.camera),
                                              title: const Text('Cámara'),
                                              onTap: () async {
                                                await _pickImageFromCamera();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.black,
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.add_a_photo,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Text(
                            "${user!.nombre} ${user!.apellido1} ${user!.apellido2}",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          alignment: Alignment.centerLeft,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.only(top: 20),
                          child: Text("Correo : ${user!.email}",
                              style:
                                  AppTheme().getTheme().textTheme.bodyMedium),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await logout(context);
                          },
                          child: const Text("Cerrar Sesión",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                      ],
                    ),
                  ),
                );
              }
            case ConnectionState.none:
              return const Text('none');
            case ConnectionState.active:
              return const Text('active');
            default:
              return const Text('default');
          }
        },
      ),
    );
  }
}
