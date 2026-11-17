import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiServicio {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3001/api',
  );

  static const Duration _tiempoEspera = Duration(seconds: 4);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };

  static Uri _uri(String ruta) => Uri.parse('$baseUrl/$ruta');

  static dynamic _decodificar(http.Response respuesta) {
    if (respuesta.statusCode >= 400) {
      String mensaje = respuesta.body;
      try {
        final cuerpo = jsonDecode(respuesta.body) as Map<String, dynamic>;
        mensaje = cuerpo['error']?.toString() ?? mensaje;
      } catch (_) {}
      throw Exception(mensaje);
    }
    if (respuesta.body.isEmpty) return null;
    return jsonDecode(respuesta.body);
  }

  static Future<Map<String, dynamic>> cargarDatos() async {
    final respuesta = await http.get(_uri('datos'), headers: _headers).timeout(_tiempoEspera);
    return _decodificar(respuesta) as Map<String, dynamic>;
  }

  static Future<dynamic> post(String recurso, Map<String, dynamic> datos) async {
    final respuesta = await http
        .post(_uri(recurso), headers: _headers, body: jsonEncode(datos))
        .timeout(_tiempoEspera);
    return _decodificar(respuesta);
  }

  static Future<dynamic> put(String recurso, String id, Map<String, dynamic> datos) async {
    final respuesta = await http
        .put(_uri('$recurso/${Uri.encodeComponent(id)}'), headers: _headers, body: jsonEncode(datos))
        .timeout(_tiempoEspera);
    return _decodificar(respuesta);
  }

  static Future<dynamic> patch(String recurso, String id, String accion, Map<String, dynamic> datos) async {
    final respuesta = await http
        .patch(_uri('$recurso/${Uri.encodeComponent(id)}/$accion'), headers: _headers, body: jsonEncode(datos))
        .timeout(_tiempoEspera);
    return _decodificar(respuesta);
  }

  static Future<void> delete(String recurso, String id) async {
    final respuesta = await http
        .delete(_uri('$recurso/${Uri.encodeComponent(id)}'), headers: _headers)
        .timeout(_tiempoEspera);
    _decodificar(respuesta);
  }
}
