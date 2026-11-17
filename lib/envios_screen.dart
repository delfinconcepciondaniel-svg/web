import 'package:flutter/material.dart';

import '../comunes.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class EnviosScreen extends StatefulWidget {
  const EnviosScreen({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  State<EnviosScreen> createState() => _EnviosScreenState();
}

class _EnviosScreenState extends State<EnviosScreen> {
  final TextEditingController _busqueda = TextEditingController();
  EstadoEnvio? _filtro;

  List<Envio> get _lista {
    final q = _busqueda.text.toLowerCase().trim();
    return widget.repositorio.envios.where((e) {
      final coincide = q.isEmpty ||
          e.id.toLowerCase().contains(q) ||
          widget.repositorio.nombreCliente(e.clienteId).toLowerCase().contains(q) ||
          e.origen.toLowerCase().contains(q) ||
          e.destino.toLowerCase().contains(q) ||
          e.estado.label.toLowerCase().contains(q);
      return coincide && (_filtro == null || e.estado == _filtro);
    }).toList();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repositorio,
      builder: (context, _) {
        final lista = _lista;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EncabezadoPagina(
              titulo: 'EnvÃ­os',
              subtitulo: 'Gestione el registro, el seguimiento y los estados de cada servicio',
              accion: FilledButton.icon(
                onPressed: () => _nuevoEnvio(context),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Nuevo envÃ­o'),
              ),
            ),
            const SizedBox(height: 20),
            Tarjeta(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _busqueda,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar por cÃ³digo, cliente u origen...',
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppColores.textoSecundario),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Filtro(label: 'Todos', activo: _filtro == null, onTap: () => setState(() => _filtro = null)),
                      for (final e in EstadoEnvio.values)
                        _Filtro(
                          label: e.label,
                          activo: _filtro == e,
                          color: e.color,
                          onTap: () => setState(() => _filtro = e),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Tarjeta(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                    child: Row(
                      children: [
                        Text('Lista de envÃ­os', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColores.primaryLight, borderRadius: BorderRadius.circular(20)),
                          child: Text('${lista.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColores.primary)),
                        ),
                      ],
                    ),
                  ),
                  if (lista.isEmpty)
                    const EstadoVacio(mensaje: 'No se encontraron envÃ­os con los criterios seleccionados')
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        headingTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColores.textoSecundario),
                        dataTextStyle: const TextStyle(fontSize: 12, color: AppColores.texto),
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('CÃ“DIGO')),
                          DataColumn(label: Text('CLIENTE')),
                          DataColumn(label: Text('RUTA')),
                          DataColumn(label: Text('FECHA')),
                          DataColumn(label: Text('PAQ.')),
                          DataColumn(label: Text('TARIFA')),
                          DataColumn(label: Text('ESTADO')),
                          DataColumn(label: Text('ACCIONES')),
                        ],
                        rows: [
                          for (final e in lista)
                            DataRow(
                              cells: [
                                DataCell(TextButton(
                                  onPressed: () => _detalle(context, e),
                                  child: Text(e.id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                )),
                                DataCell(celda(widget.repositorio.nombreCliente(e.clienteId))),
                                DataCell(celda(e.rutaId ?? 'Sin asignar', color: e.rutaId == null ? AppColores.textoSecundario : AppColores.texto)),
                                DataCell(celda(_fechaCorta(e.fecha))),
                                DataCell(celda('${widget.repositorio.paquetesDe(e.id).length}')),
                                DataCell(celda('S/ ${e.tarifa.toStringAsFixed(2)}', peso: FontWeight.w600)),
                                DataCell(ChipEstado(e.estado)),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Ver detalle',
                                      icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColores.primary),
                                      onPressed: () => _detalle(context, e),
                                    ),
                                    if (e.estado.siguientes.isNotEmpty)
                                      IconButton(
                                        tooltip: 'Cambiar estado',
                                        icon: const Icon(Icons.swap_horiz, size: 18, color: AppColores.naranja),
                                        onPressed: () => _cambiarEstado(context, e),
                                      ),
                                    if (e.estado != EstadoEnvio.entregado && e.estado != EstadoEnvio.cancelado)
                                      IconButton(
                                        tooltip: 'Asignar ruta y repartidor',
                                        icon: const Icon(Icons.route_outlined, size: 18, color: AppColores.verde),
                                        onPressed: () => _asignar(context, e),
                                      ),
                                  ],
                                )),
                              ],
                            ),
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

  String _fechaCorta(DateTime f) => '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  void _nuevoEnvio(BuildContext context) {
    final repo = widget.repositorio;
    final formKey = GlobalKey<FormState>();
    final clienteId = TextEditingController(text: repo.clientes.first.id);
    final origen = TextEditingController();
    final destino = TextEditingController();
    final tarifa = TextEditingController();
    final empleadoId = TextEditingController(text: repo.empleados.first.id);
    final desc = TextEditingController();
    final peso = TextEditingController();
    final dimensiones = TextEditingController();
    final valor = TextEditingController();
    DateTime fecha = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrar nuevo envÃ­o'),
        content: SizedBox(
          width: 640,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Etiqueta('Datos del envÃ­o', color: AppColores.primary),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _select('Cliente', clienteId, [for (final c in repo.clientes) DropdownMenuItem(value: c.id, child: Text('${c.id} - ${c.nombre}'))])),
                      const SizedBox(width: 12),
                      Expanded(child: _select('Responsable', empleadoId, [for (final e in repo.empleados) DropdownMenuItem(value: e.id, child: Text('${e.id} - ${e.nombre}'))])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: CampoTexto(controlador: origen, etiqueta: 'Origen')),
                      const SizedBox(width: 12),
                      Expanded(child: CampoTexto(controlador: destino, etiqueta: 'Destino')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ListenableBuilder(
                          listenable: repo,
                          builder: (context, _) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Etiqueta('Fecha de registro'),
                            subtitle: Text(_fechaCorta(fecha), style: const TextStyle(fontSize: 13, color: AppColores.texto)),
                            trailing: IconButton(
                              icon: const Icon(Icons.calendar_today_outlined, size: 18, color: AppColores.primary),
                              onPressed: () async {
                                final f = await showDatePicker(context: ctx, initialDate: fecha, firstDate: DateTime(2020), lastDate: DateTime(2035));
                                if (f != null) fecha = f;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CampoTexto(controlador: tarifa, etiqueta: 'Tarifa (S/)', teclado: const TextInputType.numberWithOptions(decimal: true)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Etiqueta('Primer paquete (RN04)', color: AppColores.primary),
                  const SizedBox(height: 12),
                  CampoTexto(controlador: desc, etiqueta: 'DescripciÃ³n'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: CampoTexto(controlador: peso, etiqueta: 'Peso (kg)', teclado: const TextInputType.numberWithOptions(decimal: true))),
                      const SizedBox(width: 12),
                      Expanded(child: CampoTexto(controlador: dimensiones, etiqueta: 'Dimensiones')),
                      const SizedBox(width: 12),
                      Expanded(child: CampoTexto(controlador: valor, etiqueta: 'Valor declarado (S/)', teclado: const TextInputType.numberWithOptions(decimal: true))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final p = parseMonto(peso.text);
              final v = parseMonto(valor.text);
              if (p <= 0) {
                mostrarMensaje(ctx, 'RN05: el peso debe ser mayor que cero', error: true);
                return;
              }
              final t = parseMonto(tarifa.text);
              if (t < 0 || v < 0) {
                mostrarMensaje(ctx, 'RN06: la tarifa y el valor no pueden ser negativos', error: true);
                return;
              }
              final id = repo.nuevoEnvioId();
              repo.agregarEnvio(
                Envio(
                  id: id,
                  clienteId: clienteId.text,
                  origen: origen.text.trim(),
                  destino: destino.text.trim(),
                  fecha: fecha,
                  tarifa: t,
                  estado: EstadoEnvio.registrado,
                  empleadoId: empleadoId.text,
                ),
                Paquete(
                  id: repo.nuevoPaqueteId(),
                  envioId: id,
                  descripcion: desc.text.trim(),
                  peso: p,
                  dimensiones: dimensiones.text.trim(),
                  valorDeclarado: v,
                ),
              );
              Navigator.pop(ctx);
              mostrarMensaje(context, 'EnvÃ­o $id registrado correctamente');
            },
            child: const Text('Guardar envÃ­o'),
          ),
        ],
      ),
    );
  }

  Widget _select(String etiqueta, TextEditingController controller, List<DropdownMenuItem<String>> items) {
    return DropdownButtonFormField<String>(
      initialValue: controller.text,
      decoration: InputDecoration(labelText: '$etiqueta *'),
      items: items,
      onChanged: (v) => controller.text = v ?? '',
      validator: (v) => v == null || v.isEmpty ? 'Seleccione $etiqueta' : null,
    );
  }

  void _detalle(BuildContext context, Envio envio) {
    showDialog(
      context: context,
      builder: (ctx) => ListenableBuilder(
        listenable: widget.repositorio,
        builder: (context, _) {
          final repo = widget.repositorio;
          final paquetes = repo.paquetesDe(envio.id);
          final pago = repo.pagoDe(envio.id);
          final ruta = repo.ruta(envio.rutaId);
          final repartidor = repo.repartidor(envio.repartidorId);
          return AlertDialog(
            title: Row(
              children: [
                Text('Detalle de ${envio.id}'),
                const Spacer(),
                ChipEstado(envio.estado),
              ],
            ),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _bloque('InformaciÃ³n del envÃ­o', [
                      _dato('Cliente', repo.nombreCliente(envio.clienteId)),
                      _dato('Responsable', repo.empleado(envio.empleadoId)?.nombre ?? envio.empleadoId),
                      _dato('Origen', envio.origen),
                      _dato('Destino', envio.destino),
                      _dato('Fecha', _fechaCorta(envio.fecha)),
                      _dato('Tarifa', 'S/ ${envio.tarifa.toStringAsFixed(2)}'),
                      _dato('Ruta', ruta?.zona ?? 'Sin asignar'),
                      _dato('Repartidor', repartidor?.nombre ?? 'Sin asignar'),
                    ]),
                    const SizedBox(height: 18),
                    _bloque('Paquetes (${paquetes.length})', [
                      for (final p in paquetes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColores.fondo, borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${p.id} Â· ${p.descripcion}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text('${p.peso.toStringAsFixed(1)} kg Â· ${p.dimensiones} Â· Valor S/ ${p.valorDeclarado.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 11, color: AppColores.textoSecundario)),
                              ],
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 18),
                    _bloque('Pago', pago == null
                        ? [_dato('Estado', 'Sin pago registrado')]
                        : [
                            _dato('CÃ³digo', pago.id),
                            _dato('Importe', 'S/ ${pago.importe.toStringAsFixed(2)}'),
                            _dato('MÃ©todo', pago.metodo),
                            _dato('Estado', pago.estado.label),
                          ]),
                    if (envio.confirmacion != null) ...[
                      const SizedBox(height: 18),
                      _bloque('ConfirmaciÃ³n de entrega', [_dato('Detalle', envio.confirmacion!)]),
                    ],
                    const SizedBox(height: 18),
                    const Etiqueta('Trazabilidad de estados', color: AppColores.primary),
                    const SizedBox(height: 10),
                    _LineaEstados(estado: envio.estado),
                  ],
                ),
              ),
            ),
            actions: [
              if (envio.estado.siguientes.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _cambiarEstado(context, envio);
                  },
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Cambiar estado'),
                ),
              FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
            ],
          );
        },
      ),
    );
  }

  Widget _bloque(String titulo, List<Widget> hijos) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Etiqueta(titulo, color: AppColores.primary),
          const SizedBox(height: 8),
          ...hijos,
        ],
      );

  Widget _dato(String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(etiqueta, style: const TextStyle(fontSize: 12, color: AppColores.textoSecundario))),
            Expanded(child: Text(valor, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
          ],
        ),
      );

  void _cambiarEstado(BuildContext context, Envio envio) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cambiar estado de ${envio.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('Estado actual:', style: TextStyle(fontSize: 12, color: AppColores.textoSecundario)),
            ),
            ChipEstado(envio.estado),
            const SizedBox(height: 18),
            const Etiqueta('Seleccione el nuevo estado', color: AppColores.primary),
            const SizedBox(height: 10),
            for (final estado in envio.estado.siguientes)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(estado.icon, color: estado.color, size: 20),
                title: Text(estado.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                onTap: () {
                  final error = widget.repositorio.cambiarEstado(envio, estado);
                  Navigator.pop(ctx);
                  if (error != null) {
                    mostrarMensaje(context, error, error: true);
                  } else {
                    mostrarMensaje(context, 'Estado actualizado a ${estado.label}');
                  }
                },
              ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar'))],
      ),
    );
  }

  void _asignar(BuildContext context, Envio envio) {
    final repo = widget.repositorio;
    String? rutaId = envio.rutaId;
    String? repId = envio.repartidorId;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Asignar ruta y repartidor Â· ${envio.id}'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: rutaId,
                  decoration: const InputDecoration(labelText: 'Ruta'),
                  items: [
                    for (final r in repo.rutas)
                      DropdownMenuItem(value: r.id, child: Text('${r.id} Â· ${r.zona}')),
                  ],
                  onChanged: (v) => setStateDialog(() => rutaId = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: repId,
                  decoration: const InputDecoration(labelText: 'Repartidor'),
                  items: [
                    for (final r in repo.repartidores)
                      DropdownMenuItem(value: r.id, child: Text('${r.id} Â· ${r.nombre}')),
                  ],
                  onChanged: (v) => setStateDialog(() => repId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (rutaId == null || repId == null) {
                  mostrarMensaje(ctx, 'Seleccione una ruta y un repartidor', error: true);
                  return;
                }
                repo.asignarRutaRepartidor(envio, rutaId: rutaId!, repartidorId: repId!);
                Navigator.pop(ctx);
                mostrarMensaje(context, 'Ruta y repartidor asignados');
              },
              child: const Text('Asignar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filtro extends StatelessWidget {
  const _Filtro({required this.label, required this.activo, required this.onTap, this.color});

  final String label;
  final bool activo;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColores.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: activo ? c : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: activo ? Colors.white : AppColores.textoSecundario)),
      ),
    );
  }
}

class _LineaEstados extends StatelessWidget {
  const _LineaEstados({required this.estado});

  final EstadoEnvio estado;

  @override
  Widget build(BuildContext context) {
    const pasos = [EstadoEnvio.registrado, EstadoEnvio.clasificado, EstadoEnvio.enRuta, EstadoEnvio.entregado];
    final indiceActual = estado == EstadoEnvio.cancelado ? 0 : pasos.indexOf(estado);
    return Row(
      children: [
        for (var i = 0; i < pasos.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: estado == EstadoEnvio.cancelado
                        ? (i == 0 ? AppColores.rojo : AppColores.borde)
                        : (i <= indiceActual ? pasos[i].color : AppColores.borde),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(i <= indiceActual || estado == EstadoEnvio.cancelado ? Icons.check : Icons.remove,
                      color: Colors.white, size: 15),
                ),
                const SizedBox(height: 5),
                Text(pasos[i].label, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 9.5, color: i <= indiceActual ? AppColores.texto : AppColores.textoSecundario)),
              ],
            ),
          ),
          if (i < pasos.length - 1)
            Container(height: 2, width: 24, color: i < indiceActual ? AppColores.verde : AppColores.borde),
        ],
      ],
    );
  }
}

