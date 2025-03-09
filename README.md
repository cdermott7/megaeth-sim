# Blockchain Time Visualization

An interactive, web-based tool that simulates a blockchain network and visually represents how blocks are created and propagated across nodes. This visualization helps to understand the impact of block time and propagation time on blockchain performance.

## Features

- Adjustable parameters:
  - Block Time: The interval between block creation (0.1s for MegaETH, 12s for Ethereum, 600s for Bitcoin)
  - Number of Nodes: The total nodes in the simulated network
  - Average Propagation Time: How long it takes for blocks to propagate to all nodes
  - Simulation Speed: Control the pace of the visualization

- Visual representation of:
  - Nodes in the network
  - Blockchain with block creation and confirmation status
  - Block propagation across nodes with progress bars
  - Real-time metrics like confirmation time and blocks per second

- Preset configurations for different blockchain systems:
  - MegaETH (0.1s block time)
  - Ethereum (12s block time)
  - Bitcoin (600s block time)

## How It Works

The simulation shows how blocks are created at regular intervals and then propagate across the network. When a block is created:

1. A random node is selected as the block creator
2. The block instantly propagates to the creator node
3. Other nodes receive the block after a delay (based on propagation time)
4. A block is confirmed when all nodes have received it
5. Performance metrics are calculated based on confirmation times

## How to Use

1. Open `index.html` in a modern web browser
2. Use the sliders to adjust simulation parameters
3. Click the preset buttons to try different blockchain configurations
4. Use the Start/Pause/Reset buttons to control the simulation

## Technical Details

- Built with vanilla JavaScript and HTML5 Canvas
- No external dependencies or data sources required
- The simulation uses a virtual clock to manage timing events
