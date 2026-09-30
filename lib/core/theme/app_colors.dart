import 'package:material_ui/material_ui.dart';

@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.approved,
    required this.approvedContainer,
    required this.rejected,
    required this.rejectedContainer,
    required this.pending,
    required this.pendingContainer,
  });

  static const light = StatusColors(
    approved: Color(0xFF067647),
    approvedContainer: Color(0xFFE7F7EE),
    rejected: Color(0xFFB42318),
    rejectedContainer: Color(0xFFFDECEA),
    pending: Color(0xFFB54708),
    pendingContainer: Color(0xFFFEF4E6),
  );

  static const dark = StatusColors(
    approved: Color(0xFF75E0A7),
    approvedContainer: Color(0xFF0B3321),
    rejected: Color(0xFFFDA29B),
    rejectedContainer: Color(0xFF4A1510),
    pending: Color(0xFFFEC84B),
    pendingContainer: Color(0xFF45240B),
  );

  final Color approved;
  final Color approvedContainer;
  final Color rejected;
  final Color rejectedContainer;
  final Color pending;
  final Color pendingContainer;

  @override
  StatusColors copyWith({
    Color? approved,
    Color? approvedContainer,
    Color? rejected,
    Color? rejectedContainer,
    Color? pending,
    Color? pendingContainer,
  }) {
    return StatusColors(
      approved: approved ?? this.approved,
      approvedContainer: approvedContainer ?? this.approvedContainer,
      rejected: rejected ?? this.rejected,
      rejectedContainer: rejectedContainer ?? this.rejectedContainer,
      pending: pending ?? this.pending,
      pendingContainer: pendingContainer ?? this.pendingContainer,
    );
  }

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;

    return StatusColors(
      approved: Color.lerp(approved, other.approved, t)!,
      approvedContainer: Color.lerp(approvedContainer, other.approvedContainer, t)!,
      rejected: Color.lerp(rejected, other.rejected, t)!,
      rejectedContainer: Color.lerp(rejectedContainer, other.rejectedContainer, t)!,
      pending: Color.lerp(pending, other.pending, t)!,
      pendingContainer: Color.lerp(pendingContainer, other.pendingContainer, t)!,
    );
  }
}

extension StatusColorsContext on BuildContext {
  StatusColors get statusColors => Theme.of(this).extension<StatusColors>()!;
}
