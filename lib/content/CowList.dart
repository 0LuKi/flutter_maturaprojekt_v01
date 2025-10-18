import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CowList extends StatefulWidget {
  const CowList({super.key});

  @override
  State<CowList> createState() => _CowListState();
}

class _CowListState extends State<CowList> {
  final firestoreRef = FirebaseFirestore.instance.collection('cows');
  QuerySnapshot? _lastSnapshot;
  bool _isFirstLoad = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreRef.snapshots(),
      builder: (context, snapshot) {
        // Wenn gerade geladen
        if (snapshot.connectionState == ConnectionState.waiting &&
            _lastSnapshot != null) {
          return _buildList(_lastSnapshot!);
        }

        // Wenn neue Daten
        if (snapshot.hasData) {
          _lastSnapshot = snapshot.data!;
          _isFirstLoad = false;
        }

        // Kein Snapshot bekommen
        if (_isFirstLoad && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Wenn keine Kühe
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Keine Kühe gefunden 🐄"));
        }

        // Normale Anzeige
        return _buildList(snapshot.data!);
      },
    );
  }

  Widget _buildList(QuerySnapshot snapshot) {
    final docs = snapshot.docs;

    return ListView.builder(
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final id = docs[index].id;
        final name = data['name'] ?? 'Unbekannt';
        return CowCard(id: id, name: name);
      },
    );
  }
}


// Item zur Liste hinzufügen
class AddCow extends StatefulWidget {
  const AddCow({super.key});

  @override
  State<AddCow> createState() => _AddCowState();
}

class _AddCowState extends State<AddCow> {
  final TextEditingController _controller = TextEditingController();
  final firestoreRef = FirebaseFirestore.instance.collection('cows');

  void addCow() {
    if (_controller.text.isEmpty) return;
    firestoreRef.add({'name': _controller.text});
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Cow Name',
              filled: true,
              fillColor: Theme.of(context).colorScheme.outlineVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none
              )
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: addCow,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)
            )
          ), 
          child: const Icon(Icons.add)
        ),
      ]
    );
  }
}

class CowCard extends StatelessWidget {
  final String id;
  final String name;

  const CowCard({super.key, required this.id, required this.name});

  void _confirmDelete(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Delete Cow"),
        content: const Text("Do you really want to delete this cow?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // close dialog first
              await FirebaseFirestore.instance.collection('cows').doc(id).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cow deleted")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: Theme.of(context).colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(MdiIcons.cow),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _confirmDelete(context),
        ),
      ),
    );
  }
}