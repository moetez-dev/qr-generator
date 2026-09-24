// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ChangeNotifierProvider(
      create: (_) => QrState(prefs), child: const QrApp()));
}

class QrItem {
  const QrItem({required this.data, required this.createdAt});
  final String data;
  final DateTime createdAt;
  Map<String, dynamic> toJson() =>
      {'data': data, 'createdAt': createdAt.toIso8601String()};
  factory QrItem.fromJson(Map<String, dynamic> json) => QrItem(
      data: json['data'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String));
}

class QrState extends ChangeNotifier {
  QrState(this._prefs) {
    _dark = _prefs.getBool('dark') ?? false;
    final stored = _prefs.getStringList('history') ?? <String>[];
    for (final value in stored) {
      final parts = value.split('|');
      if (parts.length == 2)
        _history.add(QrItem(
            data: parts[0],
            createdAt: DateTime.tryParse(parts[1]) ?? DateTime.now()));
    }
  }
  final SharedPreferences _prefs;
  final List<QrItem> _history = <QrItem>[];
  bool _dark = false;
  Color foreground = const Color(0xff111827);
  Color background = Colors.white;
  int errorCorrection = QrErrorCorrectLevel.M;
  double size = 280;
  double margin = 12;
  bool get dark => _dark;
  List<QrItem> get history => List.unmodifiable(_history);
  void setDark(bool value) {
    _dark = value;
    _prefs.setBool('dark', value);
    notifyListeners();
  }

  void addHistory(String data) {
    _history.removeWhere((item) => item.data == data);
    _history.insert(0, QrItem(data: data, createdAt: DateTime.now()));
    if (_history.length > 30) _history.removeLast();
    _persistHistory();
    notifyListeners();
  }

  void removeHistory(QrItem item) {
    _history.remove(item);
    _persistHistory();
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    _persistHistory();
    notifyListeners();
  }

  void _persistHistory() => _prefs.setStringList(
      'history',
      _history
          .map((e) => '${e.data}|${e.createdAt.toIso8601String()}')
          .toList());
  void updateColors(Color fg, Color bg) {
    foreground = fg;
    background = bg;
    notifyListeners();
  }

  void updateOptions({int? correction, double? newSize, double? newMargin}) {
    if (correction != null) errorCorrection = correction;
    if (newSize != null) size = newSize;
    if (newMargin != null) margin = newMargin;
    notifyListeners();
  }
}

class QrApp extends StatelessWidget {
  const QrApp({super.key});
  @override
  Widget build(BuildContext context) => Consumer<QrState>(
      builder: (_, state, __) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'QR Generator',
          themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
          theme: _theme(Brightness.light),
          darkTheme: _theme(Brightness.dark),
          home: const HomeScreen()));
  ThemeData _theme(Brightness brightness) => ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: const Color(0xff6366f1),
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xfff8fafc)
          : const Color(0xff111827),
      inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(), filled: true));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  int _tab = 0;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: const Text('QR Generator',
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
                icon: const Icon(Icons.settings_outlined))
          ]),
      body: IndexedStack(index: _tab, children: [
        GeneratorView(controller: _controller),
        const HistoryView(),
        const AboutView()
      ]),
      bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (index) => setState(() => _tab = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'Create'),
            NavigationDestination(icon: Icon(Icons.history), label: 'History'),
            NavigationDestination(
                icon: Icon(Icons.info_outline), label: 'About')
          ]));
}

class GeneratorView extends StatelessWidget {
  const GeneratorView({super.key, required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) =>
      Consumer<QrState>(builder: (context, state, _) {
        final data = controller.text;
        return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create your QR code',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                      'Turn any text or link into a beautiful, shareable code.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  TextField(
                      controller: controller,
                      minLines: 3,
                      maxLines: 5,
                      onChanged: (_) => (context as Element).markNeedsBuild(),
                      decoration: const InputDecoration(
                          labelText: 'Content',
                          hintText: 'Paste a link, text, email, or anything...',
                          prefixIcon: Icon(Icons.edit_outlined))),
                  const SizedBox(height: 22),
                  if (data.trim().isNotEmpty)
                    _QrPreview(data: data)
                  else
                    const _EmptyPreview(),
                  const SizedBox(height: 18),
                  Wrap(spacing: 10, runSpacing: 10, children: [
                    FilledButton.icon(
                        onPressed: data.trim().isEmpty
                            ? null
                            : () {
                                context.read<QrState>().addHistory(data.trim());
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('QR code generated')));
                              },
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Generate QR')),
                    FilledButton.icon(
                        onPressed: data.trim().isEmpty
                            ? null
                            : () => _save(context, data),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Save PNG')),
                    OutlinedButton.icon(
                        onPressed: data.trim().isEmpty
                            ? null
                            : () => _share(context, data),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share')),
                    OutlinedButton.icon(
                        onPressed: data.trim().isEmpty
                            ? null
                            : () async {
                                await ClipboardService.copy(data);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Copied to clipboard')));
                                }
                              },
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copy')),
                    TextButton.icon(
                        onPressed: data.isEmpty
                            ? null
                            : () {
                                controller.clear();
                                (context as Element).markNeedsBuild();
                              },
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear')),
                  ]),
                  const SizedBox(height: 18),
                  _CustomizationCard(state: state),
                ]));
      });
  Future<void> _save(BuildContext context, String data) async {
    final bytes = await _render(data, context.read<QrState>());
    final dir = await getApplicationDocumentsDirectory();
    final file =
        File('${dir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    if (context.mounted) {
      context.read<QrState>().addHistory(data);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
    }
  }

  Future<void> _share(BuildContext context, String data) async {
    final bytes = await _render(data, context.read<QrState>());
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/qr_share.png');
    await file.writeAsBytes(bytes);
    await SharePlus.instance
        .share(ShareParams(text: data, files: [XFile(file.path)]));
    if (context.mounted) context.read<QrState>().addHistory(data);
  }
}

class _QrPreview extends StatelessWidget {
  const _QrPreview({required this.data});
  final String data;
  @override
  Widget build(BuildContext context) => Consumer<QrState>(
      builder: (_, s, __) => Card(
          child: Padding(
              padding: EdgeInsets.all(s.margin),
              child: Center(
                  child: QrImageView(
                      data: data,
                      size: s.size.clamp(160, 320),
                      eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square, color: s.foreground),
                      dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: s.foreground),
                      backgroundColor: s.background,
                      errorCorrectionLevel: s.errorCorrection)))));
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview();
  @override
  Widget build(BuildContext context) => Card(
      child: SizedBox(
          height: 230,
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.qr_code_2, size: 64),
            const SizedBox(height: 8),
            const Text('Your QR code will appear here')
          ]))));
}

class _CustomizationCard extends StatelessWidget {
  const _CustomizationCard({required this.state});
  final QrState state;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Customize',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Error correction'),
              const Spacer(),
              DropdownButton<int>(
                  value: state.errorCorrection,
                  items: const [
                    DropdownMenuItem(
                        value: QrErrorCorrectLevel.L, child: Text('Low')),
                    DropdownMenuItem(
                        value: QrErrorCorrectLevel.M, child: Text('Medium')),
                    DropdownMenuItem(
                        value: QrErrorCorrectLevel.Q, child: Text('Quartile')),
                    DropdownMenuItem(
                        value: QrErrorCorrectLevel.H, child: Text('High'))
                  ],
                  onChanged: (v) => state.updateOptions(correction: v))
            ]),
            Row(children: [
              const Text('Size'),
              Expanded(
                  child: Slider(
                      value: state.size,
                      min: 160,
                      max: 320,
                      divisions: 16,
                      onChanged: (v) => state.updateOptions(newSize: v)))
            ]),
            Row(children: [
              const Text('Margin'),
              Expanded(
                  child: Slider(
                      value: state.margin,
                      min: 0,
                      max: 32,
                      divisions: 16,
                      onChanged: (v) => state.updateOptions(newMargin: v)))
            ]),
            Row(children: [
              const Text('Colors'),
              const Spacer(),
              _ColorDot(
                  color: state.foreground, onTap: () => _pick(context, true)),
              const SizedBox(width: 12),
              _ColorDot(
                  color: state.background, onTap: () => _pick(context, false))
            ])
          ])));
  void _pick(BuildContext context, bool foreground) {
    final colors = [
      Colors.black,
      const Color(0xff1d4ed8),
      const Color(0xff7c3aed),
      const Color(0xffbe123c),
      Colors.white,
      const Color(0xfffef3c7)
    ];
    showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
                children: colors
                    .map((c) => _ColorDot(
                        color: c,
                        onTap: () {
                          state.updateColors(foreground ? c : state.foreground,
                              foreground ? state.background : c);
                          Navigator.pop(context);
                        }))
                    .toList())));
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.onTap});
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border:
                  Border.all(color: Theme.of(context).colorScheme.outline))));
}

class ClipboardService {
  static Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});
  @override
  Widget build(BuildContext context) =>
      Consumer<QrState>(builder: (_, state, __) {
        if (state.history.isEmpty)
          return const Center(child: Text('No saved QR codes yet.'));
        return ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            Text('Recent codes',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton(
                onPressed: state.clearHistory, child: const Text('Clear all'))
          ]),
          ...state.history.map((item) => Card(
              child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.qr_code_2)),
                  title: Text(item.data,
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                      '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}'),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailScreen(data: item.data))),
                  trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => state.removeHistory(item)))))
        ]);
      });
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('QR code')),
      body: Center(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                QrImageView(data: data, size: 280),
                const SizedBox(height: 20),
                SelectableText(data, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton.icon(
                    onPressed: () async {
                      await ClipboardService.copy(data);
                      if (context.mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Copied to clipboard')));
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy content'))
              ]))));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<QrState>(
      builder: (_, state, __) => Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(padding: const EdgeInsets.all(16), children: [
            Card(
                child: SwitchListTile(
                    title: const Text('Dark mode'),
                    subtitle: const Text('Use a darker appearance'),
                    value: state.dark,
                    onChanged: state.setDark)),
            Card(
                child: ListTile(
                    leading: const Icon(Icons.delete_sweep_outlined),
                    title: const Text('Clear history'),
                    onTap: () {
                      state.clearHistory();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('History cleared')));
                    }))
          ])));
}

class AboutView extends StatelessWidget {
  const AboutView({super.key});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.qr_code_2,
                size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('QR Generator',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
                'A fast, private QR generator. QR data is generated locally on your device and never sent to a server.',
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const Text('Version 1.0.0'),
            const SizedBox(height: 20),
            const Text(
                'Static QR codes do not expire by themselves. They continue to work as long as the encoded link or content remains available.',
                textAlign: TextAlign.center)
          ])));
}

Future<Uint8List> _render(String data, QrState state) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      color: state.foreground,
      emptyColor: state.background,
      errorCorrectionLevel: state.errorCorrection);
  painter.paint(canvas, Size(state.size, state.size));
  final image = await recorder
      .endRecording()
      .toImage(state.size.round(), state.size.round());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}
