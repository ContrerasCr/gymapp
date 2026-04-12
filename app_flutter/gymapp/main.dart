import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ─── DATA MODEL ────────────────────────────────────────────────────────────────

class Item {
  String c1;
  String c2;
  String c3;
  String c4;
  String c5;

  Item({
    required this.c1,
    required this.c2,
    required this.c3,
    required this.c4,
    required this.c5,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        c1: json['c1'] ?? '',
        c2: json['c2'] ?? '',
        c3: json['c3'] ?? '',
        c4: json['c4'] ?? '',
        c5: json['c5'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'c1': c1,
        'c2': c2,
        'c3': c3,
        'c4': c4,
        'c5': c5,
      };
}

// ─── DATA STORE (simulates JSON persistence) ──────────────────────────────────

class DataStore {
  static final DataStore _instance = DataStore._internal();
  factory DataStore() => _instance;
  DataStore._internal();

  // Initial JSON data
  final String _initialJson = '''
[
  {"c1": "Electrónica", "c2": "Laptop Pro X", "c3": "2499.99", "c4": "En stock", "c5": "⭐⭐⭐⭐⭐"},
  {"c1": "Ropa", "c2": "Camisa Oxford", "c3": "59.90", "c4": "En stock", "c5": "⭐⭐⭐⭐"},
  {"c1": "Hogar", "c2": "Silla Ergonómica", "c3": "349.00", "c4": "Agotado", "c5": "⭐⭐⭐⭐⭐"},
  {"c1": "Deportes", "c2": "Zapatillas Run", "c3": "129.50", "c4": "En stock", "c5": "⭐⭐⭐"},
  {"c1": "Libros", "c2": "Flutter en Acción", "c3": "45.00", "c4": "En stock", "c5": "⭐⭐⭐⭐⭐"}
]
''';

  late List<Item> _items;
  bool _initialized = false;

  List<Item> get items {
    if (!_initialized) {
      final decoded = jsonDecode(_initialJson) as List;
      _items = decoded.map((e) => Item.fromJson(e)).toList();
      _initialized = true;
    }
    return _items;
  }

  String get rawJson =>
      const JsonEncoder.withIndent('  ').convert(_items.map((e) => e.toJson()).toList());

  void addItem(Item item) => _items.add(item);

  void updateItem(int index, Item item) => _items[index] = item;

  void deleteItem(int index) => _items.removeAt(index);
}

// ─── THEME ────────────────────────────────────────────────────────────────────

class AppTheme {
  static const bg = Color(0xFF0F0F13);
  static const surface = Color(0xFF1A1A24);
  static const card = Color(0xFF22222F);
  static const accent = Color(0xFFE8C547);
  static const accent2 = Color(0xFF7C6AF7);
  static const textPrimary = Color(0xFFF0EDE6);
  static const textSecondary = Color(0xFF8A8A9A);
  static const border = Color(0xFF2E2E40);
  static const danger = Color(0xFFE05252);
  static const success = Color(0xFF52C48A);

  static ThemeData get theme => ThemeData(
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accent2,
          surface: surface,
          background: bg,
          error: danger,
        ),
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          labelStyle: const TextStyle(color: textSecondary, fontSize: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: bg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      );
}

// ─── APP ──────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON List Manager',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const ListScreen(),
    );
  }
}

// ─── LIST SCREEN ──────────────────────────────────────────────────────────────

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final store = DataStore();
  String _searchQuery = '';
  int? _selectedIndex;

  List<Item> get filteredItems {
    if (_searchQuery.isEmpty) return store.items;
    final q = _searchQuery.toLowerCase();
    return store.items.where((item) {
      return item.c1.toLowerCase().contains(q) ||
          item.c2.toLowerCase().contains(q) ||
          item.c3.toLowerCase().contains(q) ||
          item.c4.toLowerCase().contains(q) ||
          item.c5.toLowerCase().contains(q);
    }).toList();
  }

  void _openAdd() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FormScreen()),
    );
    if (result == true) setState(() {});
  }

  void _openEdit(int globalIndex) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(index: globalIndex, item: store.items[globalIndex]),
      ),
    );
    if (result == true) setState(() {});
  }

  void _deleteItem(int globalIndex) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Eliminar item', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('¿Confirmas la eliminación?',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              store.deleteItem(globalIndex);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Eliminar', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  void _showJson() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(children: [
          const Icon(Icons.data_object, color: AppTheme.accent, size: 18),
          const SizedBox(width: 8),
          const Text('JSON actual', style: TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
        ]),
        content: SizedBox(
          width: 500,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              store.rawJson,
              style: const TextStyle(
                color: AppTheme.success,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredItems;
    final allItems = store.items;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'JSON LIST MANAGER',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
                letterSpacing: 2,
              ),
            ),
            Text(
              '${allItems.length} registros',
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showJson,
            icon: const Icon(Icons.data_object, color: AppTheme.accent2),
            tooltip: 'Ver JSON',
          ),
          IconButton(
            onPressed: _openAdd,
            icon: const Icon(Icons.add_circle, color: AppTheme.accent),
            tooltip: 'Agregar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Header row ──
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Buscar en c1, c2, c3, c4, c5...',
                hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary, size: 18),
                isDense: true,
              ),
            ),
          ),

          // ── Column headers ──
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _headerCell('C1', flex: 2),
                _headerCell('C2', flex: 3),
                _headerCell('C3', flex: 2),
                _headerCell('C4', flex: 2),
                _headerCell('C5', flex: 2),
                const SizedBox(width: 80),
              ],
            ),
          ),
          Container(height: 1, color: AppTheme.border),

          // ── List ──
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Sin resultados',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        Container(height: 1, color: AppTheme.border),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      // find global index
                      final globalIndex = allItems.indexOf(item);
                      final isSelected = _selectedIndex == globalIndex;

                      return InkWell(
                        onTap: () => setState(
                            () => _selectedIndex = isSelected ? null : globalIndex),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          color: isSelected
                              ? AppTheme.accent.withOpacity(0.08)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              _dataCell(item.c1,
                                  flex: 2, color: AppTheme.accent),
                              _dataCell(item.c2, flex: 3),
                              _dataCell(item.c3,
                                  flex: 2, color: AppTheme.success),
                              _dataCell(item.c4, flex: 2),
                              _dataCell(item.c5, flex: 2),
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    _iconBtn(
                                      icon: Icons.edit_outlined,
                                      color: AppTheme.accent2,
                                      onTap: () => _openEdit(globalIndex),
                                    ),
                                    const SizedBox(width: 4),
                                    _iconBtn(
                                      icon: Icons.delete_outline,
                                      color: AppTheme.danger,
                                      onTap: () => _deleteItem(globalIndex),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ── Footer ──
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mostrando ${items.length} de ${allItems.length}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11),
                ),
                ElevatedButton.icon(
                  onPressed: _openAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Nuevo registro',
                      style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _dataCell(String value, {int flex = 1, Color? color}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: TextStyle(
          color: color ?? AppTheme.textPrimary,
          fontSize: 13,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _iconBtn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ─── FORM SCREEN (Add / Edit) ─────────────────────────────────────────────────

class FormScreen extends StatefulWidget {
  final int? index;
  final Item? item;

  const FormScreen({super.key, this.index, this.item});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final store = DataStore();

  late final TextEditingController _c1 = TextEditingController();
  late final TextEditingController _c2 = TextEditingController();
  late final TextEditingController _c3 = TextEditingController();
  late final TextEditingController _c4 = TextEditingController();
  late final TextEditingController _c5 = TextEditingController();

  bool get isEditing => widget.index != null;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _c1.text = widget.item!.c1;
      _c2.text = widget.item!.c2;
      _c3.text = widget.item!.c3;
      _c4.text = widget.item!.c4;
      _c5.text = widget.item!.c5;
    }
  }

  @override
  void dispose() {
    _c1.dispose();
    _c2.dispose();
    _c3.dispose();
    _c4.dispose();
    _c5.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      c1: _c1.text.trim(),
      c2: _c2.text.trim(),
      c3: _c3.text.trim(),
      c4: _c4.text.trim(),
      c5: _c5.text.trim(),
    );

    if (isEditing) {
      store.updateItem(widget.index!, item);
    } else {
      store.addItem(item);
    }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'EDITAR REGISTRO' : 'NUEVO REGISTRO',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
                letterSpacing: 2,
              ),
            ),
            Text(
              isEditing ? 'Modifica los campos individualmente' : 'Completa los 5 campos',
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview card
              if (isEditing) ...[
                _SectionLabel(label: 'REGISTRO #${widget.index! + 1}'),
                const SizedBox(height: 12),
              ],

              _SectionLabel(label: 'CAMPOS'),
              const SizedBox(height: 12),

              _FieldCard(
                tag: 'C1',
                label: 'Categoría 1',
                controller: _c1,
                hint: 'ej. Electrónica',
              ),
              const SizedBox(height: 12),

              _FieldCard(
                tag: 'C2',
                label: 'Categoría 2',
                controller: _c2,
                hint: 'ej. Laptop Pro X',
              ),
              const SizedBox(height: 12),

              _FieldCard(
                tag: 'C3',
                label: 'Categoría 3',
                controller: _c3,
                hint: 'ej. 2499.99',
              ),
              const SizedBox(height: 12),

              _FieldCard(
                tag: 'C4',
                label: 'Categoría 4',
                controller: _c4,
                hint: 'ej. En stock',
              ),
              const SizedBox(height: 12),

              _FieldCard(
                tag: 'C5',
                label: 'Categoría 5',
                controller: _c5,
                hint: 'ej. ⭐⭐⭐⭐⭐',
              ),

              const SizedBox(height: 32),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.border),
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
                      icon: Icon(isEditing ? Icons.save_outlined : Icons.add,
                          size: 18),
                      label: Text(isEditing ? 'Guardar cambios' : 'Agregar registro'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // JSON preview
              _SectionLabel(label: 'PREVIEW JSON'),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: Listenable.merge([_c1, _c2, _c3, _c4, _c5]),
                builder: (_, __) {
                  final preview = Item(
                    c1: _c1.text,
                    c2: _c2.text,
                    c3: _c3.text,
                    c4: _c4.text,
                    c5: _c5.text,
                  );
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      const JsonEncoder.withIndent('  ').convert(preview.toJson()),
                      style: const TextStyle(
                        color: AppTheme.success,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SHARED WIDGETS ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _FieldCard extends StatelessWidget {
  final String tag;
  final String label;
  final String hint;
  final TextEditingController controller;

  const _FieldCard({
    required this.tag,
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Text(
              tag,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                hintStyle: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Campo requerido' : null,
            ),
          ),
        ],
      ),
    );
  }
}