import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:megaeth_simulator/models/blockchain_model.dart';
import 'package:megaeth_simulator/models/transaction_model.dart';

class SimulatorController with ChangeNotifier {
  // Current blockchain being simulated
  BlockchainModel _blockchain = BlockchainModel.megaEth();
  BlockchainModel get blockchain => _blockchain;
  
  // Simulation state
  bool _isRunning = false;
  bool get isRunning => _isRunning;
  
  // Transaction generation rate (per second)
  int _transactionsPerSecond = 5;
  int get transactionsPerSecond => _transactionsPerSecond;
  
  // Maximum number of pending transactions to show on screen
  int _maxPendingTransactions = 50;
  int get maxPendingTransactions => _maxPendingTransactions;
  
  // Active transactions in the simulation
  final List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  
  // Statistics
  int _confirmedTransactions = 0;
  int get confirmedTransactions => _confirmedTransactions;
  
  double _averageConfirmationTimeMs = 0;
  double get averageConfirmationTimeMs => _averageConfirmationTimeMs;
  
  // Size of the simulation area
  Size _simulationSize = const Size(800, 600);
  
  // Timers
  Timer? _transactionGenerationTimer;
  final Map<String, Timer> _confirmationTimers = {};
  
  // Initialize the controller
  void initialize(Size simulationSize) {
    _simulationSize = simulationSize;
  }
  
  // Change the blockchain being simulated
  void setBlockchain(BlockchainModel blockchain) {
    _blockchain = blockchain;
    notifyListeners();
  }
  
  // Start the simulation
  void startSimulation() {
    if (_isRunning) return;
    
    _isRunning = true;
    
    // Start generating transactions at the specified rate
    _transactionGenerationTimer = Timer.periodic(
      Duration(milliseconds: (1000 / _transactionsPerSecond).round()),
      (_) => _generateTransaction(),
    );
    
    notifyListeners();
  }
  
  // Stop the simulation
  void stopSimulation() {
    if (!_isRunning) return;
    
    _isRunning = false;
    
    // Cancel transaction generation timer
    _transactionGenerationTimer?.cancel();
    _transactionGenerationTimer = null;
    
    // Cancel all confirmation timers
    for (final timer in _confirmationTimers.values) {
      timer.cancel();
    }
    _confirmationTimers.clear();
    
    notifyListeners();
  }
  
  // Remove all stage timers for a transaction
  void _removeTransactionTimers(String transactionId) {
    // Remove main confirmation timer
    final mainTimer = _confirmationTimers.remove(transactionId);
    mainTimer?.cancel();
    
    // Remove all stage-specific timers
    final stageTimerKeys = [
      "${transactionId}_executing",
      "${transactionId}_stateChanging",
      "${transactionId}_diffGenerating",
      "${transactionId}_propagating",
      "${transactionId}_stateUpdating",
    ];
    
    for (final key in stageTimerKeys) {
      final timer = _confirmationTimers.remove(key);
      timer?.cancel();
    }
  }
  
  // Reset the simulation
  void resetSimulation() {
    stopSimulation();
    
    _transactions.clear();
    _confirmedTransactions = 0;
    _averageConfirmationTimeMs = 0;
    
    notifyListeners();
  }
  
  // Set transaction generation rate
  void setTransactionsPerSecond(int tps) {
    if (tps <= 0 || tps > blockchain.maxTransactionsPerSecond) return;
    
    bool wasRunning = _isRunning;
    if (wasRunning) {
      stopSimulation();
    }
    
    _transactionsPerSecond = tps;
    
    if (wasRunning) {
      startSimulation();
    }
    
    notifyListeners();
  }
  
  // Set maximum number of pending transactions
  void setMaxPendingTransactions(int max) {
    if (max < 10 || max > 300) return;
    _maxPendingTransactions = max;
    notifyListeners();
  }
  
  // Generate a new transaction
  void _generateTransaction() {
    // Only generate if we're under the max pending limit
    if (_transactions.where((t) => !t.isConfirmed).length >= _maxPendingTransactions) {
      return;
    }
    
    final transaction = TransactionModel.random(_simulationSize);
    _transactions.add(transaction);
    
    // Remove older confirmed transactions if we have too many
    if (_transactions.length > _maxPendingTransactions * 1.5) {
      _transactions.removeWhere((t) => t.isConfirmed);
    }
    
    notifyListeners();
  }
  
  // Select a transaction (user interaction)
  void selectTransaction(String transactionId) {
    final transactionIndex = _transactions.indexWhere((t) => t.id == transactionId);
    
    if (transactionIndex == -1) return;
    
    final transaction = _transactions[transactionIndex];
    
    // Skip if already confirmed or selected
    if (transaction.isConfirmed || transaction.isSelected) return;
    
    // Select the transaction
    transaction.select();
    
    // Schedule confirmation based on blockchain latency
    _scheduleConfirmation(transaction);
    
    notifyListeners();
  }
  
  // Schedule a transaction to be confirmed after the blockchain's latency time
  void _scheduleConfirmation(TransactionModel transaction) {
    // For MegaETH, we use detailed stage transitions
    if (blockchain.name == 'MegaETH') {
      _scheduleMegaETHConfirmation(transaction);
    } else {
      // For other blockchains, use the simplified confirmation model
      final confirmationDelayMs = blockchain.totalLatencyMs.toInt();
      
      // Create a timer to confirm the transaction after the delay
      _confirmationTimers[transaction.id] = Timer(
        Duration(milliseconds: confirmationDelayMs),
        () => _confirmTransaction(transaction.id),
      );
    }
  }
  
  // Schedule MegaETH-specific transaction confirmation with detailed stages
  void _scheduleMegaETHConfirmation(TransactionModel transaction) {
    // Store execution time for each stage based on transaction type
    final isERC20 = transaction.type == TransactionType.erc20Transfer;
    
    // Calculate more accurate timing values based on MegaETH specifications and transaction type
    
    // For visualization purposes, we extend some of the very fast times slightly to make them visible
    // But proportions are maintained based on the whitepaper
    
    // 1. EVM execution - main bottleneck in high-throughput blockchains
    // Whitepaper indicates how this is affected by STATICCALL (17%), MLOAD256 (10%), etc.
    final executingTimeMs = isERC20 ? 3 : 4;  // Uniswap swaps are more complex operations
    
    // 2. State transition computation - follows execution
    final stateChangingTimeMs = isERC20 ? 1 : 2; // More complex state changes for Uniswap swaps
    
    // 3. State diff generation - ERC-20 transfers ~200 bytes, Uniswap swaps ~624 bytes
    final diffGeneratingTimeMs = isERC20 ? 1 : 2;
    
    // 4. Network propagation - matches the blockchain's propagation delay parameter 
    final propagatingTimeMs = blockchain.propagationDelayMs.toInt();
    
    // 5. MPT updates - based on the number of state changes requiring MPT updates
    // More state changes (Uniswap has ~8 vs ERC-20's ~3) = more MPT operations
    final stateUpdatingTimeMs = isERC20 ? 2 : 4;
    
    // Schedule stage transitions
    
    // 1. Executing - start immediately after selection
    _confirmationTimers[transaction.id + "_executing"] = Timer(
      Duration(milliseconds: 1),
      () {
        transaction.updateStage(TransactionStage.executing);
        notifyListeners();
      },
    );
    
    // 2. State Changing - compute state transitions after execution
    _confirmationTimers[transaction.id + "_stateChanging"] = Timer(
      Duration(milliseconds: 1 + executingTimeMs),
      () {
        transaction.updateStage(TransactionStage.stateChanging);
        notifyListeners();
      },
    );
    
    // 3. Diff Generating - generate diffs of state changes after state computation
    _confirmationTimers[transaction.id + "_diffGenerating"] = Timer(
      Duration(milliseconds: 1 + executingTimeMs + stateChangingTimeMs),
      () {
        transaction.updateStage(TransactionStage.diffGenerating);
        notifyListeners();
      },
    );
    
    // 4. Propagating - send state diffs across the network
    _confirmationTimers[transaction.id + "_propagating"] = Timer(
      Duration(milliseconds: 1 + executingTimeMs + stateChangingTimeMs + diffGeneratingTimeMs),
      () {
        transaction.updateStage(TransactionStage.propagating);
        notifyListeners();
      },
    );
    
    // 5. State Updating - update the MPT with the new state
    _confirmationTimers[transaction.id + "_stateUpdating"] = Timer(
      Duration(milliseconds: 1 + executingTimeMs + stateChangingTimeMs + diffGeneratingTimeMs + propagatingTimeMs),
      () {
        transaction.updateStage(TransactionStage.stateUpdating);
        notifyListeners();
      },
    );
    
    // 6. Confirmed - transaction is fully confirmed after all stages complete
    final totalTimeMs = 1 + executingTimeMs + stateChangingTimeMs + diffGeneratingTimeMs + propagatingTimeMs + stateUpdatingTimeMs;
    _confirmationTimers[transaction.id] = Timer(
      Duration(milliseconds: totalTimeMs),
      () => _confirmTransaction(transaction.id),
    );
  }
  
  // Confirm a transaction
  void _confirmTransaction(String transactionId) {
    final transactionIndex = _transactions.indexWhere((t) => t.id == transactionId);
    
    if (transactionIndex == -1) return;
    
    final transaction = _transactions[transactionIndex];
    
    // Skip if already confirmed
    if (transaction.isConfirmed) return;
    
    // Confirm the transaction
    transaction.confirm();
    
    // Remove all timers for this transaction
    _removeTransactionTimers(transaction.id);
    
    // Update statistics
    _confirmedTransactions++;
    
    // Update average confirmation time
    final confirmationTimeMs = transaction.confirmationDuration?.inMicroseconds ?? 0;
    if (_confirmedTransactions == 1) {
      _averageConfirmationTimeMs = confirmationTimeMs / 1000.0; // Convert to ms
    } else {
      _averageConfirmationTimeMs = (_averageConfirmationTimeMs * (_confirmedTransactions - 1) + 
                                    confirmationTimeMs / 1000.0) / _confirmedTransactions;
    }
    
    notifyListeners();
  }
  
  // Get the throughput (transactions confirmed per second)
  double get currentThroughput {
    if (_confirmedTransactions < 10) return 0;
    // Simple estimation based on average confirmation time
    return _averageConfirmationTimeMs > 0 ? 
           min(1000 / _averageConfirmationTimeMs, blockchain.maxTransactionsPerSecond.toDouble()) : 0;
  }
  
  // Run a stress test with maximum TPS for the selected blockchain
  void runStressTest() {
    resetSimulation();
    
    // Set transactions per second to 80% of the blockchain's max for a proper stress test
    setTransactionsPerSecond((blockchain.maxTransactionsPerSecond * 0.8).round());
    
    // Increase the max pending transactions to handle the stress test
    setMaxPendingTransactions(200);
    
    // Start the simulation
    startSimulation();
  }
  
  @override
  void dispose() {
    stopSimulation();
    super.dispose();
  }
}