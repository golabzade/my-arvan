import 'package:flutter/material.dart';
import '../models/server.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  factory StatusBadge.fromServerStatus(ServerStatus status) {
    switch (status) {
      case ServerStatus.active:
        return const StatusBadge(
          label: 'Active',
          color: Color(0xFF10B981),
        );
      case ServerStatus.shutoff:
        return const StatusBadge(
          label: 'Off',
          color: Color(0xFF64748B),
        );
      case ServerStatus.shelvedOffloaded:
        return const StatusBadge(
          label: 'Terminated',
          color: Color(0xFFEF4444),
        );
      case ServerStatus.reboot:
        return const StatusBadge(
          label: 'Rebooting',
          color: Color(0xFFF59E0B),
        );
      case ServerStatus.build:
        return const StatusBadge(
          label: 'Building',
          color: Color(0xFF3B82F6),
        );
      case ServerStatus.unknown:
        return const StatusBadge(
          label: 'Unknown',
          color: Color(0xFF94A3B8),
        );
    }
  }

  factory StatusBadge.fromDatacenterState(String state) {
    final isUp = state.toLowerCase() == 'up';
    return StatusBadge(
      label: isUp ? 'Operational' : state.toUpperCase(),
      color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(76), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
