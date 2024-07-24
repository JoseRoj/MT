import 'dart:async';

import 'package:clubconnect/config/theme/app_theme.dart';
import 'package:clubconnect/helpers/toast.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/usuario_provider.dart';
import 'package:clubconnect/presentation/widget/formInput.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const name = 'login-screen';
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends ConsumerState<LoginScreen> {
  FocusNode _focusNode = FocusNode();
  final controllerCorreo = TextEditingController();
  final controllerContrasena = TextEditingController();
  final styleTextTheme = AppTheme().getTheme().textTheme;

  Data? token;
  bool isLoading = false; // Flag to indicate login button state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 116, 157, 75),
        body: Container(
          width: MediaQuery.of(context).size.width,
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "ClubConnect",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 45,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      offset: Offset(0, 1),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 0, bottom: 20),
                child: Text(
                  "Localiza y Gestiona tus clubes",
                  textAlign: TextAlign.center,
                  style: styleTextTheme.bodyMedium,
                ),
              ),
              Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      width: 300,
                      child: formInput(
                          label: "Correo",
                          controller: controllerCorreo,
                          validator: (value) {}),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      width: 300,
                      child: formInput(
                          label: "Contraseña",
                          controller: controllerContrasena,
                          validator: (value) {}),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿No tienes cuenta?"),
                  TextButton(
                    onPressed: () {
                      context.push('/register');
                    },
                    child: const Text('Registrarse',
                        style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
              isLoading
                  ? CircularProgressIndicator()
                  : FilledButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(2),
                        backgroundColor: MaterialStateProperty.all(
                            Color.fromARGB(255, 114, 255, 74)),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 10)),
                      ),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          isLoading = true;
                        });
                        final responde = await ref
                            .read(authProvider.notifier)
                            .saveToken(controllerCorreo.text,
                                controllerContrasena.text);

                        if (responde != null) {
                          //* Save user data in the provider
                          final id = ref.read(authProvider).id;
                          final tokenfb =
                              await ref.read(authProvider).tokenDispositivo;

                          await ref
                              .read(clubConnectProvider)
                              .updateToken(id!, "tokenfb");
                          print("tokenfb: $tokenfb");
                          context.go('/home/1');
                          //ref.watch(UsuarioProvider(responde.id as int));
                        } else {
                          customToast(
                              'Error al iniciar sesión', context, "isError");
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: const Text('Iniciar Sesión',
                          style: TextStyle(color: Colors.black, fontSize: 18)),
                    ),
            ],
          ),
        ));
  }
}
