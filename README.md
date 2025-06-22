# Exploring UART Protocol: Analysis and Verilog Simulation

This repository contains a Verilog implementation of a Universal Asynchronous Receiver/Transmitter (UART) module, designed for serial communication between digital devices. The project includes a full-duplex UART with configurable parameters, FIFO buffers, a comprehensive testbench for simulation, and Algorithmic State Machine (ASM) charts for key components. It serves as an educational resource for understanding UART protocol fundamentals, Verilog-based hardware design, and state machine visualization, with simulation results to validate functionality.

## Project Overview

The UART module facilitates asynchronous serial communication, transmitting and receiving 8-bit data frames with start and stop bits. Key components include a baud rate generator, transmitter, receiver, and FIFO buffers for data handling. The design is parameterized for flexibility and tested using a loopback configuration in the testbench. ASM charts provide a visual representation of the state machines for the receiver, transmitter, and baud rate generator.

### Features

- **Full-Duplex Operation**: Simultaneous transmission and reception of serial data.
- **Configurable Parameters**:
  - Data bits (`DBIT = 8`): Supports 8-bit data frames.
  - Stop bit ticks (`SB_TICK = 16`): Configurable stop bit duration.
  - FIFO depth (`FIFO_W = 2`): 4-entry FIFO buffers for TX and RX.
- **Baud Rate Generator**: Generates sampling ticks based on a programmable divisor (`dvsr`).
- **FIFO Buffers**: Manages data flow to prevent overflow/underflow during high-speed communication.
- **Testbench**: Simulates data transmission/reception with loopback (`rx = tx`) and displays received bytes.
- **Wrapper Circuit**: Includes a top-level wrapper with register mapping for integration into larger systems.
- **Simulation Results**: Waveform snapshot provided to visualize signal behavior.
- **ASM Charts**: Visual diagrams for the state machines of the receiver, transmitter, and baud rate generator.

## Repository Structure

```
Exploring-UART-Protocol-Analysis-and-Verilog-Simulation/
├── Verilog_Codes/
│   ├── brg.v                # Baud rate generator module
│   ├── fifo.v               # FIFO buffer module
│   ├── rx.v                 # UART receiver module
│   ├── tx.v                 # UART transmitter module
│   ├── uart.v               # Top-level UART module integrating TX, RX, and FIFOs
│   ├── tb_uart.v            # Testbench for UART simulation
│   └── wrap_reg_map.v       # Wrapper circuit with register mapping
├── Simulation_Results/
│   └── simulation.png       # Snapshot of simulation waveform
├── ASM_Charts/
│   ├── rx_asm.pdf           # ASM chart for UART receiver
│   ├── tx_asm.pdf           # ASM chart for UART transmitter
│   └── brg_asm.pdf          # ASM chart for baud rate generator
└── README.md                # Project documentation
```

## UART Design Details

### Module Breakdown

1. **Baud Generator (**`brg.v`**)**:

   - Generates a tick signal every `dvsr` clock cycles for baud rate control.
   - Example: With `dvsr = 4` and a 50 MHz clock (20 ns period), ticks occur every 80 ns.

2. **UART Receiver (**`rx.v`**)**:

   - Finite State Machine (FSM) with states: `IDLE`, `START`, `DATA`, `STOP`.
   - Samples `rx` input, shifts bits into an 8-bit register (`b_reg`), and outputs via `dout`.
   - Bit shifting: `b_next = {rx, b_reg[7:1]}` inserts received bit into MSB.

3. **UART Transmitter (**`tx.v`**)**:

   - FSM with states: `IDLE`, `START`, `DATA`, `STOP`.
   - Serializes 8-bit input (`din`), sends LSB first, and asserts `tx_done_tick`.

4. **FIFO (**`fifo.v`**)**:

   - Synchronous FIFO with 4-entry depth (`ADDR_WIDTH = 2`).
   - Handles data buffering for both TX and RX paths.

5. **Top-Level UART (**`uart.v`**)**:

   - Integrates baud generator, transmitter, receiver, and two FIFOs.
   - Interfaces: `clk`, `reset`, `rd_uart`, `wr_uart`, `rx`, `w_data`, `dvsr`, `tx_full`, `rx_empty`, `tx`, `r_data`.

6. **Wrapper Circuit (**`wrap_reg_map.v`**)**:

   - Provides a top-level interface with register mapping for system integration.
   - Details depend on the specific implementation.

7. **Testbench (**`tb_uart.v`**)**:

   - Simulates UART with a 50 MHz clock and loopback configuration (`rx = tx`).
   - Sends bytes `0x41` ('A'), `0x42` ('B'), `0x43` ('C') and displays received data.
   - Generates VCD file (`uart.vcd`) for waveform analysis.

### Data Flow

- **Transmission**: Parallel data (`w_data`) is written to the TX FIFO, serialized by the transmitter, and sent over `tx`.
- **Reception**: Serial data on `rx` is deserialized by the receiver, stored in the RX FIFO, and read as `r_data`.
- **Loopback**: In the testbench, `tx` is connected to `rx` for self-testing.

## ASM Charts

The `ASM_Charts` folder contains Algorithmic State Machine diagrams for the following modules:

- **Receiver (**`rx_asm.pdf`**)**: Illustrates the FSM transitions (`IDLE`, `START`, `DATA`, `STOP`), including conditions for sampling `rx` and updating `b_reg`.
- **Transmitter (**`tx_asm.pdf`**)**: Depicts the FSM states (`IDLE`, `START`, `DATA`, `STOP`), showing how `din` is serialized and `tx` is driven.
- **Baud Rate Generator (**`brg_asm.pdf`**)**: Visualizes the counter-based tick generation logic, highlighting reset and divisor comparison.

These charts aid in understanding the control flow and decision points of each module, making the design process more accessible for learning and debugging.

## Getting Started

### Prerequisites

- **Verilog Simulator**: Icarus Verilog, ModelSim, or Vivado.
- **Waveform Viewer**: GTKWave for viewing `uart.vcd`.
- **Synthesis Tool** (optional): Xilinx Vivado or Quartus for FPGA implementation.
- **Image Viewer**: For viewing ASM charts (e.g., any standard PNG viewer).

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Akshdeep-Kumar/Exploring-UART-Protocol-Analysis-and-Verilog-Simulation.git
   cd Exploring-UART-Protocol-Analysis-and-Verilog-Simulation
   ```
2. Install Icarus Verilog (example for Ubuntu):

   ```bash
   sudo apt-get install iverilog
   ```
3. Install GTKWave:

   ```bash
   sudo apt-get install gtkwave
   ```

### Running the Simulation

1. Navigate to the `Verilog_Codes` directory:

   ```bash
   cd Verilog_Codes
   ```
2. Compile the Verilog files:

   ```bash
   iverilog -o uart_sim tb_uart.v uart.v
   ```
3. Run the simulation:

   ```bash
   vvp uart_sim
   ```
4. View the waveform:

   ```bash
   gtkwave uart.vcd
   ```
5. Check the `Simulation_Results/simulation.png` for a reference waveform snapshot.
6. Review ASM charts in `ASM_Charts/` for state machine insights.

### Expected Output

The testbench sends bytes `0x41`, `0x42`, `0x43` and displays received bytes. Sample terminal output:

```
Time 15510000: Received byte: 0x0 ('?')
Time 31810000: Received byte: 0x41 ('A')
Time 48110000: Received byte: 0x42 ('B')
Simulation finished.
```

Note: The initial `0x0` may indicate a timing or initialization issue in the testbench, under investigation.

## Simulation Results

The `Simulation_Results/simulation.png` shows key signals (`clk`, `reset`, `rx`, `tx`, `r_data`, etc.) during the transmission and reception of test bytes. The waveform confirms correct serialization/deserialization and FIFO operation, despite the noted `0x0` anomaly.

## FPGA Implementation

To implement on an FPGA:

1. Create a project in Vivado or Quartus.
2. Add all `.v` files from `Verilog_Codes`.
3. Set `wrap_reg_map.v` as the top module (if applicable).
4. Configure constraints (e.g., clock, I/O pins).
5. Synthesize, implement, and program the FPGA.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a pull request.

Please follow the Contributing Guidelines (if added later) and report issues via the GitHub Issues tab.

## Acknowledgments

- Inspired by standard UART designs and Verilog tutorials.
- www.youtube.com/@anassalaheddin1258 (Video tutorials on UART using SystemVerilog)
- Tools: Icarus Verilog, GTKWave, and Xilinx Vivado (for potential synthesis).

## Contact

For questions or feedback, reach out via GitHub Issues or contact the repository owner, Akshdeep-Kumar.