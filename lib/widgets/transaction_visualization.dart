import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Import for HapticFeedback
import 'package:megaeth_simulator/models/transaction_model.dart';
import 'package:megaeth_simulator/widgets/particle_effects.dart';
import 'package:megaeth_simulator/constants/theme.dart';

class TransactionVisualization extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Function(String) onTransactionSelected;

  const TransactionVisualization({
    Key? key,
    required this.transactions,
    required this.onTransactionSelected,
  }) : super(key: key);

  @override
  TransactionVisualizationState createState() => TransactionVisualizationState();
}

class TransactionVisualizationState extends State<TransactionVisualization> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Map<String, Key> _particleKeys = {};
  final Map<String, bool> _showingParticles = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        
        return Stack(
          children: [
            // Background grid
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: GridPainter(),
            ),
            
            // Transactions
            ...widget.transactions.map((transaction) {
              // Create a unique key for each transaction's particles if not exists
              _particleKeys.putIfAbsent(transaction.id, () => UniqueKey());
              
              // Check if this transaction was just confirmed and needs particles
              final needsParticles = transaction.isConfirmed && !_showingParticles.containsKey(transaction.id);
              if (needsParticles) {
                _showingParticles[transaction.id] = true;
              }
              
              // Adjust transaction size for mobile screens to be more touch-friendly
              final adjustedSize = isMobile ? 
                  transaction.size * 1.5 : // 50% larger on mobile for easier touch
                  transaction.size;
              
              return Stack(
                children: [
                  // The transaction circle
                  Positioned(
                    left: transaction.x - adjustedSize / 2,
                    top: transaction.y - adjustedSize / 2,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(adjustedSize),
                        onTap: () {
                          widget.onTransactionSelected(transaction.id);
                          // Add haptic feedback on mobile
                          if (isMobile) {
                            HapticFeedback.lightImpact();
                          }
                        },
                        // Use a larger hit area for mobile touch
                        child: Container(
                          width: adjustedSize,
                          height: adjustedSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                transaction.color.withOpacity(1.0),
                                transaction.color.withOpacity(0.8),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: transaction.color.withOpacity(0.7),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: -3,
                                offset: const Offset(-2, -2),
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: transaction.isConfirmed
                                ? Icon(
                                    Icons.check, 
                                    color: Colors.white,
                                    size: isMobile ? 22 : 16, // Larger icon on mobile
                                  )
                                : transaction.isSelected
                                    ? const SizedBox() // Empty when selected
                                    : AnimatedBuilder(
                                        animation: _animationController,
                                        builder: (context, child) {
                                          return Opacity(
                                            opacity: 0.6 + _animationController.value * 0.4,
                                            child: child,
                                          );
                                        },
                                        child: Icon(
                                          Icons.circle, 
                                          color: Colors.white70, 
                                          size: isMobile ? 12 : 8, // Larger on mobile
                                        ),
                                      ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Particle effect when confirmed
                  if (needsParticles)
                    Positioned(
                      left: transaction.x,
                      top: transaction.y,
                      child: ParticleSystem(
                        key: _particleKeys[transaction.id],
                        position: Offset.zero,
                        particleCount: isMobile ? 60 : 40, // More particles on mobile for more visible effect
                        duration: 1.5,
                        onComplete: () {
                          setState(() {
                            _showingParticles.remove(transaction.id);
                          });
                        },
                      ),
                    ),
                ],
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines
    const double spacing = 40.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Draw some diagonal accent lines for futuristic look
    final accentPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    for (double x = 0; x < size.width; x += spacing * 3) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), accentPaint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}