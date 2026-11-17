import 'package:flutter/material.dart';

import '../comunes.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class RutasScreen extends StatefulWidget {
  const RutasScreen({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  State<RutasScreen> createState() => _RutasScreenState();
}

class _RutasScreenState extends State<RutasScreen> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repositorio,
      builder: (context, _) {
        final lista = widget.repositorio.rutas;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EncabezadoPagina(
              titulo: 'Rutas',
              subtitulo: 'Planificación de zonas, fechas de despacho y asignación de repartidores (RF05, RN07)',
              accion: FilledButton.icon(
                onPressed: () => _formulario(context),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Nueva ruta'),
              ),
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
                    DataColumn(label: Text('ZONA')),
                    DataColumn(label: Text('FECHA')),
                    DataColumn(label: Text('DESCRIPCIÓN')),
                    DataColumn(label: Text('REPARTIDOR')),
                    DataColumn(label: Text('ENVÍOS')),
                    DataColumn(label: Text('')),
                  ],
                  rows: [
                    for (final r in lista)
                      DataRow(
                        cells: [
                          DataCell(celda(r.id, peso: FontWeight.w700, color: AppColores.primary)),
                          DataCell(celda(r.zona, peso: FontWeight.w600)),
                          DataCell(celda(_fechaCorta(r.fecha))),
                          DataCell(celda(r.descripcion)),
                          DataCell(celda(widget.repositorio.nombreRepartidor(r.repartidorId),
                              color: r.repartidorId == null ? AppColores.naranja : AppColores.texto)),
                          DataCell(celda('${widget.repositorio.envios.where((e) => e.rutaId == r.id).length}')),
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
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final ancho = constraints.maxWidth;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final r in lista)
                      SizedBox(
                        width: ancho > 1000 ? (ancho - 64) / 3 : ancho > 650 ? (ancho - 16) / 2 : ancho,
                        child: Tarjeta(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(color: AppColores.primaryLight, borderRadius: BorderRadius.circular(9)),
                                    child: const Icon(Icons.route_outlined, size: 18, color: AppColores.primary),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(r.id, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColores.primary)),
                                  const Spacer(),
                                  if (r.repartidorId != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: AppColores.verde.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                                      child: const Text('Asignada', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColores.verde)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(r.zona, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(r.descripcion, style: const TextStyle(fontSize: 12, color: AppColores.textoSecundario)),
                              const Divider(height: 22),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 14, color: AppColores.textoSecundario),
                                  const SizedBox(width: 6),
                                  Expanded(child: Text(widget.repositorio.nombreRepartidor(r.repartidorId),
                                      style: const TextStyle(fontSize: 11.5, color: AppColores.textoSecundario), overflow: TextOverflow.ellipsis)),
                                  Text(_fechaCorta(r.fecha), style: const TextStyle(fontSize: 11, color: AppColores.textoSecundario)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _fechaCorta(DateTime f) => '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  void _formulario(BuildContext context, [Ruta? ruta]) {
    final repo = widget.repositorio;
    final formKey = GlobalKey<FormState>();
    final zona = TextEditingController(text: ruta?.zona ?? '');
    final descripcion = TextEditingController(text: ruta?.descripcion ?? '');
    String? repartidorId = ruta?.repartidorId;
    DateTime fecha = ruta?.fecha ?? DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(ruta == null ? 'Nueva ruta' : 'Editar ruta ${ruta.id}'),
          content: SizedBox(
            width: 460,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CampoTexto(controlador: zona, etiqueta: 'Zona'),
                  const SizedBox(height: 12),
                  CampoTexto(controlador: descripcion, etiqueta: 'Descripción'),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Etiqueta('Fecha de despacho'),
                    subtitle: Text(_fechaCorta(fecha), style: const TextStyle(fontSize: 13, color: AppColores.texto)),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today_outlined, size: 18, color: AppColores.primary),
                      onPressed: () async {
                        final f = await showDatePicker(context: ctx, initialDate: fecha, firstDate: DateTime(2020), lastDate: DateTime(2035));
                        if (f != null) setStateDialog(() => fecha = f);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: repartidorId,
                    decoration: const InputDecoration(labelText: 'Repartidor (opcional)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin asignar')),
                      for (final r in repo.repartidores) DropdownMenuItem(value: r.id, child: Text('${r.id} · ${r.nombre}')),
                    ],
                    onChanged: (v) => setStateDialog(() => repartidorId = v),
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
                if (ruta == null) {
                  repo.agregarRuta(Ruta(
                    id: repo.nuevoRutaId(),
                    zona: zona.text.trim(),
                    fecha: fecha,
                    descripcion: descripcion.text.trim(),
                    repartidorId: repartidorId,
                  ));
                  mostrarMensaje(context, 'Ruta registrada');
                } else {
                  repo.actualizarRuta(ruta,
                      zona: zona.text.trim(), fecha: fecha, descripcion: descripcion.text.trim(), repartidorId: repartidorId);
                  mostrarMensaje(context, 'Ruta actualizada');
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
