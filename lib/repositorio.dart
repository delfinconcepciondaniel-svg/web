import 'package:flutter/foundation.dart';

import 'api_servicio.dart';
import 'models.dart';

class Indicadores {
  Indicadores({
    required this.totalEnvios,
    required this.entregados,
    required this.enRuta,
    required this.pendientes,
    required this.ingresos,
    required this.rutasActivas,
    required this.entregasATiempo,
    required this.promedioPaquetes,
  });

  final int totalEnvios;
  final int entregados;
  final int enRuta;
  final int pendientes;
  final double ingresos;
  final int rutasActivas;
  final double entregasATiempo;
  final double promedioPaquetes;
}

class Repositorio extends ChangeNotifier {
  Repositorio() {
    _inicializar();
  }

  final List<Cliente> clientes = [];
  final List<Empleado> empleados = [];
  final List<Envio> envios = [];
  final List<Paquete> paquetes = [];
  final List<Repartidor> repartidores = [];
  final List<Ruta> rutas = [];
  final List<Pago> pagos = [];

  Rol rolActual = Rol.administrador;
  bool conectado = false;
  String? errorConexion;

  void _inicializar() {
    clientes.addAll([
      Cliente(
        id: 'C001',
        nombre: 'María Elena Ramírez',
        documento: '87654321',
        telefono: '987 654 321',
        correo: 'maria.ramirez@correo.com',
        direccion: 'Av. Lima 245, Miraflores',
      ),
      Cliente(
        id: 'C002',
        nombre: 'Carlos Alberto Flores',
        documento: '10234567',
        telefono: '944 120 883',
        correo: 'carlos.flores@correo.com',
        direccion: 'Jr. Ayacucho 1180, Breña',
      ),
      Cliente(
        id: 'C003',
        nombre: 'Lucía Mendoza Vargas',
        documento: '45871239',
        telefono: '912 556 740',
        correo: 'lucia.mendoza@correo.com',
        direccion: 'Calle Real 329, San Isidro',
      ),
      Cliente(
        id: 'C004',
        nombre: 'Jorge Luis Castro',
        documento: '20145678',
        telefono: '998 340 112',
        correo: 'jorge.castro@correo.com',
        direccion: 'Av. Brasil 1750, Jesús María',
      ),
      Cliente(
        id: 'C005',
        nombre: 'Ana Patricia Rojas',
        documento: '76543210',
        telefono: '935 781 204',
        correo: 'ana.rojas@correo.com',
        direccion: 'Psje. Los Olivos 45, Surco',
      ),
    ]);

    empleados.addAll([
      Empleado(
        id: 'E001',
        nombre: 'Rosa Villanueva',
        cargo: 'Atención al Cliente',
        correo: 'rosa.villanueva@rutaexpress.com',
        telefono: '911 222 333',
      ),
      Empleado(
        id: 'E002',
        nombre: 'Miguel Ángel Soto',
        cargo: 'Operaciones',
        correo: 'miguel.soto@rutaexpress.com',
        telefono: '922 333 444',
      ),
      Empleado(
        id: 'E003',
        nombre: 'Fernanda Ríos',
        cargo: 'Clasificación',
        correo: 'fernanda.rios@rutaexpress.com',
        telefono: '933 444 555',
      ),
    ]);

    repartidores.addAll([
      Repartidor(id: 'RP01', nombre: 'Diego Fernando Paredes', telefono: '944 555 666', disponible: true),
      Repartidor(id: 'RP02', nombre: 'Andrea Salazar', telefono: '955 666 777', disponible: true),
      Repartidor(id: 'RP03', nombre: 'Pedro Nolasco', telefono: '966 777 888', disponible: false),
    ]);

    final now = DateTime.now();
    rutas.addAll([
      Ruta(
        id: 'R01',
        zona: 'Miraflores - San Isidro',
        fecha: now,
        descripcion: 'Reparto zona norte',
        repartidorId: 'RP01',
      ),
      Ruta(
        id: 'R02',
        zona: 'Breña - Jesús María',
        fecha: now,
        descripcion: 'Reparto zona céntrica',
        repartidorId: 'RP02',
      ),
      Ruta(id: 'R03', zona: 'Surco - Barranco', fecha: now, descripcion: 'Reparto zona sur'),
    ]);

    envios.addAll([
      Envio(
        id: 'ENV-1001',
        clienteId: 'C001',
        origen: 'Miraflores',
        destino: 'San Isidro',
        fecha: now.subtract(const Duration(days: 1)),
        tarifa: 25,
        estado: EstadoEnvio.enRuta,
        empleadoId: 'E001',
        rutaId: 'R01',
        repartidorId: 'RP01',
      ),
      Envio(
        id: 'ENV-1002',
        clienteId: 'C002',
        origen: 'Breña',
        destino: 'Jesús María',
        fecha: now.subtract(const Duration(days: 2)),
        tarifa: 18.5,
        estado: EstadoEnvio.entregado,
        empleadoId: 'E002',
        rutaId: 'R02',
        repartidorId: 'RP02',
        confirmacion: 'Recibido por el cliente',
      ),
      Envio(
        id: 'ENV-1003',
        clienteId: 'C003',
        origen: 'San Isidro',
        destino: 'Surco',
        fecha: now.subtract(const Duration(hours: 8)),
        tarifa: 32,
        estado: EstadoEnvio.clasificado,
        empleadoId: 'E003',
      ),
      Envio(
        id: 'ENV-1004',
        clienteId: 'C004',
        origen: 'Jesús María',
        destino: 'Miraflores',
        fecha: now.subtract(const Duration(hours: 4)),
        tarifa: 15,
        estado: EstadoEnvio.registrado,
        empleadoId: 'E001',
      ),
      Envio(
        id: 'ENV-1005',
        clienteId: 'C005',
        origen: 'Surco',
        destino: 'Barranco',
        fecha: now.subtract(const Duration(days: 3)),
        tarifa: 21,
        estado: EstadoEnvio.entregado,
        empleadoId: 'E002',
        rutaId: 'R03',
        repartidorId: 'RP01',
        confirmacion: 'Recibido por receptor autorizado',
      ),
      Envio(
        id: 'ENV-1006',
        clienteId: 'C001',
        origen: 'Miraflores',
        destino: 'Breña',
        fecha: now.subtract(const Duration(days: 5)),
        tarifa: 28.5,
        estado: EstadoEnvio.cancelado,
        empleadoId: 'E003',
      ),
      Envio(
        id: 'ENV-1007',
        clienteId: 'C003',
        origen: 'San Isidro',
        destino: 'Jesús María',
        fecha: now.subtract(const Duration(hours: 2)),
        tarifa: 19,
        estado: EstadoEnvio.registrado,
        empleadoId: 'E001',
      ),
    ]);

    paquetes.addAll([
      Paquete(id: 'P001', envioId: 'ENV-1001', descripcion: 'Caja de documentos', peso: 2.5, dimensiones: '30 x 20 x 15 cm', valorDeclarado: 120),
      Paquete(id: 'P002', envioId: 'ENV-1001', descripcion: 'Libros', peso: 3.2, dimensiones: '25 x 20 x 18 cm', valorDeclarado: 80),
      Paquete(id: 'P003', envioId: 'ENV-1002', descripcion: 'Ropa', peso: 1.8, dimensiones: '40 x 30 x 20 cm', valorDeclarado: 150),
      Paquete(id: 'P004', envioId: 'ENV-1003', descripcion: 'Repuestos', peso: 4.1, dimensiones: '35 x 25 x 20 cm', valorDeclarado: 320),
      Paquete(id: 'P005', envioId: 'ENV-1004', descripcion: 'Sobres administrativos', peso: 0.6, dimensiones: '35 x 25 x 3 cm', valorDeclarado: 30),
      Paquete(id: 'P006', envioId: 'ENV-1005', descripcion: 'Electrónica', peso: 2.9, dimensiones: '30 x 22 x 12 cm', valorDeclarado: 450),
      Paquete(id: 'P007', envioId: 'ENV-1006', descripcion: 'Caja de vidrio', peso: 5.5, dimensiones: '40 x 40 x 30 cm', valorDeclarado: 200),
      Paquete(id: 'P008', envioId: 'ENV-1007', descripcion: 'Muestras comerciales', peso: 1.2, dimensiones: '20 x 15 x 10 cm', valorDeclarado: 95),
    ]);

    pagos.addAll([
      Pago(id: 'PG001', envioId: 'ENV-1001', importe: 25, metodo: 'Yape', estado: EstadoPago.pagado, fecha: now.subtract(const Duration(days: 1))),
      Pago(id: 'PG002', envioId: 'ENV-1002', importe: 18.5, metodo: 'Efectivo', estado: EstadoPago.pagado, fecha: now.subtract(const Duration(days: 2))),
      Pago(id: 'PG003', envioId: 'ENV-1003', importe: 32, metodo: 'Transferencia', estado: EstadoPago.pendiente, fecha: now.subtract(const Duration(hours: 8))),
      Pago(id: 'PG004', envioId: 'ENV-1004', importe: 15, metodo: 'Tarjeta', estado: EstadoPago.pendiente, fecha: now.subtract(const Duration(hours: 4))),
      Pago(id: 'PG005', envioId: 'ENV-1005', importe: 21, metodo: 'Yape', estado: EstadoPago.pagado, fecha: now.subtract(const Duration(days: 3))),
      Pago(id: 'PG006', envioId: 'ENV-1006', importe: 28.5, metodo: 'Efectivo', estado: EstadoPago.anulado, fecha: now.subtract(const Duration(days: 5))),
    ]);
  }

  void setRol(Rol rol) {
    rolActual = rol;
    notifyListeners();
  }

  Future<void> cargarDesdeApi() async {
    try {
      final datos = await ApiServicio.cargarDatos();
      clientes
        ..clear()
        ..addAll((datos['clientes'] as List? ?? []).map((e) => clienteDeJson(e as Map<String, dynamic>)));
      empleados
        ..clear()
        ..addAll((datos['empleados'] as List? ?? []).map((e) => empleadoDeJson(e as Map<String, dynamic>)));
      repartidores
        ..clear()
        ..addAll((datos['repartidores'] as List? ?? []).map((e) => repartidorDeJson(e as Map<String, dynamic>)));
      rutas
        ..clear()
        ..addAll((datos['rutas'] as List? ?? []).map((e) => rutaDeJson(e as Map<String, dynamic>)));
      envios
        ..clear()
        ..addAll((datos['envios'] as List? ?? []).map((e) => envioDeJson(e as Map<String, dynamic>)));
      paquetes
        ..clear()
        ..addAll((datos['paquetes'] as List? ?? []).map((e) => paqueteDeJson(e as Map<String, dynamic>)));
      pagos
        ..clear()
        ..addAll((datos['pagos'] as List? ?? []).map((e) => pagoDeJson(e as Map<String, dynamic>)));
      conectado = true;
      errorConexion = null;
    } catch (e) {
      conectado = false;
      errorConexion = e.toString();
    }
    notifyListeners();
  }

  void _sync(Future<void> Function() accion) {
    accion().then((_) {
      if (!conectado) {
        conectado = true;
        errorConexion = null;
        notifyListeners();
      }
    }).catchError((Object e) {
      conectado = false;
      errorConexion = e.toString();
      notifyListeners();
    });
  }

  Cliente clienteDeJson(Map<String, dynamic> j) => Cliente(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        documento: j['documento'] as String,
        telefono: j['telefono'] as String,
        correo: j['correo'] as String,
        direccion: j['direccion'] as String,
      );

  Empleado empleadoDeJson(Map<String, dynamic> j) => Empleado(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        cargo: j['cargo'] as String,
        correo: j['correo'] as String,
        telefono: j['telefono'] as String,
      );

  Repartidor repartidorDeJson(Map<String, dynamic> j) => Repartidor(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        telefono: j['telefono'] as String,
        disponible: j['disponible'] == 1 || j['disponible'] == true,
      );

  Ruta rutaDeJson(Map<String, dynamic> j) => Ruta(
        id: j['id'] as String,
        zona: j['zona'] as String,
        fecha: DateTime.parse(j['fecha'] as String),
        descripcion: j['descripcion'] as String,
        repartidorId: j['repartidorId'] as String?,
      );

  Envio envioDeJson(Map<String, dynamic> j) => Envio(
        id: j['id'] as String,
        clienteId: j['clienteId'] as String,
        origen: j['origen'] as String,
        destino: j['destino'] as String,
        fecha: DateTime.parse(j['fecha'] as String),
        tarifa: (j['tarifa'] as num).toDouble(),
        estado: EstadoEnvio.values.firstWhere((e) => e.label == j['estado']),
        empleadoId: j['empleadoId'] as String,
        rutaId: j['rutaId'] as String?,
        repartidorId: j['repartidorId'] as String?,
        confirmacion: j['confirmacion'] as String?,
      );

  Paquete paqueteDeJson(Map<String, dynamic> j) => Paquete(
        id: j['id'] as String,
        envioId: j['envioId'] as String,
        descripcion: j['descripcion'] as String,
        peso: (j['peso'] as num).toDouble(),
        dimensiones: j['dimensiones'] as String,
        valorDeclarado: (j['valorDeclarado'] as num).toDouble(),
      );

  Pago pagoDeJson(Map<String, dynamic> j) => Pago(
        id: j['id'] as String,
        envioId: j['envioId'] as String,
        importe: (j['importe'] as num).toDouble(),
        metodo: j['metodo'] as String,
        estado: EstadoPago.values.firstWhere((e) => e.label == j['estado']),
        fecha: DateTime.parse(j['fecha'] as String),
      );

  Cliente? cliente(String id) {
    for (final c in clientes) {
      if (c.id == id) return c;
    }
    return null;
  }

  Empleado? empleado(String id) {
    for (final e in empleados) {
      if (e.id == id) return e;
    }
    return null;
  }

  Repartidor? repartidor(String? id) {
    for (final r in repartidores) {
      if (r.id == id) return r;
    }
    return null;
  }

  Ruta? ruta(String? id) {
    for (final r in rutas) {
      if (r.id == id) return r;
    }
    return null;
  }

  List<Paquete> paquetesDe(String envioId) => paquetes.where((p) => p.envioId == envioId).toList();

  Pago? pagoDe(String envioId) {
    for (final p in pagos) {
      if (p.envioId == envioId) return p;
    }
    return null;
  }

  String nombreCliente(String id) => cliente(id)?.nombre ?? id;

  String nombreRepartidor(String? id) => repartidor(id)?.nombre ?? 'Sin asignar';

  Indicadores get indicadores {
    final entregados = envios.where((e) => e.estado == EstadoEnvio.entregado).length;
    final enRuta = envios.where((e) => e.estado == EstadoEnvio.enRuta).length;
    final cancelados = envios.where((e) => e.estado == EstadoEnvio.cancelado).length;
    final ingresos = pagos.where((p) => p.estado == EstadoPago.pagado).fold<double>(0, (sum, p) => sum + p.importe);
    final activas = rutas.where((r) => r.repartidorId != null).length;
    final finalizados = entregados + cancelados;
    return Indicadores(
      totalEnvios: envios.length,
      entregados: entregados,
      enRuta: enRuta,
      pendientes: envios.length - finalizados,
      ingresos: ingresos,
      rutasActivas: activas,
      entregasATiempo: finalizados == 0 ? 0 : (entregados / finalizados) * 100,
      promedioPaquetes: envios.isEmpty ? 0 : paquetes.length / envios.length,
    );
  }

  String _siguienteId(String prefijo, List<String> existentes) {
    var n = 1;
    while (existentes.contains('$prefijo${n.toString().padLeft(3, '0')}')) {
      n++;
    }
    return '$prefijo${n.toString().padLeft(3, '0')}';
  }

  void agregarCliente(Cliente cliente) {
    clientes.add(cliente);
    notifyListeners();
    _sync(() => ApiServicio.post('clientes', {
          'id': cliente.id,
          'nombre': cliente.nombre,
          'documento': cliente.documento,
          'telefono': cliente.telefono,
          'correo': cliente.correo,
          'direccion': cliente.direccion,
        }));
  }

  void actualizarCliente(Cliente cliente, {required String nombre, required String documento, required String telefono, required String correo, required String direccion}) {
    cliente
      ..nombre = nombre
      ..documento = documento
      ..telefono = telefono
      ..correo = correo
      ..direccion = direccion;
    notifyListeners();
    _sync(() => ApiServicio.put('clientes', cliente.id, {
          'nombre': nombre,
          'documento': documento,
          'telefono': telefono,
          'correo': correo,
          'direccion': direccion,
        }));
  }

  String nuevoClienteId() => _siguienteId('C', clientes.map((c) => c.id).toList());

  void agregarEmpleado(Empleado empleado) {
    empleados.add(empleado);
    notifyListeners();
    _sync(() => ApiServicio.post('empleados', {
          'id': empleado.id,
          'nombre': empleado.nombre,
          'cargo': empleado.cargo,
          'correo': empleado.correo,
          'telefono': empleado.telefono,
        }));
  }

  void actualizarEmpleado(Empleado empleado, {required String nombre, required String cargo, required String correo, required String telefono}) {
    empleado
      ..nombre = nombre
      ..cargo = cargo
      ..correo = correo
      ..telefono = telefono;
    notifyListeners();
    _sync(() => ApiServicio.put('empleados', empleado.id, {
          'nombre': nombre,
          'cargo': cargo,
          'correo': correo,
          'telefono': telefono,
        }));
  }

  String nuevoEmpleadoId() => _siguienteId('E', empleados.map((e) => e.id).toList());

  void agregarRepartidor(Repartidor repartidor) {
    repartidores.add(repartidor);
    notifyListeners();
    _sync(() => ApiServicio.post('repartidores', {
          'id': repartidor.id,
          'nombre': repartidor.nombre,
          'telefono': repartidor.telefono,
          'disponible': repartidor.disponible,
        }));
  }

  void actualizarRepartidor(Repartidor repartidor, {required String nombre, required String telefono, required bool disponible}) {
    repartidor
      ..nombre = nombre
      ..telefono = telefono
      ..disponible = disponible;
    notifyListeners();
    _sync(() => ApiServicio.put('repartidores', repartidor.id, {
          'nombre': nombre,
          'telefono': telefono,
          'disponible': disponible,
        }));
  }

  String nuevoRepartidorId() => _siguienteId('RP', repartidores.map((r) => r.id).toList());

  void agregarRuta(Ruta ruta) {
    rutas.add(ruta);
    notifyListeners();
    _sync(() => ApiServicio.post('rutas', {
          'id': ruta.id,
          'zona': ruta.zona,
          'fecha': ruta.fecha.toIso8601String().substring(0, 10),
          'descripcion': ruta.descripcion,
          'repartidorId': ruta.repartidorId,
        }));
  }

  void actualizarRuta(Ruta ruta, {required String zona, required DateTime fecha, required String descripcion, String? repartidorId}) {
    ruta
      ..zona = zona
      ..fecha = fecha
      ..descripcion = descripcion
      ..repartidorId = repartidorId;
    notifyListeners();
    _sync(() => ApiServicio.put('rutas', ruta.id, {
          'zona': zona,
          'fecha': fecha.toIso8601String().substring(0, 10),
          'descripcion': descripcion,
          'repartidorId': repartidorId,
        }));
  }

  String nuevoRutaId() => _siguienteId('R', rutas.map((r) => r.id).toList());

  void agregarEnvio(Envio envio, Paquete paquete) {
    envios.add(envio);
    paquetes.add(paquete);
    notifyListeners();
    _sync(() => ApiServicio.post('envios', {
          'id': envio.id,
          'clienteId': envio.clienteId,
          'origen': envio.origen,
          'destino': envio.destino,
          'fecha': envio.fecha.toIso8601String(),
          'tarifa': envio.tarifa,
          'empleadoId': envio.empleadoId,
          'paquete': {
            'id': paquete.id,
            'descripcion': paquete.descripcion,
            'peso': paquete.peso,
            'dimensiones': paquete.dimensiones,
            'valorDeclarado': paquete.valorDeclarado,
          },
        }));
  }

  void actualizarEnvio(Envio envio, {required String clienteId, required String origen, required String destino, required DateTime fecha, required double tarifa, required String empleadoId}) {
    envio
      ..clienteId = clienteId
      ..origen = origen
      ..destino = destino
      ..fecha = fecha
      ..tarifa = tarifa
      ..empleadoId = empleadoId;
    notifyListeners();
    _sync(() => ApiServicio.put('envios', envio.id, {
          'clienteId': clienteId,
          'origen': origen,
          'destino': destino,
          'fecha': fecha.toIso8601String(),
          'tarifa': tarifa,
          'empleadoId': empleadoId,
        }));
  }

  String nuevoEnvioId() {
    var n = 1001;
    while (envios.any((e) => e.id == 'ENV-$n')) {
      n++;
    }
    return 'ENV-$n';
  }

  String nuevoPaqueteId() => _siguienteId('P', paquetes.map((p) => p.id).toList());

  void agregarPaquete(Paquete paquete) {
    paquetes.add(paquete);
    notifyListeners();
    _sync(() => ApiServicio.post('paquetes', {
          'id': paquete.id,
          'envioId': paquete.envioId,
          'descripcion': paquete.descripcion,
          'peso': paquete.peso,
          'dimensiones': paquete.dimensiones,
          'valorDeclarado': paquete.valorDeclarado,
        }));
  }

  void actualizarPaquete(Paquete paquete, {required String descripcion, required double peso, required String dimensiones, required double valorDeclarado}) {
    paquete
      ..descripcion = descripcion
      ..peso = peso
      ..dimensiones = dimensiones
      ..valorDeclarado = valorDeclarado;
    notifyListeners();
    _sync(() => ApiServicio.put('paquetes', paquete.id, {
          'descripcion': descripcion,
          'peso': peso,
          'dimensiones': dimensiones,
          'valorDeclarado': valorDeclarado,
        }));
  }

  void agregarPago(Pago pago) {
    pagos.add(pago);
    notifyListeners();
    _sync(() => ApiServicio.post('pagos', {
          'id': pago.id,
          'envioId': pago.envioId,
          'importe': pago.importe,
          'metodo': pago.metodo,
          'estado': pago.estado.label,
          'fecha': pago.fecha.toIso8601String().substring(0, 10),
        }));
  }

  void actualizarPago(Pago pago, {required double importe, required String metodo, required EstadoPago estado}) {
    pago
      ..importe = importe
      ..metodo = metodo
      ..estado = estado;
    notifyListeners();
    _sync(() => ApiServicio.put('pagos', pago.id, {
          'envioId': pago.envioId,
          'importe': importe,
          'metodo': metodo,
          'estado': estado.label,
          'fecha': pago.fecha.toIso8601String().substring(0, 10),
        }));
  }

  String nuevoPagoId() => _siguienteId('PG', pagos.map((p) => p.id).toList());

  String? cambiarEstado(Envio envio, EstadoEnvio estado) {
    if (estado == EstadoEnvio.enRuta && (envio.rutaId == null || envio.repartidorId == null)) {
      return 'RN07: asigne una ruta y un repartidor antes de pasar a En ruta.';
    }
    envio.estado = estado;
    if (estado == EstadoEnvio.entregado) {
      envio.confirmacion ??= 'Entrega confirmada';
    }
    notifyListeners();
    _sync(() => ApiServicio.patch('envios', envio.id, 'estado', {
          'estado': estado.label,
          'confirmacion': envio.confirmacion,
        }));
    return null;
  }

  void asignarRutaRepartidor(Envio envio, {required String rutaId, required String repartidorId}) {
    envio.rutaId = rutaId;
    envio.repartidorId = repartidorId;
    notifyListeners();
    _sync(() => ApiServicio.patch('envios', envio.id, 'asignacion', {
          'rutaId': rutaId,
          'repartidorId': repartidorId,
        }));
  }
}
