import 'package:flutter/material.dart';
import 'package:megaeth_simulator/constants/theme.dart';
import 'package:megaeth_simulator/widgets/tooltip_helper.dart';

class LearningScreen extends StatelessWidget {
  const LearningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: AppTheme.darkBackgroundLight,
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: GlitchEffect(
                intensity: 0.3,
                child: const Text(
                  'Blockchain Concepts',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.darkBackground,
                      AppTheme.primaryPurple,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background grid pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GridPainter(),
                      ),
                    ),
                    
                    // Title
                    Positioned(
                      top: 70,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.school,
                              color: AppTheme.primaryCyan,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Understanding Real-Time Blockchains',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Introduction
                  Text(
                    'Core Concepts',
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // Block Time card
                  InfoCard(
                    title: 'Block Time',
                    description: 'Block time is the time interval between consecutive blocks being added to the blockchain. MegaETH targets a 10ms block time, compared to Ethereum\'s 12 seconds, enabling real-time applications.',
                    icon: Icons.timer,
                  ),
                  const SizedBox(height: 16),
                  
                  // Propagation Delay card
                  InfoCard(
                    title: 'Propagation Delay',
                    description: 'The time it takes for a new block to spread across the entire network. Lower propagation delay means faster network synchronization and reduced risk of forks.',
                    icon: Icons.network_cell,
                  ),
                  const SizedBox(height: 16),
                  
                  // Throughput card
                  InfoCard(
                    title: 'Throughput (TPS)',
                    description: 'Transactions Per Second (TPS) measures how many operations a blockchain can process in one second. MegaETH targets beyond 100,000 TPS, far exceeding traditional blockchains.',
                    icon: Icons.speed,
                  ),
                  const SizedBox(height: 16),
                  
                  // Gas per Second card
                  InfoCard(
                    title: 'Gas Per Second',
                    description: 'Gas measures computational effort. Gas per second indicates how much computation a blockchain can perform per second. MegaETH aims to exceed 100 MGas/s, orders of magnitude beyond other chains.',
                    icon: Icons.local_gas_station,
                  ),
                  const SizedBox(height: 24),
                  
                  // MegaETH Architecture
                  Text(
                    'MegaETH Architecture',
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // Node Types
                  InfoCard(
                    title: 'Specialized Node Architecture',
                    description: 'MegaETH employs a heterogeneous node architecture with four distinct roles:\n• Sequencers: Order and execute transactions on high-end servers (100 cores, 1-4 TB RAM, 10 Gbps)\n• Provers: Validate blocks asynchronously using ZK or optimistic proofs\n• Full Nodes: Re-execute transactions for fast finality (16 cores, 64 GB RAM, 200 Mbps)\n• Replica Nodes: Apply state diffs without re-execution (4-8 cores, 16 GB RAM, 100 Mbps)',
                    icon: Icons.account_tree,
                  ),
                  const SizedBox(height: 16),
                  
                  // Real-time Applications
                  InfoCard(
                    title: 'Real-time Blockchain Requirements',
                    description: 'MegaETH\'s 10ms block times enable previously impossible blockchain use cases:\n• On-chain Gaming: Requires tick rates <100ms for responsive gameplay\n• High-frequency Trading: Demands order placement/cancellation within 10ms\n• Compute-intensive Tasks: 100 millionth Fibonacci number computed in 30ms vs 55s on opBNB (1,833x faster)\n• Web2-level Performance: Aiming to match traditional cloud servers handling 1M+ TPS',
                    icon: Icons.bolt,
                  ),
                  const SizedBox(height: 24),
                  
                  // Comparison
                  Text(
                    'Blockchain Comparison',
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // Comparison table
                  _buildComparisonTable(),
                  const SizedBox(height: 24),
                  
                  // Technical Challenges
                  Text(
                    'Technical Challenges',
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  // Transaction Execution
                  InfoCard(
                    title: 'Transaction Execution Optimizations',
                    description: 'MegaETH addresses core EVM inefficiencies:\n• State Access: Using 1-4 TB RAM to hold entire blockchain state (~100 GB) in memory\n• Parallel Execution: Advanced conflict resolution to improve workload parallelism beyond median of <2\n• Interpreter Overhead: AOT/JIT compilation for compute-intensive contracts, targeting 2x speedups',
                    icon: Icons.speed,
                  ),
                  const SizedBox(height: 16),
                  
                  // State Sync Bandwidth
                  InfoCard(
                    title: 'State Sync Bandwidth',
                    description: 'Precise bandwidth calculations for 100,000 ERC-20 transfers per second:\n• Each transfer modifies 3 values (~200B per diff)\n• Total bandwidth: 200B × 100,000 = 152.6 Mbps\n• Uniswap swaps (624B per diff) would require 476.1 Mbps\n• 19x compression needed for sustainable node operation',
                    icon: Icons.sync,
                  ),
                  const SizedBox(height: 16),
                  
                  // State Root Updates
                  InfoCard(
                    title: 'State Root Update Challenges',
                    description: 'Merkle Patricia Trie updates at scale:\n• 16 billion keys (1 TB state) would require ~6 million IOPS for 100,000 transfers/s\n• NOMT optimization reduces reads to ~2 per update (600,000 IOPS)\n• Thrum benchmarks show 50,000 updates/s on 134M keys—still 6x below target',
                    icon: Icons.device_hub,
                  ),
                  const SizedBox(height: 16),
                  
                  // Hardware Limits
                  InfoCard(
                    title: 'Hardware-First Design Philosophy',
                    description: 'MegaETH follows three core principles:\n1. "Measure, Then Build": Detailed performance analysis before solution design\n2. Hardware Limits: Clean-slate designs targeting theoretical hardware maximums\n3. End-to-End Optimization: All components addressed simultaneously to prevent bottleneck shifts',
                    icon: Icons.memory,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildComparisonTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'Blockchain',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Block Time',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'TPS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Gas/s',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows: [
            _buildDataRow(
              'MegaETH',
              '10ms',
              '100,000+',
              '1,000 MGas/s',
              isHighlighted: true,
            ),
            _buildDataRow(
              'Ethereum',
              '12s',
              '15',
              '1.25 MGas/s',
            ),
            _buildDataRow(
              'Arbitrum One',
              '250ms',
              '420',
              '7.0 MGas/s',
            ),
            _buildDataRow(
              'opBNB',
              '1s',
              '650 swaps',
              '100 MGas/s',
            ),
            _buildDataRow(
              'BSC',
              '3s',
              '~2,000',
              '46.6 MGas/s',
            ),
            _buildDataRow(
              'Polygon',
              '2s',
              '~450',
              '7.5 MGas/s',
            ),
          ],
          headingRowColor: MaterialStateProperty.all(AppTheme.darkBackground),
          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return AppTheme.primaryPurple.withOpacity(0.2);
            }
            return null;
          }),
        ),
      ),
    );
  }
  
  DataRow _buildDataRow(
    String name,
    String blockTime,
    String tps,
    String gasPerSecond, {
    bool isHighlighted = false,
  }) {
    final Color textColor = isHighlighted ? AppTheme.primaryCyan : Colors.white70;
    final fontWeight = isHighlighted ? FontWeight.bold : FontWeight.normal;
    
    return DataRow(
      cells: [
        DataCell(
          Text(
            name,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
        DataCell(
          Text(
            blockTime,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
        DataCell(
          Text(
            tps,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
        DataCell(
          Text(
            gasPerSecond,
            style: TextStyle(
              color: textColor,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ],
      selected: isHighlighted,
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryPurple.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw horizontal grid lines
    const spacing = 20.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw vertical grid lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}