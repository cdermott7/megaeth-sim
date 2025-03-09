import 'package:flutter/material.dart';
import 'package:megaeth_simulator/constants/theme.dart';

class TooltipHelper extends StatelessWidget {
  final String tooltipText;
  final Widget child;
  final double width;

  const TooltipHelper({
    Key? key,
    required this.tooltipText,
    required this.child,
    this.width = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: TextSpan(
        text: tooltipText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      preferBelow: true,
      showDuration: const Duration(seconds: 5),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryCyan.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryCyan.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(width: 4),
          const Icon(
            Icons.info_outline,
            color: AppTheme.primaryCyan,
            size: 16,
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final VoidCallback? onTap;

  const InfoCard({
    Key? key,
    required this.title,
    required this.description,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkBackgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with icon
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: AppTheme.primaryCyan,
                    size: 20,
                  ),
                if (icon != null)
                  const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlitchEffect extends StatefulWidget {
  final Widget child;
  final double intensity;
  final Duration duration;

  const GlitchEffect({
    Key? key,
    required this.child,
    this.intensity = 0.5,
    this.duration = const Duration(milliseconds: 2000),
  }) : super(key: key);

  @override
  State<GlitchEffect> createState() => _GlitchEffectState();
}

class _GlitchEffectState extends State<GlitchEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glitchAmount = widget.intensity * (_controller.value / 5);
        
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                AppTheme.primaryCyan.withOpacity(_controller.value * 0.2),
                Colors.white.withOpacity(_controller.value * 0.3),
                AppTheme.primaryPurple.withOpacity(_controller.value * 0.2),
              ],
              stops: [0.0, 0.5, 1.0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Stack(
            children: [
              // Main content
              widget.child,
              
              // Glitch offset effect when animation is at peak
              if (_controller.value > 0.8)
                Positioned(
                  left: 2 * glitchAmount,
                  right: -2 * glitchAmount,
                  top: 0,
                  bottom: 0,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primaryCyan.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: widget.child,
                  ),
                ),
                
              // Occasional random horizontal glitch lines
              if (_controller.value > 0.9)
                Positioned.fill(
                  child: CustomPaint(
                    painter: GlitchLinePainter(
                      intensity: widget.intensity,
                      animationValue: _controller.value,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class GlitchLinePainter extends CustomPainter {
  final double intensity;
  final double animationValue;
  
  GlitchLinePainter({
    required this.intensity,
    required this.animationValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = animationValue * 1000;
    final lineCount = (intensity * 5).round();
    
    for (int i = 0; i < lineCount; i++) {
      final y = (random + i * 50) % size.height;
      final width = intensity * 50 + (random + i * 10) % (size.width / 2);
      final x = (random + i * 20) % (size.width - width);
      
      final paint = Paint()
        ..color = i % 2 == 0 ? 
                  AppTheme.primaryCyan.withOpacity(0.3) : 
                  AppTheme.primaryPurple.withOpacity(0.3)
        ..style = PaintingStyle.fill;
        
      canvas.drawRect(
        Rect.fromLTWH(x, y, width, 1 + intensity),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant GlitchLinePainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}