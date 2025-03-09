import 'package:flutter/material.dart';
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/models/blockchain_model.dart';
import 'dart:math';

class StatsDisplay extends StatelessWidget {
  final BlockchainModel blockchain;
  final int confirmedTransactions;
  final double averageConfirmationTimeMs;
  final double currentThroughput;
  final bool compactMode; // Add flag for mobile compact mode

  const StatsDisplay({
    Key? key,
    required this.blockchain,
    required this.confirmedTransactions,
    required this.averageConfirmationTimeMs,
    required this.currentThroughput,
    this.compactMode = false, // Default to regular mode
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final efficiency = _calculateEfficiency();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: compactMode ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8) : const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Title
          Text(
            'Performance Metrics',
            style: compactMode 
                ? AppTheme.subHeadingStyle.copyWith(fontSize: 16) 
                : AppTheme.subHeadingStyle,
          ),
          SizedBox(height: compactMode ? 8 : 16),
          
          // Performance metrics
          _buildMetricRow(
            compactMode ? 'Confirmed:' : 'Confirmed Transactions:',
            confirmedTransactions.toString(),
            compact: compactMode,
          ),
          SizedBox(height: compactMode ? 6 : 12),
          
          _buildMetricRow(
            compactMode ? 'Confirm Time:' : 'Avg. Confirmation Time:',
            _formatTimeValue(averageConfirmationTimeMs),
            compact: compactMode,
          ),
          SizedBox(height: compactMode ? 6 : 12),
          
          _buildMetricRow(
            compactMode ? 'Throughput:' : 'Current Throughput:',
            '${currentThroughput.toStringAsFixed(1)} TPS',
            compact: compactMode,
          ),
          SizedBox(height: compactMode ? 6 : 12),
          
          _buildMetricRow(
            compactMode ? 'Efficiency:' : 'Hardware Efficiency:',
            '${(efficiency * 100).toStringAsFixed(1)}%',
            valueColor: _getEfficiencyColor(efficiency),
            compact: compactMode,
          ),
          SizedBox(height: compactMode ? 12 : 24),
          
          // Visual throughput meter (mobile friendly)
          _buildThroughputMeter(compact: compactMode),
          
          // Conditionally show latency comparison based on space
          if (!compactMode || screenWidth > 350) ...[
            SizedBox(height: compactMode ? 12 : 24),
            // Latency comparison with smaller height for mobile
            _buildLatencyComparison(compact: compactMode),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? valueColor, bool compact = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: compact ? 12 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppTheme.primaryCyan,
            fontWeight: FontWeight.bold,
            fontSize: compact ? 14 : 16,
          ),
        ),
      ],
    );
  }

  String _formatTimeValue(double timeMs) {
    if (timeMs < 1) {
      return '< 1 ms';
    } else if (timeMs < 1000) {
      return '${timeMs.toStringAsFixed(1)} ms';
    } else {
      return '${(timeMs / 1000).toStringAsFixed(2)} s';
    }
  }

  // Calculate efficiency as a ratio of actual throughput to max possible
  double _calculateEfficiency() {
    if (blockchain.maxTransactionsPerSecond == 0 || currentThroughput == 0) {
      return 0;
    }
    return min(currentThroughput / blockchain.maxTransactionsPerSecond, 1.0);
  }

  // Get color based on efficiency percentage
  Color _getEfficiencyColor(double efficiency) {
    if (efficiency < 0.3) {
      return Colors.red;
    } else if (efficiency < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  Widget _buildThroughputMeter({bool compact = false}) {
    final efficiency = _calculateEfficiency();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Throughput',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: compact ? 12 : 14,
          ),
        ),
        SizedBox(height: compact ? 4 : 8),
        
        // Progress indicator - smaller height for mobile
        Container(
          width: double.infinity,
          height: compact ? 16 : 20,
          decoration: BoxDecoration(
            color: AppTheme.darkBackground,
            borderRadius: BorderRadius.circular(compact ? 8 : 10),
            border: Border.all(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Background with grid lines
              Positioned.fill(
                child: CustomPaint(
                  painter: GridLinePainter(),
                ),
              ),
              
              // Fill
              FractionallySizedBox(
                widthFactor: efficiency,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryCyan.withOpacity(0.7),
                        AppTheme.primaryPurple.withOpacity(0.7),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(compact ? 8 : 10),
                  ),
                ),
              ),
              
              // Value text - smaller for mobile
              Center(
                child: Text(
                  compact 
                    ? '${currentThroughput.toInt()} / ${blockchain.maxTransactionsPerSecond}'
                    : '${currentThroughput.toInt()} / ${blockchain.maxTransactionsPerSecond} TPS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 10 : 12,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLatencyComparison({bool compact = false}) {
    // Comparison values for reference (in ms)
    const humanReactionTime = 250.0;
    const keyPressRegistration = 8.0;
    const mouseClickLatency = 12.0;
    const highFreqTrading = 0.5;
    
    // Adjust height based on compact mode for mobile
    final chartHeight = compact ? 100.0 : 140.0; 
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Latency Comparison',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: compact ? 12 : 14,
          ),
        ),
        SizedBox(height: compact ? 4 : 8),
        
        // Latency comparison chart (logarithmic scale) - reduced height on mobile
        SizedBox(
          height: chartHeight, 
          child: CustomPaint(
            size: Size(double.infinity, chartHeight),
            painter: LatencyComparisonPainter(
              blockchain: blockchain,
              actualLatency: averageConfirmationTimeMs,
              compactMode: compact,
            ),
          ),
        ),
        
        // Legend in a more compact, organized grid
        Padding(
          padding: EdgeInsets.only(top: compact ? 2.0 : 4.0),
          child: Wrap(
            spacing: compact ? 5 : 10,
            runSpacing: compact ? 4 : 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('MegaETH', AppTheme.primaryCyan, compact: compact),
              _buildLegendItem('Ethereum', Colors.blue, compact: compact),
              _buildLegendItem('Arbitrum', Colors.indigo, compact: compact),
              _buildLegendItem('opBNB', Colors.amber, compact: compact),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, {bool compact = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 8 : 12,
          height: compact ? 8 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: compact ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: compact ? 9 : 12,
          ),
        ),
      ],
    );
  }
}

class GridLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw vertical grid lines
    final barWidth = size.width;
    final step = barWidth / 10;
    
    for (int i = 1; i < 10; i++) {
      canvas.drawLine(
        Offset(step * i, 0),
        Offset(step * i, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LatencyComparisonPainter extends CustomPainter {
  final BlockchainModel blockchain;
  final double actualLatency;
  final bool compactMode;
  
  // Comparison values in ms (scientifically accurate)
  static const double humanReactionTime = 215.0; // Average visual reaction time
  static const double keyPressRegistration = 8.0; // Typical keyboard input latency
  static const double mouseClickLatency = 10.0; // Average mouse click registration
  static const double highFreqTrading = 0.5; // High-frequency trading response
  
  // For log scale visualization
  static const double minLatency = 0.1; // 0.1ms
  static const double maxLatency = 15000.0; // 15 seconds
  
  LatencyComparisonPainter({
    required this.blockchain,
    required this.actualLatency,
    this.compactMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create logarithmic scale
    final logMinLatency = log(minLatency) / log(10);
    final logMaxLatency = log(maxLatency) / log(10);
    final logRange = logMaxLatency - logMinLatency;
    
    // Helper to convert ms to x position
    double msToX(double ms) {
      final logMs = log(max(ms, minLatency)) / log(10);
      final normalizedPos = (logMs - logMinLatency) / logRange;
      return size.width * normalizedPos;
    }
    
    // Draw background grid
    _drawGrid(canvas, size, msToX);
    
    // Define comparison values to visualize - simplified for clarity
    // More focused set of comparison points to avoid overlapping
    final items = [
      _LatencyItem('MegaETH', blockchain.totalLatencyMs, AppTheme.primaryCyan),
      _LatencyItem('Arbitrum', 250 + 120, Colors.indigo), // 250ms block time + 120ms propagation
      _LatencyItem('opBNB', 1000 + 150, Colors.amber), // 1s block time + 150ms propagation
      _LatencyItem('Ethereum', 12000 + 700, Colors.blue), // 12s block time + 700ms propagation
    ];
    
    // Sort items by latency to handle label positioning better
    items.sort((a, b) => a.latencyMs.compareTo(b.latencyMs));
    
    // Draw each latency comparison with better spacing
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final x = msToX(item.latencyMs);
      
      // Skip if out of bounds
      if (x < 0 || x > size.width) continue;
      
      // Draw vertical line (thinner on mobile)
      final linePaint = Paint()
        ..color = item.color.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = compactMode ? 1.5 : 2;
        
      canvas.drawLine(
        Offset(x, size.height * 0.3),
        Offset(x, size.height * 0.7),
        linePaint,
      );
      
      // Draw marker dot (smaller on mobile)
      final dotPaint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;
        
      canvas.drawCircle(
        Offset(x, size.height * 0.5),
        compactMode ? 5 : 7,
        dotPaint,
      );
      
      // Draw background for text to improve readability
      final textBgPaint = Paint()
        ..color = Colors.black.withOpacity(0.6)
        ..style = PaintingStyle.fill;
        
      // Alternate label positions (top/bottom) to avoid overlap
      final isTop = i % 2 == 0;
      final labelY = isTop ? size.height * 0.10 : size.height * 0.75;
      
      // Draw formatted text (smaller on mobile)
      final formattedTime = _formatLatency(item.latencyMs);
      final textSpan = TextSpan(
        text: item.name,
        style: TextStyle(
          color: item.color,
          fontSize: compactMode ? 9 : 11,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(
            text: '\n$formattedTime',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: compactMode ? 8 : 10,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      
      // Limit width more aggressively on mobile
      textPainter.layout(minWidth: 0, maxWidth: compactMode ? 50 : 60);
      
      // Draw text background
      final textRect = Rect.fromCenter(
        center: Offset(x, labelY + textPainter.height / 2),
        width: textPainter.width + (compactMode ? 6 : 10),
        height: textPainter.height + (compactMode ? 4 : 6),
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(textRect, Radius.circular(compactMode ? 3 : 4)),
        textBgPaint,
      );
      
      // Draw the text
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, labelY),
      );
    }
  }
  
  void _drawGrid(Canvas canvas, Size size, double Function(double) msToX) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = compactMode ? 0.5 : 1;
    
    // Draw logarithmic grid lines at powers of 10
    // For mobile, show fewer grid lines
    final values = compactMode 
        ? [0.1, 10.0, 1000.0, 10000.0] // Fewer values for mobile
        : [0.1, 1.0, 10.0, 100.0, 1000.0, 10000.0];
    
    for (final value in values) {
      final x = msToX(value);
      
      // Skip if out of bounds
      if (x < 0 || x > size.width) continue;
      
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
      
      // Draw tick label (smaller on mobile)
      final textSpan = TextSpan(
        text: _formatLatency(value),
        style: TextStyle(
          color: Colors.white70,
          fontSize: compactMode ? 8 : 10,
        ),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - (compactMode ? 12 : 15)),
      );
    }
    
    // Draw horizontal axis line
    canvas.drawLine(
      Offset(0, size.height - 2),
      Offset(size.width, size.height - 2),
      gridPaint,
    );
  }
  
  String _formatLatency(double ms) {
    if (ms < 1) {
      return '${ms.toStringAsFixed(1)}ms';
    } else if (ms < 1000) {
      return '${ms.toStringAsFixed(0)}ms';
    } else {
      return '${(ms / 1000).toStringAsFixed(1)}s';
    }
  }

  @override
  bool shouldRepaint(covariant LatencyComparisonPainter oldDelegate) =>
      oldDelegate.blockchain != blockchain || 
      oldDelegate.actualLatency != actualLatency ||
      oldDelegate.compactMode != compactMode;
}

class _LatencyItem {
  final String name;
  final double latencyMs;
  final Color color;
  
  _LatencyItem(this.name, this.latencyMs, this.color);
}