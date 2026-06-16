import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/providers.dart';

class DataRoomScreen extends ConsumerWidget {
  const DataRoomScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataRoomAsync = ref.watch(dataRoomProvider);
    return Scaffold(
      backgroundColor: AppTheme.baseColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Data Room',
            style: TextStyle(
              color: AppTheme.onSurfaceText(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            )),
      ),
      body: dataRoomAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: TextStyle(color: AppTheme.coral))),
        data: (files) {
          if (files.isEmpty) {
            return Center(
                child: Text('No files in data room',
                    style: TextStyle(
                        color: AppTheme.onSurfaceTextSecondary(context))));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: files.length,
            itemBuilder: (ctx, i) {
              final f = files[i];
              return _buildFileCard(context, f);
            },
          );
        },
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, dynamic file) {
    final icon = _iconForType(file.type);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${file.name}...'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.iconOnSurface(context)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.iconOnSurface(context),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurfaceText(context),
                          )),
                      const SizedBox(height: 4),
                      Text(
                        '${file.type.toUpperCase()} \u2022 ${file.size} \u2022 Updated: ${file.updatedAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.onSurfaceTextMuted(context),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
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
