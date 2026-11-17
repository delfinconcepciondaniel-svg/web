import 'package:flutter/material.dart';

enum EstadoEnvio { registrado, clasificado, enRuta, entregado, cancelado }

enum EstadoPago { pendiente, pagado, anulado }

enum Rol { administrador, atencion, repartidor, gerente }

extension EstadoEnvioX on EstadoEnvio {
  String get label => switch (this) {
        EstadoEnvio.registrado => 'Registrado',
        EstadoEnvio.clasificado => 'Clasificado',
        EstadoEnvio.enRuta => 'En ruta',
        EstadoEnvio.entregado => 'Entregado',
        EstadoEnvio.cancelado => 'Cancelado',
      };

  Color get color => switch (this) {
        EstadoEnvio.registrado => const Color(0xFF64748B),
        EstadoEnvio.clasificado => const Color(0xFF2563EB),
        EstadoEnvio.enRuta => const Color(0xFFD97706),
        EstadoEnvio.entregado => const Color(0xFF059669),
        EstadoEnvio.cancelado => const Color(0xFFDC2626),
      };

  IconData get icon => switch (this) {
        EstadoEnvio.registrado => Icons.assignment_outlined,
        EstadoEnvio.clasificado => Icons.inventory_2_outlined,
        EstadoEnvio.enRuta => Icons.local_shipping_outlined,
        EstadoEnvio.entregado => Icons.check_circle_outline,
        EstadoEnvio.cancelado => Icons.cancel_outlined,
      };

  List<EstadoEnvio> get siguientes => switch (this) {
        EstadoEnvio.registrado => [EstadoEnvio.clasificado, EstadoEnvio.cancelado],
        EstadoEnvio.clasificado => [EstadoEnvio.enRuta, EstadoEnvio.registrado],
        EstadoEnvio.enRuta => [EstadoEnvio.entregado],
        EstadoEnvio.entregado => [],
        EstadoEnvio.cancelado => [],
      };
}

extension EstadoPagoX on EstadoPago {
  String get label => switch (this) {
        EstadoPago.pendiente => 'Pendiente',
        EstadoPago.pagado => 'Pagado',
        EstadoPago.anulado => 'Anulado',
      };

  Color get color => switch (this) {
        EstadoPago.pendiente => const Color(0xFFD97706),
        EstadoPago.pagado => const Color(0xFF059669),
        EstadoPago.anulado => const Color(0xFFDC2626),
      };
}

extension RolX on Rol {
  String get label => switch (this) {
        Rol.administrador => 'Administrador',
        Rol.atencion => 'Atención al Cliente',
        Rol.repartidor => 'Repartidor',
        Rol.gerente => 'Gerente',
      };
}

class Cliente {
  Cliente({
    required this.id,
    required this.nombre,
    required this.documento,
    required this.telefono,
    required this.correo,
    required this.direccion,
  });

  final String id;
  String nombre;
  String documento;
  String telefono;
  String correo;
  String direccion;
}

class Empleado {
  Empleado({
    required this.id,
    required this.nombre,
    required this.cargo,
    required this.correo,
    required this.telefono,
  });

  final String id;
  String nombre;
  String cargo;
  String correo;
  String telefono;
}

class Paquete {
  Paquete({
    required this.id,
    required this.envioId,
    required this.descripcion,
    required this.peso,
    required this.dimensiones,
    required this.valorDeclarado,
  });

  final String id;
  String envioId;
  String descripcion;
  double peso;
  String dimensiones;
  double valorDeclarado;
}

class Repartidor {
  Repartidor({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.disponible,
  });

  final String id;
  String nombre;
  String telefono;
  bool disponible;
}

class Ruta {
  Ruta({
    required this.id,
    required this.zona,
    required this.fecha,
    required this.descripcion,
    this.repartidorId,
  });

  final String id;
  String zona;
  DateTime fecha;
  String descripcion;
  String? repartidorId;
}

class Pago {
  Pago({
    required this.id,
    required this.envioId,
    required this.importe,
    required this.metodo,
    required this.estado,
    required this.fecha,
  });

  final String id;
  String envioId;
  double importe;
  String metodo;
  EstadoPago estado;
  DateTime fecha;
}

class Envio {
  Envio({
    required this.id,
    required this.clienteId,
    required this.origen,
    required this.destino,
    required this.fecha,
    required this.tarifa,
    required this.estado,
    required this.empleadoId,
    this.rutaId,
    this.repartidorId,
    this.confirmacion,
  });

  final String id;
  String clienteId;
  String origen;
  String destino;
  DateTime fecha;
  double tarifa;
  EstadoEnvio estado;
  String empleadoId;
  String? rutaId;
  String? repartidorId;
  String? confirmacion;
}
