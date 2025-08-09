/// Biblioteca principal del paquete paywall_flutter.
///
/// Proporciona el widget [PaywallOverlay], el controlador [PaywallController]
/// y utilidades como [computeOpacity] para aplicar un recordatorio visual de
/// pago vencido sobre una interfaz Flutter.
library paywall_overlay;

import 'dart:async';
import 'package:flutter/material.dart';

/// Efectos visuales disponibles para el paywall.
enum PaywallEffect {
  /// Gradiente superpuesto cuya intensidad aumenta con el atraso.
  gradient,

  /// Capa sólida cuyo oscurecimiento aumenta con el atraso.
  solid,

  /// Disminuye la opacidad del contenido directamente.
  fade,
}

/// Controlador para habilitar o deshabilitar el paywall en tiempo de ejecución.
class PaywallController extends ChangeNotifier {
  bool _enabled = true;
  bool get enabled => _enabled;

  /// Habilita el paywall y notifica a los oyentes.
  void enable() {
    if (!_enabled) {
      _enabled = true;
      notifyListeners();
    }
  }

  /// Deshabilita el paywall y notifica a los oyentes.
  void disable() {
    if (_enabled) {
      _enabled = false;
      notifyListeners();
    }
  }
}

/// Calcula la opacidad (0..1) en función de la fecha de vencimiento y el plazo.
///
/// - Retorna 1.0 si aún no hay atraso.
/// - Decrece linealmente hasta 0.0 cuando `daysDeadline` días de atraso se cumplen.
double computeOpacity({
  required DateTime dueDate,
  required int daysDeadline,
  DateTime? now,
}) {
  final DateTime current = now ?? DateTime.now().toUtc();
  final DateTime dueUtc = DateTime.utc(
    dueDate.year,
    dueDate.month,
    dueDate.day,
  );
  final DateTime currentUtc = DateTime.utc(
    current.year,
    current.month,
    current.day,
  );

  final int days = currentUtc.difference(dueUtc).inDays;
  if (days <= 0) return 1.0;

  final int daysLate = daysDeadline - days;
  double opacity = daysLate / daysDeadline;
  if (opacity < 0) opacity = 0;
  if (opacity > 1) opacity = 1;
  return opacity;
}

/// Widget que superpone un efecto visual para recordar pagos vencidos.
class PaywallOverlay extends StatefulWidget {
  final Widget child;

  /// Fecha de vencimiento del pago.
  final DateTime dueDate;

  /// Días para alcanzar la máxima intensidad del efecto.
  final int daysDeadline;

  /// Tipo de efecto visual a aplicar.
  final PaywallEffect effect;

  /// Color para el efecto sólido.
  final Color color;

  /// Color inicial del gradiente.
  final Color gradientFrom;

  /// Color final del gradiente.
  final Color gradientTo;

  /// Si es falso, el efecto no se aplica.
  final bool enabled;

  /// Si es verdadero, bloquea interacciones bajo el overlay.
  final bool blockInteractions;

  /// Muestra un mensaje centrado sobre el overlay.
  final bool showMessage;

  /// Texto del mensaje a mostrar.
  final String message;

  /// Controlador opcional para controlar el estado en runtime.
  final PaywallController? controller;

  /// Recalcula automáticamente al cruzar medianoche.
  final bool recalculateOnMidnight;

  const PaywallOverlay({
    super.key,
    required this.child,
    required this.dueDate,
    this.daysDeadline = 60,
    this.effect = PaywallEffect.gradient,
    this.color = const Color(0xFFFF0000),
    this.gradientFrom = const Color(0xFFFF0000),
    this.gradientTo = const Color(0xFF000000),
    this.enabled = true,
    this.blockInteractions = false,
    this.showMessage = true,
    this.message = 'Pago pendiente',
    this.controller,
    this.recalculateOnMidnight = false,
  });

  @override
  State<PaywallOverlay> createState() => _PaywallOverlayState();
}

class _PaywallOverlayState extends State<PaywallOverlay> {
  late bool _enabled;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _enabled = widget.enabled;
    widget.controller?.addListener(_onControllerChange);
    if (widget.recalculateOnMidnight) _scheduleMidnightTick();
  }

  @override
  void didUpdateWidget(covariant PaywallOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChange);
      widget.controller?.addListener(_onControllerChange);
    }
    if (oldWidget.enabled != widget.enabled) {
      setState(() => _enabled = widget.enabled);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChange);
    _midnightTimer?.cancel();
    super.dispose();
  }

  void _onControllerChange() {
    final controller = widget.controller;
    if (controller == null) return;
    setState(() => _enabled = controller.enabled);
  }

  void _scheduleMidnightTick() {
    final now = DateTime.now();
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final duration = nextMidnight.difference(now);
    _midnightTimer?.cancel();
    _midnightTimer = Timer(duration, () {
      if (!mounted) return;
      setState(() {});
      _scheduleMidnightTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = computeOpacity(
      dueDate: widget.dueDate,
      daysDeadline: widget.daysDeadline,
    );

    if (!_enabled) {
      return widget.child;
    }

    switch (widget.effect) {
      case PaywallEffect.fade:
        if (widget.blockInteractions) {
          return Stack(
            children: [
              AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: widget.child,
              ),
              // Capa transparente para bloquear interacciones cuando se solicita
              const Positioned.fill(
                child: AbsorbPointer(
                  absorbing: true,
                  child: ColoredBox(color: Colors.transparent),
                ),
              ),
            ],
          );
        }
        return AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: widget.child,
        );
      case PaywallEffect.solid:
      case PaywallEffect.gradient:
        return Stack(
          children: [
            widget.child,
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: widget.blockInteractions,
                child: Opacity(
                  opacity: 1 - opacity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: widget.effect == PaywallEffect.gradient
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [widget.gradientFrom, widget.gradientTo],
                            )
                          : null,
                      color: widget.effect == PaywallEffect.solid
                          ? widget.color
                          : null,
                    ),
                    child: Center(
                      child: widget.showMessage
                          ? Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(2, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
}
