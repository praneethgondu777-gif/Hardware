# CS224: Extended RV32IM Processor with Mathematical Acceleration Unit (MAU)

## Overview
This project presents the design and implementation of an enhanced **3-stage pipelined RV32IM RISC-V processor** integrated with a **Custom Mathematical Acceleration Unit (MAU)** on the Xilinx Artix-7 FPGA platform (Nexys A7).

The processor extends the standard RV32I instruction set by incorporating full **RV32M hardware multiplication/division support** along with several custom mathematical acceleration instructions such as:

- `ABS`
- `MAX`
- `MIN`
- `SQRT`
- `LOG2`

These hardware accelerators eliminate costly software emulation loops and significantly improve performance for DSP, embedded computation, and mathematical workloads.

The complete processor was designed, implemented, simulated, synthesized, and validated on FPGA hardware using multiple benchmark applications compiled with the RISC-V GNU Toolchain.

---

# Features

- 3-stage pipelined RV32IM processor
- Full RV32M hardware multiply/divide support
- Custom Mathematical Acceleration Unit (MAU)
- Multi-cycle execution with unified stall control
- FPGA implementation on Nexys A7 (Artix-7)
- DSP-oriented instruction extensions
- Synthesizable Verilog RTL design
- Modular architecture for easy scalability
- Hardware validation using real benchmark programs

---

# Processor Architecture

## 3-Stage Pipeline

Unlike conventional 5-stage RISC-V processors, this implementation uses a compact and optimized **3-stage pipeline**:

```text
IF/ID  →  EX  →  MEM/WB
```

### 1. IF/ID — Instruction Fetch & Decode
This stage:
- Fetches instructions from BRAM
- Decodes RV32I, RV32M, and custom instructions
- Reads operands from the register file
- Generates control signals
- Handles pipeline freeze/stall logic

### 2. EX — Execute Stage
The execute stage serves as the computational core and contains:
- Standard ALU
- Hardware Multiplier
- Hardware Divider
- MAU Units
- Large result selection multiplexer

Both single-cycle and multi-cycle instructions execute here.

### 3. MEM/WB — Memory & Writeback
This stage:
- Handles load/store operations
- Interfaces with data memory
- Writes execution results back into the register file

---

# Multi-Cycle Stall Logic

Certain operations require multiple clock cycles:

| Operation | Latency |
|---|---|
| MUL | 3 cycles |
| DIV / REM | 32 cycles |
| SQRT | 16 cycles |

To support these operations safely within the pipeline, a unified stall controller:
- Freezes the Program Counter (PC)
- Holds IF/ID pipeline registers
- Waits until the corresponding execution unit asserts a `done` signal

Single-cycle operations such as:
- `ABS`
- `MAX`
- `MIN`
- `LOG2`

execute without pipeline stalls.

---

# Instruction Set Extensions

## RV32M Extension

The processor fully supports the RV32M instruction set extension.

### Multiplication Instructions
- `MUL`
- `MULH`
- `MULHU`
- `MULHSU`

Features:
- 32×32 multiplication
- 64-bit internal product generation
- Upper/lower 32-bit extraction depending on instruction type

### Division Instructions
- `DIV`
- `DIVU`
- `REM`
- `REMU`

Features:
- 32-bit hardware division
- Restoring division algorithm
- Complete RISC-V edge-case handling:
  - Divide-by-zero
  - Signed overflow (`INT_MIN / -1`)

---

# Custom Mathematical Acceleration Unit (MAU)

The MAU utilizes the RISC-V `custom-0` opcode space (`0001011`) and maps instructions using `funct3`.

| Instruction | Description | Latency |
|---|---|---|
| ABS | Absolute value | 1 cycle |
| MAX | Maximum of two operands | 1 cycle |
| MIN | Minimum of two operands | 1 cycle |
| SQRT | Integer square root | 16 cycles |
| LOG2 | Base-2 logarithm | 1 cycle |

---

# Hardware Modules

| Module | File | Description |
|---|---|---|
| Multiplier | `multiplier.v` | 3-cycle pipelined 32×32 multiplier using DSP48 slices |
| Divider | `divider.v` | 32-cycle restoring divider FSM |
| MAU Simple | `mau_simple.v` | ABS, MAX, MIN combinational unit |
| SQRT Unit | `sqrt_unit.v` | Non-restoring square root FSM |
| CLZ Unit | `clz_unit.v` | Leading-zero counter for LOG2 |
| Execute Stage | `execute.v` | Extended datapath and result multiplexer |
| Control Logic | `opcode.vh` | RV32IM and custom instruction decoding |
| Seven Segment Driver | `sev_seg.v` | FPGA display peripheral driver |

---

# Mathematical Acceleration Algorithms

## Integer Square Root
The SQRT accelerator uses:
- Non-restoring iterative square root algorithm
- Processes 2 bits per cycle
- Completes in 16 cycles for 32-bit operands

## LOG2 Acceleration
The `LOG2` instruction is implemented using:
- Count Leading Zeros (CLZ)
- Hierarchical priority encoder tree
- Constant-time O(1) computation

---

# FPGA Validation Programs

The processor was validated using multiple benchmark applications compiled with:

```bash
-march=rv32im
```

## 1. FIR DSP Filter
Implements a 16-tap FIR filter using:
- `MUL`
- `ABS`

## 2. Euclidean Distance Computation

Computes:

\[
\sqrt{(x_1-x_2)^2 + (y_1-y_2)^2}
\]

using:
- `SUB`
- `MUL`
- `ADD`
- `SQRT`

## 3. Data Normalization
Performs sensor data clamping using:
- `MAX`
- `MIN`

## 4. Logarithmic Scaling
Implements decibel-style scaling using:
- `LOG2`

## 5. GCD Computation
Accelerates recursive Euclidean division using:
- `DIV`
- `REM`

---

# FPGA Resource Utilization

**Target FPGA:** Xilinx Artix-7 XC7A100T (Nexys A7)

| Resource | Usage | Utilization |
|---|---|---|
| LUTs | ~4,125 | ~6.5% |
| Flip-Flops | ~2,540 | ~2.0% |
| BRAM (36Kb) | 4 | ~3.0% |
| DSP48 Slices | 3 | ~1.2% |

The design demonstrates that advanced arithmetic acceleration can be integrated with minimal FPGA resource overhead.

---

# Toolchain & Development Environment

## FPGA Tools
- Xilinx Vivado 2022.1+

## Compiler Toolchain
- RISC-V GNU Toolchain
- `riscv32-unknown-elf-gcc`

---

# Compiling Programs

Compile C programs into Verilog-compatible memory initialization files using:

```bash
riscv32-unknown-elf-gcc -O1 -march=rv32im -mabi=ilp32 -nostdlib -T linker.ld -o program.elf program.c

riscv32-unknown-elf-objcopy -O verilog program.elf program.hex
```

Alternatively, using Makefile automation:

```bash
make <program_name>
```

---

# Simulation

Module-level verification was performed using:
- Vivado XSIM
- ModelSim

Example testbenches:
- `tb_multiplier.v`
- `tb_divider.v`
- `tb_sqrt.v`

Golden reference vectors were generated using Python scripts:

```bash
python3 gen_vectors.py > input.txt
```

---

# FPGA Build Instructions

1. Open Vivado
2. Create a project targeting:
   ```text
   xc7a100tcsg324-1
   ```
3. Add all `.v` and `.vh` files from the `src/` directory
4. Set `top_module.v` as the top module
5. Add the Nexys A7 constraint (`.xdc`) file
6. Run:
   - Synthesis
   - Implementation
   - Bitstream Generation
7. Program the FPGA

---

# Project Highlights

- Designed a complete RV32IM-compatible pipelined processor
- Implemented hardware multiply/divide acceleration
- Added custom mathematical ISA extensions
- Developed efficient multi-cycle arithmetic units
- Built unified pipeline stall handling
- Integrated FPGA peripherals and display support
- Verified functionality through simulation and FPGA testing
- Demonstrated acceleration for DSP and mathematical workloads

---

# Future Improvements

Potential future extensions include:
- Data forwarding and hazard resolution
- Branch prediction
- Floating-point acceleration
- Cache hierarchy support
- UART/SPI/I2C peripherals
- SIMD/vector arithmetic support
- Linux-capable memory subsystem

---

# Conclusion

This project demonstrates the successful implementation of an enhanced RV32IM RISC-V processor with dedicated mathematical acceleration hardware on FPGA. By combining a compact pipeline architecture with specialized arithmetic units, the processor achieves significantly improved performance for computational workloads while maintaining low FPGA resource utilization.

The design serves as an effective platform for:
- Embedded DSP applications
- Hardware acceleration research
- Custom ISA experimentation
- FPGA-based processor development

within the growing RISC-V ecosystem.

---

# Author

## Sai Praneeth Gondu

### Contributions
- Complete RV32IM processor design
- Pipeline architecture implementation
- Multiplier and divider hardware design
- MAU instruction design and integration
- SQRT and LOG2 acceleration units
- Pipeline stall control implementation
- FPGA integration and synthesis
- Simulation and verification
- Benchmark application development
- Vivado project setup and testing

---
