import 'dart:math';
import 'package:flutter/material.dart';
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/models/blockchain_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class MegaETHTopology extends StatefulWidget {
  final BlockchainModel blockchain;
  final bool showDetailedInfo;
  
  const MegaETHTopology({
    Key? key,
    required this.blockchain,
    this.showDetailedInfo = true,
  }) : super(key: key);

  @override
  State<MegaETHTopology> createState() => _MegaETHTopologyState();
}

class _MegaETHTopologyState extends State<MegaETHTopology> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  NodeType? _selectedNode;
  final Map<String, Offset> _nodePositions = {};
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    
    _generateNodePositions();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _generateNodePositions() {
    // Clear previous positions
    _nodePositions.clear();
    
    // Check if we have MegaETH nodes
    if (widget.blockchain.nodeTypes == null || widget.blockchain.nodeTypes!.isEmpty) {
      return;
    }
    
    // High-end visualization with more organized, intuitive layout
    
    // Sequencer at the center as the core of the network
    _nodePositions['Sequencer'] = const Offset(0.5, 0.42);
    
    // Position replica nodes in an evenly spaced inner circle around sequencer
    // These are tightly coupled with the sequencer
    final replicaCount = 6;
    final replicaRadius = 0.18; // Tight inner circle
    for (int i = 0; i < replicaCount; i++) {
      final angle = (2 * pi * i / replicaCount);
      final x = 0.5 + replicaRadius * cos(angle);
      final y = 0.42 + replicaRadius * sin(angle);
      _nodePositions['Replica_$i'] = Offset(x, y);
    }
    
    // Position full nodes in a middle circle with even spacing
    // These are important infrastructure but not as tightly coupled
    final fullNodeCount = 3;
    final fullNodeRadius = 0.30;
    for (int i = 0; i < fullNodeCount; i++) {
      final angle = (2 * pi * i / fullNodeCount) + (pi / fullNodeCount); // Offset to avoid overlapping with replicas
      final x = 0.5 + fullNodeRadius * cos(angle);
      final y = 0.42 + fullNodeRadius * sin(angle);
      _nodePositions['FullNode_$i'] = Offset(x, y);
    }
    
    // Position prover nodes in an outer circle with slight variations
    // These are numerous lightweight nodes that form the outer network layer
    final proverCount = 10;
    for (int i = 0; i < proverCount; i++) {
      // Create an organized pattern with slight variations for visual interest
      final baseAngle = (2 * pi * i / proverCount);
      final angle = baseAngle + (_random.nextDouble() * 0.05 - 0.025); // Small controlled variation
      
      // Different distances from center to show network hierarchy
      // Increasing base distance for better visibility on the page
      final radius = 0.42 + (_random.nextDouble() * 0.04);
      final x = 0.5 + radius * cos(angle);
      final y = 0.42 + radius * sin(angle);
      _nodePositions['Prover_$i'] = Offset(x, y);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Return a placeholder if not MegaETH
    if (widget.blockchain.name != 'MegaETH' || widget.blockchain.nodeTypes == null) {
      return Center(
        child: Text(
          'Node specialization network topology\nonly available for MegaETH',
          textAlign: TextAlign.center,
          style: AppTheme.bodyStyle,
        ),
      );
    }
    
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      constraints: BoxConstraints(
        // CRITICAL: On mobile use almost full screen height for the visualization
        minHeight: MediaQuery.of(context).size.height * (isMobile ? 0.8 : 0.5),
      ),
      child: Stack(
        children: [
          // Network visualization
          Container(
            height: MediaQuery.of(context).size.height * (isMobile ? 0.85 : 0.8),
            width: double.infinity,
            child: CustomPaint(
              painter: NetworkPainter(
                nodePositions: _nodePositions,
                animationValue: _animationController.value,
                selectedNode: _selectedNode,
              ),
              size: Size.infinite,
            ),
          ),
          
          // Premium Y2K Legend panel
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: 380,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.jetBlack.withOpacity(0.9),
                    AppTheme.charcoal.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: AppTheme.silver, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.silver.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(4, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Premium header bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.silverGradient,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.hub, 
                          color: AppTheme.jetBlack, 
                          size: 16
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MEGAETH NODE ARCHITECTURE',
                          style: TextStyle(
                            color: AppTheme.jetBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.0,
                            fontFamily: 'Helvetica',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content section with padding
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Typewriter animated text
                        DefaultTextStyle(
                          style: AppTheme.bodyStyle.copyWith(
                            fontSize: 13,
                            color: AppTheme.silver,
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Click on any node to view its detailed specifications and functions.',
                                speed: Duration(milliseconds: 60),
                              ),
                            ],
                            totalRepeatCount: 1,
                            displayFullTextOnTap: true,
                          ),
                        ),
                        const SizedBox(height: 4),
                        DefaultTextStyle(
                          style: AppTheme.bodyStyle.copyWith(
                            fontSize: 13,
                            color: AppTheme.silver,
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Node specialization enables 100,000 TPS with 10ms block times.',
                                speed: Duration(milliseconds: 60),
                              ),
                            ],
                            totalRepeatCount: 1,
                            displayFullTextOnTap: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Premium stat indicators
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.jetBlack.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NODE SPECIFICATIONS',
                                style: TextStyle(
                                  color: AppTheme.silver,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.0,
                                  fontFamily: 'Helvetica',
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Node type legends in a grid
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildPremiumLegendItem('Sequencer', Icons.hub, '100 cores', '1TB RAM'),
                                  _buildPremiumLegendItem('Replica', Icons.storage, '8 cores', '16GB RAM'),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildPremiumLegendItem('Full Node', Icons.dns, '16 cores', '64GB RAM'),
                                  _buildPremiumLegendItem('Prover', Icons.verified, '1 core', '1GB RAM'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Bandwidth indicator
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.jetBlack.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STATE DIFF COMPRESSION:',
                                    style: TextStyle(
                                      color: AppTheme.silver,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                      fontFamily: 'Helvetica',
                                    ),
                                  ),
                                  Text(
                                    'Key to 100,000 TPS',
                                    style: TextStyle(
                                      color: AppTheme.silver.withOpacity(0.7),
                                      fontSize: 10,
                                      fontFamily: 'Helvetica',
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.silverGradient,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.silver.withOpacity(0.3),
                                      blurRadius: 5,
                                      spreadRadius: 0,
                                    )
                                  ]
                                ),
                                child: Text(
                                  '19x',
                                  style: TextStyle(
                                    color: AppTheme.jetBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'Helvetica',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0, duration: 400.ms),
          ),
          
          // Nodes
          ...widget.blockchain.nodeTypes!.expand((nodeType) => _buildNodesForType(nodeType)),
          
          // Node details overlay when a node is selected
          if (_selectedNode != null)
            Positioned(
              right: 16,
              top: 16,
              width: 320,
              child: GlassmorphicContainer(
                width: 320,
                height: 320,
                borderRadius: 3,
                blur: 10,
                alignment: Alignment.center,
                border: 1,
                linearGradient: AppTheme.glassGradient,
                borderGradient: AppTheme.silverGradient,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with close button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedNode!.name,
                            style: AppTheme.headingStyle.copyWith(fontSize: 24),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.silver),
                            onPressed: () => setState(() => _selectedNode = null),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    
                    // Scrollable content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedNode!.description,
                              style: AppTheme.bodyStyle,
                            ),
                            const SizedBox(height: 16),
                            _buildNodeDetailsRow(
                              'Hardware',
                              '${_selectedNode!.cpuCores} CPU cores, ${_selectedNode!.ramGB} GB RAM',
                            ),
                            _buildNodeDetailsRow(
                              'Network',
                              '${_selectedNode!.networkMbps} Mbps',
                            ),
                            _buildNodeDetailsRow(
                              'Storage',
                              _selectedNode!.storageType,
                            ),
                            _buildNodeDetailsRow(
                              'Cost',
                              '\$${_selectedNode!.hourlyPrice}/hour (${_selectedNode!.cloudEquivalent})',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Functions:',
                              style: AppTheme.subHeadingStyle.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            ...(_selectedNode!.functions.map((function) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: AppTheme.bodyStyle),
                                  Expanded(
                                    child: Text(function, style: AppTheme.bodyStyle),
                                  ),
                                ],
                              ),
                            ))),
                            const SizedBox(height: 8),
                            Text(
                              'State Management:',
                              style: AppTheme.subHeadingStyle.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            ...(_selectedNode!.stateManagement.map((stateManagement) => Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: AppTheme.bodyStyle),
                                  Expanded(
                                    child: Text(stateManagement, style: AppTheme.bodyStyle),
                                  ),
                                ],
                              ),
                            ))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }
  
  Widget _buildNodeDetailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                color: AppTheme.silver,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildNodesForType(NodeType nodeType) {
    switch (nodeType.name) {
      case 'Sequencer':
        return [_buildSequencerNode(nodeType)];
      case 'Replica':
        return List.generate(6, (index) => _buildReplicaNode(nodeType, index));
      case 'Full Node':
        return List.generate(3, (index) => _buildFullNode(nodeType, index));
      case 'Prover':
        return List.generate(10, (index) => _buildProverNode(nodeType, index));
      default:
        return [];
    }
  }
  
  Widget _buildSequencerNode(NodeType nodeType) {
    final position = _nodePositions['Sequencer']!;
    
    return Positioned(
      left: MediaQuery.of(context).size.width * position.dx - 50,
      top: MediaQuery.of(context).size.height * position.dy - 50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedNode = nodeType),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.silver.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.4, 0.9],
                    ),
                  ),
                ),
                // Main node circle
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.silver.withOpacity(0.9),
                        AppTheme.steelGray.withOpacity(0.7),
                        AppTheme.obsidian.withOpacity(0.9),
                      ],
                      stops: const [0.2, 0.7, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.silver.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.silver.withOpacity(0.7),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hub,
                          color: AppTheme.platinum,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "SEQUENCER",
                          style: TextStyle(
                            color: AppTheme.platinum,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // CPU cores indicators (mini circles around the main circle)
                ...List.generate(8, (index) {
                  final angle = (2 * pi * index / 8);
                  return Positioned(
                    left: 50 + 46 * cos(angle),
                    top: 50 + 46 * sin(angle),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.silver,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.silver.withOpacity(0.6),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).shimmer(
            duration: 3.seconds,
            curve: Curves.easeInOut,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.jetBlack.withOpacity(0.8),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppTheme.silver.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.silver.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              '100 CPU Cores • 1TB RAM',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: AppTheme.silver,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.jetBlack.withOpacity(0.6),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 1),
            ),
            child: Text(
              '10 Gbps • \$10/hour',
              style: AppTheme.bodyStyle.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReplicaNode(NodeType nodeType, int index) {
    final position = _nodePositions['Replica_$index']!;
    
    return Positioned(
      left: MediaQuery.of(context).size.width * position.dx - 30,
      top: MediaQuery.of(context).size.height * position.dy - 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedNode = nodeType),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle glow behind node
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.silver.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.4, 0.9],
                    ),
                  ),
                ),
                // Main node
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.silver.withOpacity(0.8),
                        AppTheme.steelGray.withOpacity(0.7),
                        AppTheme.charcoal.withOpacity(0.8),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.silver.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.silver.withOpacity(0.6),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.storage,
                          color: AppTheme.platinum,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "REPLICA",
                          style: TextStyle(
                            color: AppTheme.platinum,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Memory banks indicators (little rectangles at top and bottom)
                Positioned(
                  top: 12,
                  child: Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.silver.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  child: Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.silver.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).shimmer(
            duration: 3.seconds,
            delay: (index * 0.5).seconds,
            curve: Curves.easeInOut,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.jetBlack.withOpacity(0.8),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppTheme.silver.withOpacity(0.4), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.silver.withOpacity(0.1),
                  blurRadius: 3,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              '8 Cores • 16GB RAM',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                color: AppTheme.silver.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.jetBlack.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              '100 Mbps • \$0.4/hour',
              style: AppTheme.bodyStyle.copyWith(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFullNode(NodeType nodeType, int index) {
    final position = _nodePositions['FullNode_$index']!;
    
    return Positioned(
      left: MediaQuery.of(context).size.width * position.dx - 35,
      top: MediaQuery.of(context).size.height * position.dy - 35,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedNode = nodeType),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle glow
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.steelGray.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0.4, 0.9],
                    ),
                  ),
                ),
                // Main node
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.steelGray.withOpacity(0.8),
                        AppTheme.charcoal.withOpacity(0.7),
                        AppTheme.jetBlack.withOpacity(0.9),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.steelGray.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.steelGray.withOpacity(0.7),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dns,
                          color: AppTheme.silver,
                          size: 24,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "FULL NODE",
                          style: TextStyle(
                            color: AppTheme.silver,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // CPU and storage indicators
                ...List.generate(4, (i) {
                  final angle = (2 * pi * i / 4) + (pi / 8);
                  return Positioned(
                    left: 35 + 32 * cos(angle),
                    top: 35 + 32 * sin(angle),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.steelGray,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.steelGray.withOpacity(0.4),
                            blurRadius: 3,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                // Storage block symbol
                Positioned(
                  right: 15,
                  bottom: 15,
                  child: Container(
                    width: 12,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppTheme.steelGray.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(
                        color: AppTheme.silver.withOpacity(0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.storage,
                        color: AppTheme.silver,
                        size: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).shimmer(
            duration: 3.seconds,
            delay: (index * 0.7).seconds,
            curve: Curves.easeInOut,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.jetBlack.withOpacity(0.8),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppTheme.steelGray.withOpacity(0.5), width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.steelGray.withOpacity(0.1),
                  blurRadius: 3,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              '16 Cores • 64GB RAM',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 10, 
                fontWeight: FontWeight.bold,
                color: AppTheme.silver.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.jetBlack.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppTheme.steelGray.withOpacity(0.3), width: 0.5),
            ),
            child: Text(
              '200 Mbps • \$1.6/hour',
              style: AppTheme.bodyStyle.copyWith(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProverNode(NodeType nodeType, int index) {
    final position = _nodePositions['Prover_$index']!;
    
    return Positioned(
      left: MediaQuery.of(context).size.width * position.dx - 18,
      top: MediaQuery.of(context).size.height * position.dy - 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedNode = nodeType),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Subtle glow
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.charcoal.withOpacity(0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.4, 0.9],
                    ),
                  ),
                ),
                // Main node
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.charcoal.withOpacity(0.6),
                        AppTheme.steelGray.withOpacity(0.4),
                        AppTheme.obsidian.withOpacity(0.7),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.charcoal.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.steelGray.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          color: AppTheme.silver,
                          size: 14,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "PROVER",
                          style: TextStyle(
                            color: AppTheme.silver.withOpacity(0.8),
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Cryptographic elements - small symbol
                if (index % 3 == 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.steelGray.withOpacity(0.6),
                        border: Border.all(
                          color: AppTheme.silver.withOpacity(0.4),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "✓",
                          style: TextStyle(
                            color: AppTheme.silver,
                            fontSize: 5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).shimmer(
            duration: 2.seconds,
            delay: (index * 0.3).seconds,
            curve: Curves.easeInOut,
          ),
          // All prover nodes now have labels with actual specs
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.jetBlack.withOpacity(0.8),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: AppTheme.charcoal.withOpacity(0.5), width: 0.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.charcoal.withOpacity(0.1),
                  blurRadius: 2,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Text(
              '1 Core • 0.5GB RAM',
              style: AppTheme.bodyStyle.copyWith(
                fontSize: 7, 
                fontWeight: FontWeight.bold,
                color: AppTheme.silver.withOpacity(0.8),
              ),
            ),
          ),
          if (index % 4 == 0) // Only some provers show bandwidth info to avoid crowding
            Column(
              children: [
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppTheme.charcoal.withOpacity(0.3), width: 0.5),
                  ),
                  child: Text(
                    '10 Mbps • \$0.004/hr',
                    style: AppTheme.bodyStyle.copyWith(fontSize: 6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Build a premium legend item with icon and specs
  Widget _buildPremiumLegendItem(String label, IconData icon, String spec1, String spec2) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.charcoal.withOpacity(0.8),
            AppTheme.jetBlack.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppTheme.silver.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon in a circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.silver.withOpacity(0.2),
                  AppTheme.jetBlack.withOpacity(0.8),
                ],
                stops: const [0.3, 1.0],
              ),
              border: Border.all(color: AppTheme.silver.withOpacity(0.5), width: 1),
            ),
            child: Center(
              child: Icon(icon, size: 16, color: AppTheme.silver),
            ),
          ),
          const SizedBox(width: 8),
          // Text specs
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.silver,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    fontFamily: 'Helvetica',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  spec1,
                  style: TextStyle(
                    color: AppTheme.silver.withOpacity(0.8),
                    fontSize: 10,
                    fontFamily: 'Helvetica',
                  ),
                ),
                Text(
                  spec2,
                  style: TextStyle(
                    color: AppTheme.silver.withOpacity(0.8),
                    fontSize: 10,
                    fontFamily: 'Helvetica',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0, delay: 800.ms, duration: 400.ms);
  }
}

class NetworkPainter extends CustomPainter {
  final Map<String, Offset> nodePositions;
  final double animationValue;
  final NodeType? selectedNode;
  final _random = Random();
  
  NetworkPainter({
    required this.nodePositions,
    required this.animationValue,
    this.selectedNode,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Draw premium background effects first
    _drawPremiumBackground(canvas, size);
    
    final paint = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    final particlePaint = Paint()
      ..style = PaintingStyle.fill;
    
    final sequencerPos = _getPositionInPixels(nodePositions['Sequencer']!, size);
    
    // Draw connections organized by layer and importance
    // First: Draw all replica connections (inner circle - highest priority)
    _drawReplicaConnections(canvas, sequencerPos, particlePaint, size);
    
    // Second: Draw full node connections (middle circle)
    _drawFullNodeConnections(canvas, sequencerPos, particlePaint, size);
    
    // Third: Draw prover connections (outer circle)
    _drawProverConnections(canvas, sequencerPos, particlePaint, size);
    
    // Finally: Draw highlight effects for selected node type
    _drawSelectionHighlights(canvas, sequencerPos, size);
  }
  
  // Draw premium background effects
  void _drawPremiumBackground(Canvas canvas, Size size) {
    // Draw subtle radial gradient from center
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.charcoal.withOpacity(0.05),
          AppTheme.jetBlack.withOpacity(0.0),
        ],
        radius: 0.6,
      ).createShader(Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.42),
        width: size.width,
        height: size.height,
      ));
      
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint
    );
    
    // Draw subtle grid lines
    final gridPaint = Paint()
      ..color = AppTheme.silver.withOpacity(0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    // Horizontal grid lines
    for (int i = 0; i < 20; i++) {
      final y = i * (size.height / 20);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
    
    // Vertical grid lines
    for (int i = 0; i < 20; i++) {
      final x = i * (size.width / 20);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
    
    // Draw a subtle glow around the sequencer
    if (nodePositions.containsKey('Sequencer')) {
      final sequencerPos = _getPositionInPixels(nodePositions['Sequencer']!, size);
      final sequencerGlowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppTheme.silver.withOpacity(0.05),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: sequencerPos,
          radius: size.width * 0.25,
        ));
      
      canvas.drawCircle(
        sequencerPos,
        size.width * 0.25,
        sequencerGlowPaint,
      );
    }
  }
  
  // Draw replica connections in an elegant, organized way
  void _drawReplicaConnections(Canvas canvas, Offset sequencerPos, Paint particlePaint, Size size) {
    // Find all replica nodes
    final replicaEntries = nodePositions.entries
        .where((entry) => entry.key.startsWith('Replica_'))
        .toList();
    
    // Draw connections from sequencer to each replica
    for (final entry in replicaEntries) {
      final replicaPos = _getPositionInPixels(entry.value, size);
      final nodeIndex = int.tryParse(entry.key.split('_').last) ?? 0;
      
      // Draw high-bandwidth connection to sequencer
      _drawPremiumConnection(
        canvas, 
        sequencerPos, 
        replicaPos, 
        AppTheme.silver.withOpacity(0.7), // Brighter for important connections
        AppTheme.silver.withOpacity(0.2),
        3.0,
        size
      );
      
      // Draw active data flow particles 
      _drawDataParticles(
        canvas, 
        sequencerPos, 
        replicaPos,
        AppTheme.silver,
        particlePaint,
        animationValue,
        15, // More particles for high-bandwidth replicas
        1.2, // Larger particles
        size
      );
      
      // Draw replica-to-replica mesh connections (ring topology)
      // Connect to next replica in the ring
      final nextIndex = (nodeIndex + 1) % replicaEntries.length;
      final nextReplicaEntry = replicaEntries.firstWhere(
        (e) => e.key == 'Replica_$nextIndex', 
        orElse: () => replicaEntries.first
      );
      
      final nextReplicaPos = _getPositionInPixels(nextReplicaEntry.value, size);
      
      // Draw replica-to-replica connection (less prominent than to sequencer)
      _drawPremiumConnection(
        canvas,
        replicaPos,
        nextReplicaPos,
        AppTheme.silver.withOpacity(0.4),
        AppTheme.silver.withOpacity(0.1),
        1.5,
        size
      );
      
      // Draw fewer particles between replicas
      _drawDataParticles(
        canvas,
        replicaPos,
        nextReplicaPos,
        AppTheme.silver.withOpacity(0.8),
        particlePaint,
        animationValue * 0.7 + (nodeIndex * 0.1), // Offset timing for visual interest
        4, // Fewer particles
        0.7, // Smaller particles
        size
      );
    }
  }
  
  // Draw full node connections
  void _drawFullNodeConnections(Canvas canvas, Offset sequencerPos, Paint particlePaint, Size size) {
    // Find all full nodes
    final fullNodeEntries = nodePositions.entries
        .where((entry) => entry.key.startsWith('FullNode_'))
        .toList();
    
    // Find replica nodes for secondary connections
    final replicaEntries = nodePositions.entries
        .where((entry) => entry.key.startsWith('Replica_'))
        .toList();
    
    // Draw connections from sequencer to each full node
    for (final entry in fullNodeEntries) {
      final fullNodePos = _getPositionInPixels(entry.value, size);
      final nodeIndex = int.tryParse(entry.key.split('_').last) ?? 0;
      
      // Draw medium-bandwidth connection to sequencer
      _drawPremiumConnection(
        canvas, 
        sequencerPos, 
        fullNodePos, 
        AppTheme.steelGray.withOpacity(0.6),
        AppTheme.steelGray.withOpacity(0.15),
        2.5,
        size
      );
      
      // Draw active data flow particles
      _drawDataParticles(
        canvas, 
        sequencerPos, 
        fullNodePos,
        AppTheme.steelGray,
        particlePaint,
        animationValue * 0.8, // Slightly slower than replicas
        6, // Medium number of particles
        0.9, // Medium-sized particles
        size
      );
      
      // Connect full node to nearest replica
      // Smart connection - connect to optimal replica based on position
      final closestReplicaEntry = _findClosestNode(fullNodePos, replicaEntries, size);
      final replicaPos = _getPositionInPixels(closestReplicaEntry.value, size);
      
      // Draw full node to replica connection (less prominent)
      _drawPremiumConnection(
        canvas,
        fullNodePos,
        replicaPos,
        AppTheme.steelGray.withOpacity(0.4),
        AppTheme.steelGray.withOpacity(0.1),
        1.2,
        size
      );
      
      // Draw minimal particles for replica to full node connection
      _drawDataParticles(
        canvas,
        replicaPos,
        fullNodePos,
        AppTheme.steelGray.withOpacity(0.7),
        particlePaint,
        animationValue * 0.6 + (nodeIndex * 0.2), // Different timing
        3, // Fewer particles
        0.6, // Smaller particles
        size
      );
    }
  }
  
  // Draw prover connections
  void _drawProverConnections(Canvas canvas, Offset sequencerPos, Paint particlePaint, Size size) {
    // Find all prover nodes
    final proverEntries = nodePositions.entries
        .where((entry) => entry.key.startsWith('Prover_'))
        .toList();
    
    // Find full nodes and replicas for smart connections
    final fullNodeEntries = nodePositions.entries
        .where((entry) => entry.key.startsWith('FullNode_'))
        .toList();
    
    final replicaEntries = nodePositions.entries
        .where((entry) => entry.key.startsWith('Replica_'))
        .toList();
    
    // Draw connections for each prover with a sophisticated layout
    for (final entry in proverEntries) {
      final proverPos = _getPositionInPixels(entry.value, size);
      final nodeIndex = int.tryParse(entry.key.split('_').last) ?? 0;
      
      // Different connection patterns based on prover's "role" within the network
      if (nodeIndex % 3 == 0) {
        // This prover connects directly to sequencer (1/3 of provers)
        _drawPremiumConnection(
          canvas, 
          sequencerPos, 
          proverPos, 
          AppTheme.charcoal.withOpacity(0.5),
          AppTheme.charcoal.withOpacity(0.1),
          1.0,
          size
        );
        
        // Minimal data particles
        _drawDataParticles(
          canvas, 
          sequencerPos, 
          proverPos,
          AppTheme.charcoal.withOpacity(0.8),
          particlePaint,
          animationValue * 0.5 + (nodeIndex * 0.1),
          3, // Very few particles
          0.6, // Small particles
          size
        );
      } else if (nodeIndex % 3 == 1) {
        // This prover connects to the closest full node (1/3 of provers)
        final closestFullNode = _findClosestNode(proverPos, fullNodeEntries, size);
        final fullNodePos = _getPositionInPixels(closestFullNode.value, size);
        
        _drawPremiumConnection(
          canvas, 
          fullNodePos, 
          proverPos, 
          AppTheme.charcoal.withOpacity(0.4),
          AppTheme.charcoal.withOpacity(0.08),
          0.8,
          size
        );
        
        // Very minimal data particles
        _drawDataParticles(
          canvas, 
          fullNodePos, 
          proverPos,
          AppTheme.charcoal.withOpacity(0.7),
          particlePaint,
          animationValue * 0.4 + (nodeIndex * 0.15),
          2, // Minimal particles
          0.5, // Smaller particles
          size
        );
      } else {
        // This prover connects to the closest replica (1/3 of provers)
        final closestReplica = _findClosestNode(proverPos, replicaEntries, size);
        final replicaPos = _getPositionInPixels(closestReplica.value, size);
        
        _drawPremiumConnection(
          canvas, 
          replicaPos, 
          proverPos, 
          AppTheme.charcoal.withOpacity(0.35),
          AppTheme.charcoal.withOpacity(0.07),
          0.7,
          size
        );
        
        // Minimal data particles
        _drawDataParticles(
          canvas, 
          replicaPos, 
          proverPos,
          AppTheme.charcoal.withOpacity(0.6),
          particlePaint,
          animationValue * 0.3 + (nodeIndex * 0.2),
          2, // Minimal particles
          0.4, // Smallest particles
          size
        );
      }
    }
  }
  
  // Draw selection highlights when a node type is selected
  void _drawSelectionHighlights(Canvas canvas, Offset sequencerPos, Size size) {
    if (selectedNode == null) return;
    
    // Find nodes of the selected type
    final selectedNodes = nodePositions.entries
        .where((entry) => entry.key.startsWith('${selectedNode!.name}_') || 
                         (entry.key == 'Sequencer' && selectedNode!.name == 'Sequencer'))
        .toList();
    
    // Draw highlights for all connections
    for (final entry in selectedNodes) {
      final nodePos = _getPositionInPixels(entry.value, size);
      
      // Skip if this is the sequencer (already drawn connections from others)
      if (entry.key == 'Sequencer') continue;
      
      // Draw premium highlight effect
      // Bright connection line
      final highlightPaint = Paint()
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..color = AppTheme.silver.withOpacity(0.8);
      
      canvas.drawLine(sequencerPos, nodePos, highlightPaint);
      
      // Pulsing glow effect based on animation value
      final pulseIntensity = 0.1 + 0.1 * sin(animationValue * 2 * pi);
      final glowPaint = Paint()
        ..strokeWidth = 12.0
        ..style = PaintingStyle.stroke
        ..color = AppTheme.silver.withOpacity(pulseIntensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5.0);
      
      canvas.drawLine(sequencerPos, nodePos, glowPaint);
      
      // Draw additional connecting lines between selected nodes if they're not connected to sequencer
      if (selectedNodes.length > 1 && selectedNode!.name != 'Sequencer') {
        for (final otherEntry in selectedNodes) {
          if (entry == otherEntry) continue;
          
          final otherNodePos = _getPositionInPixels(otherEntry.value, size);
          
          // Draw connecting line between same node types
          final connectionPaint = Paint()
            ..strokeWidth = 1.0
            ..style = PaintingStyle.stroke
            ..color = AppTheme.silver.withOpacity(0.4);
          
          canvas.drawLine(nodePos, otherNodePos, connectionPaint);
        }
      }
    }
  }
  
  // Find the closest node from a list of entries
  MapEntry<String, Offset> _findClosestNode(Offset position, List<MapEntry<String, Offset>> entries, Size size) {
    if (entries.isEmpty) {
      throw Exception('Cannot find closest node from an empty list');
    }
    
    double minDistance = double.infinity;
    late MapEntry<String, Offset> closestEntry;
    
    for (final entry in entries) {
      final entryPos = _getPositionInPixels(entry.value, size);
      final distance = (position - entryPos).distance;
      
      if (distance < minDistance) {
        minDistance = distance;
        closestEntry = entry;
      }
    }
    
    return closestEntry;
  }
  
  Offset _getPositionInPixels(Offset normalizedPos, Size size) {
    return Offset(
      normalizedPos.dx * size.width,
      normalizedPos.dy * size.height,
    );
  }
  
  // Draw premium connection with gradient and glow effects
  void _drawPremiumConnection(
    Canvas canvas, 
    Offset start, 
    Offset end, 
    Color color, 
    Color glowColor, 
    double width, 
    Size size
  ) {
    // Calculate direction for gradient
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final normalizedDx = dx / distance;
    final normalizedDy = dy / distance;
    
    // Calculate perpendicular direction for gradient width
    final perpDx = -normalizedDy;
    final perpDy = normalizedDx;
    
    // Define gradient bounds
    final gradientRect = Rect.fromPoints(
      Offset(
        start.dx - perpDx * 2, 
        start.dy - perpDy * 2
      ),
      Offset(
        end.dx + perpDx * 2, 
        end.dy + perpDy * 2
      ),
    );
    
    // Draw wider glow effect
    final glowPaint = Paint()
      ..strokeWidth = width * 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, width)
      ..color = glowColor;
    
    canvas.drawLine(start, end, glowPaint);
    
    // Draw gradient line
    final linePaint = Paint()
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.7),
          color,
          color.withOpacity(0.7),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(gradientRect);
    
    canvas.drawLine(start, end, linePaint);
  }
  
  // Draw data flow particles with premium effects
  void _drawDataParticles(
    Canvas canvas, 
    Offset start, 
    Offset end, 
    Color color, 
    Paint paint, 
    double animationValue, 
    int particleCount, 
    double particleSize, 
    Size size
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    // Calculate direction vectors
    final dirX = dx / distance;
    final dirY = dy / distance;
    final perpX = -dirY;
    final perpY = dirX;
    
    // Generate particles with premium effects
    for (int i = 0; i < particleCount; i++) {
      // Calculate base particle position with varied speeds
      final speed = 0.6 + (i % 5) * 0.08; // Varied speeds for different particles
      final seed = (i * 13) % 97; // Use prime numbers for better pseudo-randomness
      final offset = (animationValue * speed + seed * 0.01) % 1.0;
      
      // Position along the line with slight curve effect
      final progress = offset;
      final curveOffsetFactor = sin(progress * pi) * 0.05; // Creates a slight curve
      
      final x = start.dx + dx * progress + perpX * curveOffsetFactor * distance;
      final y = start.dy + dy * progress + perpY * curveOffsetFactor * distance;
      
      // Add small controlled random offset for more natural flow
      final randomOffset = sin(progress * pi * 2 + seed) * 3;
      final offsetX = perpX * randomOffset;
      final offsetY = perpY * randomOffset;
      
      final particlePos = Offset(x + offsetX, y + offsetY);
      
      // Particle fade based on position with smooth curve
      final fadeBase = sin(progress * pi);
      final fade = fadeBase * fadeBase; // Square for more dramatic fade in/out
      
      // Size variation based on position
      final sizeMultiplier = 0.8 + fadeBase * 0.5; // Larger in the middle
      
      // Draw main particle with glow
      paint.color = color.withOpacity(fade * 0.9);
      canvas.drawCircle(particlePos, particleSize * sizeMultiplier, paint);
      
      // Draw outer glow with blur effect
      paint.color = color.withOpacity(fade * 0.4);
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize * 0.8);
      canvas.drawCircle(particlePos, particleSize * 2 * sizeMultiplier, paint);
      paint.maskFilter = null;
      
      // Draw bright core
      paint.color = Colors.white.withOpacity(fade * 0.6);
      canvas.drawCircle(particlePos, particleSize * 0.4 * sizeMultiplier, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}