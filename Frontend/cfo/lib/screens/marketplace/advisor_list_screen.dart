import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';

class AdvisorListScreen extends ConsumerWidget {
  const AdvisorListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advisorsAsync = ref.watch(advisorsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('CFO Marketplace')),
      body: advisorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (advisors) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: advisors.length,
          itemBuilder: (ctx, i) {
            final a = advisors[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: a.photo != null ? NetworkImage(a.photo!) : null,
                  child: a.photo == null ? const Icon(Icons.person) : null,
                ),
                title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${a.specialization} • ${a.region}'),
                    Text('${a.experience} yrs exp • ⭐ ${a.rating.toStringAsFixed(1)} • \$${a.pricePerHour}/hr', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Navigator.pushNamed(context, '/marketplace/advisor-detail', arguments: a.id),
              ),
            );
          },
        ),
      ),
    );
  }
}