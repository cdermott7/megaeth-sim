import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:megaeth_simulator/constants/theme.dart';

class Particle {
  double x;
  double y;
  double dx;
  double dy;
  double size;
  double alpha;
  Color color;
  double rotation = 0;
  double rotationSpeed;

  Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.size,
    required this.alpha,
    required this.color,
    required this.rotationSpeed,
  });

  void update() {
    x += dx;
    y += dy;
    size *= 0.96; // Shrink over time
    alpha *= 0.95; // Fade over time
    rotation += rotationSpeed;
  }

  bool get isDead => alpha < 0.01 || size < 0.5;
}

class ParticleSystem extends StatefulWidget {
  final Offset position;
  final int particleCount;
  final double duration;
  final VoidCallback? onComplete;

  const ParticleSystem({
    Key? key,
    required this.position,
    this.particleCount = 30,
    this.duration = 1.0,
    this.onComplete,
  }) : super(key: key);

  @override
  ParticleSystemState createState() => ParticleSystemState();
}

class ParticleSystemState extends State<ParticleSystem> {
  final List<Particle> _particles = [];
  Timer? _timer;
  final Random _random = Random();
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _createParticles();
    _startAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _createParticles() {
    _particles.clear();
    
    for (int i = 0; i < widget.particleCount; i++) {
      // Random velocity in all directions
      final speed = 1.0 + _random.nextDouble() * 5.0;
      final angle = _random.nextDouble() * 2 * pi;
      
      // More sophisticated particle color palette
      final colorRoll = _random.nextDouble();
      final Color color;
      
      if (colorRoll < 0.4) {
        // Primary colors
        color = _random.nextBool() ? AppTheme.primaryPurple : AppTheme.primaryCyan;
      } else if (colorRoll < 0.7) {
        // Gold accents for premium feel
        color = AppTheme.accentGold;
      } else if (colorRoll < 0.9) {
        // Electric blue for energy
        color = AppTheme.accentBlue;
      } else {
        // Occasional white particles for sparkle
        color = Colors.white;
      }
      
      _particles.add(
        Particle(
          x: widget.position.dx,
          y: widget.position.dy,
          dx: cos(angle) * speed,
          dy: sin(angle) * speed,
          size: 4 + _random.nextDouble() * 8,
          alpha: 0.7 + _random.nextDouble() * 0.3,
          color: color,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        ),
      );
    }
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(_startTime).inMilliseconds / 1000;
      
      if (elapsed > widget.duration) {
        timer.cancel();
        widget.onComplete?.call();
        return;
      }
      
      setState(() {
        for (final particle in _particles) {
          particle.update();
        }
        
        // Remove dead particles
        _particles.removeWhere((particle) => particle.isDead);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(particles: _particles),
      child: Container(),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.alpha)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation);
      
      // Premium particle shapes
      final shapeType = (particle.hashCode % 4); // Deterministic but varied shapes
      
      // Draw glow effect for all particles
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size / 2);
      
      canvas.drawCircle(Offset.zero, particle.size * 1.5, glowPaint);
      
      if (shapeType == 0 && particle.size > 5) {
        // Star shape - premium version
        final path = Path();
        final outerRadius = particle.size;
        final innerRadius = particle.size * 0.4;
        final centerX = 0.0;
        final centerY = 0.0;
        
        // More points for a more complex star
        final numPoints = 6;
        
        for (int i = 0; i < numPoints; i++) {
          final outerAngle = pi / 2 + i * 2 * pi / numPoints;
          final innerAngle = outerAngle + pi / numPoints;
          
          final outerX = centerX + cos(outerAngle) * outerRadius;
          final outerY = centerY + sin(outerAngle) * outerRadius;
          final innerX = centerX + cos(innerAngle) * innerRadius;
          final innerY = centerY + sin(innerAngle) * innerRadius;
          
          if (i == 0) {
            path.moveTo(outerX, outerY);
          } else {
            path.lineTo(outerX, outerY);
          }
          
          path.lineTo(innerX, innerY);
        }
        
        path.close();
        canvas.drawPath(path, paint);
        
        // Add inner highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.0);
          
        canvas.drawCircle(Offset.zero, particle.size * 0.2, highlightPaint);
      } 
      else if (shapeType == 1) {
        // Diamond shape
        final path = Path();
        final size = particle.size * 0.7;
        
        path.moveTo(0, -size);
        path.lineTo(size, 0);
        path.lineTo(0, size);
        path.lineTo(-size, 0);
        path.close();
        
        canvas.drawPath(path, paint);
        
        // Inner highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.fill;
          
        final innerPath = Path();
        final innerSize = size * 0.4;
        
        innerPath.moveTo(0, -innerSize);
        innerPath.lineTo(innerSize, 0);
        innerPath.lineTo(0, innerSize);
        innerPath.lineTo(-innerSize, 0);
        innerPath.close();
        
        canvas.drawPath(innerPath, highlightPaint);
      }
      else if (shapeType == 2) {
        // Hexagon
        final path = Path();
        final size = particle.size * 0.6;
        
        for (int i = 0; i < 6; i++) {
          final angle = i * pi / 3;
          final x = cos(angle) * size;
          final y = sin(angle) * size;
          
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        
        path.close();
        canvas.drawPath(path, paint);
      }
      else {
        // Premium circle with inner highlight
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);
        
        // Inner highlight for depth
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.fill;
          
        canvas.drawCircle(Offset(-particle.size/6, -particle.size/6), particle.size/5, highlightPaint);
      }
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}