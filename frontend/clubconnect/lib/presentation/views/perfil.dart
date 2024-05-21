import 'package:clubconnect/insfrastructure/models/user.dart';
import 'package:clubconnect/presentation/providers/auth_provider.dart';
import 'package:clubconnect/presentation/providers/usuario_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Perfil extends ConsumerStatefulWidget {
  const Perfil({super.key});

  @override
  PerfilState createState() => PerfilState();
}

class PerfilState extends ConsumerState<Perfil> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(UsuarioProvider(ref.read(authProvider).id!));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Center(
        child: userAsync.when(
          data: (user) => Column(
            children: [
              Text(user.nombre),
              Text(user.email),
            ],
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ),
    );
  }
}
