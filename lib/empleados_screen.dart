import 'package:flutter/material.dart';

import '../comunes.dart';
import '../models.dart';
import '../repositorio.dart';
import '../tema.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key, required this.repositorio});

  final Repositorio repositorio;

  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  final TextEditingController _busqueda = TextEditingController();

  List<Empleado> get _lista {
    final q = _busqueda.text.toLowerCase().trim();
    if (q.isEmpty) return widget.repositorio.empleados;
    return widget.repositorio.empleados.where((e) =>
        e.nombre.toLowerCase().contains(q) || e.cargo.toLowerCase().contains(q)).toList();
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
              titulo: 'Empleados',
              subtitulo: 'Personal de la empresa, cargos y responsabilidades (RF02, RN02)',
              accion: FilledButton.icon(
                onPressed: () => _formulario(context),
                icon: const Icon(Icons.person_add_outlined, size: 17),
                label: const Text('Nuevo empleado'),
              ),
            ),
            const SizedBox(height: 20),
            Tarjeta(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Buscador(controlador: _busqueda, etiqueta: 'Buscar empleado...', onChanged: (_) => setState(() {})),
                  const Spacer(),
                  Etiqueta('${lista.length} registros'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Tarjeta(
              padding: EdgeInsets.zero,
              child: lista.isEmpty
                  ? const EstadoVacio(mensaje: 'No se encontraron empleados')
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
                          DataColumn(label: Text('CARGO')),
                          DataColumn(label: Text('CORREO')),
                          DataColumn(label: Text('TELÉFONO')),
                          DataColumn(label: Text('ENVÍOS A CARGO')),
                          DataColumn(label: Text('')),
                        ],
                        rows: [
                          for (final e in lista)
                            DataRow(
                              cells: [
                                DataCell(celda(e.id, peso: FontWeight.w700, color: AppColores.primary)),
                                DataCell(celda(e.nombre, peso: FontWeight.w600)),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColores.primaryLight, borderRadius: BorderRadius.circular(6)),
                                  child: celda(e.cargo, color: AppColores.primary, peso: FontWeight.w600),
                                )),
                                DataCell(celda(e.correo)),
                                DataCell(celda(e.telefono)),
                                DataCell(celda('${widget.repositorio.envios.where((x) => x.empleadoId == e.id).length}')),
                                DataCell(IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit_outlined, size: 17, color: AppColores.primary),
                                  onPressed: () => _formulario(context, e),
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

  void _formulario(BuildContext context, [Empleado? empleado]) {
    final repo = widget.repositorio;
    final formKey = GlobalKey<FormState>();
    final nombre = TextEditingController(text: empleado?.nombre ?? '');
    final cargo = TextEditingController(text: empleado?.cargo ?? '');
    final correo = TextEditingController(text: empleado?.correo ?? '');
    final telefono = TextEditingController(text: empleado?.telefono ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(empleado == null ? 'Nuevo empleado' : 'Editar empleado ${empleado.id}'),
        content: SizedBox(
          width: 460,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampoTexto(controlador: nombre, etiqueta: 'Nombre completo'),
                const SizedBox(height: 12),
                CampoTexto(controlador: cargo, etiqueta: 'Cargo'),
                const SizedBox(height: 12),
                CampoTexto(controlador: correo, etiqueta: 'Correo', teclado: TextInputType.emailAddress),
                const SizedBox(height: 12),
                CampoTexto(controlador: telefono, etiqueta: 'Teléfono'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              if (empleado == null) {
                repo.agregarEmpleado(Empleado(
                  id: repo.nuevoEmpleadoId(),
                  nombre: nombre.text.trim(),
                  cargo: cargo.text.trim(),
                  correo: correo.text.trim(),
                  telefono: telefono.text.trim(),
                ));
                mostrarMensaje(context, 'Empleado registrado correctamente');
              } else {
                repo.actualizarEmpleado(
                  empleado,
                  nombre: nombre.text.trim(),
                  cargo: cargo.text.trim(),
                  correo: correo.text.trim(),
                  telefono: telefono.text.trim(),
                );
                mostrarMensaje(context, 'Empleado actualizado');
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
