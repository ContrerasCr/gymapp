import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const MyApp());

// ══════════════════════════════════════════════════════════════════════════════
// MODEL
// ══════════════════════════════════════════════════════════════════════════════

class Item {
  String c1, c2, c3, c4, c5;
  Item({required this.c1, required this.c2, required this.c3,
        required this.c4, required this.c5});

  factory Item.fromJson(Map<String, dynamic> j) => Item(
        c1: j['Tipo'] ?? '', c2: j['Ejercicio'] ?? '', c3: j['Peso'] ?? '',
        c4: j['Repeticiones'] ?? '', c5: j['Series'] ?? '');

  Map<String, dynamic> toJson() =>
      {'Tipo': c1, 'Ejercicio': c2, 'Peso': c3, 'Repeticiones': c4, 'Series': c5};
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION CONFIG — define las 4 secciones aquí
// ══════════════════════════════════════════════════════════════════════════════

class SectionConfig {
  final String name;
  final IconData icon;
  final Color accent;
  final String initialJson;

  const SectionConfig({
    required this.name,
    required this.icon,
    required this.accent,
    required this.initialJson,
  });
}

const List<SectionConfig> kSections = [
  SectionConfig(
    name: 'Pectoral',
    icon: Icons.inventory_2_outlined,
    accent: Color(0xFFE8C547),
    initialJson: '''[
    ]''',
  ),
  SectionConfig(
    name: 'Espalda',
    icon: Icons.people_outline,
    accent: Color(0xFF7C6AF7),
    initialJson: '''[
    ]''',
  ),
  SectionConfig(
    name: 'Biceps',
    icon: Icons.bar_chart_outlined,
    accent: Color(0xFF52C48A),
    initialJson: '''[
    ]''',
  ),
  SectionConfig(
    name: 'Hombros',
    icon: Icons.warehouse_outlined,
    accent: Color(0xFFE05252),
    initialJson: '''[
    ]''',
  ),
    SectionConfig(
    name: 'Triceps',
    icon: Icons.warehouse_outlined,
    accent: Color(0xFFE05252),
    initialJson: '''[
    ]''',
  ),
    SectionConfig(
    name: 'Piernas',
    icon: Icons.warehouse_outlined,
    accent: Color(0xFFE05252),
    initialJson: '''[
    ]''',
  ),
];

// ══════════════════════════════════════════════════════════════════════════════
// ─── Configure your fixed category labels here ───────────────────────────────
// ══════════════════════════════════════════════════════════════════════════════
const List<String> kCategoryLabels = [
  'Tipo',
  'Ejercicio',
  'Peso',
  'Repeticiones',
  'Series',
];




// ══════════════════════════════════════════════════════════════════════════════
// DATA STORE — shared singleton with 4 independent lists
// ══════════════════════════════════════════════════════════════════════════════

class DataStore {
  static final DataStore _i = DataStore._();
  factory DataStore() => _i;
  DataStore._();

  final Map<int, List<Item>> _data = {};

  // Carga desde archivo (o JSON inicial si no existe)
  Future<List<Item>> loadItems(int si) async {
    if (_data.containsKey(si)) return _data[si]!;
    try {
      final file = await _getFile();
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString()) as Map;
        final raw = decoded['section_$si'] as List? ?? [];
        _data[si] = raw.map((e) => Item.fromJson(e)).toList();
      } else {
        final raw = jsonDecode(kSections[si].initialJson) as List;
        _data[si] = raw.map((e) => Item.fromJson(e)).toList();
      }
    } catch (_) {
      final raw = jsonDecode(kSections[si].initialJson) as List;
      _data[si] = raw.map((e) => Item.fromJson(e)).toList();
    }
    return _data[si]!;
  }

  // Acceso síncrono (solo usar si loadItems ya fue llamado antes)
  List<Item> cachedItems(int si) => _data[si] ?? [];

  Future<String> rawJson(int si) async {
    final items = await loadItems(si);
    return const JsonEncoder.withIndent('  ')
        .convert(items.map((e) => e.toJson()).toList());
  }

  Future<void> add(int si, Item item) async {
    (await loadItems(si)).add(item);
    await _save();
  }

  Future<void> update(int si, int idx, Item item) async {
    (await loadItems(si))[idx] = item;
    await _save();
  }

  Future<void> delete(int si, int idx) async {
    (await loadItems(si)).removeAt(idx);
    await _save();
  }

  Future<void> _save() async {
    final file = await _getFile();
    final Map<String, dynamic> all = {};
    for (final si in _data.keys) {
      all['section_$si'] = _data[si]!.map((e) => e.toJson()).toList();
    }
    await file.writeAsString(jsonEncode(all));
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/data.json');
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// THEME
// ══════════════════════════════════════════════════════════════════════════════

class T {
  static const bg      = Color(0xFF0F0F13);
  static const surface = Color(0xFF1A1A24);
  static const card    = Color(0xFF22222F);
  static const border  = Color(0xFF2E2E40);
  static const text    = Color(0xFFF0EDE6);
  static const sub     = Color(0xFF8A8A9A);
  static const danger  = Color(0xFFE05252);
}

// ══════════════════════════════════════════════════════════════════════════════
// APP
// ══════════════════════════════════════════════════════════════════════════════

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: T.bg,
        colorScheme: const ColorScheme.dark(surface: T.surface, background: T.bg),
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: T.surface, foregroundColor: T.text, elevation: 0),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, fillColor: T.card,
          labelStyle: const TextStyle(color: T.sub, fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: T.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: T.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white38, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      home: const RootScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ROOT — manages drawer + active section
// ══════════════════════════════════════════════════════════════════════════════

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _current = 0;

  void _goTo(int i) {
    setState(() => _current = i);
    Navigator.pop(context); // close drawer
  }

  @override
  Widget build(BuildContext context) {
    final sec = kSections[_current];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Icon(sec.icon, color: sec.accent, size: 20),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(sec.name.toUpperCase(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                    color: sec.accent, letterSpacing: 2)),
            Text('${DataStore().cachedItems(_current).length} registros',
                style: const TextStyle(fontSize: 11, color: T.sub)),
          ]),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.data_object, size: 20),
            color: sec.accent.withOpacity(0.8),
            tooltip: 'Ver JSON',
            onPressed: () => _showJson(context, _current),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, size: 22),
            color: sec.accent,
            tooltip: 'Agregar',
            onPressed: () => _openForm(context, _current),
          ),
          const SizedBox(width: 6),
        ],
      ),
      drawer: _AppDrawer(current: _current, onSelect: _goTo),
      body: ListBody(sectionIndex: _current, onRefresh: () => setState(() {})),
    );
  }

  void _openForm(BuildContext ctx, int si) async {
    final ok = await Navigator.push<bool>(ctx,
        MaterialPageRoute(builder: (_) => FormScreen(sectionIndex: si)));
    if (ok == true) setState(() {});
  }

void _showJson(BuildContext ctx, int si) {
  final sec = kSections[si];
  showDialog(
    context: ctx,
    builder: (_) => AlertDialog(
      backgroundColor: T.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(children: [
        Icon(Icons.data_object, color: sec.accent, size: 16),
        const SizedBox(width: 8),
        Text('JSON — ${sec.name}',
            style: const TextStyle(color: T.text, fontSize: 15)),
      ]),
      content: SizedBox(
        width: 500,
        height: 400,
        child: SingleChildScrollView(
          child: FutureBuilder<String>(
            future: DataStore().rawJson(si),
            builder: (_, snap) => Text(
              snap.data ?? 'Cargando...',
              style: TextStyle(
                  color: sec.accent, fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
      ),                          // ← cierre de SizedBox (content)
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Cerrar', style: TextStyle(color: sec.accent)),
        ),
      ],
    ),
  );
}
}

// ══════════════════════════════════════════════════════════════════════════════
// DRAWER
// ══════════════════════════════════════════════════════════════════════════════

class _AppDrawer extends StatelessWidget {
  final int current;
  final ValueChanged<int> onSelect;
  const _AppDrawer({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: T.surface,
      child: Column(children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
          decoration: BoxDecoration(
            color: T.card,
            border: Border(bottom: BorderSide(color: T.border)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('JSON', style: TextStyle(
                color: Colors.white, fontSize: 26,
                fontWeight: FontWeight.w900, letterSpacing: 3)),
            const Text('MANAGER', style: TextStyle(
                color: T.sub, fontSize: 13, letterSpacing: 5)),
            const SizedBox(height: 6),
            Text('${kSections.length} secciones activas',
                style: const TextStyle(color: T.sub, fontSize: 11)),
          ]),
        ),

        // Section items
        const SizedBox(height: 8),
        ...List.generate(kSections.length, (i) {
          final s = kSections[i];
          final isActive = i == current;
          final count = DataStore().cachedItems(i).length;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Material(
              color: isActive ? s.accent.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onSelect(i),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: isActive ? s.accent.withOpacity(0.3) : Colors.transparent),
                  ),
                  child: Row(children: [
                    Icon(s.icon, color: isActive ? s.accent : T.sub, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(s.name,
                          style: TextStyle(
                              color: isActive ? s.accent : T.text,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? s.accent.withOpacity(0.2) : T.border,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$count',
                          style: TextStyle(
                              color: isActive ? s.accent : T.sub,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ]),
                ),
              ),
            ),
          );
        }),

        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('v1.0.0 · JSON Manager',
              style: const TextStyle(color: T.sub, fontSize: 10)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LIST BODY
// ══════════════════════════════════════════════════════════════════════════════

class ListBody extends StatefulWidget {
  final int sectionIndex;
  final VoidCallback onRefresh;
  const ListBody({super.key, required this.sectionIndex, required this.onRefresh});

  @override
  State<ListBody> createState() => _ListBodyState();
}

class _ListBodyState extends State<ListBody> {
  String _q = '';
  final store = DataStore();

  @override
  void initState() {
    super.initState();
    store.loadItems(widget.sectionIndex).then((_) => setState(() {}));
  }

  SectionConfig get sec => kSections[widget.sectionIndex];
  int get si => widget.sectionIndex;

  List<Item> get filtered {
    final all = store.cachedItems(si);
    if (_q.isEmpty) return all;
    final q = _q.toLowerCase();
    return all.where((it) =>
        it.c1.toLowerCase().contains(q) || it.c2.toLowerCase().contains(q) ||
        it.c3.toLowerCase().contains(q) || it.c4.toLowerCase().contains(q) ||
        it.c5.toLowerCase().contains(q)).toList();
  }

  void _edit(int globalIdx) async {
    final ok = await Navigator.push<bool>(context, MaterialPageRoute(
        builder: (_) => FormScreen(
            sectionIndex: si,
            index: globalIdx,
            item: store.cachedItems(si)[globalIdx])));
    if (ok == true) { widget.onRefresh(); setState(() {}); }
  }

  void _delete(int globalIdx) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: T.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Eliminar', style: TextStyle(color: T.text)),
        content: const Text('¿Confirmas la eliminación?',
            style: TextStyle(color: T.sub)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: T.sub))),
          TextButton(
            onPressed: () async {
              store.delete(si, globalIdx);
              Navigator.pop(context);
              widget.onRefresh();
              setState(() {});
            },
            child: const Text('Eliminar', style: TextStyle(color: T.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filtered;
    final all = store.cachedItems(si);

    return Column(children: [
      // Search bar
      Container(
        color: T.surface,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: TextField(
          onChanged: (v) => setState(() => _q = v),
          style: const TextStyle(color: T.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Buscar',
            hintStyle: const TextStyle(color: T.sub, fontSize: 13),
            prefixIcon: Icon(Icons.search, color: sec.accent, size: 18),
            isDense: true,
          ),
        ),
      ),

      // Column headers
      Container(
        color: T.surface,
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Row(children: [
          _hdr('Tipo', 2), _hdr('Ejercicio', 3), _hdr('Peso', 2),
          _hdr('Repeticiones', 2), _hdr('Series', 2),
          const SizedBox(width: 72),
        ]),
      ),
      Divider(height: 1, color: T.border),

      // Rows
      Expanded(
        child: items.isEmpty
            ? Center(child: Text('Sin resultados',
                style: const TextStyle(color: T.sub)))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: T.border),
                itemBuilder: (ctx, i) {
                  final item = items[i];
                  final gi = all.indexOf(item);
                  return InkWell(
                    onTap: () => _edit(gi),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        _cell(item.c1, 2, color: sec.accent),
                        _cell(item.c2, 3),
                        _cell(item.c3, 2),
                        _cell(item.c4, 2),
                        _cell(item.c5, 2),
                        SizedBox(
                          width: 72,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _btn(Icons.edit_outlined, sec.accent,
                                  () => _edit(gi)),
                              const SizedBox(width: 4),
                              _btn(Icons.delete_outline, T.danger,
                                  () => _delete(gi)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),

      // Footer
      Container(
        color: T.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${items.length} de ${all.length} registros',
                style: const TextStyle(color: T.sub, fontSize: 11)),
            ElevatedButton.icon(
              onPressed: () async {
                final ok = await Navigator.push<bool>(context,
                    MaterialPageRoute(
                        builder: (_) => FormScreen(sectionIndex: si)));
                if (ok == true) { widget.onRefresh(); setState(() {}); }
              },
              icon: const Icon(Icons.add, size: 15),
              label: const Text('Nuevo', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: sec.accent,
                foregroundColor: T.bg,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _hdr(String l, int flex) => Expanded(
    flex: flex,
    child: Text(l, style: const TextStyle(
        color: T.sub, fontSize: 10,
        fontWeight: FontWeight.bold, letterSpacing: 1.5)),
  );

  Widget _cell(String v, int flex, {Color? color}) => Expanded(
    flex: flex,
    child: Text(v,
        style: TextStyle(color: color ?? T.text, fontSize: 13),
        overflow: TextOverflow.ellipsis),
  );

  Widget _btn(IconData icon, Color color, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, color: color, size: 17),
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// FORM SCREEN (Add / Edit)
// ══════════════════════════════════════════════════════════════════════════════

class FormScreen extends StatefulWidget {
  final int sectionIndex;
  final int? index;
  final Item? item;
  const FormScreen({super.key, required this.sectionIndex, this.index, this.item});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _key = GlobalKey<FormState>();
  final store = DataStore();
  late final _c = List.generate(5, (_) => TextEditingController());

  bool get isEdit => widget.index != null;
  SectionConfig get sec => kSections[widget.sectionIndex];

  @override
  void initState() {
    super.initState();
    if (widget.item case final it?) {
      _c[0].text = sec.name; _c[0].text = it.c1; _c[1].text = it.c2;
      _c[2].text = it.c3; _c[3].text = it.c4;
    }
  }

  @override
  void dispose() { for (final c in _c) c.dispose(); super.dispose(); }

  void _save() {
    if (!_key.currentState!.validate()) return;
    final item = Item(
      c1: sec.name, c2: _c[0].text.trim(), c3: _c[1].text.trim(),
      c4: _c[2].text.trim(), c5: _c[3].text.trim(),
    );
    isEdit
        ? store.update(widget.sectionIndex, widget.index!, item)
        : store.add(widget.sectionIndex, item);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isEdit ? 'EDITAR REGISTRO' : 'NUEVO REGISTRO',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                  color: sec.accent, letterSpacing: 2)),
          Text(sec.name,
              style: const TextStyle(fontSize: 11, color: T.sub)),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _key,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Section badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sec.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sec.accent.withOpacity(0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(sec.icon, color: sec.accent, size: 14),
                const SizedBox(width: 6),
                Text(sec.name,
                    style: TextStyle(color: sec.accent, fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ]),
            ),

            const SizedBox(height: 20),
            _label('CAMPOS'),
            const SizedBox(height: 12),

            // Fields
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FieldTile(
                tag: 'C${i + 1}',
                accent: sec.accent,
                controller: _c[i],
                label: 'Categoría ${i + 1}',
              ),
            )),

            const SizedBox(height: 8),

            // Actions
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: T.sub,
                    side: const BorderSide(color: T.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(isEdit ? Icons.save_outlined : Icons.add, size: 17),
                  label: Text(isEdit ? 'Guardar cambios' : 'Agregar registro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sec.accent,
                    foregroundColor: T.bg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),
            _label('PREVIEW JSON'),
            const SizedBox(height: 8),

            // Live preview
            AnimatedBuilder(
              animation: Listenable.merge(_c),
              builder: (_, __) {
                final preview = Item(
                  c1: sec.name, c2: _c[0].text, c3: _c[1].text,
                  c4: _c[2].text, c5: _c[3].text,
                );
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: T.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: T.border),
                  ),
                  child: Text(
                    const JsonEncoder.withIndent('  ').convert(preview.toJson()),
                    style: TextStyle(
                        color: sec.accent, fontSize: 12,
                        fontFamily: 'monospace'),
                  ),
                );
              },
            ),
          ]),
        ),
      ),
    );
  }

  Widget _label(String s) => Text(s, style: const TextStyle(
      color: T.sub, fontSize: 10,
      letterSpacing: 2, fontWeight: FontWeight.bold));
}

// ── Field tile ────────────────────────────────────────────────────────────────

class _FieldTile extends StatelessWidget {
  final String tag, label;
  final Color accent;
  final TextEditingController controller;

  const _FieldTile({
    required this.tag, required this.label,
    required this.accent, required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: T.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accent.withOpacity(0.3)),
          ),
          alignment: Alignment.center,
          child: Text(tag, style: TextStyle(
              color: accent, fontSize: 11,
              fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: T.text, fontSize: 14),
            decoration: InputDecoration(
              labelText: label,
              filled: false, border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero, isDense: true,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Campo requerido' : null,
          ),
        ),
      ]),
    );
  }
}
