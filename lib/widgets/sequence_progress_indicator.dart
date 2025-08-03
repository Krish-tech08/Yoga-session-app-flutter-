import 'package:flutter/material.dart';

class SequenceProgressIndicator extends StatelessWidget {
  final int currentSequence;
  final int totalSequences;
  final List<String> sequenceNames;
  final List<bool> isLoopSequence;

  const SequenceProgressIndicator({
    Key? key,
    required this.currentSequence,
    required this.totalSequences,
    required this.sequenceNames,
    required this.isLoopSequence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSequences, (index) {
          final isActive = index == currentSequence;
          final isCompleted = index < currentSequence;
          final isLoop = index < isLoopSequence.length ? isLoopSequence[index] : false;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? Colors.green[400]
                        : isActive
                        ? (isLoop ? const Color(0xFF4facfe) : const Color(0xFF667eea))
                        : Colors.grey[300],
                    border: isActive
                        ? Border.all(
                      color: isLoop ? const Color(0xFF4facfe) : const Color(0xFF667eea),
                      width: 2,
                    )
                        : null,
                  ),
                  child: isCompleted
                      ? const Icon(
                    Icons.check,
                    size: 6,
                    color: Colors.white,
                  )
                      : isLoop && isActive
                      ? const Icon(
                    Icons.repeat,
                    size: 6,
                    color: Colors.white,
                  )
                      : null,
                ),
                const SizedBox(height: 4),
                if (isActive)
                  Text(
                    sequenceNames[index].replaceAll('_', ' '),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}