import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class DataRoomScreen extends ConsumerWidget {
  const DataRoomScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataRoomAsync = ref.watch(dataRoomProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Data Room')),
      body: dataRoomAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (files) {
          if (files.isEmpty) return const Center(child: Text('No files in data room'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: files.length,
            itemBuilder: (ctx, i) {
              final f = files[i];
              return Card(
                child: ListTile(
                  leading: Icon(_iconForType(f.type), color: const Color(0xFF0B1F3A)),
                  title: Text(f.name),
                  subtitle: Text('${f.type.toUpperCase()} • ${f.size} • Updated: ${f.updatedAt}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'xlsx': return Icons.grid_view;
      case 'docx': return Icons.description;
      case 'pptx': return Icons.slideshow;
      default: return Icons.file_present;
    }
  }
}