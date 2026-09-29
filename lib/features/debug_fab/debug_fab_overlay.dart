import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:payment_approval/features/approval/presentation/approval_presenter.dart';
import 'package:payment_approval/features/debug_fab/fab_position.dart';
import 'package:payment_approval/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:payment_approval/l10n/app_localizations.dart';

/// Debug button that simulates an incoming payment request
///
/// It sits above the router, so it floats over every screen and stays where it was dragged. It
/// hides while a request is on screen
class DebugFabOverlay extends StatefulWidget {
  const DebugFabOverlay({required this.presenter, required this.child, super.key});

  final ApprovalPresenter presenter;
  final Widget child;

  @override
  State<DebugFabOverlay> createState() => _DebugFabOverlayState();
}

class _DebugFabOverlayState extends State<DebugFabOverlay> {
  /// Null until the first drag, so the default spot follows the screen size
  Offset? _position;

  @override
  Widget build(BuildContext context) {
    final isLoaded = context.select((PaymentsBloc bloc) => bloc.state is PaymentsLoaded);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = constraints.biggest;
        final safeArea = MediaQuery.paddingOf(context);
        final position = clampFabPosition(
          _position ??
              defaultFabPosition(
                screen: screen,
                safeArea: safeArea,
                size: fabSize,
                textDirection: Directionality.of(context),
              ),
          screen: screen,
          safeArea: safeArea,
          size: fabSize,
        );

        return Stack(
          children: [
            widget.child,
            Positioned(
              left: position.dx,
              top: position.dy,
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.presenter.isBusy,
                builder: (context, isBusy, _) => _DebugFab(
                  visible: isLoaded && !isBusy,
                  size: fabSize,
                  onTap: widget.presenter.simulateIncomingRequest,
                  // Start from the shown position, which may have been clamped after a resize
                  onDragStart: () => _position = position,
                  // Several moves can arrive in one frame, so each builds on the latest position
                  onDrag: (delta) => setState(() {
                    _position = clampFabPosition(
                      (_position ?? position) + delta,
                      screen: screen,
                      safeArea: safeArea,
                      size: fabSize,
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DebugFab extends StatelessWidget {
  const _DebugFab({
    required this.visible,
    required this.size,
    required this.onTap,
    required this.onDragStart,
    required this.onDrag,
  });

  final bool visible;
  final double size;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final ValueChanged<Offset> onDrag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = AppLocalizations.of(context).debugFabLabel;

    return IgnorePointer(
      ignoring: !visible,
      child: ExcludeSemantics(
        excluding: !visible,
        child: AnimatedScale(
          scale: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          // A plain GestureDetector, because Draggable and Tooltip need an Overlay and this sits
          // above the Navigator
          child: GestureDetector(
            // Includes the movement before the drag was recognized, so the button stays under the
            // finger
            dragStartBehavior: DragStartBehavior.down,
            onPanStart: (_) => onDragStart(),
            onPanUpdate: (details) => onDrag(details.delta),
            child: Semantics(
              button: true,
              label: label,
              child: Material(
                color: colorScheme.secondary,
                shape: const CircleBorder(),
                elevation: 6,
                shadowColor: colorScheme.secondary.withValues(alpha: 0.5),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onTap();
                  },
                  child: SizedBox.square(
                    dimension: size,
                    child: Icon(Icons.add_rounded, size: 30, color: colorScheme.onSecondary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
