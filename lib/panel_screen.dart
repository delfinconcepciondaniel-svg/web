import 'package:flutter/material.dart';

import '../comunes.dart';
import '../layout.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class PanelScreen extends StatelessWidget {
  const PanelScreen({super.key, required this.repositorio, required this.irA});

  final Repositorio repositorio;
  final void Function(Seccion) irA;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repositorio,
      builder: (context, _) {
        final ind = repositorio.indicadores;
        final fecha = DateTime.now();
        final recientes = repositorio.envios.reversed.take(5).toList();
        final maxEstado = repositorio.envios.isEmpty ? 1 : repositorio.envios.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bienvenido, ${repositorio.rolActual.label}', style: Theme.of(context).textTheme.displaySmall),
                      const SizedBox(height: 6),
                      Text('Aquí tienes el resumen de la operación de RutaExpress al ${_fechaTexto(fecha)}',
                          style: const TextStyle(color: AppColores.textoSecundario, fontSize: 13)),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => irA(Seccion.envios),
                  icon: const Icon(Icons.add, size: 17),
                  label: const Text('Nuevo envío'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 1100 ? 4 : constraints.maxWidth > 620 ? 2 : 1;
                final items = [
                  _Kpi(titulo: 'Total envíos', valor: '${ind.totalEnvios}', icono: Icons.local_shipping_outlined, color: AppColores.primary, pie: 'Registrados en el sistema'),
                  _Kpi(titulo: 'Entregados', valor: '${ind.entregados}', icono: Icons.check_circle_outline, color: AppColores.verde, pie: '${ind.entregasATiempo.toStringAsFixed(0)}% de efectividad'),
                  _Kpi(titulo: 'En ruta', valor: '${ind.enRuta}', icono: Icons.route_outlined, color: AppColores.naranja, pie: 'Despachos en curso'),
                  _Kpi(titulo: 'Ingresos', valor: 'S/ ${ind.ingresos.toStringAsFixed(2)}', icono: Icons.payments_outlined, color: const Color(0xFF7C3AED), pie: 'Pagos confirmados'),
                ];
                return GridView.count(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: cols == 1 ? 3 : 2.35,
                  children: [for (final item in items) _TarjetaKpi(item: item)],
                );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final ancho = constraints.maxWidth;
                final estadosCard = Tarjeta(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TituloTarjeta(titulo: 'Estado de los envíos'),
                      const SizedBox(height: 20),
                      for (final estado in EstadoEnvio.values)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _BarraEstado(
                            estado: estado,
                            cantidad: repositorio.envios.where((e) => e.estado == estado).length,
                            total: maxEstado,
                          ),
                        ),
                    ],
                  ),
                );
                final accesosCard = Tarjeta(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TituloTarjeta(titulo: 'Accesos rápidos'),
                      const SizedBox(height: 12),
                      _Acceso(icono: Icons.person_add_outlined, titulo: 'Registrar cliente', color: AppColores.primary, onTap: () => irA(Seccion.clientes)),
                      _Acceso(icono: Icons.route_outlined, titulo: 'Planificar ruta', color: AppColores.naranja, onTap: () => irA(Seccion.rutas)),
                      _Acceso(icono: Icons.inventory_2_outlined, titulo: 'Agregar paquete', color: const Color(0xFF7C3AED), onTap: () => irA(Seccion.paquetes)),
                      _Acceso(icono: Icons.bar_chart_outlined, titulo: 'Ver indicadores', color: AppColores.verde, onTap: () => irA(Seccion.reportes)),
                    ],
                  ),
                );
                if (ancho <= 1000) {
                  return Column(children: [estadosCard, const SizedBox(height: 16), accesosCard]);
                }
                return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(flex: 3, child: estadosCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: accesosCard),
                ]);
              },
            ),
            const SizedBox(height: 20),
            Tarjeta(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: TituloTarjeta(
                      titulo: 'Últimos envíos registrados',
                      accion: TextButton(onPressed: () => irA(Seccion.envios), child: const Text('Ver todos')),
                    ),
                  ),
                  _TablaRecientes(envios: recientes, repositorio: repositorio),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _fechaTexto(DateTime fecha) {
    const meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

class _Kpi {
  const _Kpi({required this.titulo, required this.valor, required this.icono, required this.color, required this.pie});

  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final String pie;
}

class _TarjetaKpi extends StatelessWidget {
  const _TarjetaKpi({required this.item});

  final _Kpi item;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(child: Etiqueta(item.titulo)),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: item.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
                child: Icon(item.icono, size: 18, color: item.color),
              ),
            ],
          ),
          Text(item.valor, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: item.color, letterSpacing: -0.5)),
          Text(item.pie, style: const TextStyle(fontSize: 11, color: AppColores.textoSecundario)),
        ],
      ),
    );
  }
}

class _BarraEstado extends StatelessWidget {
  const _BarraEstado({required this.estado, required this.cantidad, required this.total});

  final EstadoEnvio estado;
  final int cantidad;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 104, child: ChipEstado(estado)),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : cantidad / total,
              minHeight: 8,
              backgroundColor: AppColores.borde,
              color: estado.color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(width: 24, child: Text('$cantidad', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    );
  }
}

class _Acceso extends StatelessWidget {
  const _Acceso({required this.icono, required this.titulo, required this.color, required this.onTap});

  final IconData icono;
  final String titulo;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9)),
              child: Icon(icono, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(titulo, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
            const Icon(Icons.arrow_forward_ios, size: 13, color: AppColores.textoSecundario),
          ],
        ),
      ),
    );
  }
}

class _TablaRecientes extends StatelessWidget {
  const _TablaRecientes({required this.envios, required this.repositorio});

  final List<Envio> envios;
  final Repositorio repositorio;

  @override
  Widget build(BuildContext context) {
    if (envios.isEmpty) return const EstadoVacio(mensaje: 'Aún no hay envíos registrados');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
        headingTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColores.textoSecundario),
        dataTextStyle: const TextStyle(fontSize: 12, color: AppColores.texto),
        columnSpacing: 24,
        columns: const [
          DataColumn(label: Text('CÓDIGO')),
          DataColumn(label: Text('CLIENTE')),
          DataColumn(label: Text('ORIGEN → DESTINO')),
          DataColumn(label: Text('TARIFA')),
          DataColumn(label: Text('ESTADO')),
        ],
        rows: [
          for (final e in envios)
            DataRow(
              cells: [
                DataCell(celda(e.id, peso: FontWeight.w700, color: AppColores.primary)),
                DataCell(celda(repositorio.nombreCliente(e.clienteId))),
                DataCell(celda('${e.origen} → ${e.destino}')),
                DataCell(celda('S/ ${e.tarifa.toStringAsFixed(2)}')),
                DataCell(ChipEstado(e.estado)),
              ],
            ),
        ],
      ),
    );
  }
}
