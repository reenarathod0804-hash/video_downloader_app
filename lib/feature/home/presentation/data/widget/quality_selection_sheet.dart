import 'package:flutter/material.dart';
import 'package:video_dloader/configue/constant/AppColors.dart';

class QualityOption {
  final String label;
  final String title;
  final String description;
  final IconData icon;

  const QualityOption({
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class QualitySelectionSheet extends StatelessWidget {
  final String? videoTitle;

  const QualitySelectionSheet({super.key, this.videoTitle});

  static const List<QualityOption> options = [
    QualityOption(
      label: '720p',
      title: '720p',
      description: 'HD • Best quality',
      icon: Icons.hd_outlined,
    ),
    QualityOption(
      label: '360p',
      title: '360p',
      description: 'Standard • Fast download',
      icon: Icons.sd_outlined,
    ),
  ];

  static Future<String?> show(BuildContext context, {String? videoTitle}) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => QualitySelectionSheet(videoTitle: videoTitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Quality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'League Spartan-Bold',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            if (videoTitle != null && videoTitle!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                videoTitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onboard,
                  fontFamily: 'Niramit Regular',
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Options List
            ...options.map((opt) => _buildOptionTile(context, opt)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, QualityOption opt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context, opt.label),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1.2),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.tomato.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    opt.icon,
                    color: AppColors.tomato,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'League Spartan-Bold',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opt.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onboard,
                          fontFamily: 'Niramit Regular',
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
