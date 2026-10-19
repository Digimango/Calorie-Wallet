import 'package:flutter/material.dart';
import '../models/food_item.dart';

class AddFoodScreen extends StatefulWidget {
  final String? barcode;
  const AddFoodScreen({super.key, this.barcode});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _fiber = TextEditingController(text: '0');
  final _portion = TextEditingController(text: '100');

  @override
  void dispose() {
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _fiber.dispose();
    _portion.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    final kcal = double.tryParse(_kcal.text.replaceAll(',', '.'));
    if (name.isEmpty || kcal == null || kcal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name und kcal (pro 100 g) nötig')),
      );
      return;
    }
    final item = FoodItem(
      id: widget.barcode ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      kcal: kcal,
      protein: double.tryParse(_protein.text.replaceAll(',', '.')) ?? 0,
      carbs: double.tryParse(_carbs.text.replaceAll(',', '.')) ?? 0,
      fat: double.tryParse(_fat.text.replaceAll(',', '.')) ?? 0,
      fiber: double.tryParse(_fiber.text.replaceAll(',', '.')) ?? 0,
      defaultPortion: double.tryParse(_portion.text.replaceAll(',', '.')) ?? 100,
      barcode: widget.barcode,
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lebensmittel anlegen'),
        actions: [
          TextButton(onPressed: _save, child: const Text('SPEICHERN')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.barcode != null)
            Text('Barcode: ${widget.barcode}',
                style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 8),
          const Text('Angaben pro 100 g',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _num('kcal', _kcal),
          _num('Protein (g)', _protein),
          _num('Kohlenhydrate (g)', _carbs),
          _num('Fett (g)', _fat),
          _num('Ballaststoffe (g)', _fiber),
          _num('Standardportion (g)', _portion),
        ],
      ),
    );
  }

  Widget _num(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
