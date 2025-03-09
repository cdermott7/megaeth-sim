import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/models/blockchain_model.dart';
import 'package:megaeth_simulator/widgets/particle_effects.dart';

/// A visualization inspired by the bunny/carrot demo showing how block time
/// and network propagation delay affect user experience in blockchain applications.
class BlockGame extends StatefulWidget {
  final BlockchainModel blockchain;
  final bool isRunning;

  const BlockGame({
    Key? key,
    required this.blockchain,
    required this.isRunning,
  }) : super(key: key);

  @override
  BlockGameState createState() => BlockGameState();
}

class BlockGameState extends State<BlockGame> with TickerProviderStateMixin {
  // Game state
  Offset _userPosition = Offset.zero;
  Offset _blockchainPosition = Offset.zero;
  List<GameTarget> _targets = [];
  int _score = 0;
  int _missedTargets = 0;
  
  // Game dimensions
  double _gameWidth = 300;
  double _gameHeight = 400;
  bool _isInitialized = false;
  
  // Animation controllers for effects
  late AnimationController _glitchController;
  late AnimationController _pulseController;
  late AnimationController _blockchainController;
  
  // Game timing
  Timer? _gameTimer;
  Timer? _targetSpawnTimer;
  int _tickCount = 0;
  final List<PositionRecord> _positionHistory = [];
  
  // Visual effects
  bool _showCollectionEffect = false;
  Offset _collectionEffectPosition = Offset.zero;
  final List<TrailParticle> _userTrail = [];
  final Random _random = Random();
  
  // Block timing
  int _blockTimeTicks = 1;
  int _networkPropagationTicks = 0;
  static const int ticksPerSecond = 100;
  
  // Performance tracking
  int _successfulMoves = 0;
  int _totalMoves = 0;
  
  @override
  void initState() {
    super.initState();
    // Create animation controllers
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _blockchainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _updateDelayTicks();
  }
  
  @override
  void didUpdateWidget(BlockGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isRunning != oldWidget.isRunning) {
      if (widget.isRunning) {
        _startGame();
      } else {
        _stopGame();
      }
    }
    
    if (widget.blockchain != oldWidget.blockchain) {
      _updateDelayTicks();
      if (widget.isRunning) {
        _resetGame();
        _startGame();
      }
    }
  }
  
  void _updateDelayTicks() {
    _blockTimeTicks = max(1, (widget.blockchain.blockTimeMs / (1000 / ticksPerSecond)).round());
    _networkPropagationTicks = max(0, (widget.blockchain.propagationDelayMs / (1000 / ticksPerSecond)).round());
  }
  
  void _initializeGame(Size size) {
    _gameWidth = size.width;
    _gameHeight = size.height;
    _isInitialized = true;
    
    // Center initial positions
    _userPosition = Offset(_gameWidth / 2, _gameHeight / 2);
    _blockchainPosition = _userPosition;
    
    // Initialize position history
    _positionHistory.clear();
    for (int i = 0; i < 3000; i++) {
      _positionHistory.add(PositionRecord(_tickCount, _userPosition));
    }
    
    if (widget.isRunning) {
      _startGame();
    }
  }
  
  void _startGame() {
    _stopGame();
    
    // Start game loop
    _gameTimer = Timer.periodic(
      Duration(milliseconds: 1000 ~/ ticksPerSecond),
      (_) => _updateGame(),
    );
    
    // Start target spawning
    _targetSpawnTimer = Timer.periodic(
      const Duration(milliseconds: 2000),
      (_) => _spawnTarget(),
    );
  }
  
  void _stopGame() {
    _gameTimer?.cancel();
    _targetSpawnTimer?.cancel();
  }
  
  void _resetGame() {
    setState(() {
      _score = 0;
      _missedTargets = 0;
      _targets.clear();
      _userTrail.clear();
      _successfulMoves = 0;
      _totalMoves = 0;
      _userPosition = Offset(_gameWidth / 2, _gameHeight / 2);
      _blockchainPosition = _userPosition;
    });
  }
  
  void _updateGame() {
    if (!mounted) return;
    
    _tickCount++;
    
    // Update position history
    _recordCurrentPosition();
    
    // Update blockchain position on block creation
    if (_tickCount % _blockTimeTicks == 0) {
      _updateBlockchainPosition();
    }
    
    // Update targets
    _updateTargets();
    
    // Update trail particles
    _updateTrailParticles();
    
    setState(() {});
  }
  
  void _updateTrailParticles() {
    // Add new trail particles occasionally when user moves
    if (_totalMoves > 0 && _userTrail.length < 20 && _random.nextDouble() < 0.3) {
      _addTrailParticle();
    }
    
    // Update existing trail particles
    for (final particle in _userTrail) {
      particle.update();
    }
    
    // Remove dead particles
    _userTrail.removeWhere((particle) => particle.isDead);
  }
  
  void _addTrailParticle() {
    // Add a trail particle at the user position
    _userTrail.add(
      TrailParticle(
        position: _userPosition,
        velocity: Offset(
          (_random.nextDouble() - 0.5) * 2,
          (_random.nextDouble() - 0.5) * 2,
        ),
        size: 3 + _random.nextDouble() * 5,
        color: AppTheme.primaryCyan.withOpacity(0.8),
        lifespan: 40 + _random.nextInt(30),
      ),
    );
  }
  
  void _recordCurrentPosition() {
    _positionHistory.add(PositionRecord(_tickCount, _userPosition));
    while (_positionHistory.length > 3000) {
      _positionHistory.removeAt(0);
    }
  }
  
  void _updateBlockchainPosition() {
    final targetTick = _tickCount - _blockTimeTicks - _networkPropagationTicks;
    if (targetTick < 0) return;
    
    for (int i = _positionHistory.length - 1; i >= 0; i--) {
      if (_positionHistory[i].tick <= targetTick) {
        final oldPosition = _blockchainPosition;
        _blockchainPosition = _positionHistory[i].position;
        
        // Trigger animation effect when blockchain position updates
        if ((oldPosition - _blockchainPosition).distance > 5) {
          _blockchainController.reset();
          _blockchainController.forward();
        }
        break;
      }
    }
    
    // Check for target collection with blockchain position
    _checkTargetCollection();
  }
  
  void _spawnTarget() {
    if (!widget.isRunning) return;
    
    // Create a new target at a random position that's not too close to existing ones or to the overlays
    Offset position;
    bool validPosition = false;
    
    // Define safe margins to avoid targets spawning too close to overlay areas
    final double topMargin = 50; // Avoid score overlay
    final double bottomMargin = 50; // Avoid instructions
    final double sideMargin = 60; // Safe distance from edges
    
    // Try to find a position that's not too close to existing targets and is in the safe area
    int attempts = 0;
    do {
      position = Offset(
        sideMargin + _random.nextDouble() * (_gameWidth - sideMargin * 2),
        topMargin + _random.nextDouble() * (_gameHeight - topMargin - bottomMargin),
      );
      
      // Check if the position is far enough from existing targets
      validPosition = _targets.every((target) => 
        (target.position - position).distance > 80);
      
      attempts++;
    } while (!validPosition && attempts < 15); // Increased max attempts
    
    final target = GameTarget(
      position: position,
      createdAt: _tickCount,
      timeToLive: 500, // 5 seconds at 100 ticks/second
    );
    
    setState(() {
      _targets.add(target);
    });
  }
  
  void _updateTargets() {
    // Remove expired targets and count as missed
    final expiredTargets = _targets.where((t) => 
      _tickCount - t.createdAt > t.timeToLive && !t.isCollected).length;
    
    _missedTargets += expiredTargets;
    
    // Update remaining targets
    _targets.removeWhere((target) => 
      _tickCount - target.createdAt > target.timeToLive);
  }
  
  void _checkTargetCollection() {
    bool collected = false;
    Offset? collectionPos;
    
    for (final target in _targets) {
      if (!target.isCollected && 
          (_blockchainPosition - target.position).distance < 40) {
        target.isCollected = true;
        collected = true;
        collectionPos = target.position;
        _score++;
        _successfulMoves++;
      }
    }
    
    if (collected && collectionPos != null) {
      // Show collection effect
      setState(() {
        _showCollectionEffect = true;
        _collectionEffectPosition = collectionPos!;
      });
      
      // Create particle explosion at collection point
      // Hide effect after animation
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _showCollectionEffect = false;
          });
        }
      });
    }
  }
  
  void _handlePointerMove(PointerMoveEvent event) {
    if (!widget.isRunning) return;
    
    // Calculate the old and new positions
    final oldPosition = _userPosition;
    final newPosition = Offset(
      event.localPosition.dx.clamp(60, _gameWidth - 60),
      event.localPosition.dy.clamp(60, _gameHeight - 60),
    );
    
    // Only update if the position has actually changed
    if ((oldPosition - newPosition).distance > 1) {
      setState(() {
        _userPosition = newPosition;
        _totalMoves++;
        
        // Add trail particles when moving at higher speeds
        if ((oldPosition - newPosition).distance > 5) {
          _addTrailParticle();
        }
      });
    }
  }

  // Draw a connection line with dashes between the user and blockchain positions
  Widget _buildConnectionLine() {
    return CustomPaint(
      painter: DashLinePainter(
        start: _userPosition,
        end: _blockchainPosition,
        glitchValue: _glitchController.value,
      ),
      size: Size(_gameWidth, _gameHeight),
    );
  }
  
  // Create a painter for trail particles
  Widget _buildTrailParticles() {
    return CustomPaint(
      painter: TrailParticlePainter(particles: _userTrail),
      size: Size(_gameWidth, _gameHeight),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_isInitialized) {
          _initializeGame(Size(constraints.maxWidth, constraints.maxHeight));
        }
        
        return Listener(
          onPointerMove: _handlePointerMove,
          child: Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              color: AppTheme.darkBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  // Grid background with animation
                  CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: GridPainter(),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .fadeIn(duration: 600.ms)
                   .shimmer(delay: 1000.ms, duration: 1800.ms),
                  
                  // Connection line
                  _buildConnectionLine(),
                  
                  // Trail particles
                  _buildTrailParticles(),
                  
                  // Game elements
                  ..._buildTargets(),
                  
                  // User cursor
                  _buildUserCursor(),
                  
                  // Blockchain cursor
                  _buildBlockchainCursor(),
                  
                  // Collection effect
                  if (_showCollectionEffect) 
                    Positioned(
                      left: _collectionEffectPosition.dx - 50,
                      top: _collectionEffectPosition.dy - 50,
                      child: ParticleSystem(
                        position: Offset(50, 50),
                        particleCount: 40,
                        duration: 0.6,
                      ),
                    ),
                  
                  // Score overlay
                  _buildScoreOverlay(),
                  
                  // Instructions
                  _buildInstructions(),
                  
                  // Start message
                  if (!widget.isRunning)
                    _buildStartMessage(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  List<Widget> _buildTargets() {
    return _targets.map((target) {
      final progress = 1 - ((_tickCount - target.createdAt) / target.timeToLive);
      
      return Positioned(
        left: target.position.dx - 20,
        top: target.position.dy - 20,
        child: AnimatedOpacity(
          opacity: target.isCollected ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentGold.withOpacity(0.9),
                  AppTheme.accentGold.withOpacity(0.3),
                ],
                stops: [0.3, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Progress ring
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryCyan,
                  ),
                  strokeWidth: 3,
                ),
                // Center dot
                Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
  
  Widget _buildUserCursor() {
    return Positioned(
      left: _userPosition.dx - 30,
      top: _userPosition.dy - 30,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.primaryCyan.withOpacity(0.9),
              AppTheme.primaryCyan.withOpacity(0.1),
            ],
            stops: [0.3, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryCyan.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated rings
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 60 + (_pulseController.value * 20),
                    height: 60 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryCyan.withOpacity(0.3 - (_pulseController.value * 0.3)),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Core icon
            Center(
              child: Icon(
                Icons.touch_app,
                color: Colors.white,
                size: 28,
              ).animate(autoPlay: true)
                .fadeIn(duration: 400.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBlockchainCursor() {
    return Positioned(
      left: _blockchainPosition.dx - 40,
      top: _blockchainPosition.dy - 40,
      child: AnimatedBuilder(
        animation: _blockchainController,
        builder: (context, child) {
          final scale = 1.0 + (_blockchainController.value * 0.3);
          final opacity = 1.0;
          
          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.9),
                      AppTheme.primaryPurple.withOpacity(0.3),
                    ],
                    stops: [0.2, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.5 + _blockchainController.value * 0.5),
                      blurRadius: 15 + (_blockchainController.value * 10),
                      spreadRadius: 2 + (_blockchainController.value * 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Rotating border
                    Center(
                      child: RotationTransition(
                        turns: _glitchController,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentGold.withOpacity(0.3),
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                            gradient: SweepGradient(
                              colors: [
                                AppTheme.primaryPurple.withOpacity(0.0),
                                AppTheme.primaryPurple.withOpacity(0.5),
                                AppTheme.primaryPurple.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Core icon
                    Center(
                      child: Icon(
                        Icons.block,
                        color: Colors.white.withOpacity(0.9),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildScoreOverlay() {
    final accuracy = _totalMoves > 0 
        ? (_successfulMoves / _totalMoves * 100).toStringAsFixed(1)
        : '0.0';
        
    return Positioned(
      top: 8, // Reduced top margin
      left: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // More compact padding
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7), // Darker background for better contrast
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryCyan.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildScoreItem(
              'Score',
              _score.toString(),
              AppTheme.accentGold,
            ),
            _buildScoreItem(
              'Missed',
              _missedTargets.toString(),
              AppTheme.primaryPurple,
            ),
            _buildScoreItem(
              'Accuracy',
              '$accuracy%',
              AppTheme.primaryCyan,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScoreItem(String label, String value, Color color) {
    return Row(  // Changed to row for more compact display
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label and value in a column
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12, // Smaller text
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18, // Smaller value
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildInstructions() {
    return Positioned(
      bottom: 8, // Reduced bottom margin for more space
      left: 8,
      right: 8,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7), // Darker background for better contrast
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryCyan.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon on the left
            Container(
              padding: EdgeInsets.all(6),
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryCyan.withOpacity(0.2),
              ),
              child: Icon(
                Icons.touch_app,
                color: AppTheme.accentGold,
                size: 16,
              ),
            ),
            // Text on the right
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text: 'Move cursor (cyan) to collect targets. ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: 'Blockchain (purple) follows with ${widget.blockchain.blockTimeMs}ms block time + ${widget.blockchain.propagationDelayMs}ms delay.',
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStartMessage() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryCyan,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryCyan.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2, // Reduced spread
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon on the left
            Icon(
              Icons.play_circle_outline,
              color: AppTheme.primaryCyan,
              size: 36, // Smaller icon
            ),
            SizedBox(width: 16),
            // Text on the right
            Text(
              'Press START to begin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, // Smaller text
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontFamily: 'Orbitron',
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _stopGame();
    // Dispose all animation controllers
    _glitchController.dispose();
    _pulseController.dispose();
    _blockchainController.dispose();
    super.dispose();
  }
}

class PositionRecord {
  final int tick;
  final Offset position;
  
  PositionRecord(this.tick, this.position);
}

class GameTarget {
  final Offset position;
  final int createdAt;
  final int timeToLive;
  bool isCollected = false;
  
  GameTarget({
    required this.position,
    required this.createdAt,
    required this.timeToLive,
  });
}

class TrailParticle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  int lifespan;
  int age = 0;
  
  TrailParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    required this.lifespan,
  });
  
  void update() {
    position += velocity;
    velocity *= 0.95; // Slow down over time
    size *= 0.97; // Shrink over time
    age++;
  }
  
  bool get isDead => age >= lifespan || size < 0.5;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    const spacing = 40.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => false;
}

class DashLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double glitchValue;
  
  DashLinePainter({
    required this.start,
    required this.end,
    required this.glitchValue,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final lineDist = (end - start).distance;
    if (lineDist < 10) return;
    
    // Create dash paint
    final dashPaint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.4 + glitchValue * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Create a path for the main line
    final linePath = Path()
      ..moveTo(start.dx, start.dy);
    
    // Add a curve to the path for a more dynamic feel
    final controlX = (start.dx + end.dx) / 2 + 20 * sin(glitchValue * pi);
    final controlY = (start.dy + end.dy) / 2 - 20 * cos(glitchValue * pi);
    
    linePath.quadraticBezierTo(
      controlX, 
      controlY, 
      end.dx, 
      end.dy
    );
    
    // Draw dashed line manually
    final dashWidth = 8.0;
    final dashSpace = 4.0;
    final pathMetric = linePath.computeMetrics().first;
    final pathLength = pathMetric.length;
    
    var distance = 0.0;
    final dashOffset = dashWidth * glitchValue; // Animate the dashes
    
    // Draw each dash segment
    while (distance < pathLength) {
      final startDist = distance + dashOffset;
      final endDist = startDist + dashWidth;
      
      if (startDist < pathLength) {
        final startTangent = pathMetric.getTangentForOffset(startDist);
        final endTangent = pathMetric.getTangentForOffset(min(endDist, pathLength));
        
        if (startTangent != null && endTangent != null) {
          canvas.drawLine(startTangent.position, endTangent.position, dashPaint);
        }
      }
      
      distance = endDist + dashSpace;
    }
    
    // Display distance and latency information
    final lineLengthPx = lineDist.toInt();
    final lineLengthMs = (lineDist / 30).toStringAsFixed(1);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$lineLengthPx px\n$lineLengthMs ms delay',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Position text in the middle of the line
    final textPos = Offset(
      (start.dx + end.dx) / 2 - textPainter.width / 2,
      (start.dy + end.dy) / 2 - textPainter.height / 2,
    );
    
    textPainter.paint(canvas, textPos);
  }
  
  @override
  bool shouldRepaint(DashLinePainter oldDelegate) =>
      oldDelegate.start != start ||
      oldDelegate.end != end ||
      oldDelegate.glitchValue != glitchValue;
}

class TrailParticlePainter extends CustomPainter {
  final List<TrailParticle> particles;
  
  TrailParticlePainter({required this.particles});
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final opacity = 1.0 - (particle.age / particle.lifespan);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.size / 2);
      
      // Draw glow effect
      canvas.drawCircle(
        particle.position,
        particle.size * 1.5,
        paint,
      );
      
      // Draw core
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        particle.position,
        particle.size * 0.5,
        corePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(TrailParticlePainter oldDelegate) => true;
}