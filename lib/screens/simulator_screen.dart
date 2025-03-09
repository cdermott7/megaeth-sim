import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/models/simulator_controller.dart';
import 'package:megaeth_simulator/models/blockchain_model.dart';
import 'package:megaeth_simulator/widgets/transaction_visualization.dart';
import 'package:megaeth_simulator/widgets/network_visualization.dart';
import 'package:megaeth_simulator/widgets/blockchain_controls.dart';
import 'package:megaeth_simulator/widgets/stats_display.dart';
import 'package:megaeth_simulator/widgets/block_game.dart';
import 'package:megaeth_simulator/widgets/tooltip_helper.dart';
import 'package:megaeth_simulator/widgets/megaeth_topology.dart';
import 'package:megaeth_simulator/widgets/transaction_journey.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({Key? key}) : super(key: key);

  @override
  SimulatorScreenState createState() => SimulatorScreenState();
}

class SimulatorScreenState extends State<SimulatorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SimulatorController(),
      child: Consumer<SimulatorController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: AppTheme.darkBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.y2kGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.silver.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              title: Row(
                children: [
                  // Y2K squared logo container with metal border
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3), // Square with slight rounding
                      gradient: AppTheme.metallicGradient,
                      border: Border.all(
                        color: AppTheme.silver,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.silver.withOpacity(0.3),
                          blurRadius: 3,
                          spreadRadius: 0,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.bolt,
                        color: AppTheme.jetBlack,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'MegaETH Simulator',
                    style: TextStyle(
                      color: AppTheme.silver,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.5,
                      fontFamily: 'Helvetica',
                      shadows: [
                        Shadow(
                          color: AppTheme.jetBlack,
                          blurRadius: 1,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              bottom: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(3), // Sharper corners for Y2K
                  gradient: AppTheme.metallicGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.silver.withOpacity(0.3),
                      blurRadius: 3,
                      spreadRadius: 0,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  fontSize: 12,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Helvetica',
                  fontWeight: FontWeight.normal,
                  fontSize: 12,
                ),
                labelColor: AppTheme.jetBlack,
                unselectedLabelColor: AppTheme.silver.withOpacity(0.7),
                tabs: [
                  Tab(
                    icon: Icon(Icons.touch_app, size: 16),
                    text: 'TRANSACTIONS',
                  ),
                  Tab(
                    icon: Icon(Icons.route, size: 16),
                    text: 'JOURNEY',
                  ),
                  Tab(
                    icon: Icon(Icons.grid_3x3, size: 16),
                    text: 'BLOCKS',
                  ),
                  Tab(
                    icon: Icon(Icons.account_tree, size: 16),
                    text: 'NETWORK',
                  ),
                  Tab(
                    icon: Icon(Icons.hub, size: 16),
                    text: 'TOPOLOGY',
                  ),
                ],
                indicatorPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              ),
              actions: [
                // Y2K-styled squared help button
                Container(
                  height: 36,
                  width: 36,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack,
                    borderRadius: BorderRadius.circular(3), // Y2K squared corners
                    border: Border.all(
                      color: AppTheme.silver,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(3),
                      onTap: () {
                        _showHelpDialog(context);
                      },
                      child: Center(
                        child: Icon(
                          Icons.help_outline,
                          size: 18,
                          color: AppTheme.silver,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // Main visualization area - take MOST of the screen
                Expanded(
                  flex: 7, // CRITICAL: Increased ratio to give even more space to the visualizations on mobile
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 4), // Consistent padding
                    // CRITICAL: Ensure this container fills its parent
                    width: double.infinity,
                    height: double.infinity,
                    child: TabBarView(
                      controller: _tabController,
                      // CRITICAL: Disable physics to fix mobile scrolling issues that resize the tabs
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // Transaction visualization tab - wrap in SafeArea to respect system bars
                        SafeArea(
                          // Force full height and width
                          bottom: false, // Don't add bottom padding to allow full height
                          maintainBottomViewPadding: false,
                          child: _buildTransactionTab(controller),
                        ),
                        
                        // Transaction journey tab - wrap in SafeArea
                        SafeArea(
                          bottom: false, // Don't add bottom padding to allow full height
                          maintainBottomViewPadding: false,
                          child: _buildTransactionJourneyTab(controller),
                        ),
                        
                        // Block game tab - wrap in SafeArea
                        SafeArea(
                          bottom: false, // Don't add bottom padding to allow full height
                          maintainBottomViewPadding: false,
                          child: _buildBlockGameTab(controller),
                        ),
                        
                        // Network visualization tab - wrap in SafeArea
                        SafeArea(
                          bottom: false, // Don't add bottom padding to allow full height
                          maintainBottomViewPadding: false,
                          child: _buildNetworkTab(controller),
                        ),
                        
                        // MegaETH topology tab - wrap in SafeArea
                        SafeArea(
                          bottom: false, // Don't add bottom padding to allow full height
                          maintainBottomViewPadding: false,
                          child: _buildTopologyTab(controller),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Controls and stats panel at bottom - Y2K control panel style
                Container(
                  constraints: BoxConstraints(
                    // CRITICAL: Make the bottom panel much smaller on mobile to maximize visualization space
                    maxHeight: MediaQuery.of(context).size.width < 600 
                        ? MediaQuery.of(context).size.height * 0.18 // Only 18% on mobile
                        : MediaQuery.of(context).size.height * 0.22, // 22% on desktop
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.darkGradient,
                    border: Border(
                      top: BorderSide(
                        color: AppTheme.silver.withOpacity(0.4),
                        width: 1, // Thinner lines for precision Y2K look
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        spreadRadius: 0,
                        offset: Offset(0, -1),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Use a column layout on narrow screens (mobile)
                      if (constraints.maxWidth < 900) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Blockchain controls - more compact for mobile
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: BlockchainControls(
                                    currentBlockchain: controller.blockchain,
                                    onBlockchainChanged: controller.setBlockchain,
                                    transactionsPerSecond: controller.transactionsPerSecond,
                                    onTransactionsPerSecondChanged: controller.setTransactionsPerSecond,
                                    isRunning: controller.isRunning,
                                    onStartStop: () {
                                      if (controller.isRunning) {
                                        controller.stopSimulation();
                                      } else {
                                        controller.startSimulation();
                                      }
                                    },
                                    onReset: controller.resetSimulation,
                                    onStressTest: controller.runStressTest,
                                  ),
                                ),
                                
                                // Stats display - more compact for mobile
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: StatsDisplay(
                                    blockchain: controller.blockchain,
                                    confirmedTransactions: controller.confirmedTransactions,
                                    averageConfirmationTimeMs: controller.averageConfirmationTimeMs,
                                    currentThroughput: controller.currentThroughput,
                                    compactMode: true, // Enable compact mode for mobile
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Use row layout for wider screens
                        return SingleChildScrollView(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Blockchain controls
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: BlockchainControls(
                                    currentBlockchain: controller.blockchain,
                                    onBlockchainChanged: controller.setBlockchain,
                                    transactionsPerSecond: controller.transactionsPerSecond,
                                    onTransactionsPerSecondChanged: controller.setTransactionsPerSecond,
                                    isRunning: controller.isRunning,
                                    onStartStop: () {
                                      if (controller.isRunning) {
                                        controller.stopSimulation();
                                      } else {
                                        controller.startSimulation();
                                      }
                                    },
                                    onReset: controller.resetSimulation,
                                    onStressTest: controller.runStressTest,
                                  ),
                                ),
                              ),
                              
                              // Stats display
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: StatsDisplay(
                                    blockchain: controller.blockchain,
                                    confirmedTransactions: controller.confirmedTransactions,
                                    averageConfirmationTimeMs: controller.averageConfirmationTimeMs,
                                    currentThroughput: controller.currentThroughput,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildTransactionTab(SimulatorController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headerHeight = 60.0; // Fixed compact height for the header
        final isMobile = MediaQuery.of(context).size.width < 600;
        
        // CRITICAL: Force height to be at least 70% of screen height on mobile
        final minimumHeight = MediaQuery.of(context).size.height * (isMobile ? 0.7 : 0.5);
        final effectiveHeight = constraints.maxHeight < minimumHeight ? minimumHeight : constraints.maxHeight;
        
        return Container(
          width: constraints.maxWidth,
          // CRITICAL: Ensure minimum height for mobile
          height: effectiveHeight,
          constraints: BoxConstraints(
            minHeight: minimumHeight,
          ),
          child: Stack(
            fit: StackFit.expand, // CRITICAL: Ensure stack fills the container
            children: [
              // Transaction visualization takes the FULL space behind
              Positioned.fill( // CRITICAL: Fill the entire space
                child: TransactionVisualization(
                  transactions: controller.transactions,
                  onTransactionSelected: controller.selectTransaction,
                ),
              ),
              
              // Y2K-styled instructions panel with squared corners
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  height: headerHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack,
                    borderRadius: BorderRadius.circular(3), // Squared Y2K corners
                    border: Border.all(
                      color: AppTheme.silver,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        spreadRadius: 0,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Squared Y2K info icon
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: AppTheme.jetBlack,
                          border: Border.all(
                            color: AppTheme.silver,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: AppTheme.silver,
                          size: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Click transaction circles to process them. With MegaETH, they confirm after just 10ms block time + 2ms propagation delay.',
                          style: TextStyle(
                            color: AppTheme.silver,
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Helvetica',
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
  
  Widget _buildBlockGameTab(SimulatorController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 600;
        
        // CRITICAL: Force height to be at least 70% of screen height on mobile
        final minimumHeight = MediaQuery.of(context).size.height * (isMobile ? 0.7 : 0.5);
        final effectiveHeight = constraints.maxHeight < minimumHeight ? minimumHeight : constraints.maxHeight;
        
        return Container(
          width: constraints.maxWidth,
          // CRITICAL: Ensure minimum height for mobile
          height: effectiveHeight,
          constraints: BoxConstraints(
            minHeight: minimumHeight,
          ),
          // No padding to maximize game area
          child: BlockGame(
            blockchain: controller.blockchain,
            isRunning: controller.isRunning,
          ),
        );
      }
    );
  }
  
  Widget _buildNetworkTab(SimulatorController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headerHeight = 60.0; // Fixed compact height for the header
        final isMobile = MediaQuery.of(context).size.width < 600;
        
        // CRITICAL: Force height to be at least 70% of screen height on mobile
        final minimumHeight = MediaQuery.of(context).size.height * (isMobile ? 0.7 : 0.5);
        final effectiveHeight = constraints.maxHeight < minimumHeight ? minimumHeight : constraints.maxHeight;
        
        return Container(
          width: constraints.maxWidth,
          // CRITICAL: Ensure minimum height for mobile
          height: effectiveHeight,
          constraints: BoxConstraints(
            minHeight: minimumHeight,
          ),
          child: Stack(
            fit: StackFit.expand, // CRITICAL: Ensure stack fills the container
            children: [
              // Network visualization takes the FULL space behind
              Positioned.fill( // CRITICAL: Fill the entire space
                child: NetworkVisualization(
                  blockchain: controller.blockchain,
                  size: Size(constraints.maxWidth, effectiveHeight),
                ),
              ),
              
              // Y2K-styled instructions panel with squared corners
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  height: headerHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack,
                    borderRadius: BorderRadius.circular(3), // Squared Y2K corners
                    border: Border.all(
                      color: AppTheme.silver,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        spreadRadius: 0,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Squared Y2K info icon
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: AppTheme.jetBlack,
                          border: Border.all(
                            color: AppTheme.silver,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: AppTheme.silver,
                          size: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This visualization shows how quickly data propagates across the blockchain network.',
                          style: TextStyle(
                            color: AppTheme.silver,
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Helvetica',
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: AppTheme.jetBlack,
            borderRadius: BorderRadius.circular(4), // Y2K squared corners
            border: Border.all(
              color: AppTheme.silver,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(3, 3),
              ),
              BoxShadow(
                color: AppTheme.silver.withOpacity(0.1),
                blurRadius: 0,
                spreadRadius: 0,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Y2K metallic header
              Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppTheme.metallicGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: AppTheme.jetBlack,
                          border: Border.all(
                            color: AppTheme.silver,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.help_outline,
                          color: AppTheme.silver,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'MEGAETH SIMULATOR HELP',
                        style: TextStyle(
                          fontFamily: 'Helvetica',
                          color: AppTheme.jetBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Y2K-styled content
              Padding(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.jetBlack,
                          borderRadius: BorderRadius.circular(3), // Y2K squared corners
                          border: Border.all(
                            color: AppTheme.silver.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'This simulator demonstrates MegaETH\'s exceptional performance compared to other blockchains.',
                          style: TextStyle(
                            color: AppTheme.silver,
                            fontSize: 13,
                            height: 1.4,
                            fontFamily: 'Helvetica',
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Y2K-styled section header
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.jetBlack,
                          border: Border.all(
                            color: AppTheme.silver,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          'FEATURES',
                          style: TextStyle(
                            fontFamily: 'Helvetica',
                            color: AppTheme.silver,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Feature items with premium icons
                      _buildFeatureItem(
                        icon: Icons.touch_app,
                        title: 'Transaction Tab',
                        description: 'Click on transaction circles to process them and observe confirmation times.',
                      ),
                      SizedBox(height: 12),
                      
                      _buildFeatureItem(
                        icon: Icons.route,
                        title: 'Journey Tab',
                        description: 'Visualize the complete transaction journey through all stages: execution, state changing, diff generation, propagation, and MPT updates.',
                      ),
                      SizedBox(height: 12),
                      
                      _buildFeatureItem(
                        icon: Icons.grid_3x3,
                        title: 'Block Game Tab',
                        description: 'Watch blocks stack in real-time, demonstrating the effects of block time.',
                      ),
                      SizedBox(height: 12),
                      
                      _buildFeatureItem(
                        icon: Icons.account_tree,
                        title: 'Network Tab',
                        description: 'Visualize data propagation across the network.',
                      ),
                      SizedBox(height: 12),
                      
                      _buildFeatureItem(
                        icon: Icons.hub,
                        title: 'Topology Tab',
                        description: 'Explore MegaETH\'s specialized node architecture: Sequencer (100 CPU cores), Replica nodes, Full nodes, and Provers.',
                      ),
                      SizedBox(height: 12),
                      
                      _buildFeatureItem(
                        icon: Icons.settings,
                        title: 'Controls',
                        description: 'Change blockchains, adjust transaction rate, run stress tests.',
                      ),
                      SizedBox(height: 12),
                      
                      _buildFeatureItem(
                        icon: Icons.bar_chart,
                        title: 'Statistics',
                        description: 'View performance metrics and comparisons.',
                      ),
                      SizedBox(height: 24),
                      
                      // Y2K-styled tip box
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.jetBlack,
                          borderRadius: BorderRadius.circular(3), // Y2K squared corners
                          border: Border.all(
                            color: AppTheme.silver.withOpacity(0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: AppTheme.silver.withOpacity(0.6),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.lightbulb_outline,
                                color: AppTheme.silver,
                                size: 14,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Try MegaETH with 10ms block times, 19x compression ratio, and specialized node architecture for dramatic 100,000 TPS performance!',
                                style: TextStyle(
                                  color: AppTheme.silver,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.3,
                                  fontFamily: 'Helvetica',
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Y2K-styled button container
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.jetBlack,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.silver.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Y2K-styled button
                    ElevatedButton(
                      style: AppTheme.y2kButtonStyle,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close,
                            size: 12,
                            color: AppTheme.silver,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'CLOSE',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              fontSize: 12,
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
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Y2K-styled squared icon container
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.jetBlack,
            borderRadius: BorderRadius.circular(3), // Y2K squared corners
            border: Border.all(
              color: AppTheme.silver,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.silver,
            size: 14,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y2K-styled tech title
              Text(
                title.toUpperCase(), // Uppercase for Y2K tech look
                style: TextStyle(
                  color: AppTheme.silver,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Helvetica',
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              // Y2K-styled description
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.silver.withOpacity(0.8),
                  height: 1.3,
                  fontSize: 12,
                  fontFamily: 'Helvetica',
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTransactionJourneyTab(SimulatorController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headerHeight = 60.0;
        final isMobile = MediaQuery.of(context).size.width < 600;
        
        // CRITICAL: Force height to be at least 70% of screen height on mobile
        final minimumHeight = MediaQuery.of(context).size.height * (isMobile ? 0.7 : 0.5);
        final effectiveHeight = constraints.maxHeight < minimumHeight ? minimumHeight : constraints.maxHeight;
        
        return Container(
          width: constraints.maxWidth,
          // CRITICAL: Ensure minimum height for mobile
          height: effectiveHeight,
          constraints: BoxConstraints(
            minHeight: minimumHeight,
          ),
          child: Stack(
            fit: StackFit.expand, // CRITICAL: Ensure stack fills the container
            children: [
              // Transaction journey visualization takes the FULL space behind
              Positioned.fill( // CRITICAL: Fill the entire space
                child: TransactionJourney(
                  blockchain: controller.blockchain,
                  transactions: controller.transactions,
                ),
              ),
              
              // Y2K-styled instructions panel
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  height: headerHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: AppTheme.silver,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        spreadRadius: 0,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Squared Y2K info icon
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: AppTheme.jetBlack,
                          border: Border.all(
                            color: AppTheme.silver,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: AppTheme.silver,
                          size: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Transaction journey visualizes the complete flow from selection to confirmation with detailed stages.',
                          style: TextStyle(
                            color: AppTheme.silver,
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Helvetica',
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
  
  Widget _buildTopologyTab(SimulatorController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final headerHeight = 60.0;
        final isMobile = MediaQuery.of(context).size.width < 600;
        
        // CRITICAL: Force height to be at least 70% of screen height on mobile
        final minimumHeight = MediaQuery.of(context).size.height * (isMobile ? 0.7 : 0.5);
        final effectiveHeight = constraints.maxHeight < minimumHeight ? minimumHeight : constraints.maxHeight;
        
        return Container(
          width: constraints.maxWidth,
          // CRITICAL: Ensure minimum height for mobile
          height: effectiveHeight,
          constraints: BoxConstraints(
            minHeight: minimumHeight,
          ),
          child: Stack(
            fit: StackFit.expand, // CRITICAL: Ensure stack fills the container
            children: [
              // MegaETH topology visualization takes the FULL space behind
              Positioned.fill( // CRITICAL: Fill the entire space
                child: MegaETHTopology(
                  blockchain: controller.blockchain,
                ),
              ),
              
              // Y2K-styled instructions panel
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                child: Container(
                  height: headerHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.jetBlack,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: AppTheme.silver,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        spreadRadius: 0,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Squared Y2K info icon
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: AppTheme.jetBlack,
                          border: Border.all(
                            color: AppTheme.silver,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: AppTheme.silver,
                          size: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'MegaETH uses specialized node types - click on nodes to see their specifications and functions.',
                          style: TextStyle(
                            color: AppTheme.silver,
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Helvetica',
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}