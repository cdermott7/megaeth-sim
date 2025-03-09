import 'dart:math';
import 'package:flutter/material.dart';

enum TransactionStage {
  pending,      // Transaction in mempool
  selected,     // User selected transaction
  executing,    // Being executed by sequencer
  stateChanging, // State changes being calculated
  diffGenerating, // State diff being generated
  propagating,  // State diff being propagated
  stateUpdating, // State root being updated
  confirmed     // Transaction confirmed
}

enum TransactionType {
  erc20Transfer,
  uniswapSwap,
}

class TransactionModel {
  final String id;
  final double x;
  final double y;
  final double size;
  final DateTime createdAt;
  DateTime? confirmedAt;
  DateTime? selectedAt;
  bool isConfirmed = false;
  bool isSelected = false;
  
  // Transaction visual state
  Color color;
  
  // MegaETH-specific properties
  TransactionStage _stage = TransactionStage.pending;
  final TransactionType type;
  final Map<TransactionStage, DateTime?> stageTimestamps = {};
  
  TransactionModel({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.createdAt,
    required this.color,
    this.type = TransactionType.erc20Transfer,
  }) {
    stageTimestamps[TransactionStage.pending] = createdAt;
  }
  
  // Factory to create a random transaction
  static TransactionModel random(Size screenSize) {
    final random = Random();
    final id = DateTime.now().millisecondsSinceEpoch.toString() + random.nextInt(10000).toString();
    
    // Generate position within the screen bounds
    final x = 50 + random.nextDouble() * (screenSize.width - 100);
    final y = 100 + random.nextDouble() * (screenSize.height - 200);
    
    // Randomly choose transaction type with 70% ERC-20, 30% Uniswap
    final type = random.nextDouble() < 0.7 
        ? TransactionType.erc20Transfer 
        : TransactionType.uniswapSwap;
    
    return TransactionModel(
      id: id,
      x: x,
      y: y,
      size: 30 + random.nextDouble() * 20, // Random size between 30 and 50
      createdAt: DateTime.now(),
      color: Colors.cyan, // Default pending transaction color
      type: type,
    );
  }
  
  // Getters
  TransactionStage get stage => _stage;
  
  // Get transaction state size in bytes
  int get stateDiffSize => type == TransactionType.erc20Transfer ? 200 : 624;
  
  // Update transaction stage
  void updateStage(TransactionStage newStage) {
    if (_stage.index >= newStage.index) return;
    
    _stage = newStage;
    stageTimestamps[newStage] = DateTime.now();
    
    // Update visual state based on stage
    switch (newStage) {
      case TransactionStage.pending:
        color = Colors.cyan;
        break;
      case TransactionStage.selected:
        color = Colors.purple;
        isSelected = true;
        selectedAt = DateTime.now();
        break;
      case TransactionStage.executing:
        color = Colors.deepPurple;
        break;
      case TransactionStage.stateChanging:
        color = Colors.indigo;
        break;
      case TransactionStage.diffGenerating:
        color = Colors.blue;
        break;
      case TransactionStage.propagating:
        color = Colors.teal;
        break;
      case TransactionStage.stateUpdating:
        color = Colors.lightGreen;
        break;
      case TransactionStage.confirmed:
        color = Colors.green.withOpacity(0.7);
        isConfirmed = true;
        confirmedAt = DateTime.now();
        break;
    }
  }
  
  // Mark transaction as selected
  void select() {
    if (!isSelected && !isConfirmed) {
      isSelected = true;
      selectedAt = DateTime.now();
      color = Colors.purple; // Change color to purple when selected
      updateStage(TransactionStage.selected);
    }
  }
  
  // Mark transaction as confirmed (legacy support)
  void confirm() {
    if (isSelected && !isConfirmed) {
      isConfirmed = true;
      confirmedAt = DateTime.now();
      color = Colors.green.withOpacity(0.7); // Change color to green when confirmed
      updateStage(TransactionStage.confirmed);
    }
  }
  
  // Calculate the duration from selection to confirmation
  Duration? get confirmationDuration {
    if (selectedAt != null && confirmedAt != null) {
      return confirmedAt!.difference(selectedAt!);
    }
    return null;
  }
  
  // Calculate duration between stages
  Duration? getStageDuration(TransactionStage fromStage, TransactionStage toStage) {
    final fromTime = stageTimestamps[fromStage];
    final toTime = stageTimestamps[toStage];
    
    if (fromTime != null && toTime != null) {
      return toTime.difference(fromTime);
    }
    
    return null;
  }
  
  // Get EVM operation time breakdown (percentages based on whitepaper)
  Map<String, double> get evmOperationTimeBreakdown {
    return {
      'STATICCALL': 17.0,
      'MLOAD256': 10.0,
      'SLOAD': 8.8,
      'PUSH1': 7.0,
      'HOST': 38.6 - 17.0, // HOST - STATICCALL
      'SYSTEM': 11.7,
      'STACK': 28.7 - 10.0 - 7.0, // STACK - MLOAD256 - PUSH1
      'ARITHMETIC': 6.8,
      'BITWISE': 5.0,
      'CONTROL': 5.6,
      'MEMORY': 3.5,
    };
  }
}