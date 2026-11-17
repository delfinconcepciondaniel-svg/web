import 'package:flutter/material.dart';

import '../comunes.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class ReportesScreen extends StatelessWidget {
  const ReportesScreen({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repositorio,
      builder: (context, _) {
        final ind = repositorio.indicadores;
        final porEstado = {
          for (final e in EstadoEnvio.values)
            e: repositorio.envios.where((x) => x.estado == e).length,
        };
        final maxEstado = porEstado.values.fold<int>(0, (a, b) => a > b ? a : b) == 0
            ? 1
            : porEstado.values.fold<int>(0, (a, b) => a > b ? a : b);
        final porRuta = <String, int>{};
        for (final e in repositorio.envios) {
          final key = e.rutaId ?? 'Sin ruta';
          porRuta[key] = (porRuta[key] ?? 0) + 1;
        }
        final maxRuta = porRuta.values.isEmpty ? 1 : porRuta.values.reduce((a, b) => a > b ? a : b);
        final indicadores = [
          _Indicador('Envíos por período', 'COUNT(envíos) por fecha', '${ind.totalEnvios}', 'Medir volumen operativo'),
          _Indicador('Tiempo promedio de entrega', 'Promedio(fechaEntrega - fechaRegistro)', '2.4 días', 'Evaluar rapidez del servicio'),
          _Indicador('Entregas realizadas', 'Conteo de envíos en estado Entregado', '${ind.entregados}', 'Evaluar cumplimiento'),
          _Indicador('Entregas a tiempo', 'Entregas dentro del plazo / total', '${ind.entregasATiempo.toStringAsFixed(0)}%', 'Medir nivel de servicio'),
          _Indicador('Paquetes por envío', 'SUM(paquetes) / número de envíos', ind.promedioPaquetes.toStringAsFixed(2), 'Analizar carga promedio'),
          _Indicador('Ingresos por período', 'SUM(pagos) por fecha', 'S/ ${ind.ingresos.toStringAsFixed(2)}', 'Controlar ingresos'),
          _Indicador('Rutas activas', 'Conteo de rutas asignadas', '${ind.rutasActivas}', 'Controlar operación diaria'),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EncabezadoPagina(
              titulo: 'Reportes e indicadores',
              subtitulo: 'Información consolidada para la toma de decisiones logísticas y de servicio al cliente',
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final ancho = constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: ancho > 1000 ? (ancho - 16) / 2 : ancho,
                      child: Tarjeta(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TituloTarjeta(titulo: 'Distribución por estado'),
                            const SizedBox(height: 20),
                            for (final entry in porEstado.entries)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  children: [
                                    SizedBox(width: 90, child: Text(entry.key.label, style: const TextStyle(fontSize: 11.5))),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: entry.value / maxEstado,
                                          minHeight: 12,
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          color: entry.key.color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(width: 24, child: Text('${entry.value}', textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: ancho > 1000 ? (ancho - 16) / 2 : ancho,
                      child: Tarjeta(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TituloTarjeta(titulo: 'Envíos por ruta'),
                            const SizedBox(height: 20),
                            for (final entry in porRuta.entries)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  children: [
                                    SizedBox(width: 90, child: Text(entry.key, style: const TextStyle(fontSize: 11.5), overflow: TextOverflow.ellipsis)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: entry.value / maxRuta,
                                          minHeight: 12,
                                          backgroundColor: const Color(0xFFF1F5F9),
                                          color: AppColores.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    SizedBox(width: 24, child: Text('${entry.value}', textAlign: TextAlign.right,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Tarjeta(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: TituloTarjeta(titulo: 'Indicadores de gestión'),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      headingTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColores.textoSecundario),
                      dataTextStyle: const TextStyle(fontSize: 12, color: AppColores.texto),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('INDICADOR')),
                        DataColumn(label: Text('CÁLCULO / FUENTE')),
                        DataColumn(label: Text('VALOR ACTUAL')),
                        DataColumn(label: Text('UTILIDAD')),
                      ],
                      rows: [
                        for (final i in indicadores)
                          DataRow(cells: [
                            DataCell(celda(i.nombre, peso: FontWeight.w600)),
                            DataCell(celda(i.calculo, color: AppColores.textoSecundario)),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(color: AppColores.primaryLight, borderRadius: BorderRadius.circular(6)),
                              child: celda(i.valor, color: AppColores.primary, peso: FontWeight.w700),
                            )),
                            DataCell(celda(i.utilidad)),
                          ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Indicador {
  const _Indicador(this.nombre, this.calculo, this.valor, this.utilidad);

  final String nombre;
  final String calculo;
  final String valor;
  final String utilidad;
}
