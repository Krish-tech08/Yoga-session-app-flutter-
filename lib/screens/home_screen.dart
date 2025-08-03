
import 'package:flutter/material.dart';
import 'package:yoga_session_app/screens/session_screen.dart';

import '../models/asana_session.dart';

class YogaHomeScreen extends StatefulWidget {
  const YogaHomeScreen({super.key});

  @override
  State<YogaHomeScreen> createState() => _YogaHomeScreenState();
}

class _YogaHomeScreenState extends State<YogaHomeScreen> {
  AsanaSession? session;
  bool isLoading = true;
  int selectedLoopCount = 4;

  @override
  void initState() {
    super.initState();
    loadSession();
  }

  Future<void> loadSession() async {
    try {
      // In a real app, you'd load from assets
      // For demo, using the provided sample data
      final sampleData = getSampleAsanaData();
      setState(() {
        session = AsanaSession.fromJson(sampleData, customLoopCount: selectedLoopCount);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading session: $e')),
      );
    }
  }

  void updateLoopCount(int count) {
    setState(() {
      selectedLoopCount = count;
      if (session != null) {
        session = AsanaSession.fromJson(getSampleAsanaData(), customLoopCount: count);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ArvyaX Yoga')),
        body: const Center(
          child: Text('Failed to load yoga session'),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                Text(
                  session!.metadata.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${session!.metadata.category.toUpperCase()} • ${session!.totalDuration ~/ 60} min ${session!.totalDuration % 60} sec',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),

                // Session Preview
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Loop Count Selector
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Repetitions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [1, 2, 3, 4, 5, 6].map((count) {
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => updateLoopCount(count),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: selectedLoopCount == count
                                              ? const Color(0xFF667eea)
                                              : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$count',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: selectedLoopCount == count
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        // Sequence Preview
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: session!.sequence.length,
                            itemBuilder: (context, index) {
                              final sequence = session!.sequence[index];
                              return SequencePreviewCard(
                                sequence: sequence,
                                session: session!,
                                index: index + 1,
                              );
                            },
                          ),
                        ),

                        // Start Session Button
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AsanaSessionScreen(session: session!),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF667eea),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'Start Session',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class SequencePreviewCard extends StatelessWidget {
  final AsanaSequence sequence;
  final AsanaSession session;
  final int index;

  const SequencePreviewCard({
    Key? key,
    required this.sequence,
    required this.session,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = sequence.isLoop
        ? sequence.durationSec * session.actualLoopCount
        : sequence.durationSec;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Sequence Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: sequence.isLoop ? const Color(0xFF4facfe) : const Color(0xFF667eea),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                sequence.isLoop ? Icons.repeat : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 15),

          // Sequence Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sequence.name.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${duration}s ${sequence.isLoop ? '(${session.actualLoopCount}x ${sequence.durationSec}s)' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${sequence.script.length} script elements',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Type indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: sequence.isLoop ? Colors.blue[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              sequence.type.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: sequence.isLoop ? Colors.blue[700] : Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}