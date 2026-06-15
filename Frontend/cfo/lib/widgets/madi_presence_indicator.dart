import 'package:flutter/material.dart';

class MadiPresenceIndicator extends StatefulWidget {
  final String lastReviewed;
  final bool isActive;

  const MadiPresenceIndicator({
    super.key,
    this.lastReviewed = '2h ago',
    this.isActive = true,
  });

  @override
  State<MadiPresenceIndicator> createState() => _MadiPresenceIndicatorState();
}

class _MadiPresenceIndicatorState extends State<MadiPresenceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFD4AF37)
                    .withValues(alpha: _pulse.value),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'MADI \u00B7 ${widget.lastReviewed}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFD4AF37),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
