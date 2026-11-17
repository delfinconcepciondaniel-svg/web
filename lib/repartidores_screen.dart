import 'package:flutter/material.dart';

import '../comunes.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class RepartidoresScreen extends StatefulWidget {
  const RepartidoresScreen({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  State<RepartidoresScreen> createState() => _RepartidoresScreenState();
}

class _RepartidoresScreenState extends State<RepartidoresScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repositorio,
      builder: (context, _) {
        final lista = widget.repositorio.repartidores;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EncabezadoPagina(
              titulo: 'Repartidores',
              subtitulo: 'Responsables de ejecutar las entregas y actualizar los estados (RF05)',
              accion: FilledButton.icon(
                onPressed: () => _formulario(context),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Nuevo repartidor'),
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final disponibles = lista.where((r) => r.disponible).length;
                final items = [
                  _MiniKpi(titulo: 'Total repartidores', valor: '${lista.length}', icono: Icons.delivery_dining_outlined, color: AppColores.primary),
                  _MiniKpi(titulo: 'Disponibles', valor: '$disponibles', icono: Icons.check_circle_outline, color: AppColores.verde),
                  _MiniKpi(titulo: 'Ocupados', valor: '${lista.length - disponibles}', icono: Icons.hourglass_empty, color: AppColores.naranja),
                ];
                return GridView.count(
                  crossAxisCount: constraints.maxWidth > 900 ? 3 : 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3.5,
                  children: [for (final item in items) item],
                );
              },
            ),
            const SizedBox(height: 20),
            Tarjeta(
              padding: EdgeInsets.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  headingTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColores.textoSecundario),
                  dataTextStyle: const TextStyle(fontSize: 12, color: AppColores.texto),
                  columnSpacing: 22,
                  columns: const [
                    DataColumn(label: Text('CÓDIGO')),
                    DataColumn(label: Text('NOMBRE')),
                    DataColumn(label: Text('TELÉFONO')),
                    DataColumn(label: Text('DISPONIBILIDAD')),
                    DataColumn(label: Text('ENVÍOS ASIGNADOS')),
                    DataColumn(label: Text('')),
                  ],
                  rows: [
                    for (final r in lista)
                      DataRow(
                        cells: [
                          DataCell(celda(r.id, peso: FontWeight.w700, color: AppColores.primary)),
                          DataCell(celda(r.nombre, peso: FontWeight.w600)),
                          DataCell(celda(r.telefono)),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: (r.disponible ? AppColores.verde : AppColores.naranja).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: celda(r.disponible ? 'Disponible' : 'Ocupado',
                                color: r.disponible ? AppColores.verde : AppColores.naranja, peso: FontWeight.w700),
                          )),
                          DataCell(celda('${widget.repositorio.envios.where((e) => e.repartidorId == r.id).length}')),
                          DataCell(IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit_outlined, size: 17, color: AppColores.primary),
                            onPressed: () => _formulario(context, r),
                          )),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _formulario(BuildContext context, [Repartidor? repartidor]) {
    final repo = widget.repositorio;
    final formKey = GlobalKey<FormState>();
    final nombre = TextEditingController(text: repartidor?.nombre ?? '');
    final telefono = TextEditingController(text: repartidor?.telefono ?? '');
    bool disponible = repartidor?.disponible ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(repartidor == null ? 'Nuevo repartidor' : 'Editar repartidor ${repartidor.id}'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CampoTexto(controlador: nombre, etiqueta: 'Nombre completo'),
                  const SizedBox(height: 12),
                  CampoTexto(controlador: telefono, etiqueta: 'Teléfono'),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Disponible para entregas', style: TextStyle(fontSize: 13)),
                    value: disponible,
                    onChanged: (v) => setStateDialog(() => disponible = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                if (repartidor == null) {
                  repo.agregarRepartidor(Repartidor(
                    id: repo.nuevoRepartidorId(),
                    nombre: nombre.text.trim(),
                    telefono: telefono.text.trim(),
                    disponible: disponible,
                  ));
                  mostrarMensaje(context, 'Repartidor registrado');
                } else {
                  repo.actualizarRepartidor(repartidor,
                      nombre: nombre.text.trim(), telefono: telefono.text.trim(), disponible: disponible);
                  mostrarMensaje(context, 'Repartidor actualizado');
                }
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({required this.titulo, required this.valor, required this.icono, required this.color});

  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tarjeta(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icono, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Etiqueta(titulo),
              const SizedBox(height: 3),
              Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
