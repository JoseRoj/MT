import 'dart:convert';
import 'package:clubconnect/insfrastructure/repositories/club_repository_impl.dart';
import 'package:clubconnect/presentation/providers/club_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Login {
  Data data;

  Login({
    required this.data,
  });

  factory Login.fromRawJson(String str) => Login.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Login.fromJson(Map<String, dynamic> json) => Login(
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
      };
}

class Data {
  usuario user;
  String token;

  Data({
    required this.user,
    required this.token,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: usuario.fromJson(json["user"]),
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "token": token,
      };
}

class usuario {
  String id;
  String nombre;
  String email;

  usuario({
    required this.id,
    required this.nombre,
    required this.email,
  });

  factory usuario.fromRawJson(String str) => usuario.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory usuario.fromJson(Map<String, dynamic> json) => usuario(
        id: json["id"],
        nombre: json["nombre"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "email": email,
      };
}

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider extends ChangeNotifier {
  AuthProvider() : super();
  String? _token;
  String? _tokenDispositivo;

  int? _id;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? get token => _token;
  String? get tokenDispositivo => _tokenDispositivo;

  int? get id => _id;

  Future<usuario?> saveToken(String email, String contrasena) async {
    Login res;
    try {
      final dio = Dio(BaseOptions(headers: {}));
      final response = await dio.post('${dotenv.env["API_URL"]}/login',
          data: jsonEncode(
              <String, String>{"email": email, "contrasena": contrasena}));
      if (response.statusCode == 200) {
        res = Login.fromJson(response.data);
        Data? resToken = res.data;
        _token = resToken.token;
        _id = int.parse(resToken.user.id);
        await _secureStorage.write(
          key: 'token',
          value: resToken.token,
        );

        notifyListeners();
        return resToken.user;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> loadToken() async {
    _token = await _secureStorage.read(
      key: 'token',
    );
    notifyListeners();
  }

  Future<void> clearToken() async {
    _token = null;
    await _secureStorage.delete(key: 'token');
    notifyListeners();
  }

  Future<void> saveTokenDispositivo(String tokenDispositivo) async {
    _tokenDispositivo = tokenDispositivo;
    await _secureStorage.write(
      key: 'tokenDispositivo',
      value: tokenDispositivo,
    );
    notifyListeners();
  }

  Future<void> loadTokenDispositivo() async {
    _token = await _secureStorage.read(
      key: 'tokenDispositivo',
    );
    notifyListeners();
  }
}
