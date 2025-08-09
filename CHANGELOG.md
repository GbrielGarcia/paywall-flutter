# Changelog
# Changelog

## 0.1.2
- Corrección de metadatos en `pubspec.yaml`: URLs de `homepage`, `repository` e `issue_tracker` apuntando a `paywall-flutter`.

## 0.1.1
- Documentación mejorada en español (README, dartdoc en API pública).
- Regla `public_member_api_docs` habilitada.
- Separación de controles en el ejemplo readonly para evitar bloqueo involuntario.
- Nombre de paquete `paywall_flutter` e imports actualizados en ejemplos.

## 0.1.0
- Primera publicación del paquete.
- `PaywallOverlay` (Dart puro) con efectos: `gradient`, `solid`, `fade`.
- Cálculo lineal de opacidad según `dueDate` y `daysDeadline`.
- Control en tiempo de ejecución vía `PaywallController` (`enable()`, `disable()`).
- `blockInteractions` opcional para bloquear clics/toques.
- `showMessage` y `message` para texto superpuesto.
- Ejemplos incluidos: principal y `example_readonly`.
