import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/models/blockchain_model.dart';

class BlockchainControls extends StatefulWidget {
  final BlockchainModel currentBlockchain;
  final Function(BlockchainModel) onBlockchainChanged;
  final int transactionsPerSecond;
  final Function(int) onTransactionsPerSecondChanged;
  final bool isRunning;
  final VoidCallback onStartStop;
  final VoidCallback onReset;
  final VoidCallback onStressTest;

  const BlockchainControls({
    Key? key,
    required this.currentBlockchain,
    required this.onBlockchainChanged,
    required this.transactionsPerSecond,
    required this.onTransactionsPerSecondChanged,
    required this.isRunning,
    required this.onStartStop,
    required this.onReset,
    required this.onStressTest,
  }) : super(key: key);

  @override
  State<BlockchainControls> createState() => _BlockchainControlsState();
}

class _BlockchainControlsState extends State<BlockchainControls> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _hoverController;
  
  // Selected blockchain index for animation
  int _selectedIndex = 0;
  int _hoveredButtonIndex = -1;

  // Loading animation for stress test
  bool _isStressTesting = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    // Set the initial index based on the current blockchain
    _updateSelectedIndex();
  }
  
  @override
  void didUpdateWidget(BlockchainControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.currentBlockchain != oldWidget.currentBlockchain) {
      _updateSelectedIndex();
    }
  }
  
  void _updateSelectedIndex() {
    if (widget.currentBlockchain.name == 'MegaETH') {
      _selectedIndex = 0;
    } else if (widget.currentBlockchain.name == 'Ethereum') {
      _selectedIndex = 1;
    } else if (widget.currentBlockchain.name == 'Arbitrum One') {
      _selectedIndex = 2;
    } else if (widget.currentBlockchain.name == 'opBNB') {
      _selectedIndex = 3;
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated title with glow effect
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppTheme.primaryCyan,
                        AppTheme.primaryPurple.withOpacity(0.8 + _pulseController.value * 0.2),
                        AppTheme.primaryCyan,
                      ],
                      stops: [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      tileMode: TileMode.mirror,
                    ).createShader(bounds),
                    child: Text(
                      'Blockchain Controls',
                      style: AppTheme.subHeadingStyle.copyWith(
                        fontSize: 22,
                        shadows: [
                          Shadow(
                            color: AppTheme.primaryCyan.withOpacity(0.5 + _pulseController.value * 0.5),
                            blurRadius: 10 + _pulseController.value * 5,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            
            // Blockchain selection with animated indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.language,
                        color: AppTheme.primaryCyan,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Select Blockchain:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildBlockchainSelector(),
              ],
            ),
            const SizedBox(height: 32),
            
            // Animated blockchain parameters card
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.darkBackground,
                        AppTheme.darkBackgroundLight.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.currentBlockchain.name == 'MegaETH' 
                        ? AppTheme.primaryCyan.withOpacity(0.5 + _glowController.value * 0.3)
                        : AppTheme.primaryPurple.withOpacity(0.3),
                      width: widget.currentBlockchain.name == 'MegaETH' ? 2 : 1,
                    ),
                    boxShadow: widget.currentBlockchain.name == 'MegaETH' 
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withOpacity(0.1 + _glowController.value * 0.1),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ] 
                      : [],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Blockchain Parameters',
                          style: TextStyle(
                            color: AppTheme.primaryCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // Parameter rows with animated values
                      _buildParameterRow(
                        'Block Time:',
                        _formatTimeValue(widget.currentBlockchain.blockTimeMs),
                        widget.currentBlockchain.blockTimeMs < 100, // Highlight if super fast
                      ),
                      const SizedBox(height: 16),
                      _buildParameterRow(
                        'Propagation Delay:',
                        _formatTimeValue(widget.currentBlockchain.propagationDelayMs),
                        widget.currentBlockchain.propagationDelayMs < 100, // Highlight if super fast
                      ),
                      const SizedBox(height: 16),
                      _buildParameterRow(
                        'Total Latency:',
                        _formatTimeValue(widget.currentBlockchain.totalLatencyMs),
                        widget.currentBlockchain.totalLatencyMs < 100, // Highlight if super fast
                      ),
                      const SizedBox(height: 16),
                      _buildParameterRow(
                        'Gas/Second:',
                        '${(widget.currentBlockchain.gasPerSecond / 1000000).toStringAsFixed(2)} MGas/s',
                        widget.currentBlockchain.gasPerSecond > 50000000, // Highlight if high gas
                      ),
                      const SizedBox(height: 16),
                      _buildParameterRow(
                        'Max TPS:',
                        '${widget.currentBlockchain.maxTransactionsPerSecond}',
                        widget.currentBlockchain.maxTransactionsPerSecond > 1000, // Highlight if high TPS
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Transaction rate control with animated label
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.speed,
                    color: AppTheme.primaryCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Transaction Rate (TPS):',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionRateSlider(),
            const SizedBox(height: 40),
            
            // Control buttons with animations
            _buildControlButtons(),
            // Add extra space at the bottom
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Blockchain selector with animations and selection indicator
  Widget _buildBlockchainSelector() {
    List<String> blockchainNames = ['MegaETH', 'Ethereum', 'Arbitrum', 'opBNB'];
    List<BlockchainModel> blockchainModels = [
      BlockchainModel.megaEth(),
      BlockchainModel.ethereum(),
      BlockchainModel.arbitrumOne(),
      BlockchainModel.opBNB(),
    ];
    
    return Column(
      children: [
        // Blockchain buttons - using Wrap for better responsiveness
        Container(
          constraints: BoxConstraints(minHeight: 80),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12, // Horizontal spacing
            runSpacing: 12, // Vertical spacing when wrapped
            children: List.generate(blockchainNames.length, (index) {
              final isSelected = index == _selectedIndex;
              
              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredButtonIndex = index),
                onExit: (_) => setState(() => _hoveredButtonIndex = -1),
                child: _buildAnimatedBlockchainButton(
                  blockchainNames[index],
                  isSelected,
                  index == _hoveredButtonIndex,
                  () {
                    widget.onBlockchainChanged(blockchainModels[index]);
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
              );
            }),
          ),
        ),
        
        // Comparison indicator text
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: AnimatedOpacity(
            opacity: blockchainNames[_selectedIndex] != 'MegaETH' ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  blockchainNames[_selectedIndex] == 'MegaETH'
                      ? Icons.flash_on
                      : Icons.compare_arrows,
                  color: blockchainNames[_selectedIndex] == 'MegaETH'
                      ? AppTheme.accentGold
                      : AppTheme.primaryCyan,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  blockchainNames[_selectedIndex] == 'MegaETH'
                      ? 'Lightning Fast Performance'
                      : 'MegaETH is ${_calculateSpeedComparisonText(_selectedIndex)}',
                  style: TextStyle(
                    color: blockchainNames[_selectedIndex] == 'MegaETH'
                        ? AppTheme.accentGold
                        : Colors.white70,
                    fontSize: 14,
                    fontWeight: blockchainNames[_selectedIndex] == 'MegaETH'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Calculate speed comparison text
  String _calculateSpeedComparisonText(int selectedIndex) {
    final megaEthBlockTime = BlockchainModel.megaEth().blockTimeMs;
    final selectedBlockTime = [
      BlockchainModel.megaEth().blockTimeMs,
      BlockchainModel.ethereum().blockTimeMs,
      BlockchainModel.arbitrumOne().blockTimeMs,
      BlockchainModel.opBNB().blockTimeMs,
    ][selectedIndex];
    
    final multiplier = (selectedBlockTime / megaEthBlockTime).round();
    return '$multiplier× faster';
  }

  // Animated blockchain button with hover effects
  Widget _buildAnimatedBlockchainButton(
    String name,
    bool isSelected,
    bool isHovered,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 100, // Reduced width for better fit
        height: isSelected || isHovered ? 50 : 45,
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: isSelected || isHovered ? 8 : 6,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.purpleToCyanGradient
              : isHovered
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryPurple.withOpacity(0.3),
                        AppTheme.primaryCyan.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
          color: isSelected || isHovered ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryCyan
                : isHovered
                    ? AppTheme.primaryCyan.withOpacity(0.7)
                    : AppTheme.primaryCyan.withOpacity(0.3),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : isHovered
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryCyan.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
        ),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              color: isSelected || isHovered ? Colors.white : AppTheme.primaryCyan,
              fontWeight: FontWeight.bold,
              fontSize: isSelected ? 14 : 13, // Reduced font size
              letterSpacing: isSelected ? 0.6 : 0.4,
              fontFamily: 'Orbitron',
            ),
            child: Text(
              name,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Parameter row with animated values for emphasis
  Widget _buildParameterRow(String label, String value, bool highlight) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 2),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use a column layout on very narrow screens
              if (constraints.maxWidth < 220) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label row
                    Row(
                      children: [
                        if (highlight)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.star,
                              color: AppTheme.accentGold.withOpacity(0.6 + _pulseController.value * 0.4),
                              size: 12,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: highlight ? Colors.white : Colors.white70,
                              fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Value with padding
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 16, bottom: 8),
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: highlight 
                            ? AppTheme.accentGold.withOpacity(0.8 + _pulseController.value * 0.2)
                            : AppTheme.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: highlight ? 14 : 13,
                          fontFamily: highlight ? 'Orbitron' : null,
                          shadows: highlight 
                            ? [
                                Shadow(
                                  color: AppTheme.accentGold.withOpacity(0.3 + _pulseController.value * 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ] 
                            : null,
                        ),
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Use row layout for wider screens
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Row(
                        children: [
                          if (highlight)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.star,
                                color: AppTheme.accentGold.withOpacity(0.6 + _pulseController.value * 0.4),
                                size: 12,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: highlight ? Colors.white : Colors.white70,
                                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 2,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: highlight 
                            ? AppTheme.accentGold.withOpacity(0.8 + _pulseController.value * 0.2)
                            : AppTheme.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: highlight ? 14 : 13,
                          fontFamily: highlight ? 'Orbitron' : null,
                          shadows: highlight 
                            ? [
                                Shadow(
                                  color: AppTheme.accentGold.withOpacity(0.3 + _pulseController.value * 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ] 
                            : null,
                        ),
                        child: Text(
                          value,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
          ),
        );
      },
    );
  }

  // Format time values appropriately
  String _formatTimeValue(double timeMs) {
    if (timeMs < 1000) {
      return '${timeMs.toStringAsFixed(1)} ms';
    } else if (timeMs < 60000) {
      return '${(timeMs / 1000).toStringAsFixed(2)} s';
    } else {
      final minutes = (timeMs / 60000).floor();
      final seconds = ((timeMs % 60000) / 1000).toStringAsFixed(1);
      return '$minutes min $seconds s';
    }
  }

  // Transaction rate slider with animated feedback
  Widget _buildTransactionRateSlider() {
    // Calculate max value based on blockchain
    final maxTps = widget.currentBlockchain.maxTransactionsPerSecond.toDouble();
    final sliderMax = maxTps < 100 ? maxTps : 
                     (maxTps < 1000 ? 100.0 : 500.0);
    
    return Column(
      children: [
        // Add row with min and max values
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 TPS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                '${sliderMax.toInt()} TPS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        
        // Improved slider with more height
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SliderTheme(
            data: AppTheme.sliderTheme.copyWith(
              trackHeight: 8, // Thicker track
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 16), // Larger thumb
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28), // Larger overlay
            ),
            child: Slider(
              min: 1.0,
              max: sliderMax,
              value: widget.transactionsPerSecond.toDouble().clamp(1.0, sliderMax),
              divisions: sliderMax.toInt(),
              label: '${widget.transactionsPerSecond} TPS',
              onChanged: (value) => widget.onTransactionsPerSecondChanged(value.toInt()),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Animated transaction rate value
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final efficiencyRatio = widget.transactionsPerSecond / sliderMax;
            Color valueColor;
            double glowIntensity;
            
            if (efficiencyRatio > 0.8) {
              // High efficiency - pulse between gold and cyan
              valueColor = Color.lerp(
                AppTheme.accentGold, 
                AppTheme.primaryCyan,
                _pulseController.value,
              )!;
              glowIntensity = 0.7 + _pulseController.value * 0.3;
            } else if (efficiencyRatio > 0.5) {
              // Medium efficiency - primaryCyan with moderate glow
              valueColor = AppTheme.primaryCyan;
              glowIntensity = 0.4 + _pulseController.value * 0.2;
            } else {
              // Low efficiency - dim primaryCyan
              valueColor = AppTheme.primaryCyan.withOpacity(0.7);
              glowIntensity = 0.1;
            }
            
            return Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: valueColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: valueColor.withOpacity(glowIntensity * 0.3),
                    blurRadius: 12,
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flash_on,
                    color: valueColor.withOpacity(0.7 + _pulseController.value * 0.3),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${widget.transactionsPerSecond} TPS',
                    style: TextStyle(
                      color: valueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      fontFamily: 'Orbitron',
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: valueColor.withOpacity(glowIntensity * 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        // Add efficiency indicator
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _buildEfficiencyIndicator(),
        ),
      ],
    );
  }
  
  // Efficiency indicator component
  Widget _buildEfficiencyIndicator() {
    final maxTps = widget.currentBlockchain.maxTransactionsPerSecond.toDouble();
    final sliderMax = maxTps < 100 ? maxTps : 
                     (maxTps < 1000 ? 100.0 : 500.0);
    final efficiencyRatio = widget.transactionsPerSecond / sliderMax;
    
    String efficiencyText;
    Color efficiencyColor;
    IconData efficiencyIcon;
    
    if (efficiencyRatio > 0.8) {
      efficiencyText = "High Performance";
      efficiencyColor = AppTheme.positiveGreen;
      efficiencyIcon = Icons.rocket_launch;
    } else if (efficiencyRatio > 0.5) {
      efficiencyText = "Moderate Load";
      efficiencyColor = AppTheme.accentGold;
      efficiencyIcon = Icons.speed;
    } else if (efficiencyRatio > 0.2) {
      efficiencyText = "Light Load";
      efficiencyColor = AppTheme.primaryCyan;
      efficiencyIcon = Icons.trending_up;
    } else {
      efficiencyText = "Minimal Load";
      efficiencyColor = AppTheme.primaryCyan.withOpacity(0.7);
      efficiencyIcon = Icons.trending_flat;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: efficiencyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: efficiencyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            efficiencyIcon,
            color: efficiencyColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            efficiencyText,
            style: TextStyle(
              color: efficiencyColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Control buttons with animated effects
  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.sports_esports,
                  color: AppTheme.primaryCyan,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Simulation Controls',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          // Replace Row with Wrap for better responsiveness
          Wrap(
            spacing: 16, // Space between buttons horizontally
            runSpacing: 16, // Space between buttons vertically if they wrap
            alignment: WrapAlignment.spaceEvenly,
            children: [
              // Start/Stop button with glow effect
              _AnimatedControlButton(
                icon: widget.isRunning ? Icons.stop : Icons.play_arrow,
                text: widget.isRunning ? 'STOP' : 'START',
                onTap: widget.onStartStop,
                style: widget.isRunning 
                  ? ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red.shade900.withOpacity(0.8)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.red.shade300, width: 2),
                        ),
                      ),
                    )
                  : ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(AppTheme.primaryPurple),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: AppTheme.primaryCyan, width: 2),
                        ),
                      ),
                    ),
                isActive: widget.isRunning,
                glowColor: widget.isRunning ? Colors.red.shade300 : AppTheme.primaryCyan,
              ),
              
              // Reset button with hover effect
              _AnimatedControlButton(
                icon: Icons.refresh,
                text: 'RESET',
                onTap: widget.onReset,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  foregroundColor: MaterialStateProperty.all(AppTheme.primaryCyan),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppTheme.primaryCyan, width: 2),
                    ),
                  ),
                ),
                isActive: false,
                glowColor: AppTheme.primaryPurple,
              ),
              
              // Stress Test button with loading animation
              _AnimatedControlButton(
                icon: _isStressTesting ? Icons.hourglass_top : Icons.flash_on,
                text: 'STRESS TEST',
                onTap: () {
                  if (!_isStressTesting) {
                    setState(() => _isStressTesting = true);
                    widget.onStressTest();
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() => _isStressTesting = false);
                      }
                    });
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(AppTheme.accentGold.withOpacity(0.15)),
                  foregroundColor: MaterialStateProperty.all(AppTheme.accentGold),
                  padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppTheme.accentGold, width: 2),
                    ),
                  ),
                ),
                isActive: _isStressTesting,
                glowColor: AppTheme.accentGold,
                isLoading: _isStressTesting,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Animated control button widget with hover effects
class _AnimatedControlButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final ButtonStyle style;
  final bool isActive;
  final Color glowColor;
  final bool isLoading;

  const _AnimatedControlButton({
    required this.icon,
    required this.text,
    required this.onTap,
    required this.style,
    required this.isActive,
    required this.glowColor,
    this.isLoading = false,
  });

  @override
  _AnimatedControlButtonState createState() => _AnimatedControlButtonState();
}

class _AnimatedControlButtonState extends State<_AnimatedControlButton> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return GestureDetector(
            onTap: widget.isLoading ? null : widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(
                      widget.isActive 
                        ? 0.4 + _hoverController.value * 0.2
                        : 0.2 + _hoverController.value * 0.2,
                    ),
                    blurRadius: 16 + _hoverController.value * 8,
                    spreadRadius: -1 + _hoverController.value * 2,
                    offset: Offset(0, 2 - _hoverController.value),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: widget.style,
                onPressed: widget.isLoading ? null : widget.onTap,
                child: Container(
                  // Removing fixed width to make responsive
                  height: 45, // Slightly shorter buttons
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Only take necessary space
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animate icon
                      widget.isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.glowColor,
                                ),
                              ),
                            )
                          : AnimatedBuilder(
                              animation: _hoverController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: widget.isActive 
                                    ? math.pi * 2 * _hoverController.value
                                    : 0,
                                  child: Icon(
                                    widget.icon,
                                    color: Colors.white,
                                    size: 18 + _hoverController.value * 2,
                                  ),
                                );
                              },
                            ),
                      const SizedBox(width: 8),
                      Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}