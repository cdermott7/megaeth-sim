import 'dart:math';
import 'package:flutter/material.dart';
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/models/blockchain_model.dart';
import 'package:megaeth_simulator/models/transaction_model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class TransactionJourney extends StatefulWidget {
  final BlockchainModel blockchain;
  final List<TransactionModel> transactions;
  
  const TransactionJourney({
    Key? key,
    required this.blockchain,
    required this.transactions,
  }) : super(key: key);

  @override
  State<TransactionJourney> createState() => _TransactionJourneyState();
}

class _TransactionJourneyState extends State<TransactionJourney> with TickerProviderStateMixin {
  late AnimationController _flowAnimationController;
  TransactionModel? _selectedTransaction;
  
  final Map<TransactionStage, IconData> _stageIcons = {
    TransactionStage.pending: Icons.hourglass_empty,
    TransactionStage.selected: Icons.search,
    TransactionStage.executing: Icons.settings,
    TransactionStage.stateChanging: Icons.sync,
    TransactionStage.diffGenerating: Icons.analytics,
    TransactionStage.propagating: Icons.send,
    TransactionStage.stateUpdating: Icons.edit_note,
    TransactionStage.confirmed: Icons.check_circle,
  };
  
  final Map<TransactionStage, String> _stageDescriptions = {
    TransactionStage.pending: 'Transaction in mempool waiting to be processed',
    TransactionStage.selected: 'Selected by user and waiting for sequencer',
    TransactionStage.executing: 'Being executed by sequencer with EVM operations',
    TransactionStage.stateChanging: 'State changes being computed',
    TransactionStage.diffGenerating: 'State diff being generated (changes to blockchain state)',
    TransactionStage.propagating: 'State diff being propagated across the network',
    TransactionStage.stateUpdating: 'State root being updated via MPT operations',
    TransactionStage.confirmed: 'Transaction confirmed and included in blockchain',
  };
  
  @override
  void initState() {
    super.initState();
    _flowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }
  
  @override
  void dispose() {
    _flowAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // If it's not MegaETH or there's no transaction data, show a message
    if (widget.blockchain.name != 'MegaETH' || 
        widget.transactions.isEmpty || 
        !widget.transactions.any((t) => t.isSelected)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.route,
              size: 64,
              color: AppTheme.silver.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Transaction Journey Visualizer',
              style: AppTheme.headingStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              widget.blockchain.name != 'MegaETH'
                  ? 'Detailed transaction journey only available for MegaETH'
                  : 'Select a transaction to visualize its journey',
              style: AppTheme.bodyStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Get the selected transaction or most recent one
    final activeTransactions = widget.transactions.where((t) => t.isSelected && !t.isConfirmed).toList();
    final confirmedTransactions = widget.transactions.where((t) => t.isConfirmed).toList();
    
    // Choose transaction to display
    if (_selectedTransaction == null || 
        !widget.transactions.contains(_selectedTransaction) ||
        (_selectedTransaction!.isConfirmed && activeTransactions.isNotEmpty)) {
      // If there are active transactions, select the first one
      if (activeTransactions.isNotEmpty) {
        _selectedTransaction = activeTransactions.first;
      }
      // Otherwise select the most recently confirmed one
      else if (confirmedTransactions.isNotEmpty) {
        confirmedTransactions.sort((a, b) => b.confirmedAt!.compareTo(a.confirmedAt!));
        _selectedTransaction = confirmedTransactions.first;
      }
    }
    
    if (_selectedTransaction == null) {
      return const Center(child: Text('No transactions to display'));
    }
    
    return Column(
      children: [
        // Transaction journey visualization
        Expanded(
          flex: 7,
          child: _buildJourneyVisualization(),
        ),
        
        // Transaction information and stage details
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.cardDecoration,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Transaction Details',
                        style: AppTheme.subHeadingStyle,
                      ),
                      const Spacer(),
                      Text(
                        'Type: ${_selectedTransaction!.type == TransactionType.erc20Transfer ? 'ERC-20 Transfer' : 'Uniswap Swap'}',
                        style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Stage: ${_getStageLabel(_selectedTransaction!.stage)}',
                    style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStageDescription(_selectedTransaction!.stage),
                    style: AppTheme.bodyStyle,
                  ),
                  const SizedBox(height: 12),
                  if (_selectedTransaction!.isConfirmed)
                    Text(
                      'Total confirmation time: ${_selectedTransaction!.confirmationDuration!.inMilliseconds} ms',
                      style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildJourneyVisualization() {
    // Check for mobile screen
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    
    return Container(
      // CRITICAL: Ensure the container has enough height - on mobile use 70% of screen height
      constraints: BoxConstraints(
        minHeight: isMobile ? screenHeight * 0.7 : 400,
      ),
      child: Stack(
        children: [
          // Background with grid pattern
          Container(
            decoration: BoxDecoration(
              color: AppTheme.jetBlack,
              // Using a gradient pattern instead of a remote image to avoid loading issues
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.jetBlack,
                  AppTheme.charcoal.withOpacity(0.8),
                  AppTheme.jetBlack,
                ],
              ),
            ),
          ),
          
          // Journey line with animation
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            left: 0,
            right: 0,
            height: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.silver.withOpacity(0.2),
                    AppTheme.silver.withOpacity(0.7),
                    AppTheme.silver.withOpacity(0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.silver.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          ),
          
          // Custom painter for active flow visualization
          CustomPaint(
            painter: TransactionJourneyPainter(
              transaction: _selectedTransaction!,
              animationValue: _flowAnimationController.value,
              isMobile: isMobile,
            ),
            size: Size.infinite,
          ),
          
          // Stage nodes along the journey
          ..._buildStageNodes(),
          
          // On Mobile: Stack details popups vertically
          // On Desktop: Position them side by side
          if (isMobile) ...[
            // For mobile, stack popups vertically with smaller sizes
            if (_selectedTransaction!.stage.index >= TransactionStage.executing.index)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.05, // Higher position
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: min(240, screenWidth * 0.9), // Smaller width on mobile
                    child: _buildEVMDetailsPopup(compact: true),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
              
            if (_selectedTransaction!.stage.index >= TransactionStage.diffGenerating.index)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3, // Below the journey line
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: min(240, screenWidth * 0.9), // Smaller width on mobile
                    child: _buildStateDiffDetailsPopup(compact: true),
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
          ] else ...[
            // Desktop layout - side by side
            if (_selectedTransaction!.stage.index >= TransactionStage.executing.index)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.08,
                left: MediaQuery.of(context).size.width * 0.23,
                child: _buildEVMDetailsPopup(),
              )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
              
            if (_selectedTransaction!.stage.index >= TransactionStage.diffGenerating.index)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.08,
                right: MediaQuery.of(context).size.width * 0.23,
                child: _buildStateDiffDetailsPopup(),
              )
              .animate()
              .fadeIn(duration: 400.ms, curve: Curves.easeOut)
              .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
          ],
        ],
      ),
    );
  }
  
  List<Widget> _buildStageNodes() {
    final stages = TransactionStage.values;
    final screenWidth = MediaQuery.of(context).size.width;
    final nodeSpacing = screenWidth / (stages.length + 1);
    
    return List.generate(stages.length, (index) {
      final stage = stages[index];
      final isCurrentStage = _selectedTransaction!.stage == stage;
      final isPastStage = _selectedTransaction!.stage.index > stage.index;
      final isFutureStage = _selectedTransaction!.stage.index < stage.index;
      
      // Calculate position - use Y coordinate that's safe for all screen sizes
      final x = (index + 1) * nodeSpacing;
      final y = MediaQuery.of(context).size.height * 0.2; // Position at the journey line
      
      // Determine visual state
      Color nodeColor;
      double nodeSize;
      double opacity;
      
      if (isCurrentStage) {
        nodeColor = AppTheme.silver;
        nodeSize = 28;
        opacity = 1.0;
      } else if (isPastStage) {
        nodeColor = AppTheme.silver.withOpacity(0.8);
        nodeSize = 24;
        opacity = 0.9;
      } else {
        nodeColor = AppTheme.steelGray.withOpacity(0.6);
        nodeSize = 22;
        opacity = 0.7;
      }
      
      // Generate animation delay based on stage
      final animationDelay = (isCurrentStage || isPastStage) ? 
         Duration(milliseconds: 100 * (isPastStage ? stage.index : 0)) : 
         Duration(milliseconds: 200 * stage.index);
      
      Widget nodeWidget = Positioned(
        left: x - nodeSize / 2,
        top: y - nodeSize / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Node circle with icon
            Container(
              width: nodeSize,
              height: nodeSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isCurrentStage ? 
                  [
                    AppTheme.silver.withOpacity(0.9),
                    AppTheme.steelGray.withOpacity(0.7),
                    AppTheme.jetBlack.withOpacity(0.9),
                  ] : 
                  [
                    AppTheme.steelGray.withOpacity(0.7),
                    AppTheme.charcoal.withOpacity(0.8),
                    AppTheme.jetBlack.withOpacity(0.9),
                  ],
                  stops: isCurrentStage ? 
                    [0.3, 0.6, 1.0] : 
                    [0.4, 0.7, 1.0],
                ),
                border: Border.all(
                  color: isCurrentStage ? 
                    AppTheme.silver : 
                    AppTheme.steelGray.withOpacity(isPastStage ? 0.7 : 0.5),
                  width: isCurrentStage ? 2.0 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: nodeColor.withOpacity(isCurrentStage ? 0.7 : 0.3),
                    blurRadius: isCurrentStage ? 15 : 8,
                    spreadRadius: isCurrentStage ? 2 : 0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getStageIcon(stage),
                  color: isCurrentStage ? AppTheme.platinum : AppTheme.silver.withOpacity(0.8),
                  size: nodeSize * 0.6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Premium stage label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentStage ? 
                  AppTheme.jetBlack.withOpacity(0.9) : 
                  AppTheme.jetBlack.withOpacity(0.7),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: isCurrentStage ? 
                    AppTheme.silver : 
                    AppTheme.steelGray.withOpacity(isPastStage ? 0.6 : 0.4),
                  width: 1,
                ),
                boxShadow: isCurrentStage ? [
                  BoxShadow(
                    color: AppTheme.silver.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ] : null,
              ),
              child: Text(
                _getStageLabel(stage),
                style: TextStyle(
                  color: isCurrentStage ? 
                    AppTheme.silver : 
                    AppTheme.silver.withOpacity(isPastStage ? 0.9 : 0.7),
                  fontSize: isCurrentStage ? 13 : 12,
                  fontWeight: isCurrentStage ? FontWeight.bold : 
                              isPastStage ? FontWeight.w500 : FontWeight.normal,
                  fontFamily: 'Helvetica',
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
      
      // Add animations
      return nodeWidget.animate(
        delay: animationDelay, 
        onPlay: (controller) => controller.repeat(reverse: isCurrentStage, period: Duration(seconds: 3)),
      )
      .fade(
        duration: 400.ms, 
        curve: Curves.easeOut, 
        begin: 0.0, 
        end: opacity
      )
      .scale(
        duration: 500.ms, 
        curve: Curves.elasticOut, 
        begin: Offset(0.7, 0.7), 
        end: Offset(1.0, 1.0)
      )
      .then()
      .shimmer(
        duration: 2.seconds, 
        curve: Curves.easeInOut
      )
      .blurXY(
        begin: isCurrentStage ? 5.0 : 0, 
        end: 0, 
        duration: 400.ms,
        curve: Curves.easeOut
      );
    });
  }
  
  Widget _buildEVMDetailsPopup({bool compact = false}) {
    return Container(
      width: compact ? 240 : 260,
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
            color: AppTheme.silver.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant Y2K header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 6 : 8),
            decoration: BoxDecoration(
              gradient: AppTheme.silverGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.memory, 
                  color: AppTheme.jetBlack, 
                  size: compact ? 12 : 14
                ),
                SizedBox(width: compact ? 4 : 8),
                // Typewriter animated title - smaller on mobile
                DefaultTextStyle(
                  style: TextStyle(
                    color: AppTheme.jetBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 10 : 12,
                    letterSpacing: compact ? 0.5 : 1.0,
                    fontFamily: 'Helvetica',
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'EVM EXECUTION BREAKDOWN',
                        speed: Duration(milliseconds: 50),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                  ),
                ),
              ],
            ),
          ),
          
          // Content with operation breakdown - more compact on mobile
          Padding(
            padding: EdgeInsets.all(compact ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // On mobile, show fewer entries to save space
                ..._selectedTransaction!.evmOperationTimeBreakdown.entries.take(compact ? 5 : 7).map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: compact ? 4 : 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                color: AppTheme.silver,
                                fontWeight: FontWeight.bold,
                                fontSize: compact ? 9 : 11,
                                letterSpacing: compact ? 0.3 : 0.5,
                                fontFamily: 'Helvetica',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 3 : 5, 
                                vertical: compact ? 1 : 2
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.jetBlack,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 0.5),
                              ),
                              child: Text(
                                '${entry.value}%',
                                style: TextStyle(
                                  color: AppTheme.silver,
                                  fontSize: compact ? 9 : 10,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: compact ? 2 : 3),
                        // Premium progress bar - thinner on mobile
                        Stack(
                          children: [
                            // Base track
                            Container(
                              height: compact ? 4 : 5,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppTheme.jetBlack,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: AppTheme.silver.withOpacity(0.2), width: 0.5),
                              ),
                            ),
                            // Progress fill with animation - adjust width for container
                            AnimatedContainer(
                              duration: Duration(milliseconds: 1500),
                              height: compact ? 4 : 5,
                              width: (compact ? 220 : 236) * (entry.value / 100), // Adjusted width for mobile
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.silver.withOpacity(0.7),
                                    AppTheme.silver.withOpacity(0.9),
                                    AppTheme.silver.withOpacity(0.7),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.silver.withOpacity(0.3),
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                            ).animate().shimmer(duration: 3.seconds, delay: 1.seconds),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 400 + 100 * _selectedTransaction!.evmOperationTimeBreakdown.entries.toList().indexOf(entry)));
                }).toList(),
                
                // Y2K-style note about optimizations - smaller on mobile
                Container(
                  margin: EdgeInsets.only(top: compact ? 6 : 8),
                  padding: EdgeInsets.all(compact ? 4 : 6),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: compact ? 8 : 10, color: AppTheme.silver),
                      SizedBox(width: compact ? 4 : 6),
                      Expanded(
                        child: Text(
                          'MegaETH optimizes SLOAD (state access) operations with in-memory state.',
                          style: TextStyle(
                            color: AppTheme.silver.withOpacity(0.8),
                            fontSize: compact ? 8 : 9,
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
    );
  }
  
  Widget _buildStateDiffDetailsPopup({bool compact = false}) {
    return Container(
      width: compact ? 240 : 260,
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
            color: AppTheme.silver.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 0,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Premium Y2K header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 6 : 8),
            decoration: BoxDecoration(
              gradient: AppTheme.silverGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(2),
                topRight: Radius.circular(2),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics, 
                  color: AppTheme.jetBlack, 
                  size: compact ? 12 : 14
                ),
                SizedBox(width: compact ? 4 : 8),
                // Typewriter animation - smaller on mobile
                DefaultTextStyle(
                  style: TextStyle(
                    color: AppTheme.jetBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: compact ? 10 : 12,
                    letterSpacing: compact ? 0.5 : 1.0,
                    fontFamily: 'Helvetica',
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'STATE DIFF ANALYSIS',
                        speed: Duration(milliseconds: 50),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                  ),
                ),
              ],
            ),
          ),
          
          // Content with premium styling
          Padding(
            padding: EdgeInsets.all(compact ? 8 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Transaction type indicator
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 6 : 10, 
                    vertical: compact ? 4 : 6
                  ),
                  margin: EdgeInsets.only(bottom: compact ? 8 : 12),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppTheme.silver.withOpacity(0.5), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_selectedTransaction!.type == TransactionType.erc20Transfer 
                          ? Icons.currency_exchange : Icons.swap_horiz,
                        size: compact ? 12 : 14,
                        color: AppTheme.silver,
                      ),
                      SizedBox(width: compact ? 4 : 6),
                      Text(
                        _selectedTransaction!.type == TransactionType.erc20Transfer 
                            ? 'ERC-20 TRANSFER' : 'UNISWAP SWAP',
                        style: TextStyle(
                          color: AppTheme.silver,
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 10 : 12,
                          letterSpacing: compact ? 0.3 : 0.5,
                          fontFamily: 'Helvetica',
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(
                  delay: 200.ms,
                  duration: 400.ms,
                  begin: Offset(0.9, 0.9),
                  end: Offset(1.0, 1.0),
                  curve: Curves.easeOut,
                ),
                
                // Stats in a grid
                Container(
                  padding: EdgeInsets.all(compact ? 8 : 10),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    children: [
                      _buildPremiumDetailRow(
                        'MODIFIED VALUES:',
                        _selectedTransaction!.type == TransactionType.erc20Transfer ? '3' : '8',
                        Icons.edit,
                        compact: compact,
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      _buildPremiumDetailRow(
                        'UNCOMPRESSED SIZE:',
                        '${_selectedTransaction!.stateDiffSize} bytes',
                        Icons.data_object,
                        compact: compact,
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      // Highlight compression info
                      Container(
                        padding: EdgeInsets.all(compact ? 6 : 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.silver.withOpacity(0.1),
                              AppTheme.jetBlack.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(color: AppTheme.silver.withOpacity(0.5), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.compress, size: compact ? 10 : 12, color: AppTheme.silver),
                                SizedBox(width: compact ? 4 : 6),
                                Text(
                                  'COMPRESSION:',
                                  style: TextStyle(
                                    color: AppTheme.silver,
                                    fontWeight: FontWeight.bold,
                                    fontSize: compact ? 9 : 11,
                                    letterSpacing: compact ? 0.3 : 0.5,
                                    fontFamily: 'Helvetica',
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 4 : 6, 
                                vertical: compact ? 2 : 3
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.silverGradient,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                '${widget.blockchain.compressionRatio}x',
                                style: TextStyle(
                                  color: AppTheme.jetBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: compact ? 10 : 12,
                                  fontFamily: 'Helvetica',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().shimmer(
                        duration: 3.seconds, 
                        delay: 1.seconds,
                        curve: Curves.easeInOut,
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      _buildPremiumDetailRow(
                        'COMPRESSED SIZE:',
                        '${(_selectedTransaction!.stateDiffSize / widget.blockchain.compressionRatio).round()} bytes',
                        Icons.compress,
                        compact: compact,
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      _buildPremiumDetailRow(
                        'BANDWIDTH:',
                        '${(_selectedTransaction!.stateDiffSize / widget.blockchain.compressionRatio / 1024 * 8).toStringAsFixed(2)} Kbps',
                        Icons.network_cell,
                        compact: compact,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                
                // Note about state diff importance (smaller on mobile)
                Container(
                  margin: EdgeInsets.only(top: compact ? 8 : 12),
                  padding: EdgeInsets.all(compact ? 6 : 8),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 0.5),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: compact ? 8 : 10, color: AppTheme.silver),
                      SizedBox(width: compact ? 4 : 6),
                      Expanded(
                        child: Text(
                          '19x compression enables MegaETH to achieve 100,000 TPS without exceeding 25Mbps bandwidth constraints.',
                          style: TextStyle(
                            color: AppTheme.silver.withOpacity(0.8),
                            fontSize: compact ? 8 : 9,
                            fontFamily: 'Helvetica',
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPremiumDetailRow(String label, String value, IconData icon, {bool compact = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: compact ? 10 : 12, color: AppTheme.silver),
            SizedBox(width: compact ? 4 : 6),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.silver,
                fontWeight: FontWeight.bold,
                fontSize: compact ? 9 : 11,
                letterSpacing: compact ? 0.3 : 0.5,
                fontFamily: 'Helvetica',
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 4 : 6, 
            vertical: compact ? 1 : 2
          ),
          decoration: BoxDecoration(
            color: AppTheme.jetBlack,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppTheme.silver.withOpacity(0.3), width: 0.5),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.silver,
              fontSize: compact ? 9 : 11,
              fontFamily: 'Helvetica',
            ),
          ),
        ),
      ],
    );
  }
  
  IconData _getStageIcon(TransactionStage stage) {
    return _stageIcons[stage] ?? Icons.help_outline;
  }
  
  String _getStageLabel(TransactionStage stage) {
    switch (stage) {
      case TransactionStage.pending:
        return 'Pending';
      case TransactionStage.selected:
        return 'Selected';
      case TransactionStage.executing:
        return 'Executing';
      case TransactionStage.stateChanging:
        return 'State Changes';
      case TransactionStage.diffGenerating:
        return 'Diff Generation';
      case TransactionStage.propagating:
        return 'Propagating';
      case TransactionStage.stateUpdating:
        return 'State Update';
      case TransactionStage.confirmed:
        return 'Confirmed';
    }
  }
  
  String _getStageDescription(TransactionStage stage) {
    return _stageDescriptions[stage] ?? 'Unknown stage';
  }
}

class TransactionJourneyPainter extends CustomPainter {
  final TransactionModel transaction;
  final double animationValue;
  final bool isMobile;
  
  TransactionJourneyPainter({
    required this.transaction,
    required this.animationValue,
    this.isMobile = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Premium path and line painting setup
    final regularPath = Paint()
      ..strokeWidth = 1.5
      ..color = AppTheme.silver.withOpacity(0.4)
      ..style = PaintingStyle.stroke;
    
    final completedPath = Paint()
      ..strokeWidth = 2.5
      ..color = AppTheme.silver
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Create gradient for completed path
    final completedGradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.silver.withOpacity(0.7),
          AppTheme.silver.withOpacity(0.9),
          AppTheme.silver.withOpacity(0.7),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, 4))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final particlePaint = Paint()
      ..style = PaintingStyle.fill;
    
    final stages = TransactionStage.values;
    final stagePositions = _calculateStagePositions(stages.length, size);
    
    // Draw decorative background grid lines
    _drawBackgroundGrid(canvas, size);
    
    // Draw dotted guideline first (under the connections)
    _drawDottedGuideline(canvas, stagePositions, size);
    
    // Draw connections between stages with premium style
    for (int i = 0; i < stages.length - 1; i++) {
      final start = stagePositions[i];
      final end = stagePositions[i + 1];
      
      // Determine if this connection is completed or active
      final isCompleted = transaction.stage.index > stages[i + 1].index;
      final isActive = transaction.stage.index > stages[i].index && 
                      transaction.stage.index <= stages[i + 1].index;
      
      if (isCompleted) {
        // Draw completed connection with gradient effect
        canvas.drawLine(start, end, completedGradientPaint);
        
        // Add a subtle glow effect behind completed connections
        final glowPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              AppTheme.silver.withOpacity(0.3),
              AppTheme.silver.withOpacity(0.0),
            ],
          ).createShader(Rect.fromLTWH(
            start.dx, 
            start.dy - 10, 
            end.dx - start.dx, 
            20))
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5)
          ..strokeWidth = 6.0
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(start, end, glowPaint);
      } else {
        // Draw incomplete connection (dotted or solid)
        if (isActive) {
          // Active connection gets a pulsing animation
          final pulsePaint = Paint()
            ..color = AppTheme.silver.withOpacity(0.2 + 0.2 * sin(animationValue * 2 * pi))
            ..strokeWidth = 2.0 + sin(animationValue * 2 * pi)
            ..style = PaintingStyle.stroke;
          
          canvas.drawLine(start, end, pulsePaint);
          
          // Calculate how far along the active stage is (based on timing)
          final progressFraction = _calculateStageProgress();
          
          // Draw progress fill with gradient
          if (progressFraction > 0) {
            final midX = start.dx + (end.dx - start.dx) * progressFraction;
            
            // Progress fill
            final progressPaint = Paint()
              ..shader = LinearGradient(
                colors: [
                  AppTheme.silver.withOpacity(0.8),
                  AppTheme.silver.withOpacity(0.5),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTWH(start.dx, start.dy - 2, midX - start.dx, 4))
              ..strokeWidth = 3.0
              ..strokeCap = StrokeCap.round
              ..style = PaintingStyle.stroke;
            
            canvas.drawLine(start, Offset(midX, start.dy), progressPaint);
            
            // Add glow at the end of the progress line
            final endGlowPaint = Paint()
              ..color = AppTheme.silver.withOpacity(0.7)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4)
              ..style = PaintingStyle.fill;
            
            canvas.drawCircle(Offset(midX, start.dy), 4, endGlowPaint);
          }
          
          // Draw particles on the active connection
          _drawFlowingParticles(canvas, start, end, particlePaint);
        } else {
          // Inactive future connection
          _drawDashedLine(canvas, start, end, regularPath);
        }
      }
    }
    
    // Draw junction nodes
    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      final position = stagePositions[i];
      final isActive = transaction.stage == stage;
      final isCompleted = transaction.stage.index > stage.index;
      
      if (isCompleted) {
        // Draw completed node with checkmark effect
        _drawCompletedNode(canvas, position);
      } else if (isActive) {
        // Draw active node with pulsing effect
        _drawActiveNode(canvas, position);
      } else {
        // Draw future node
        _drawFutureNode(canvas, position);
      }
    }
  }
  
  // Calculate how far along the current stage is (0.0 to 1.0)
  double _calculateStageProgress() {
    final stage = transaction.stage;
    final timestamp = transaction.stageTimestamps[stage];
    
    if (timestamp == null) return 0.0;
    
    // Get next stage timestamps if available
    TransactionStage? nextStage;
    if (stage.index < TransactionStage.values.length - 1) {
      nextStage = TransactionStage.values[stage.index + 1];
    }
    
    final nextTimestamp = transaction.stageTimestamps[nextStage];
    
    // If next stage hasn't started yet, estimate progress based on whitepaper timings
    if (nextTimestamp == null) {
      // Estimate duration based on transaction type and stage
      int stageDurationMs;
      switch (stage) {
        case TransactionStage.executing:
          stageDurationMs = transaction.type == TransactionType.erc20Transfer ? 3 : 4;
          break;
        case TransactionStage.stateChanging:
          stageDurationMs = transaction.type == TransactionType.erc20Transfer ? 1 : 2;
          break;
        case TransactionStage.diffGenerating:
          stageDurationMs = transaction.type == TransactionType.erc20Transfer ? 1 : 2;
          break;
        case TransactionStage.propagating:
          stageDurationMs = 2; // Fixed propagation delay
          break;
        case TransactionStage.stateUpdating:
          stageDurationMs = transaction.type == TransactionType.erc20Transfer ? 2 : 4;
          break;
        default:
          return 0.0; // Can't estimate for other stages
      }
      
      // Calculate elapsed time since stage started
      final elapsed = DateTime.now().difference(timestamp).inMilliseconds;
      
      // Calculate progress fraction
      return elapsed / stageDurationMs;
    } else {
      // We can calculate exact progress using the actual timestamps
      final totalDuration = nextTimestamp.difference(timestamp).inMilliseconds;
      final elapsed = DateTime.now().difference(timestamp).inMilliseconds;
      
      return elapsed / totalDuration;
    }
  }
  
  // Draw premium Y2K-style decorative background grid
  void _drawBackgroundGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.silver.withOpacity(0.05)
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
  }
  
  // Draw a dotted guideline under the connections
  void _drawDottedGuideline(Canvas canvas, List<Offset> positions, Size size) {
    if (positions.isEmpty) return;
    
    final dotPaint = Paint()
      ..color = AppTheme.silver.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    // Only draw between first and last position
    final start = positions.first;
    final end = positions.last;
    
    // Draw dots with spacing
    final distance = end.dx - start.dx;
    final dotCount = (distance / 10).floor(); // A dot every 10 pixels
    
    for (int i = 0; i <= dotCount; i++) {
      final x = start.dx + (distance * i / dotCount);
      canvas.drawCircle(Offset(x, start.dy), 1, dotPaint);
    }
  }
  
  // Draw a dashed line between two points
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    // Draw dash pattern
    final dashSize = 6.0;
    final gapSize = 4.0;
    double drawn = 0;
    
    while (drawn < distance) {
      final dashEnd = min(drawn + dashSize, distance);
      final fraction1 = drawn / distance;
      final fraction2 = dashEnd / distance;
      
      final p1 = Offset(
        start.dx + dx * fraction1,
        start.dy + dy * fraction1,
      );
      
      final p2 = Offset(
        start.dx + dx * fraction2,
        start.dy + dy * fraction2,
      );
      
      canvas.drawLine(p1, p2, paint);
      
      drawn += dashSize + gapSize;
    }
  }
  
  // Draw a completed node with checkmark effect
  void _drawCompletedNode(Canvas canvas, Offset position) {
    // Outer glow
    final glowPaint = Paint()
      ..color = AppTheme.silver.withOpacity(0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, 10, glowPaint);
    
    // Node fill
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.silver.withOpacity(0.9),
          AppTheme.silver.withOpacity(0.6),
        ],
        stops: [0.3, 1.0],
      ).createShader(Rect.fromCircle(center: position, radius: 8))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, 8, fillPaint);
    
    // Border
    final borderPaint = Paint()
      ..color = AppTheme.silver
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(position, 8, borderPaint);
    
    // Checkmark
    final checkPaint = Paint()
      ..color = AppTheme.jetBlack
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    path.moveTo(position.dx - 3, position.dy);
    path.lineTo(position.dx - 1, position.dy + 2);
    path.lineTo(position.dx + 3, position.dy - 2);
    
    canvas.drawPath(path, checkPaint);
  }
  
  // Draw an active node with pulsing effect
  void _drawActiveNode(Canvas canvas, Offset position) {
    // Outer pulse ring with animation
    final outerPulsePaint = Paint()
      ..color = AppTheme.silver.withOpacity(0.1 + 0.2 * sin(animationValue * 2 * pi))
      ..style = PaintingStyle.fill;
    
    final pulseSize = 14 + 4 * sin(animationValue * 2 * pi);
    canvas.drawCircle(position, pulseSize, outerPulsePaint);
    
    // Glow effect
    final glowPaint = Paint()
      ..color = AppTheme.silver.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, 10, glowPaint);
    
    // Node fill with gradient
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppTheme.silver,
          AppTheme.silver.withOpacity(0.7),
        ],
        stops: [0.4, 1.0],
      ).createShader(Rect.fromCircle(center: position, radius: 12))
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, 10, fillPaint);
    
    // Border
    final borderPaint = Paint()
      ..color = AppTheme.silver
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(position, 10, borderPaint);
    
    // Active dot in center
    final corePaint = Paint()
      ..color = AppTheme.jetBlack
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, 3, corePaint);
  }
  
  // Draw a future node that hasn't been reached yet
  void _drawFutureNode(Canvas canvas, Offset position) {
    // Node fill
    final fillPaint = Paint()
      ..color = AppTheme.jetBlack
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, 7, fillPaint);
    
    // Border
    final borderPaint = Paint()
      ..color = AppTheme.silver.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(position, 7, borderPaint);
    
    // Dot pattern inside
    final dotPaint = Paint()
      ..color = AppTheme.silver.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, 2, dotPaint);
  }
  
  List<Offset> _calculateStagePositions(int stageCount, Size size) {
    final positions = <Offset>[];
    final nodeSpacing = size.width / (stageCount + 1);
    final y = size.height * 0.2; // Aligned with the journey line
    
    for (int i = 0; i < stageCount; i++) {
      positions.add(Offset((i + 1) * nodeSpacing, y));
    }
    
    return positions;
  }
  
  void _drawFlowingParticles(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    
    // Draw more particles for a premium effect
    for (int i = 0; i < 15; i++) {
      // Calculate particle position with varied speeds
      final speed = 1.0 + (i % 3) * 0.3; // Vary speed for different particles
      final offset = (animationValue * speed + i * 0.06) % 1.0;
      final x = start.dx + dx * offset;
      final y = start.dy + dy * offset;
      
      // Fade and size based on position with some randomness
      final fade = 0.3 + 0.7 * sin(offset * pi);
      final randomFactor = ((i * 7919) % 100) / 100.0; // Pseudo-random using prime number
      final size = 1.0 + fade * 2.5 + randomFactor;
      
      // Draw particle with glow effect
      // Outer glow
      paint.color = AppTheme.silver.withOpacity(fade * 0.3);
      canvas.drawCircle(Offset(x, y), size * 2, paint);
      
      // Inner core
      paint.color = AppTheme.silver.withOpacity(fade * 0.9);
      canvas.drawCircle(Offset(x, y), size, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}