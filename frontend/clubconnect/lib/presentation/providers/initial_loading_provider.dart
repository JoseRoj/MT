import 'package:clubconnect/presentation/providers.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:clubconnect/presentation/providers/tipos_provider.dart';
import 'package:clubconnect/presentation/providers/usuario_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final initialLoadingProvider = Provider<bool>((ref) {
  //final step1 = ref.watch(clubesRegisterProvider).isEmpty;
  final step2 = ref.watch(deportesProvider).isEmpty;
  final step3 = ref.watch(categoriasProvider).isEmpty;
  final step4 = ref.watch(tiposProvider).isEmpty;
  if (step2 || step3 || step4) return true;

  return false; // terminamos de cargar
});
