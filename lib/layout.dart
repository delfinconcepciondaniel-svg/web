import 'package:flutter/material.dart';

import 'comunes.dart';
import 'models.dart';
import 'repositorio.dart';
import 'tema.dart';

import 'panel_screen.dart';
import 'envios_screen.dart';
import 'paquetes_screen.dart';
import 'rutas_screen.dart';
import 'repartidores_screen.dart';
import 'pagos_screen.dart';
import 'clientes_screen.dart';
import 'empleados_screen.dart';
import 'reportes_screen.dart';

enum Seccion { panel, envios, paquetes, rutas, repartidores, pagos, clientes, empleados, reportes }

extension SeccionX on Seccion {
  String get label => switch (this) {
        Seccion.panel => 'Panel de control',
        Seccion.envios => 'Envíos',
        Seccion.paquetes => 'Paquetes',
        Seccion.rutas => 'Rutas',
        Seccion.repartidores => 'Repartidores',
        Seccion.pagos => 'Pagos',
        Seccion.clientes => 'Clientes',
        Seccion.empleados => 'Empleados',
        Seccion.reportes => 'Reportes',
      };

  String get subtitulo => switch (this) {
        Seccion.panel => 'Resumen general de la operación logística',
        Seccion.envios => 'Registro, seguimiento y estados de los envíos',
        Seccion.paquetes => 'Características físicas de los paquetes transportados',
        Seccion.rutas => 'Planificación de zonas y asignación de repartidores',
        Seccion.repartidores => 'Personal encargado de las entregas',
        Seccion.pagos => 'Cobros, métodos y estados de pago',
        Seccion.clientes => 'Datos de contacto e historial de clientes',
        Seccion.empleados => 'Personal, cargos y responsabilidades',
        Seccion.reportes => 'Indicadores para la toma de decisiones',
      };

  IconData get icono => switch (this) {
        Seccion.panel => Icons.dashboard_outlined,
        Seccion.envios => Icons.local_shipping_outlined,
        Seccion.paquetes => Icons.inventory_2_outlined,
        Seccion.rutas => Icons.route_outlined,
        Seccion.repartidores => Icons.delivery_dining_outlined,
        Seccion.pagos => Icons.payments_outlined,
        Seccion.clientes => Icons.people_outline,
        Seccion.empleados => Icons.badge_outlined,
        Seccion.reportes => Icons.bar_chart_outlined,
      };

  String get grupo => switch (this) {
        Seccion.panel => 'GENERAL',
        Seccion.envios || Seccion.paquetes || Seccion.rutas || Seccion.repartidores => 'OPERACIÓN',
        Seccion.pagos || Seccion.clientes || Seccion.empleados || Seccion.reportes => 'ADMINISTRACIÓN',
      };
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Seccion _seccion = Seccion.panel;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void irA(Seccion seccion) {
    setState(() => _seccion = seccion);
  }

  Widget _contenido() => switch (_seccion) {
        Seccion.panel => PanelScreen(repositorio: widget.repositorio, irA: irA),
        Seccion.envios => EnviosScreen(repositorio: widget.repositorio),
        Seccion.paquetes => PaquetesScreen(repositorio: widget.repositorio),
        Seccion.rutas => RutasScreen(repositorio: widget.repositorio),
        Seccion.repartidores => RepartidoresScreen(repositorio: widget.repositorio),
        Seccion.pagos => PagosScreen(repositorio: widget.repositorio),
        Seccion.clientes => ClientesScreen(repositorio: widget.repositorio),
        Seccion.empleados => EmpleadosScreen(repositorio: widget.repositorio),
        Seccion.reportes => ReportesScreen(repositorio: widget.repositorio),
      };

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final compacto = ancho < 1000;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColores.fondo,
      appBar: compacto
          ? AppBar(
              backgroundColor: AppColores.sidebar,
              foregroundColor: Colors.white,
              title: const Text('RutaExpress', style: TextStyle(fontWeight: FontWeight.w700)),
              actions: [
                IconButton(icon: const Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
              ],
            )
          : null,
      drawer: compacto
          ? Drawer(
              width: 250,
              backgroundColor: AppColores.sidebar,
              child: _Menu(seccion: _seccion, irA: irA, repositorio: widget.repositorio),
            )
          : null,
      body: Row(
        children: [
          if (!compacto)
            SizedBox(
              width: 250,
              child: _Menu(seccion: _seccion, irA: irA, repositorio: widget.repositorio),
            ),
          Expanded(
            child: Column(
              children: [
                if (!compacto) _BarraSuperior(repositorio: widget.repositorio, seccion: _seccion),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(compacto ? 16 : 32, compacto ? 16 : 28, compacto ? 16 : 32, 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1500),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: KeyedSubtree(key: ValueKey(_seccion), child: _contenido()),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.seccion, required this.irA, required this.repositorio});

  final Seccion seccion;
  final void Function(Seccion) irA;
  final Repositorio repositorio;

  @override
  Widget build(BuildContext context) {
    final grupos = <String, List<Seccion>>{};
    for (final s in Seccion.values) {
      grupos.putIfAbsent(s.grupo, () => []).add(s);
    }
    return Container(
      color: AppColores.sidebar,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 26, 16, 26),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColores.primary, AppColores.accent]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RutaExpress', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
                        Text('PAQUETERÍA Y LOGÍSTICA', style: TextStyle(color: Color(0xFF8FA3C8), fontSize: 8.5, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final entry in grupos.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
                      child: Text(entry.key, style: const TextStyle(color: Color(0xFF6B82AC), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    ),
                    for (final s in entry.value)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                        child: _ItemMenu(
                          seccion: s,
                          activo: s == seccion,
                          onTap: () {
                            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                            irA(s);
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF182747), borderRadius: BorderRadius.circular(12)),
              child: ListenableBuilder(
                listenable: repositorio,
                builder: (context, _) {
                  final conectado = repositorio.conectado;
                  final color = conectado ? AppColores.verde : AppColores.rojo;
                  return Tooltip(
                    message: conectado ? 'Conectado a MySQL/MariaDB' : (repositorio.errorConexion ?? 'Sin conexión con la base de datos'),
                    child: Row(
                      children: [
                        Icon(conectado ? Icons.cloud_done_outlined : Icons.cloud_off_outlined, color: color, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            conectado ? 'BD conectada · v1.0' : 'BD desconectada',
                            style: TextStyle(color: conectado ? const Color(0xFFB9C8E0) : color, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  const _ItemMenu({required this.seccion, required this.activo, required this.onTap});

  final Seccion seccion;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? AppColores.sidebarActivo : Colors.transparent,
      borderRadius: BorderRadius.circular(9),
      child: ListTile(
        onTap: onTap,
        leading: Icon(seccion.icono, size: 19, color: activo ? Colors.white : const Color(0xFF9FB2D0)),
        title: Text(seccion.label, style: TextStyle(fontSize: 13, color: activo ? Colors.white : const Color(0xFFB9C8E0), fontWeight: activo ? FontWeight.w600 : FontWeight.normal)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

class _BarraSuperior extends StatelessWidget {
  const _BarraSuperior({required this.repositorio, required this.seccion});

  final Repositorio repositorio;
  final Seccion seccion;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColores.borde))),
      child: Row(
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(seccion.label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(seccion.subtitulo, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColores.textoSecundario)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 220),
              height: 38,
              decoration: BoxDecoration(color: AppColores.fondo, borderRadius: BorderRadius.circular(9)),
              child: ListenableBuilder(
                listenable: repositorio,
                builder: (context, _) {
                  final ind = repositorio.indicadores;
                  return Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.local_shipping_outlined, size: 16, color: AppColores.primary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text('${ind.enRuta} envíos en ruta', overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColores.textoSecundario)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => mostrarMensaje(context, 'No hay notificaciones nuevas'),
            icon: const Icon(Icons.notifications_none, color: AppColores.textoSecundario),
            tooltip: 'Notificaciones',
          ),
          const SizedBox(width: 10),
          ListenableBuilder(
            listenable: repositorio,
            builder: (context, _) {
              return DropdownButtonHideUnderline(
                child: DropdownButton<Rol>(
                  value: repositorio.rolActual,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  borderRadius: BorderRadius.circular(10),
                  items: [
                    for (final rol in Rol.values)
                      DropdownMenuItem(value: rol, child: Text(rol.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                  ],
                  onChanged: (rol) {
                    if (rol != null) repositorio.setRol(rol);
                  },
                ),
              );
            },
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColores.primaryLight,
            child: const Icon(Icons.person, color: AppColores.primary, size: 19),
          ),
        ],
      ),
    );
  }
}

