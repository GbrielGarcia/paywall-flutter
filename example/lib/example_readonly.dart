import 'package:flutter/material.dart';
import 'package:paywall_flutter/paywall_overlay.dart';

void main() {
  runApp(const ReadonlyExampleApp());
}

class ReadonlyExampleApp extends StatelessWidget {
  const ReadonlyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paywall Overlay - Readonly Switch Example',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const ReadonlyDemoPage(),
    );
  }
}

class ReadonlyDemoPage extends StatefulWidget {
  const ReadonlyDemoPage({super.key});

  @override
  State<ReadonlyDemoPage> createState() => _ReadonlyDemoPageState();
}

class _ReadonlyDemoPageState extends State<ReadonlyDemoPage> {
  final PaywallController _controller = PaywallController();
  PaywallEffect _effect = PaywallEffect.gradient;
  bool _enabled = true; // reflejado en el switch readonly
  bool _blockInteractions = true; // ejemplo SÍ bloquea clics por defecto

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _enabled = _controller.enabled;
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.now().subtract(const Duration(days: 5));

    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplo: Switch inhabilitado')),
      body: Column(
        children: [
          // Controles fuera del overlay para que no se bloqueen
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Este ejemplo muestra el Paywall con un Switch inhabilitado (solo lectura). '
                  'Controla el estado usando los botones Enable/Disable.',
                ),
                const SizedBox(height: 16),
                Row(children: [
                  const Text('Paywall (readonly): '),
                  Switch(value: _enabled, onChanged: null),
                  const SizedBox(width: 16),
                  const Text('Bloquear clicks'),
                  Switch(
                    value: _blockInteractions,
                    onChanged: (v) => setState(() => _blockInteractions = v),
                  ),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton(
                    onPressed: () => _controller.disable(),
                    child: const Text('Disable()'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _controller.enable(),
                    child: const Text('Enable()'),
                  ),
                ]),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Gradient'),
                      selected: _effect == PaywallEffect.gradient,
                      onSelected: (_) =>
                          setState(() => _effect = PaywallEffect.gradient),
                    ),
                    FilterChip(
                      label: const Text('Solid'),
                      selected: _effect == PaywallEffect.solid,
                      onSelected: (_) =>
                          setState(() => _effect = PaywallEffect.solid),
                    ),
                    FilterChip(
                      label: const Text('Fade'),
                      selected: _effect == PaywallEffect.fade,
                      onSelected: (_) =>
                          setState(() => _effect = PaywallEffect.fade),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Contenido bajo overlay
          Expanded(
            child: PaywallFlutter(
              controller: _controller,
              dueDate: dueDate,
              daysDeadline: 10,
              effect: _effect,
              enabled: _enabled,
              blockInteractions: _blockInteractions,
              child: Center(
                child: Container(
                  height: 200,
                  width: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.indigo, Colors.blueGrey],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Contenido de ejemplo (readonly)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Para ejecutar este ejemplo:\nflutter run -t lib/example_readonly.dart',
              style: TextStyle(
                  fontSize: 12, color: Color.fromARGB(137, 226, 120, 120)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
