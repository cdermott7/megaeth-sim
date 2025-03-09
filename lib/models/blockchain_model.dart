// Node Type class for MegaETH's specialized nodes
class NodeType {
  final String name;
  final String description;
  final int cpuCores;
  final int ramGB;
  final double networkMbps;
  final String storageType;
  final String cloudEquivalent;
  final double hourlyPrice;
  final List<String> functions;
  final List<String> stateManagement;
  
  NodeType({
    required this.name,
    required this.description,
    required this.cpuCores,
    required this.ramGB,
    required this.networkMbps,
    required this.storageType,
    required this.cloudEquivalent,
    required this.hourlyPrice,
    required this.functions,
    required this.stateManagement,
  });
  
  // Sequencer node factory
  static NodeType sequencer() {
    return NodeType(
      name: 'Sequencer',
      description: 'Specialized nodes responsible for ordering and executing user transactions',
      cpuCores: 100,
      ramGB: 1024, // 1TB RAM
      networkMbps: 10000, // 10 Gbps
      storageType: 'SSD',
      cloudEquivalent: 'AWS r6a.48xlarge',
      hourlyPrice: 10.0,
      functions: [
        'Execute transactions',
        'Produce blocks',
        'Compute state transitions', 
        'Broadcast state diffs'
      ],
      stateManagement: [
        'Maintains entire blockchain state in memory (~100GB)',
        'Eliminates SSD read latency for state access operations'
      ],
    );
  }
  
  // Replica node factory
  static NodeType replica() {
    return NodeType(
      name: 'Replica',
      description: 'Lightweight nodes that update state by applying state diffs from sequencers',
      cpuCores: 8,
      ramGB: 16,
      networkMbps: 100,
      storageType: 'SSD',
      cloudEquivalent: 'AWS lm4gn.xlarge',
      hourlyPrice: 0.4,
      functions: [
        'Apply state diffs',
        'Validate blocks indirectly using proofs from provers'
      ],
      stateManagement: [
        'Maintains blockchain state but doesn\'t re-compute it',
        'Reduces computational requirements by ~80% compared to full nodes'
      ],
    );
  }
  
  // Full node factory
  static NodeType fullNode() {
    return NodeType(
      name: 'Full Node',
      description: 'Nodes that re-execute every transaction to validate blocks',
      cpuCores: 16,
      ramGB: 64,
      networkMbps: 200,
      storageType: 'SSD',
      cloudEquivalent: 'AWS lm4gn.4xlarge',
      hourlyPrice: 1.6,
      functions: [
        'Re-execute transactions',
        'Validate blocks directly',
        'Serve RPC requests'
      ],
      stateManagement: [
        'Maintains and recalculates full blockchain state',
        'Used by bridge operators, market makers, and infrastructure providers'
      ],
    );
  }
  
  // Prover node factory
  static NodeType prover() {
    return NodeType(
      name: 'Prover',
      description: 'Specialized nodes that validate blocks asynchronously using a stateless scheme',
      cpuCores: 1,
      ramGB: 1, // 0.5 GB 
      networkMbps: 10,
      storageType: 'Basic',
      cloudEquivalent: 'AWS t4g.nano',
      hourlyPrice: 0.004,
      functions: [
        'Generate cryptographic proofs of valid state transitions',
      ],
      stateManagement: [
        'Can operate statelessly',
        'Verifies correctness of state transitions without maintaining state'
      ],
    );
  }
}

class BlockchainModel {
  final String name;
  final double blockTimeMs;
  final double propagationDelayMs;
  final double gasPerSecond;
  final int maxTransactionsPerSecond;
  
  // MegaETH specialized node types
  final List<NodeType>? nodeTypes;
  final bool supportsMPTUpdates;
  final bool supportsParallelExecution;
  final bool supportsStateDiffs;
  final double avgERC20StateDiffBytes;
  final double avgUniswapSwapStateDiffBytes;
  final double compressionRatio;
  final double stateSyncBandwidth;
  
  BlockchainModel({
    required this.name,
    required this.blockTimeMs,
    required this.propagationDelayMs,
    required this.gasPerSecond,
    required this.maxTransactionsPerSecond,
    this.nodeTypes,
    this.supportsMPTUpdates = false,
    this.supportsParallelExecution = false,
    this.supportsStateDiffs = false,
    this.avgERC20StateDiffBytes = 0,
    this.avgUniswapSwapStateDiffBytes = 0,
    this.compressionRatio = 1.0,
    this.stateSyncBandwidth = 25.0, // Default target: 25 Mbps
  });

  // Total latency calculation
  double get totalLatencyMs => blockTimeMs + propagationDelayMs;

  // Predefined blockchain configurations based on whitepaper data
  static BlockchainModel megaEth() {
    return BlockchainModel(
      name: 'MegaETH',
      blockTimeMs: 10, // Precisely 10ms block time for real-time applications like high-frequency trading
      propagationDelayMs: 2, // Ultra-low latency optimized by node specialization architecture
      gasPerSecond: 1000000000, // 1,000 MGas/s, targeting 10x improvement over opBNB's 100 MGas/s
      maxTransactionsPerSecond: 100000, // 100,000 TPS supported by high bandwidth state sync (152.6 Mbps)
      nodeTypes: [
        NodeType.sequencer(),
        NodeType.replica(),
        NodeType.fullNode(),
        NodeType.prover(),
      ],
      supportsMPTUpdates: true,
      supportsParallelExecution: true,
      supportsStateDiffs: true,
      avgERC20StateDiffBytes: 200, // ~200 bytes for ERC-20 transfer state diff
      avgUniswapSwapStateDiffBytes: 624, // ~624 bytes for Uniswap swap state diff
      compressionRatio: 19.0, // 19x compression ratio for state diffs
      stateSyncBandwidth: 25.0, // Target: 25 Mbps
    );
  }

  static BlockchainModel ethereum() {
    return BlockchainModel(
      name: 'Ethereum',
      blockTimeMs: 12000, // Precisely 12s block time as per whitepaper comparison table
      propagationDelayMs: 700, // Higher propagation delay for global network with Ethereum's modest specs (2 cores, 4-8 GB RAM, 25 Mbps)
      gasPerSecond: 1250000, // Exactly 1.25 MGas/s as per whitepaper comparison table
      maxTransactionsPerSecond: 15, // ~15 TPS based on approximately 83,333 gas per ERC-20 transfer
    );
  }

  static BlockchainModel arbitrumOne() {
    return BlockchainModel(
      name: 'Arbitrum One',
      blockTimeMs: 250, // Precisely 0.25s block time as per whitepaper comparison table
      propagationDelayMs: 120, // Moderate propagation delay based on L2 architecture
      gasPerSecond: 7000000, // Exactly 7.0 MGas/s as per whitepaper comparison table
      maxTransactionsPerSecond: 420, // Based on 7.0 MGas/s divided by 16,666 gas per simple ERC-20 transfer
    );
  }

  static BlockchainModel opBNB() {
    return BlockchainModel(
      name: 'opBNB',
      blockTimeMs: 1000, // Precisely 1.0s block time as per whitepaper comparison table
      propagationDelayMs: 150, // Standard L2 propagation delay
      gasPerSecond: 100000000, // Exactly 100.0 MGas/s peak as per whitepaper comparison table
      maxTransactionsPerSecond: 650, // Precisely 650 Uniswap swaps/s as stated in whitepaper
    );
  }
}