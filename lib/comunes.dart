import 'package:flutter/material.dart';

import '../models.dart';
import '../tema.dart';

class EncabezadoPagina extends StatelessWidget {
  const EncabezadoPagina({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.accion,
  });

  final String titulo;
  final String subtitulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(subtitulo, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13)),
            ],
          ),
        ),
        ?accion,
      ],
    );
  }
}

class Tarjeta extends StatelessWidget {
  const Tarjeta({super.key, required this.child, this.padding = const EdgeInsets.all(20)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColores.tarjeta,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColores.borde),
        boxShadow: [sombraTarjeta],
      ),
      child: child,
    );
  }
}

class TituloTarjeta extends StatelessWidget {
  const TituloTarjeta({super.key, required this.titulo, this.accion});

  final String titulo;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(titulo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColores.texto)),
        ),
        ?accion,
      ],
    );
  }
}

class ChipEstado extends StatelessWidget {
  const ChipEstado(this.estado, {super.key});

  final EstadoEnvio estado;

  @override
  Widget build(BuildContext context) {
    final color = estado.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(estado.icon, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(estado.label, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class ChipPago extends StatelessWidget {
  const ChipPago(this.estado, {super.key});

  final EstadoPago estado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: estado.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(estado.label, style: TextStyle(color: estado.color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, this.color = AppColores.textoSecundario});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(texto.toUpperCase(), style: TextStyle(fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.w700, color: color));
  }
}

class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controlador,
    required this.etiqueta,
    this.obligatorio = true,
    this.teclado,
    this.maxLineas = 1,
  });

  final TextEditingController controlador;
  final String etiqueta;
  final bool obligatorio;
  final TextInputType? teclado;
  final int maxLineas;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      keyboardType: teclado,
      maxLines: maxLineas,
      decoration: InputDecoration(labelText: obligatorio ? '$etiqueta *' : etiqueta),
      validator: obligatorio
          ? (valor) => valor == null || valor.trim().isEmpty ? 'Ingrese $etiqueta' : null
          : null,
    );
  }
}

class Buscador extends StatelessWidget {
  const Buscador({super.key, required this.controlador, required this.etiqueta, this.onChanged});

  final TextEditingController controlador;
  final String etiqueta;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: TextField(
        controller: controlador,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: etiqueta,
          prefixIcon: const Icon(Icons.search, size: 18, color: AppColores.textoSecundario),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class EstadoVacio extends StatelessWidget {
  const EstadoVacio({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 42, color: AppColores.borde),
          const SizedBox(height: 12),
          Text(mensaje, style: const TextStyle(color: AppColores.textoSecundario, fontSize: 13)),
        ],
      ),
    );
  }
}

Future<void> mostrarMensaje(BuildContext context, String mensaje, {bool error = false}) async {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(error ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: error ? AppColores.rojo : AppColores.verde,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

Widget celda(String texto, {FontWeight peso = FontWeight.normal, Color color = AppColores.texto}) => Text(
      texto,
      style: TextStyle(fontSize: 12.5, fontWeight: peso, color: color),
    );

Widget encabezadoTabla(String texto) => Text(
      texto.toUpperCase(),
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColores.textoSecundario, letterSpacing: 0.6),
    );

double parseMonto(String valor) => double.tryParse(valor.replaceAll(',', '.')) ?? 0;
