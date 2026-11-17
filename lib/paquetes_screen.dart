import 'package:flutter/material.dart';

import '../comunes.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class PaquetesScreen extends StatefulWidget {
  const PaquetesScreen({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  State<PaquetesScreen> createState() => _PaquetesScreenState();
}

class _PaquetesScreenState extends State<PaquetesScreen> {
  final TextEditingController _busqueda = TextEditingController();

  List<Paquete> get _lista {
    final q = _busqueda.text.toLowerCase().trim();
    if (q.isEmpty) return widget.repositorio.paquetes;
    return widget.repositorio.paquetes.where((p) =>
        p.id.toLowerCase().contains(q) ||
        p.envioId.toLowerCase().contains(q) ||
        p.descripcion.toLowerCase().contains(q)).toList();
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
        final pesoTotal = widget.repositorio.paquetes.fold<double>(0, (s, p) => s + p.peso);
        final valorTotal = widget.repositorio.paquetes.fold<double>(0, (s, p) => s + p.valorDeclarado);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EncabezadoPagina(
              titulo: 'Paquetes',
              subtitulo: 'Unidades transportadas: peso, dimensiones y valor declarado (RF04, RN05)',
              accion: FilledButton.icon(
                onPressed: () => _formulario(context),
                icon: const Icon(Icons.add, size: 17),
                label: const Text('Nuevo paquete'),
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
                _MiniKpi(titulo: 'Paquetes registrados', valor: '${widget.repositorio.paquetes.length}', icono: Icons.inventory_2_outlined, color: AppColores.primary),
                _MiniKpi(titulo: 'Peso total', valor: '${pesoTotal.toStringAsFixed(1)} kg', icono: Icons.scale_outlined, color: AppColores.naranja),
                _MiniKpi(titulo: 'Valor declarado', valor: 'S/ ${valorTotal.toStringAsFixed(2)}', icono: Icons.attach_money, color: AppColores.verde),
              ],
            ),
            const SizedBox(height: 20),
            Tarjeta(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Buscador(controlador: _busqueda, etiqueta: 'Buscar paquete o envío...', onChanged: (_) => setState(() {})),
                  const Spacer(),
                  Etiqueta('${lista.length} registros'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Tarjeta(
              padding: EdgeInsets.zero,
              child: lista.isEmpty
                  ? const EstadoVacio(mensaje: 'No se encontraron paquetes')
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
                          DataColumn(label: Text('DESCRIPCIÓN')),
                          DataColumn(label: Text('PESO')),
                          DataColumn(label: Text('DIMENSIONES')),
                          DataColumn(label: Text('VALOR DECLARADO')),
                          DataColumn(label: Text('')),
                        ],
                        rows: [
                          for (final p in lista)
                            DataRow(
                              cells: [
                                DataCell(celda(p.id, peso: FontWeight.w700, color: AppColores.primary)),
                                DataCell(celda(p.envioId, peso: FontWeight.w600)),
                                DataCell(celda(p.descripcion)),
                                DataCell(celda('${p.peso.toStringAsFixed(1)} kg')),
                                DataCell(celda(p.dimensiones)),
                                DataCell(celda('S/ ${p.valorDeclarado.toStringAsFixed(2)}')),
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

  void _formulario(BuildContext context, [Paquete? paquete]) {
    final repo = widget.repositorio;
    final formKey = GlobalKey<FormState>();
    final envioId = TextEditingController(text: paquete?.envioId ?? repo.envios.first.id);
    final descripcion = TextEditingController(text: paquete?.descripcion ?? '');
    final peso = TextEditingController(text: paquete?.peso.toString() ?? '');
    final dimensiones = TextEditingController(text: paquete?.dimensiones ?? '');
    final valor = TextEditingController(text: paquete?.valorDeclarado.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(paquete == null ? 'Nuevo paquete' : 'Editar paquete ${paquete.id}'),
        content: SizedBox(
          width: 480,
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
                CampoTexto(controlador: descripcion, etiqueta: 'Descripción'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CampoTexto(controlador: peso, etiqueta: 'Peso (kg)', teclado: const TextInputType.numberWithOptions(decimal: true))),
                    const SizedBox(width: 12),
                    Expanded(child: CampoTexto(controlador: dimensiones, etiqueta: 'Dimensiones')),
                  ],
                ),
                const SizedBox(height: 12),
                CampoTexto(controlador: valor, etiqueta: 'Valor declarado (S/)', teclado: const TextInputType.numberWithOptions(decimal: true)),
              ],
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
              if (v < 0) {
                mostrarMensaje(ctx, 'RN06: el valor declarado no puede ser negativo', error: true);
                return;
              }
              if (paquete == null) {
                repo.agregarPaquete(Paquete(
                  id: repo.nuevoPaqueteId(),
                  envioId: envioId.text,
                  descripcion: descripcion.text.trim(),
                  peso: p,
                  dimensiones: dimensiones.text.trim(),
                  valorDeclarado: v,
                ));
                mostrarMensaje(context, 'Paquete registrado');
              } else {
                repo.actualizarPaquete(paquete,
                    descripcion: descripcion.text.trim(), peso: p, dimensiones: dimensiones.text.trim(), valorDeclarado: v);
                mostrarMensaje(context, 'Paquete actualizado');
              }
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
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
