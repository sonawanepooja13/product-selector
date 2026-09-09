import 'package:flutter/material.dart';

class MobileHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onBack;

  const MobileHeader({
    super.key,
    required this.title,
    this.subtitle = 'Saark Operating System',
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: const Color(0xFF1F3B66), // Primary Dark
      foregroundColor: Colors.white,
      elevation: 0,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade200,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '  ›  ',
                style: TextStyle(fontSize: 11, color: Colors.blue.shade200),
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.blue.shade100),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          tooltip: 'Help',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.help_center_rounded,
                        color: Color(0xFF2F5D9F)),
                    const SizedBox(width: 8),
                    Text(title),
                  ],
                ),
                content: Text(
                  'Module: $title\n\n'
                  'This mobile interface is fully synchronized with your Saark Desktop Operating System workspace. All calculations, status changes, and data entries update in real time.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
