import 'package:flutter/material.dart';

import '../comunes.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final TextEditingController _busqueda = TextEditingController();

  List<Cliente> get _lista {
    final q = _busqueda.text.toLowerCase().trim();
    if (q.isEmpty) return widget.repositorio.clientes;
    return widget.repositorio.clientes.where((c) =>
        c.nombre.toLowerCase().contains(q) || c.documento.contains(q) || c.correo.toLowerCase().contains(q)).toList();
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
              titulo: 'Clientes',
              subtitulo: 'Información de contacto, dirección e historial de envíos (RF01, RN01)',
              accion: FilledButton.icon(
                onPressed: () => _formulario(context),
                icon: const Icon(Icons.person_add_outlined, size: 17),
                label: const Text('Nuevo cliente'),
              ),
            ),
            const SizedBox(height: 20),
            Tarjeta(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Buscador(controlador: _busqueda, etiqueta: 'Buscar cliente...', onChanged: (_) => setState(() {})),
                  const Spacer(),
                  Etiqueta('${lista.length} registros'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Tarjeta(
              padding: EdgeInsets.zero,
              child: lista.isEmpty
                  ? const EstadoVacio(mensaje: 'No se encontraron clientes')
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        headingTextStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColores.textoSecundario),
                        dataTextStyle: const TextStyle(fontSize: 12, color: AppColores.texto),
                        columnSpacing: 22,
                        columns: const [
                          DataColumn(label: Text('CÓDIGO')),
                          DataColumn(label: Text('NOMBRE')),
                          DataColumn(label: Text('DOCUMENTO')),
                          DataColumn(label: Text('TELÉFONO')),
                          DataColumn(label: Text('CORREO')),
                          DataColumn(label: Text('DIRECCIÓN')),
                          DataColumn(label: Text('ENVÍOS')),
                          DataColumn(label: Text('')),
                        ],
                        rows: [
                          for (final c in lista)
                            DataRow(
                              cells: [
                                DataCell(celda(c.id, peso: FontWeight.w700, color: AppColores.primary)),
                                DataCell(celda(c.nombre, peso: FontWeight.w600)),
                                DataCell(celda(c.documento)),
                                DataCell(celda(c.telefono)),
                                DataCell(celda(c.correo)),
                                DataCell(celda(c.direccion)),
                                DataCell(celda('${widget.repositorio.envios.where((e) => e.clienteId == c.id).length}')),
                                DataCell(IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit_outlined, size: 17, color: AppColores.primary),
                                  onPressed: () => _formulario(context, c),
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

  void _formulario(BuildContext context, [Cliente? cliente]) {
    final repo = widget.repositorio;
    final formKey = GlobalKey<FormState>();
    final nombre = TextEditingController(text: cliente?.nombre ?? '');
    final documento = TextEditingController(text: cliente?.documento ?? '');
    final telefono = TextEditingController(text: cliente?.telefono ?? '');
    final correo = TextEditingController(text: cliente?.correo ?? '');
    final direccion = TextEditingController(text: cliente?.direccion ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(cliente == null ? 'Nuevo cliente' : 'Editar cliente ${cliente.id}'),
        content: SizedBox(
          width: 480,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampoTexto(controlador: nombre, etiqueta: 'Nombre completo'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CampoTexto(controlador: documento, etiqueta: 'Documento')),
                    const SizedBox(width: 12),
                    Expanded(child: CampoTexto(controlador: telefono, etiqueta: 'Teléfono')),
                  ],
                ),
                const SizedBox(height: 12),
                CampoTexto(controlador: correo, etiqueta: 'Correo', teclado: TextInputType.emailAddress),
                const SizedBox(height: 12),
                CampoTexto(controlador: direccion, etiqueta: 'Dirección'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              if (cliente == null) {
                repo.agregarCliente(Cliente(
                  id: repo.nuevoClienteId(),
                  nombre: nombre.text.trim(),
                  documento: documento.text.trim(),
                  telefono: telefono.text.trim(),
                  correo: correo.text.trim(),
                  direccion: direccion.text.trim(),
                ));
                mostrarMensaje(context, 'Cliente registrado correctamente');
              } else {
                repo.actualizarCliente(
                  cliente,
                  nombre: nombre.text.trim(),
                  documento: documento.text.trim(),
                  telefono: telefono.text.trim(),
                  correo: correo.text.trim(),
                  direccion: direccion.text.trim(),
                );
                mostrarMensaje(context, 'Cliente actualizado');
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
