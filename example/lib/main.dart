import 'package:flutter/material.dart';
import 'package:paywall_flutter/paywall_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paywall Overlay Demo',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final PaywallController _controller = PaywallController();
  PaywallEffect _effect = PaywallEffect.gradient;
  bool _enabled = true;
  bool _blockInteractions = false; // ejemplo NO bloquea clics

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      // Mantén el Switch sincronizado con enable()/disable() del controller
      setState(() => _enabled = _controller.enabled);
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
      appBar: AppBar(title: const Text('Paywall Overlay Demo')),
      body: PaywallFlutter(
        controller: _controller,
        dueDate: dueDate,
        daysDeadline: 10,
        effect: _effect,
        enabled: _enabled,
        blockInteractions: _blockInteractions,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Demo contenido. Ajusta las opciones abajo para ver el efecto.',
              style: TextStyle(fontSize: 16),
            ),
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
            const SizedBox(height: 16),
            Row(children: [
              const Text('Paywall'),
              Switch(
                value: _enabled,
                onChanged: (v) => setState(() => _enabled = v),
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
            const Text('Switch deshabilitado (solo lectura)'),
            Row(children: [
              const Text('Paywall (readonly)'),
              Switch(
                value: _enabled,
                onChanged: null,
              ),
            ]),
            const SizedBox(height: 32),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange, Colors.deepOrange],
                ),
              ),
              child: const Center(
                child: Text(
                  'Contenido de ejemplo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
