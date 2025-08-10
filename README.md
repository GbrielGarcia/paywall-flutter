# paywall_flutter

Recordatorio visual de pagos vencidos para Flutter (Dart puro). Aplica efectos sobre tu UI cuando la fecha de pago está vencida: gradiente, sólido o fade. Incluye control en tiempo de ejecución y opción para bloquear interacciones.

## Instalación

Agrega al `pubspec.yaml` de tu app:

```yaml
dependencies:
  paywall_flutter: ^0.1.2
```

## Uso básico

```dart
import 'package:paywall_flutter/paywall_overlay.dart';

PaywallFlutter(
  child: MyHomePage(),
  dueDate: DateTime(2025, 7, 15),
  daysDeadline: 10,
  effect: PaywallEffect.gradient, // gradient | solid | fade
);
```

## Opciones

- child (Widget, requerido): contenido a cubrir.
- dueDate (DateTime, requerido): fecha de vencimiento del pago.
- daysDeadline (int, predeterminado 60): días hasta alcanzar intensidad máxima del efecto.
- effect (PaywallEffect, predeterminado gradient): `gradient` | `solid` | `fade`.
- color (Color, predeterminado rojo): color para el efecto sólido.
- gradientFrom (Color, predeterminado rojo): color inicial del gradiente.
- gradientTo (Color, predeterminado negro): color final del gradiente.
- enabled (bool, predeterminado true): habilita/deshabilita el efecto.
- blockInteractions (bool, predeterminado false): bloquea clics/toques bajo el overlay.
- showMessage (bool, predeterminado true): muestra un mensaje en el overlay.
- message (String, predeterminado "Pago pendiente"): texto del mensaje.
- controller (PaywallController?): permite `enable()`/`disable()` en runtime.
- recalculateOnMidnight (bool, predeterminado false): recalcula al cruzar medianoche.

### Control en tiempo de ejecución

```dart
final controller = PaywallController();

PaywallFlutter(
  controller: controller,
  child: MyHomePage(),
  dueDate: DateTime(2025, 7, 15),
);

// En tiempo de ejecución
controller.disable(); // apaga efecto
controller.enable();  // enciende efecto
```

## Ejemplos

Este paquete incluye dos ejemplos:

- Ejemplo principal (sin bloqueo de clics):
  ```bash
  flutter run
  ```
- Ejemplo con switch deshabilitado y opción de bloquear interacciones:
  ```bash
  flutter run -t lib/example_readonly.dart
  ```

## Notas

- El cálculo de opacidad es lineal: desde casi 1 el primer día de atraso, hasta 0 al cumplir `daysDeadline`.
- `fade` reduce opacidad del contenido; si `blockInteractions` es true, también puede bloquear interacciones con una capa transparente.

## Licencia

MIT

## Autoría y soporte

- Desarrollado por: [Alberto Guaman](https://www.linkedin.com/in/albertoguaman/)
- Apoyado por: [Tinguar](https://www.tinguar.com)
