import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';

void useDelayedAutoMove<T>({
  bool enabled = true,
  required bool isUserInteracting,
  required Object gameKey,
  required T Function() stateGetter,
  required T? Function(T) nextStateGetter,
  required Function(T) onNewState,
  Duration initialDelay = const Duration(milliseconds: 500),
  Duration repeatingDelay = const Duration(milliseconds: 300),
}) {
  // Create refs for callback functions to avoid recreation
  final stateGetterRef = useRef(stateGetter);
  final nextStateGetterRef = useRef(nextStateGetter);
  final onNewStateRef = useRef(onNewState);

  // Update refs when functions change
  useEffect(() {
    stateGetterRef.value = stateGetter;
    nextStateGetterRef.value = nextStateGetter;
    onNewStateRef.value = onNewState;
    return null;
  }, [stateGetter, nextStateGetter, onNewState]);

  // Core state
  final previousGameKeyRef = useRef(gameKey);
  final isRunning = useState(false);
  final wasUserInteracting = useState(false);

  // Function to start auto-move sequence
  void startAutoMoveSequence() {
    if (isRunning.value || !enabled) return;

    isRunning.value = true;

    // Reset state flags
    wasUserInteracting.value = false;

    // Function to process the actual auto-move sequence
    Future<void> processSequence() async {
      bool isActive = true; // Track if this sequence is still valid

      // Apply appropriate initial delay
      await Future.delayed(initialDelay);

      // Check if we should still continue
      if (!isActive || !isRunning.value || !enabled) return;

      // Process auto-moves until no more are available
      while (isActive && isRunning.value && enabled) {
        // Get current state and check for a valid move
        final currentState = stateGetterRef.value();
        final nextState = nextStateGetterRef.value(currentState);

        // If no valid move, exit the loop
        if (nextState == null) break;

        // Apply the move
        onNewStateRef.value(nextState);

        // Wait before trying the next move
        await Future.delayed(repeatingDelay);

        // Check if we should still continue
        if (!isActive || !isRunning.value || !enabled) return;
      }

      // Reset running state when done
      if (isActive) {
        isRunning.value = false;
      }
    }

    // Start the sequence asynchronously
    processSequence();
  }

  // Handle game restart
  useEffect(() {
    if (previousGameKeyRef.value != gameKey) {
      previousGameKeyRef.value = gameKey;

      // Schedule a check for auto-moves
      Future.microtask(() {
        startAutoMoveSequence();
      });
    }
    return null;
  }, [gameKey]);

  // Handle user interaction
  useEffect(() {
    if (isUserInteracting) {
      wasUserInteracting.value = true;
      isRunning.value = false; // Stop any ongoing sequence
    }
    return null;
  }, [isUserInteracting]);

  // Main effect to start auto-move when conditions change
  useEffect(() {
    if (!isRunning.value && enabled && !isUserInteracting) {
      // Check if there are valid moves
      final currentState = stateGetterRef.value();
      final hasValidMove = nextStateGetterRef.value(currentState) != null;

      if (hasValidMove) {
        // Slight delay to avoid immediate restart after a sequence just finished
        Future.microtask(() {
          startAutoMoveSequence();
        });
      }
    }

    return null;
  }, [enabled, isRunning.value, isUserInteracting, stateGetter()]);

  // Additional effect to ensure cleanup
  useEffect(() {
    return () {
      // Cleanup when hook unmounts
      isRunning.value = false;
    };
  }, []);
}
