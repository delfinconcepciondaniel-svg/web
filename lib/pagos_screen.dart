import 'package:flutter/material.dart';

import '../comunes.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  EstadoPago? _filtro;

  List<Pago> get _lista {
    if (_filtro == null) return widget.repositorio.pagos;
    return widget.repositorio.pagos.where((p) => p.estado == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repositorio,
      builder: (context, _) {
        final lista = _lista;
        final pagos = widget.repositorio.pagos;
        final cobrado = pagos.where((p) => p.estado == EstadoPago.pagado).fold<double>(0, (s, p) => s + p.importe);
        final pendiente = pagos.where((p) => p.estado == EstadoPago.pendiente).fold<double>(0, (s, p) => s + p.importe);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EncabezadoPagina(
              titulo: 'Pagos',
              subtitulo: 'Registro, validación y consulta de cobros por servicio (RF07, RN08)',
              accion: FilledButton.icon(
                onPressed: () => _formulario(context),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Nuevo pago'),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3.5,
              children: [
                _MiniKpi(titulo: 'Total cobrado', valor: 'S/ ${cobrado.toStringAsFixed(2)}', icono: Icons.payments_outlined, color: AppColores.verde),
                _MiniKpi(titulo: 'Por cobrar', valor: 'S/ ${pendiente.toStringAsFixed(2)}', icono: Icons.hourglass_empty, color: AppColores.naranja),
                _MiniKpi(titulo: 'Pagos registrados', valor: '${pagos.length}', icono: Icons.receipt_long_outlined, color: AppColores.primary),
              ],
            ),
            const SizedBox(height: 20),
            Tarjeta(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Wrap(
                spacing: 8,
                children: [
                  _Filtro(label: 'Todos', activo: _filtro == null, onTap: () => setState(() => _filtro = null)),
                  for (final e in EstadoPago.values)
                    _Filtro(label: e.label, activo: _filtro == e, color: e.color, onTap: () => setState(() => _filtro = e)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Tarjeta(
              padding: EdgeInsets.zero,
              child: lista.isEmpty
                  ? const EstadoVacio(mensaje: 'No hay pagos con el estado seleccionado')
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        headingTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColores.textoSecundario),
                        dataTextStyle: const TextStyle(fontSize: 12, color: AppColores.texto),
                        columnSpacing: 22,
                        columns: const [
                          DataColumn(label: Text('CÓDIGO')),
                          DataColumn(label: Text('ENVÍO')),
                          DataColumn(label: Text('CLIENTE')),
                          DataColumn(label: Text('IMPORTE')),
                          DataColumn(label: Text('MÉTODO')),
                          DataColumn(label: Text('FECHA')),
                          DataColumn(label: Text('ESTADO')),
                          DataColumn(label: Text('')),
                        ],
                        rows: [
                          for (final p in lista)
                            DataRow(
                              cells: [
                                DataCell(celda(p.id, peso: FontWeight.w700, color: AppColores.primary)),
                                DataCell(celda(p.envioId, peso: FontWeight.w600)),
                                DataCell(celda(_clienteDeEnvio(p.envioId))),
                                DataCell(celda('S/ ${p.importe.toStringAsFixed(2)}', peso: FontWeight.w700)),
                                DataCell(celda(p.metodo)),
                                DataCell(celda(_fechaCorta(p.fecha))),
                                DataCell(ChipPago(p.estado)),
                                DataCell(IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit_outlined, size: 17, color: AppColores.primary),
                                  onPressed: () => _formulario(context, p),
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

  String _clienteDeEnvio(String envioId) {
    final envio = widget.repositorio.envios.where((e) => e.id == envioId);
    return envio.isEmpty ? envioId : widget.repositorio.nombreCliente(envio.first.clienteId);
  }

  String _fechaCorta(DateTime f) => '${f.day.toString().padLeft(2, '0')}/${f.month.toString().padLeft(2, '0')}/${f.year}';

  void _formulario(BuildContext context, [Pago? pago]) {
    final repo = widget.repositorio;
    final formKey = GlobalKey<FormState>();
    final envioId = TextEditingController(text: pago?.envioId ?? repo.envios.first.id);
    final importe = TextEditingController(text: pago?.importe.toString() ?? '');
    final metodo = TextEditingController(text: pago?.metodo ?? 'Efectivo');
    EstadoPago estado = pago?.estado ?? EstadoPago.pendiente;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(pago == null ? 'Nuevo pago' : 'Editar pago ${pago.id}'),
          content: SizedBox(
            width: 440,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: envioId.text,
                    decoration: const InputDecoration(labelText: 'Envío asociado *'),
                    items: [for (final e in repo.envios) DropdownMenuItem(value: e.id, child: Text('${e.id} · ${e.origen} → ${e.destino}'))],
                    onChanged: (v) => envioId.text = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  CampoTexto(controlador: importe, etiqueta: 'Importe (S/)', teclado: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 12),
                  CampoTexto(controlador: metodo, etiqueta: 'Método de pago'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<EstadoPago>(
                    initialValue: estado,
                    decoration: const InputDecoration(labelText: 'Estado del pago'),
                    items: [for (final e in EstadoPago.values) DropdownMenuItem(value: e, child: Text(e.label))],
                    onChanged: (v) => setStateDialog(() => estado = v ?? EstadoPago.pendiente),
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
                final monto = parseMonto(importe.text);
                if (monto < 0) {
                  mostrarMensaje(ctx, 'RN06: el importe no puede ser negativo', error: true);
                  return;
                }
                if (pago == null) {
                  repo.agregarPago(Pago(
                    id: repo.nuevoPagoId(),
                    envioId: envioId.text,
                    importe: monto,
                    metodo: metodo.text.trim(),
                    estado: estado,
                    fecha: DateTime.now(),
                  ));
                  mostrarMensaje(context, 'Pago registrado');
                } else {
                  repo.actualizarPago(pago,
                      importe: monto, metodo: metodo.text.trim(), estado: estado);
                  mostrarMensaje(context, 'Pago actualizado');
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
              Text(valor, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ],
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
        decoration: BoxDecoration(color: activo ? c : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: activo ? Colors.white : AppColores.textoSecundario)),
      ),
    );
  }
}
