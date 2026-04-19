# Extended RV32IM Processor with Custom Mathematical Acceleration Unit (MAU)

## 📌 Overview
This project extends a 3-stage pipelined RV32I RISC-V processor by integrating the standard "M" extension (Integer Multiplication and Division) and a custom Mathematical Acceleration Unit (MAU). [cite_start]By mapping custom instructions to the RISC-V `custom-0` opcode (`0001011`), the instruction set expands from approximately 40 to 53 instructions, significantly boosting the hardware's mathematical computing capabilities[cite: 7].

## 🚀 Features & Instruction Set
The extended processor handles both multi-cycle operations with automated pipeline stalling and single-cycle combinational operations[cite: 8]. 

### Standard RV32M Instructions
* **Multiplication (3-cycle latency):** `MUL`, `MULH`, `MULHU`, `MULHSU`[cite: 8, 24].
* **Division (32-cycle latency):** `DIV`, `DIVU`, `REM`, `REMU` (Handles edge cases like divide-by-zero and `INT_MIN/-1` overflow)[cite: 8, 25].

### Custom MAU Instructions
* **Single-Cycle (Combinational):** `ABS`, `MAX`, `MIN`, `LOG2` (Returns `0` for `LOG2(0)`)[cite: 8, 29].
* **Multi-Cycle (16-cycle latency):** `SQRT` (Handles `SQRT(0)=0` to `SQRT(2^32-1)=65535` using a non-restoring integer square root FSM)[cite: 8, 28].

## 📊 Performance & Design Goals

| Metric | Target |
| :--- | :--- |
| **MUL latency** | [cite_start]3 cycles (pipelined internal stages) [cite: 35] |
| **DIV latency** | [cite_start]32 cycles (restoring algorithm, 1 bit/cycle) [cite: 35] |
| **SQRT latency** | [cite_start]16 cycles (non-restoring, 2 bits/cycle) [cite: 35] |
| **ABS/MAX/MIN/LOG2 latency** | [cite_start]1 cycle (combinational) [cite: 35] |
| **Pipeline stalls** | [cite_start]Zero stalls for single-cycle ops; stall asserted for MUL/DIV/SQRT [cite: 35] |

## 🛠️ Hardware & FPGA Relevance
The design is highly optimized for Xilinx FPGA architectures:
* **DSP48 Slices:** Dedicated 25x18 multipliers efficiently implement our 32-bit multiplier with minimal LUT overhead and high clock frequencies[cite: 18].
* **Fast Carry Chains:** Utilizing `CARRY4` primitives enables highly efficient subtract-and-shift operations within our non-restoring `SQRT` algorithm and restoring divider[cite: 19].
* **CLZ as Priority Encoder:** The `LOG2` instruction utilizes a hierarchical LUT-based priority encoder tree, successfully achieving $O(1)$ combinational latency instead of relying on a 32-cycle software loop[cite: 20].

## 💻 C Programs & Hardware Workloads
To demonstrate the capabilities of the MAU, the following C programs were compiled with `-march=rv32im` and deployed directly to the FPGA[cite: 41]:

1. **DSP Filtering (FIR Filter):** A 16-tap FIR filter kernel that utilizes the `MUL` instruction for rapid tap computation and the `ABS` instruction for magnitude envelope detection. [cite_start]This significantly reduces the cycle count compared to software emulation[cite: 11, 12].
2. **Euclidean Distance Computation:** Calculates spatial distance ($\sqrt{(x_1-x_2)^2+(y_1-y_2)^2}$) using `SUB`, `MUL`, `ADD`, and the custom hardware `SQRT` instruction. [cite_start]This workload is vital for obstacle avoidance and nearest-neighbour search algorithms[cite: 14].
3.**Data Normalization and Clamping:** Processes raw sensor data by clamping it to valid ranges using the `MAX` and `MIN` instructions, and computes absolute errors using `ABS`[cite: 16].
4.**Logarithmic Scaling:** Converts linear data into decibel (dB) scales or performs data compression utilizing the $O(1)$ hardware `LOG2` instruction[cite: 16].
5.**Greatest Common Divisor (GCD):** Leverages the `DIV` and `REM` instructions to efficiently compute the GCD of integers[cite: 30, 44].

## 🧪 Verification & Testing
* **Module-Level:** 100+ test vectors per instruction with golden I/O generated via Python, ensuring 100% correctness on edge cases[cite: 40].
* **System-Level:** Processor simulation via an extended pipeline testbench, followed by deploying the C programs to the FPGA[cite: 41].
* **Demonstration:** Tangible input/output flows using FPGA switches, LEDs, seven-segment displays, and a UART serial interface[cite: 21, 31, 32].
