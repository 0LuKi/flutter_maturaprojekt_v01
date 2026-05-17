import 'package:flutter/material.dart';
import '../services/feed_service.dart';

class AddFeedPage extends StatefulWidget {
  const AddFeedPage({Key? key}) : super(key: key);

  @override
  State<AddFeedPage> createState() => _AddFeedPageState();
}

class _AddFeedPageState extends State<AddFeedPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _consumptionController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg'); // Standardwert
  final _thresholdController = TextEditingController();

  final FeedService _feedService = FeedService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _consumptionController.dispose();
    _unitController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveFeed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _feedService.createNewFeed(
        name: _nameController.text.trim(),
        initialStock: double.parse(_stockController.text.replaceAll(',', '.')),
        dailyConsumption: double.parse(
          _consumptionController.text.replaceAll(',', '.'),
        ),
        unit: _unitController.text.trim(),
        minThreshold: double.parse(
          _thresholdController.text.replaceAll(',', '.'),
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Springt zurück zur Futterübersicht
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Neues Futter erfolgreich angelegt!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Futterart hinzufügen'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name (z.B. Heu, Silage)',
                    prefixIcon: const Icon(Icons.label_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Bitte Name eingeben' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: 'Einheit (z.B. kg, Ballen, Liter)',
                    prefixIcon: const Icon(Icons.scale_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Bitte Einheit eingeben'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _stockController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Aktueller Startbestand',
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Bitte Bestand eingeben'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _consumptionController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Ø Tagesverbrauch (zur Reichweitenprognose)',
                    prefixIcon: const Icon(Icons.trending_down_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Bitte Verbrauch eingeben'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _thresholdController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Warnschwelle (Minimum)',
                    prefixIcon: const Icon(Icons.warning_amber_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? 'Bitte Warnschwelle eingeben'
                      : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _saveFeed,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_task),
                    label: const Text(
                      'Futterart anlegen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
