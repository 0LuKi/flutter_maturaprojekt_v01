import 'package:flutter/material.dart';
import '../models/feed_item.dart';
import '../services/feed_service.dart';

class FeedEditDialog extends StatefulWidget {
  final FeedItem feed;
  final bool isConsumption; // true = Verbrauch, false = Auffüllen

  const FeedEditDialog({
    Key? key,
    required this.feed,
    required this.isConsumption,
  }) : super(key: key);

  @override
  State<FeedEditDialog> createState() => _FeedEditDialogState();
}

class _FeedEditDialogState extends State<FeedEditDialog> {
  final _amountController = TextEditingController();
  final FeedService _feedService = FeedService(); // Service direkt instanziieren
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      if (widget.isConsumption) {
        await _feedService.consumeStock(widget.feed.id, amount);
      } else {
        await _feedService.addStock(widget.feed.id, amount);
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bestand erfolgreich aktualisiert.')),
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
    final title = widget.isConsumption ? 'Verbrauch eintragen' : 'Lager auffüllen';

    return AlertDialog(
      title: Text('$title (${widget.feed.name})'),
      content: TextField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: 'Menge in ${widget.feed.unit}',
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Speichern'),
        ),
      ],
    );
  }
}