import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import '../utils/constants.dart';
import 'add_item.dart';

class DetectorScreen extends StatefulWidget {
  const DetectorScreen({super.key});

  @override
  State<DetectorScreen> createState() => _DetectorScreenState();
}

class _DetectorScreenState extends State<DetectorScreen> {
  List<YOLOResult> _detections = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Item'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          YOLOView(
            modelPath: 'assets/models/yolo8_clothing.tflite',
            task: YOLOTask.detect,
            confidenceThreshold: 0.25,
            iouThreshold: 0.4,
            onResult: (List<YOLOResult> results) {
              if (mounted) {
                setState(() => _detections = results);
              }
            },
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tap a detected object to add it',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  _uniqueDetections().isEmpty
                      ? const Text(
                    'Point camera at an item…',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 14),
                  )
                      : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _uniqueDetections()
                        .map((r) => _DetectionChip(
                      label: r.className ?? 'Unknown',
                      confidence: r.confidence ?? 0.0,
                      onTap: () => _onItemConfirmed(
                          r.className ?? 'Unknown'),
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<YOLOResult> _uniqueDetections() {
    final Map<String, YOLOResult> best = {};
    for (final r in _detections) {
      final label = r.className ?? 'Unknown';
      final conf = r.confidence ?? 0.0;
      if (!best.containsKey(label) ||
          conf > (best[label]!.confidence ?? 0.0)) {
        best[label] = r;
      }
    }
    final sorted = best.values.toList()
      ..sort((a, b) =>
          (b.confidence ?? 0.0).compareTo(a.confidence ?? 0.0));
    return sorted;
  }

  // Capitalise label and navigate to AddItemScreen with name pre-filled.
  void _onItemConfirmed(String label) {
    final name = label
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AddItemScreen(detectedName: name),
      ),
    );
  }
}

class _DetectionChip extends StatelessWidget {
  final String label;
  final double confidence;
  final VoidCallback onTap;

  const _DetectionChip({
    required this.label,
    required this.confidence,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).toStringAsFixed(0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$pct%',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}