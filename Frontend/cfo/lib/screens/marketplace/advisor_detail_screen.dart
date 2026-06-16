import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/advisor_model.dart';
import '../../providers/providers.dart';

class AdvisorDetailScreen extends ConsumerWidget {
  const AdvisorDetailScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advisorId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: const Text('Advisor Profile')),
      body: FutureBuilder(
        future:
            ref.read(marketplaceServiceProvider).getAdvisorDetail(advisorId),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final advisor = snap.data!['advisor'] as AdvisorModel;
          final reviews = snap.data!['reviews'] as List<ReviewModel>;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: CircleAvatar(
                        radius: 50,
                        backgroundImage: advisor.photo != null
                            ? NetworkImage(advisor.photo!)
                            : null,
                        child: advisor.photo == null
                            ? const Icon(Icons.person, size: 50)
                            : null)),
                const SizedBox(height: 16),
                Center(
                    child: Text(advisor.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                Center(
                    child: Text(
                        '${advisor.specialization} • ${advisor.region}',
                        style: const TextStyle(color: Colors.grey))),
                const SizedBox(height: 8),
                Center(
                    child: Text(
                        '⭐ ${advisor.rating.toStringAsFixed(1)} • ${advisor.experience} yrs • \$${advisor.pricePerHour}/hr')),
                const SizedBox(height: 16),
                Text(advisor.bio ?? '',
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Chip(
                    label: Text(advisor.availability),
                    backgroundColor: advisor.availability == 'Available'
                        ? Colors.green[100]
                        : Colors.grey[200]),
                const SizedBox(height: 24),
                const Text('Reviews',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...reviews.map((r) => Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: ListTile(
                        title: Text('⭐ ${r.rating}'),
                        subtitle: Text(r.comment ?? ''),
                      ),
                    )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: advisor.availability == 'Available'
                        ? () => Navigator.pushNamed(
                            context, '/marketplace/booking',
                            arguments: advisorId)
                        : null,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B1F3A),
                        foregroundColor: Colors.white),
                    child: const Text('Book Consultation'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
