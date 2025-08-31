// lib/main.dart
// Measures Converter - Flutter 
// Author: sri sai palamoor
// Description:
//   A unit conversion app that lets users convert between
//   metric and imperial measures (length & weight).
//
//
// ideas to extend:
// - Add more categories like Temperature by appending to the data
//   structures and updating _unitsForCategory and _convert accordingly.

import 'package:flutter/material.dart';

void main() {
  runApp(const MeasuresApp());
}

class MeasuresApp extends StatelessWidget {
  const MeasuresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measures Converter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ConverterPage(),
    );
  }
}

/// Supported categories of measures.
enum Category { length, weight }

/// names.
const Map<Category, String> kCategoryLabels = {
  Category.length: 'Length',
  Category.weight: 'Weight',
};

/// Base units used internally for conversion math.
/// - Length base: meter
/// - Weight base: kilogram
///
/// Map<category, Map<unit, factorToBase>>
const Map<Category, Map<String, double>> kUnitFactorsToBase = {
  Category.length: {
    // Metric
    'millimeters': 0.001,
    'centimeters': 0.01,
    'meters': 1.0,
    'kilometers': 1000.0,
    // Imperial
    'inches': 0.0254,
    'feet': 0.3048,
    'yards': 0.9144,
    'miles': 1609.344,
    //non imperical & non metric
    'nautical mile': 1852,
  },
  Category.weight: {
    // Metric
    'grams': 0.001,
    'kilograms': 1.0,
    // Imperial
    'ounces': 0.028349523125,
    'pounds': 0.45359237,
  },
};

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();

  Category _category = Category.length;
  late String _fromUnit;
  late String _toUnit;
  String? _result;

  @override
  void initState() {
    super.initState();
    final units = _unitsForCategory(_category);
    _fromUnit = units.first;
    _toUnit = units[1];
  }

  List<String> _unitsForCategory(Category category) =>
      kUnitFactorsToBase[category]!.keys.toList();

  /// Core conversion routine:
  /// Converts [input] in [fromUnit] to [toUnit] within the same category.
  double _convert(double input, Category category, String fromUnit, String toUnit) {
    final fromFactor = kUnitFactorsToBase[category]![fromUnit]!;
    final toFactor = kUnitFactorsToBase[category]![toUnit]!;
    // Convert to base, then out to target.
    final inBase = input * fromFactor;
    return inBase / toFactor;
  }

  void _onConvert() {
    if (!_formKey.currentState!.validate()) return;

    final raw = double.parse(_valueController.text.trim());
    final converted = _convert(raw, _category, _fromUnit, _toUnit);
    setState(() {
      _result =
          '${raw.toStringAsFixed(1)} $_fromUnit are ${converted.toStringAsFixed(3)} $_toUnit';
    });
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final units = _unitsForCategory(_category);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Measures Converter',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Text('Value', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Enter a number',
              ),
              validator: (text) {
                final t = text?.trim() ?? '';
                if (t.isEmpty) return 'Please enter a value';
                return double.tryParse(t) == null ? 'Enter a valid number' : null;
              },
            ),
            const SizedBox(height: 24),

            // Category picker (Length / Weight)
            const Text('Category'),
            const SizedBox(height: 6),
            SegmentedButton<Category>(
              segments: Category.values
                  .map((c) => ButtonSegment<Category>(
                        value: c,
                        label: Text(kCategoryLabels[c]!),
                      ))
                  .toList(),
              selected: {_category},
              onSelectionChanged: (set) {
                setState(() {
                  _category = set.first;
                  final newUnits = _unitsForCategory(_category);
                  _fromUnit = newUnits.first;
                  _toUnit = newUnits[1];
                  _result = null;
                });
              },
            ),
            const SizedBox(height: 20),

            const Text('From', style: TextStyle(fontSize: 18)),
            DropdownButtonFormField<String>(
              value: _fromUnit,
              items: units
                  .map((u) => DropdownMenuItem<String>(
                        value: u,
                        child: Text(u),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _fromUnit = v!),
            ),
            const SizedBox(height: 16),

            const Text('To', style: TextStyle(fontSize: 18)),
            DropdownButtonFormField<String>(
              value: _toUnit,
              items: units
                  .map((u) => DropdownMenuItem<String>(
                        value: u,
                        child: Text(u),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _toUnit = v!),
            ),
            const SizedBox(height: 28),
            Center(
              child: ElevatedButton(
                onPressed: _onConvert,
                child: const Text('Convert'),
              ),
            ),
            const SizedBox(height: 28),
            if (_result != null)
              Center(
                child: Text(
                  _result!,
                  style: const TextStyle(fontSize: 20, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
