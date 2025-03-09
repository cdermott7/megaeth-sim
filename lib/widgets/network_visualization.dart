import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/models/blockchain_model.dart';

class NetworkNode {
  final double x;
  final double y;
  final double size;
  final bool isMainNode;
  double pulseValue = 0.0;

  NetworkNode({
    required this.x,
    required this.y,
    required this.size,
    required this.isMainNode,
  });
}

class NetworkConnection {
  final NetworkNode from;
  final NetworkNode to;
  final List<NetworkParticle> particles = [];

  NetworkConnection({
    required this.from,
    required this.to,
  });

  double get length {
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    return sqrt(dx * dx + dy * dy);
  }

  Offset get direction {
    final dx = to.x - from.x;
    final dy = to.y - from.y;
    final length = sqrt(dx * dx + dy * dy);
    return Offset(dx / length, dy / length);
  }
}

class NetworkParticle {
  double progress; // 0.0 to 1.0 along the connection
  final Color color;
  final double size;

  NetworkParticle({
    this.progress = 0.0,
    required this.color,
    required this.size,
  });

  void update(double speed) {
    progress += speed;
  }

  bool get isComplete => progress >= 1.0;
}

class NetworkVisualization extends StatefulWidget {
  final BlockchainModel blockchain;
  final Size size;

  const NetworkVisualization({
    Key? key,
    required this.blockchain,
    required this.size,
  }) : super(key: key);

  @override
  NetworkVisualizationState createState() => NetworkVisualizationState();
}

class NetworkVisualizationState extends State<NetworkVisualization> with SingleTickerProviderStateMixin {
  final List<NetworkNode> _nodes = [];
  final List<NetworkConnection> _connections = [];
  late Timer _timer;
  late AnimationController _pulseController;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _setupNetwork();
    _startSimulation();
  }

  @override
  void didUpdateWidget(NetworkVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blockchain != widget.blockchain) {
      // Reset and recreate for new blockchain
      _nodes.clear();
      _connections.clear();
      _setupNetwork();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _setupNetwork() {
    // Create nodes
    // Main/central node
    final centerX = widget.size.width / 2;
    final centerY = widget.size.height / 2;
    
    _nodes.add(NetworkNode(
      x: centerX,
      y: centerY,
      size: 20,
      isMainNode: true,
    ));
    
    // Secondary nodes
    const nodeCount = 7;
    final radius = min(widget.size.width, widget.size.height) * 0.35;
    
    for (int i = 0; i < nodeCount; i++) {
      final angle = 2 * pi * i / nodeCount;
      final x = centerX + cos(angle) * radius;
      final y = centerY + sin(angle) * radius;
      
      _nodes.add(NetworkNode(
        x: x,
        y: y,
        size: 12 + _random.nextDouble() * 6,
        isMainNode: false,
      ));
    }
    
    // Create connections
    final mainNode = _nodes[0];
    
    // Connect main node to all secondary nodes
    for (int i = 1; i < _nodes.length; i++) {
      _connections.add(NetworkConnection(
        from: mainNode,
        to: _nodes[i],
      ));
    }
    
    // Connect some secondary nodes to each other for a more realistic network
    for (int i = 1; i < _nodes.length - 1; i++) {
      _connections.add(NetworkConnection(
        from: _nodes[i],
        to: _nodes[i + 1],
      ));
    }
    
    // Connect the last node to the first to complete the circle
    _connections.add(NetworkConnection(
      from: _nodes[_nodes.length - 1],
      to: _nodes[1],
    ));
  }

  void _startSimulation() {
    // Animation frame rate
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        _updateSimulation();
      });
    });
  }

  void _updateSimulation() {
    // Create new particles
    const particleCreationChance = 0.05; // Probability to create a new particle per frame
    
    // Calculate particle speed based on blockchain propagation delay
    // For fast blockchains, particles move faster
    final particleSpeed = 0.005 + (1 / (1 + widget.blockchain.propagationDelayMs / 100)) * 0.02;
    
    for (final connection in _connections) {
      // Chance to create a new particle
      if (_random.nextDouble() < particleCreationChance) {
        // Randomly determine direction (sometimes from main to secondary, sometimes reverse)
        final color = _random.nextBool() 
            ? AppTheme.primaryPurple
            : AppTheme.primaryCyan;
        
        connection.particles.add(NetworkParticle(
          color: color,
          size: 3 + _random.nextDouble() * 3,
        ));
      }
      
      // Update existing particles
      for (final particle in connection.particles) {
        particle.update(particleSpeed);
      }
      
      // Remove completed particles
      connection.particles.removeWhere((particle) => particle.isComplete);
    }
    
    // Update node pulse effects
    for (final node in _nodes) {
      // Modify pulse value slightly for each node to create variation
      node.pulseValue = 0.5 + 0.5 * sin(_pulseController.value * pi * 2 + _nodes.indexOf(node) * 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: NetworkPainter(
        nodes: _nodes,
        connections: _connections,
      ),
    );
  }
}

class NetworkPainter extends CustomPainter {
  final List<NetworkNode> nodes;
  final List<NetworkConnection> connections;

  NetworkPainter({
    required this.nodes,
    required this.connections,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw connections
    for (final connection in connections) {
      // Premium connection line with gradient and glow effect
      final lineGradientPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.6),
            AppTheme.primaryCyan.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
          Rect.fromPoints(
            Offset(connection.from.x, connection.from.y),
            Offset(connection.to.x, connection.to.y),
          )
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
        
      // Draw glow behind line for premium effect
      final glowLinePaint = Paint()
        ..color = AppTheme.primaryPurple.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round;
        
      // Draw the glow first
      canvas.drawLine(
        Offset(connection.from.x, connection.from.y),
        Offset(connection.to.x, connection.to.y),
        glowLinePaint,
      );
      
      // Then draw the main gradient line
      canvas.drawLine(
        Offset(connection.from.x, connection.from.y),
        Offset(connection.to.x, connection.to.y),
        lineGradientPaint,
      );
      
      // Draw particles moving along the connection
      for (final particle in connection.particles) {
        final particlePaint = Paint()
          ..color = particle.color
          ..style = PaintingStyle.fill;
          
        final dx = connection.to.x - connection.from.x;
        final dy = connection.to.y - connection.from.y;
        
        final particleX = connection.from.x + dx * particle.progress;
        final particleY = connection.from.y + dy * particle.progress;
        
        // Draw the particle with a glow effect
        final glowPaint = Paint()
          ..color = particle.color.withOpacity(0.3)
          ..style = PaintingStyle.fill;
          
        // Glow
        canvas.drawCircle(
          Offset(particleX, particleY),
          particle.size * 2,
          glowPaint,
        );
        
        // Core
        canvas.drawCircle(
          Offset(particleX, particleY),
          particle.size,
          particlePaint,
        );
      }
    }
    
    // Draw nodes with premium effects
    for (final node in nodes) {
      // Outer glow ring - premium effect
      final outerGlowPaint = Paint()
        ..color = (node.isMainNode ? AppTheme.primaryCyan : AppTheme.primaryPurple)
            .withOpacity(0.1 + 0.05 * node.pulseValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + node.pulseValue * 1.5;
      
      canvas.drawCircle(
        Offset(node.x, node.y),
        node.size * (1.5 + 0.6 * node.pulseValue),
        outerGlowPaint,
      );
      
      // Main glow - premium radial
      final Rect glowRect = Rect.fromCircle(
        center: Offset(node.x, node.y),
        radius: node.size * (1.2 + 0.4 * node.pulseValue),
      );
      
      final glowGradient = RadialGradient(
        colors: [
          (node.isMainNode ? AppTheme.primaryCyan : AppTheme.primaryPurple)
              .withOpacity(0.5 + 0.2 * node.pulseValue),
          (node.isMainNode ? AppTheme.primaryCyan : AppTheme.primaryPurple)
              .withOpacity(0.0),
        ],
        stops: const [0.4, 1.0],
      );
      
      final enhancedGlowPaint = Paint()
        ..shader = glowGradient.createShader(glowRect)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(node.x, node.y),
        node.size * (1.0 + 0.5 * node.pulseValue),
        enhancedGlowPaint,
      );
      
      // Core with gradient - premium effect
      final Rect coreRect = Rect.fromCircle(
        center: Offset(node.x, node.y),
        radius: node.size * (0.7 + 0.3 * node.pulseValue),
      );
      
      final coreGradient = RadialGradient(
        colors: node.isMainNode ?
          [
            Colors.white,
            AppTheme.primaryCyan,
            Color(0xFF00BFFF),
          ] :
          [
            Colors.white,
            AppTheme.primaryPurple,
            Color(0xFF6A00FF),
          ],
        stops: const [0.1, 0.4, 1.0],
        focal: const Alignment(-0.2, -0.2),
      );
      
      final coreWithGradientPaint = Paint()
        ..shader = coreGradient.createShader(coreRect)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(node.x, node.y),
        node.size * (0.7 + 0.3 * node.pulseValue),
        coreWithGradientPaint,
      );
      
      // Add highlight to give 3D effect
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(node.x - node.size * 0.2, node.y - node.size * 0.2),
        node.size * 0.2,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(NetworkPainter oldDelegate) => true;
}