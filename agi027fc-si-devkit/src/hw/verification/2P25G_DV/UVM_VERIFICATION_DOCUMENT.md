# UVM Verification Document
## Agilex™ 7 Multi-Channel 25GbE PTP / QoS Example Design (2P25G_DV)

Copyright © 2025 Altera Corporation. SPDX-License-Identifier: MIT

---

## Table of Contents

1. [Overview](#1-overview)
2. [Design Under Test (DUT)](#2-design-under-test-dut)
3. [Verification Environment Architecture](#3-verification-environment-architecture)
   - 3.1 [Top-Level Testbench](#31-top-level-testbench)
   - 3.2 [UVM Environment Class Hierarchy](#32-uvm-environment-class-hierarchy)
   - 3.3 [AXI VIP Configuration](#33-axi-vip-configuration)
   - 3.4 [Reset Interface](#34-reset-interface)
   - 3.5 [Scoreboard](#35-scoreboard)
   - 3.6 [Testbench Configuration Object](#36-testbench-configuration-object)
4. [File Structure](#4-file-structure)
5. [Interfaces and Clocking](#5-interfaces-and-clocking)
6. [Address Map](#6-address-map)
7. [Sequences](#7-sequences)
   - 7.1 [Sequence Library Overview](#71-sequence-library-overview)
   - 7.2 [Sequence Descriptions](#72-sequence-descriptions)
8. [Tests](#8-tests)
   - 8.1 [Test Hierarchy](#81-test-hierarchy)
   - 8.2 [Test Descriptions](#82-test-descriptions)
9. [Build and Simulation Flow](#9-build-and-simulation-flow)
10. [Coverage and Debug](#10-coverage-and-debug)

---

## 1. Overview

This document describes the UVM (Universal Verification Methodology 1.2) testbench developed for the **2P25G_DV** (Dual-Port 25 Gigabit Ethernet) verification environment of the Agilex™ 7 Multi-Channel 25GbE Precision Time Protocol (PTP) System Example Design.

The verification environment targets an RTL simulation of the full Agilex™ 7 SoC subsystem, exercising:

- **AXI4 CSR access** – register read/write verification across all subsystem blocks.
- **DMA data path** – six-channel TX/RX DMA flow over HSSI loopback.
- **User / Packet-Client traffic** – two packet-client ports sending user Ethernet frames concurrently with DMA traffic.
- **QoS arbitration** – priority-based arbitration between DMA and user-traffic ingress paths via the PTP Bridge.
- **PTP Bridge TCAM routing** – per-flow packet classification and steering using TCAM lookup tables.

The simulator used is **Synopsys VCS** with the **SVT AXI VIP** (Verification IP). UVM 1.2 is sourced from the VCS installation.

---

## 2. Design Under Test (DUT)

| Property | Value |
|---|---|
| Device | Agilex™ 7 I-Series (AGIB027R31B1E1VB) |
| Development Kit | DK-SI-AGI027FC |
| Quartus Version | 25.1.1 |
| RTL Top | `fptp_top_tb.u_dut.inst_qsys_top` |
| Number of HSSI Instances | 2 (`NUM_INST = 2`) |
| Number of DMA Channels | 6 (`NUM_CHN = 6`) |
| DMA Data Width | 64-bit payload, 8-bit strobe (`PAYLOAD_WIDTH = 64`, `PAYLOAD_STRB = 8`) |

The DUT contains the following major sub-blocks visible to the verification environment:

| Sub-block | Base Address | Description |
|---|---|---|
| HSSI Subsystem | `0x0000_0000` | 25G Ethernet hard IP (F-Tile), two ports |
| PTP Bridge | `0x0405_0000` | Packet routing, ingress arbitration, TCAM classification |
| TCAM0 | `0x0405_0200` | Per-flow classification table (key / result / mask) for DMA/user flows |
| TCAM1 | `0x0405_4200` | Second classification table for additional user flows |
| Packet Client 0 | `0x0406_0000` | Ethernet packet generator / checker on user port 0 |
| Packet Client 1 | `0x0407_0000` | Ethernet packet generator / checker on user port 1 |
| OCM | `0x0400_0000` | On-chip memory |
| Main TOD SS | `0x0404_0000` | Time-of-Day subsystem |
| TX DMA Port 0–5 | `0x0448_0000` – `0x045C_0000` | Transmit DMA prefetcher per channel |
| RX DMA Port 0–5 | `0x0448_0080` – `0x045C_0080` | Receive DMA prefetcher per channel |

---

## 3. Verification Environment Architecture

### 3.1 Top-Level Testbench

File: `testbench/fptp_top_tb.sv`

`fptp_top_tb` is the SystemVerilog module that:

1. **Instantiates the DUT** (`qsys_top`) via `top_auto_tiles`.
2. **Generates clocks** – `csr_clk` (AXI4 CSR bus), `clk_ref`, `i_refclk2pll` (HSSI reference clocks).
3. **Instantiates VIP interfaces** – `svt_axi_if` (one AXI4 master, one ACE-Lite slave) and `fptp_axi_reset_if`.
4. **Wires VIP interfaces to DUT ports** using continuous `assign` statements:
   - **Master (H2F)** → `hps_sub_sys_agilex_hps_h2f_axi_master_*` (CSR access from testbench to DUT).
   - **Slave (F2H / DMA)** → `mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_*` (host memory emulation for DMA).
5. **Initialises UVM** via `run_test()` and sets config-db entries for the VIP interfaces and reset modport.

Clock domains:

| Clock | Source | Connected to |
|---|---|---|
| `csr_clk` | `fptp_top_tb` (generated) | AXI4 master VIP, reset interface |
| DMA clock | `TOP.dma_subsys_dma_clk_out_bridge_0_out_clk_clk` | AXI ACE-Lite slave VIP |

### 3.2 UVM Environment Class Hierarchy

```
fptp_base_test  (uvm_test)
└── fptp_env  (uvm_env)
    ├── svt_axi_system_env  (SVT AXI System Agent)
    │   ├── master[0]  – AXI4 master agent (drives H2F CSR writes/reads)
    │   │   └── master_sequencer[0]  ← driven by test sequences
    │   └── slave[0]   – ACE-Lite slave agent (emulates host DDR/PCIe memory)
    │       └── slave_sequencer[0]   ← driven by fptp_axi_slave_host_response_seq
    ├── fptp_reset_sequencer          – drives fptp_axi_reset_if
    ├── fptp_scoreboard               – monitors slave[0] AXI transactions
    └── fptp_err_demoter              – demotes PKTCLIENT0/1 UVM_ERROR → UVM_INFO
```

Key UVM components:

| Class | File | Role |
|---|---|---|
| `fptp_env` | `testbench/fptp_env.sv` | Top-level UVM environment; creates and connects all sub-components |
| `fptp_scoreboard` | `testbench/fptp_scoreboard.sv` | Captures TX/RX payloads via AXI slave monitor; performs per-channel data comparison |
| `fptp_reset_sequencer` | `testbench/fptp_reset_sequencer.sv` | Dedicated sequencer for driving the DUT reset signal |
| `fptp_tb_config` | `testbench/fptp_tb_config.sv` | Lightweight config object passed through `uvm_config_db` |
| `cust_svt_axi_system_configuration` | `testbench/cust_svt_axi_system_configuration.sv` | Customises SVT AXI system configuration (port widths, VIP options) |
| `fptp_err_demoter` | `testbench/fptp_env.sv` | `uvm_report_catcher`; suppresses expected checker mismatch errors during test teardown |

### 3.3 AXI VIP Configuration

Configured in `cust_svt_axi_system_configuration`:

| Parameter | Master [0] (H2F CSR) | Slave [0] (F2H DMA/Host) |
|---|---|---|
| Interface type | AXI4 | ACE-Lite |
| Data width | 32-bit | 512-bit |
| Address width | 27-bit | 34-bit |
| ID width | 4-bit | 5-bit |
| System monitor | Disabled | — |
| XML/FSDB generation | Disabled | Disabled |

### 3.4 Reset Interface

File: `testbench/fptp_axi_reset_if.sv`

A simple interface with `reset` and `clk` signals and a single `axi_reset_modport`. The `fptp_reset_sequencer` obtains a handle to this interface via `uvm_config_db` and the `axi_simple_reset_sequence` drives the `reset` signal through the modport.

### 3.5 Scoreboard

File: `testbench/fptp_scoreboard.sv`

The `fptp_scoreboard` is connected to the **AXI slave[0] monitor** output port (`item_observed_port`). It:

1. Monitors all AXI transactions on the DMA host interface.
2. Decodes the **agent port** (bits [25:23] of address), **address type** (bits [30:28]), and **agent type** (bits [27:26]).
3. Maintains per-channel TX and RX payload queues (`axi_tx_payload_q` / `axi_rx_payload_q`) for six channels.
4. Compares TX payloads against RX payloads after each packet is fully received and reports a `UVM_ERROR` on mismatch.

Scoreboard enable is controlled by the `dis_sb` field in the test class — set to `1` in CSR tests (no data traffic) and `0` in DMA/QoS tests.

### 3.6 Testbench Configuration Object

File: `testbench/fptp_tb_config.sv`

`fptp_tb_config` is a minimal `uvm_object` carrying destination-port flags (`dest_p0`, `dest_p1`, `dest_p2`, `PO_P1_P2_DEST_P1`). It is created by the test, placed in the config-db under key `"tb_cfg"`, and retrieved by the environment and scoreboard.

---

## 4. File Structure

```
2P25G_DV/
├── ver_list.f                        # VCS compilation file list
├── UVM_VERIFICATION_DOCUMENT.md     # This document
│
├── scripts/
│   ├── Makefile.mk                   # Build and run targets (vlog, vcs, run)
│   ├── gen_ip_sim_setup.sh           # IP simulation setup generation
│   ├── generate_ip.sh                # IP generation script
│   ├── ip_script.pl                  # Perl script: IP file list generation
│   ├── parser_for_PTP.pl             # Perl script: PTP design file parser
│   ├── rename_prev_testdir.sh        # Renames previous test output directory
│   ├── rtl_script.pl                 # Perl script: RTL file list generation
│   ├── support_logic_gen.sh          # Support logic generation
│   ├── top_auto_tiles/               # Auto-generated tile wrappers
│   └── vpd_dump.key                  # VPD waveform dump key file
│
├── testbench/
│   ├── fptp_top_tb.sv                # Top-level testbench module
│   ├── fptp_tb_pkg.svh               # Testbench package (includes all TB files)
│   ├── fptp_env.sv                   # UVM environment
│   ├── fptp_scoreboard.sv            # UVM scoreboard
│   ├── fptp_reset_sequencer.sv       # Reset sequencer
│   ├── fptp_tb_config.sv             # Testbench configuration object
│   ├── fptp_defines.sv               # Global defines, localparams, address map
│   ├── fptp_axi_reset_if.sv          # Reset interface definition
│   ├── cust_svt_axi_system_configuration.sv  # Custom SVT AXI config
│   ├── qsys_top.v                    # DUT wrapper (qsys_top)
│   └── svt_axi_user_defines.svi      # SVT VIP user defines
│
└── tests/
    ├── fptp_test_pkg.svh             # Test package (includes all tests)
    ├── fptp_base_test.svh            # Base test class
    ├── fptp_csr_test.svh             # CSR test
    ├── fptp_dma_base_test.svh        # DMA base traffic test
    ├── fptp_qos_usr_test.svh         # QoS user-traffic test
    │
    └── sequences/
        ├── fptp_seq_lib.svh                      # Sequence library (includes all sequences)
        ├── axi_base_sequence_pkg.sv               # Shared type definitions package
        ├── axi_simple_reset_sequence.sv           # Reset drive sequence
        ├── fptp_axi_derived_base_seq.sv           # Low-level AXI transaction driver
        ├── fptp_null_virtual_seq.sv               # Empty placeholder sequence
        ├── fptp_base_seq.sv                       # Base sequence with read/write APIs
        ├── fptp_csr_seq.sv                        # CSR verification sequence
        ├── fptp_data_traffic_cfg_seq.sv           # DMA channel + packet client config
        ├── fptp_ptp_bridge_cfg_dma_seq.sv         # PTP Bridge TCAM config for DMA
        ├── fptp_ptp_bridge_cfg_usr_seq.sv         # PTP Bridge TCAM config for user traffic
        ├── fptp_axi_slave_host_response_seq.sv    # Host memory emulation (slave-side)
        ├── fptp_dma_base_seq.sv                   # DMA base traffic orchestration
        ├── fptp_user_traffic_check_seq.sv         # User traffic data-integrity checker
        └── fptp_qos_usr_seq.sv                    # QoS + DMA + user traffic orchestration
```

---

## 5. Interfaces and Clocking

### AXI4 Master Interface (H2F CSR)

Connects the VIP `master_if[0]` directly to the DUT's HPS H2F AXI master port:

| Signal Group | Direction (TB→DUT) | DUT Port Prefix |
|---|---|---|
| Write address channel (AW) | → DUT | `hps_sub_sys_agilex_hps_h2f_axi_master_aw*` |
| Write data channel (W) | → DUT | `hps_sub_sys_agilex_hps_h2f_axi_master_w*` |
| Write response channel (B) | ← DUT | `hps_sub_sys_agilex_hps_h2f_axi_master_b*` |
| Read address channel (AR) | → DUT | `hps_sub_sys_agilex_hps_h2f_axi_master_ar*` |
| Read data channel (R) | ← DUT | `hps_sub_sys_agilex_hps_h2f_axi_master_r*` |

Clock: `csr_clk` (testbench-generated).

### ACE-Lite Slave Interface (F2H DMA / Host Memory)

Connects the VIP `slave_if[0]` to the DUT's AXI bridge for ACP (Accelerator Coherency Port):

| Signal Group | Direction (DUT→TB) | DUT Port Prefix |
|---|---|---|
| Write address channel (AW) | DUT → | `mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_aw*` |
| Write data channel (W) | DUT → | `mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_w*` |
| Write response channel (B) | → DUT | `mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_b*` |
| Read address channel (AR) | DUT → | `mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_ar*` |
| Read data channel (R) | → DUT | `mm_interconnect_2_hps_sub_sys_agilex_axi_bridge_for_acp_0_s0_r*` |

Clock: `TOP.dma_subsys_dma_clk_out_bridge_0_out_clk_clk` (DUT-derived DMA clock).

### Reset Interface

| Signal | Direction | Description |
|---|---|---|
| `clk` | input | Tied to `csr_clk` |
| `reset` | output | Active-low reset driven by `axi_simple_reset_sequence` |

---

## 6. Address Map

### DMA Channel Base Addresses

| Channel | TX DMA Prefetcher | TX DMA CSR | RX DMA Prefetcher | RX DMA CSR | TX Descriptor Base | RX Descriptor Base |
|---|---|---|---|---|---|---|
| Port 0 | `0x0448_0000` | `0x0448_0020` | `0x0448_0080` | `0x0448_00A0` | `0x1400_0000` | `0x1000_0000` |
| Port 1 | `0x044C_0000` | `0x044C_0020` | `0x044C_0080` | `0x044C_00A0` | `0x1480_0000` | `0x1080_0000` |
| Port 2 | `0x0450_0000` | `0x0450_0020` | `0x0450_0080` | `0x0450_00A0` | `0x1500_0000` | `0x1100_0000` |
| Port 3 | `0x0454_0000` | `0x0454_0020` | `0x0454_0080` | `0x0454_00A0` | `0x1580_0000` | `0x1180_0000` |
| Port 4 | `0x0458_0000` | `0x0458_0020` | `0x0458_0080` | `0x0458_00A0` | `0x1600_0000` | `0x1200_0000` |
| Port 5 | `0x045C_0000` | `0x045C_0020` | `0x045C_0080` | `0x045C_00A0` | `0x1680_0000` | `0x1280_0000` |

### Packet Client Register Offsets (from base address)

| Offset | Register | Description |
|---|---|---|
| `+0x00` | `CFG_PKT_CL_CTRL` | Packet client control (enable, loopback, mode) |
| `+0x0C` | `DYN_DMAC_ADDR_U` | Destination MAC address upper 16 bits |
| `+0x10` | `DYN_DMAC_ADDR_L` | Destination MAC address lower 32 bits |
| `+0x14` | `DYN_SMAC_ADDR_U` | Source MAC address upper 16 bits |
| `+0x18` | `DYN_SMAC_ADDR_L` | Source MAC address lower 32 bits |
| `+0x1C` | `DYN_PKT_NUM` | Number of packets to transmit |
| `+0x20` | `DYN_PKT_SIZE_CFG` | Packet size configuration [31:16]=max, [15:0]=min |
| `+0x58` | `STAT_CHECKER_MISC` | Checker miscellaneous status (bit[0] = data mismatch flag) |

### PTP Bridge / TCAM Registers (selected)

| Address | Register | Description |
|---|---|---|
| `0x0405_0000 + 0x04` | `ING_ARB0_CFG_PRI_DMA_REG` | Ingress arbiter 0 DMA priority |
| `0x0405_0000 + 0x08` | `ING_ARB0_CFG_PRI_USR_REG` | Ingress arbiter 0 user priority |
| `0x0405_0000 + 0x10` | `ING_ARB1_CFG_PRI_DMA_REG` | Ingress arbiter 1 DMA priority |
| `0x0405_0000 + 0x14` | `ING_ARB1_CFG_PRI_USR_REG` | Ingress arbiter 1 user priority |
| `0x0405_0200 + 0x20` | `PTP_TCAM0` management | Insert/status trigger for TCAM0 |
| `0x0405_0200 + 0x30` | `PTP_TCAM0` key index | Entry index register |
| `0x0405_1200` | `PTP_TCAM0_KEY_BASE` | TCAM0 key register array (16 × 32-bit) |
| `0x0405_2200` | `PTP_TCAM0_RESULT_BASE` | TCAM0 result (routing target) |
| `0x0405_3200` | `PTP_TCAM0_MASK_BASE` | TCAM0 mask register array (16 × 32-bit) |
| `0x0405_4200` | `PTP_TCAM1` base | Same structure as TCAM0 for second flow |

---

## 7. Sequences

### 7.1 Sequence Library Overview

All sequences are compiled and included through `tests/sequences/fptp_seq_lib.svh`. The include order respects class inheritance:

```
axi_base_sequence_pkg.sv           (package – no class dependencies)
fptp_axi_derived_base_seq.sv       (extends svt_axi_master_base_sequence)
fptp_null_virtual_seq.sv           (extends uvm_sequence)
axi_simple_reset_sequence.sv       (extends uvm_sequence)
fptp_base_seq.sv                   (extends uvm_sequence)
fptp_csr_seq.sv                    (extends fptp_base_seq)
fptp_data_traffic_cfg_seq.sv       (extends fptp_base_seq)
fptp_ptp_bridge_cfg_dma_seq.sv     (extends fptp_base_seq)
fptp_ptp_bridge_cfg_usr_seq.sv     (extends fptp_base_seq)
fptp_axi_slave_host_response_seq.sv (extends svt_axi_slave_base_sequence)
fptp_dma_base_seq.sv               (extends uvm_sequence)
fptp_user_traffic_check_seq.sv     (extends fptp_base_seq)
fptp_qos_usr_seq.sv                (extends uvm_sequence)
```

### 7.2 Sequence Descriptions

---

#### `axi_base_sequence_pkg`
**File:** `sequences/axi_base_sequence_pkg.sv`

**Description:** SystemVerilog package defining all shared data types used across the testbench sequences. Contains:

- `e_direction` – enumeration: `H2D` (host-to-device) / `D2H` (device-to-host).
- `e_agent_type` – enumeration: `D2H_ST_AGENT`, `H2D_ST_AGENT`, `H2D_MM_AGENT`, `INVALID_AGENT`.
- `e_agent_port` – enumeration: `PORT_0` … `PORT_5`.
- `e_address_type` – enumeration: `CSR`, `DESCR`, `DMA_DATA`, `RESP`, `MSIX`, `BAM`.
- `eth_pkt` – packed struct representing an Ethernet frame: `da` (48-bit), `sa` (48-bit), `len` (16-bit), `data0/1/2` (128-bit each), `data3` (16-bit).
- `controlFieldMM_s` / `controlFieldST_s` – DMA descriptor control field structs.
- `t_h2d_st_descriptor` – full 448-bit H2D streaming DMA descriptor layout.

**Purpose:** Provide a common, importable set of types that ensure consistency between the AXI slave response sequence (which builds descriptors) and the scoreboard (which decodes them).

---

#### `fptp_axi_master_base_seq`
**File:** `sequences/fptp_axi_derived_base_seq.sv`

**Description:** Low-level AXI4 master sequence extending `svt_axi_master_base_sequence`. Constructs and sends a single AXI4 transaction (read or write) using the SVT VIP request object. Key behaviour:

- Retrieves port configuration via `p_sequencer.get_cfg()`.
- Sets `burst_type = INCR`, `addr_valid_delay = 0`, `data_before_addr = 0`.
- For write transactions, populates `data[]` and `wstrb[]` arrays.
- Sends the request with `uvm_send` and collects the response with `get_response`.

Randomizable fields: `addr`, `xact_type`, `burst_length`, `burst_size`, `burst_type`, `data[]`, `wstrb[]`.

**Purpose:** Serve as the atomic AXI transaction primitive used by the `fptp_base_seq` helper tasks (`axi_master_write` / `axi_master_read`). Not used directly by tests.

---

#### `fptp_null_virtual_seq`
**File:** `sequences/fptp_null_virtual_seq.sv`

**Description:** An empty UVM sequence with a no-operation `body()` task.

**Purpose:** Assigned as the `default_sequence` on the AXI system sequencer and all master sequencers during the `main_phase`, preventing UVM from issuing phase-start warnings on idle sequencers.

---

#### `axi_simple_reset_sequence`
**File:** `sequences/axi_simple_reset_sequence.sv`

**Description:** Reset control sequence registered on `fptp_reset_sequencer`. Drives the DUT reset signal through the `fptp_axi_reset_if.axi_reset_modport`. Sequence:

1. Wait 10 rising edges of `clk`.
2. Assert `reset = 1'b0` (active low) with 2 ns skew.
3. Wait 10 more rising edges.
4. Deassert `reset = 1'b1`.

Automatically launched at simulation start as the default sequence on `env.rst_sequencer.reset_phase`.

**Purpose:** Apply the initial power-on reset to the DUT, guaranteeing all logic enters a known state before any test stimulus begins.

---

#### `fptp_base_seq`
**File:** `sequences/fptp_base_seq.sv`

**Description:** Base UVM sequence bound to `svt_axi_system_sequencer`. Provides two reusable task APIs used by all configuration and verification sequences:

- **`axi_master_write(address, burst_sz, data[], burst_length, wstrb[])`** – Creates and sends an AXI4 WRITE transaction via `fptp_axi_master_base_seq` on `master_sequencer[0]`.
- **`axi_master_read(address, burst_sz, burst_length, wdata, output data[])`** – Creates and sends an AXI4 READ transaction; waits for the response and returns `data[]`.

Both tasks use `uvm_create_on` / `uvm_send` with inline randomization.

**Purpose:** Abstract AXI bus register accesses into portable helper tasks so all derived sequences can call them without directly managing VIP objects.

---

#### `fptp_csr_seq`
**File:** `sequences/fptp_csr_seq.sv`

**Description:** CSR verification sequence extending `fptp_base_seq`. Performs:

1. **Default value checks** – Reads every significant register in MSGDMA, PTP Bridge, TCAM0/1, Packet Client 0, Packet Client 1, and HSSI subsystems and compares against expected reset values.
2. **Read/Write checks** – Writes known data to read/write registers and reads back to confirm correctness.

All transactions are single-beat 32-bit AXI4 writes/reads.

**Purpose:** Verify that all CSR registers power up at correct reset values and that R/W registers correctly accept and retain written values, independently of any data-path traffic.

---

#### `fptp_data_traffic_cfg_seq`
**File:** `sequences/fptp_data_traffic_cfg_seq.sv`

**Description:** AXI configuration sequence extending `fptp_base_seq`. Programs the full hardware data path via register writes:

- **Packet Client 0** – DA/SA MAC addresses, packet count (`usr_pkt`), packet size range (64 B min – 1500 B max), and control register.
- **Packet Client 1** – Same as above with independent MAC addresses.
- **TX DMA Prefetchers (Ports 0–5)** – Writes descriptor base addresses and enables/disables each channel according to `ch_en[5:0]`.
- **RX DMA Prefetchers (Ports 0–5)** – Writes descriptor base addresses and enables/disables each channel according to `ch_en[5:0]`.

Randomizable constraints: `ch_en` (default 0 = all disabled), `usr_en` (default 0 = user traffic disabled), `usr_pkt` (default 1000 packets).

Signals completion via `h2f_cfg_done = 1`.

**Purpose:** Configure the complete hardware data-path (DMA channels and packet clients) in preparation for traffic tests. Reused by both `fptp_dma_base_seq` and `fptp_qos_usr_seq`.

---

#### `fptp_ptp_bridge_cfg_dma_seq`
**File:** `sequences/fptp_ptp_bridge_cfg_dma_seq.sv`

**Description:** PTP Bridge TCAM configuration sequence for DMA traffic, extending `fptp_base_seq`. For each of the six DMA channels:

1. Writes the TCAM entry key index register.
2. Writes key registers (16 × 32-bit): DA/SA MAC address fields in positions [0], [1], [2]; zeros elsewhere.
3. Writes the TCAM result register (routing target channel index).
4. Writes mask registers: `0xFFFFFFFF` for positions [0]–[2]; zeros elsewhere (full DA+SA match).
5. Triggers TCAM insertion and polls the management register until the busy/done bit is set.

Per-channel MAC addresses (`ch0_dma_key0/1/2` through `ch5_dma_key0/1/2`) are passed as inline constraints from the calling sequence.

Signals completion via `ptp_cfg_dma_done = 1`.

**Purpose:** Set up TCAM lookup rules so the DUT routes each ingress packet (after HSSI loopback) to the correct RX DMA channel based on the packet's DA+SA MAC address.

---

#### `fptp_ptp_bridge_cfg_usr_seq`
**File:** `sequences/fptp_ptp_bridge_cfg_usr_seq.sv`

**Description:** PTP Bridge TCAM configuration sequence for user (packet-client) traffic, extending `fptp_base_seq`. Optionally writes ingress arbitration priority registers for both arbiter banks (if `usr_pri == 1`), then for each of the two user packet clients:

1. Sets the TCAM entry key index.
2. Writes key registers (positions [0]–[2] = DA+SA MAC fields; zeros elsewhere).
3. Writes the result register (user port routing index).
4. Writes full masks for positions [0]–[2].
5. Triggers TCAM insertion and polls until done.

Randomizable constraints: `usr_pri` (0 = skip priority configuration), `arb0_usr_pri`, `arb1_usr_pri`, `usr0/1_key_index`, `usr0/1_eth_key0/1/2`, `usr0/1_key_result`.

Default MAC addresses: User0 = DA `0xEEEE_EEEE_EEEE` / SA `0xBBBB_BBBB_BBBB`; User1 = DA `0x2222_2222_2222` / SA `0x1111_1111_1111`.

Signals completion via `ptp_cfg_usr_done = 1`.

**Purpose:** Program TCAM routing rules for packet-client user traffic so that frames sent by Packet Client 0/1 are routed back to the correct ingress user ports after HSSI loopback.

---

#### `fptp_axi_slave_host_response_seq`
**File:** `sequences/fptp_axi_slave_host_response_seq.sv`

**Description:** AXI slave-side sequence extending `svt_axi_slave_base_sequence`. Runs on `slave_sequencer[0]` and models host memory (DDR / PCIe) by responding to all AXI read/write requests from the DUT DMA engines:

- **Descriptor reads** – When the DUT's TX DMA prefetcher reads a descriptor address, this sequence generates a valid `t_h2d_st_descriptor` struct (populated with the Ethernet frame length, read/write buffer addresses, control flags) and returns it over the AXI read channel.
- **Data reads** – When the prefetcher reads payload data, the sequence constructs an `eth_pkt` struct using the per-channel configured DA/SA/EtherType and returns it as AXI read data.
- **Write responses** – Accepts and acknowledges all AXI write transactions (RX DMA deposit path).

Key randomizable parameters (constrained per test): `ch0_max_desc`–`ch5_max_desc` (descriptors per channel), `ch_desc_length[0..5]` (payload bytes), `ch0_da/sa/eth` – `ch5_da/sa/eth` (per-channel MAC addresses and EtherType), `resp_time_in_ns` (response latency in nanoseconds, default 100 µs).

**Purpose:** Emulate host-side memory so DMA engines can fetch TX descriptors and packet data, and write received RX packets, enabling complete end-to-end DMA traffic verification in simulation without physical host hardware.

---

#### `fptp_dma_base_seq`
**File:** `sequences/fptp_dma_base_seq.sv`

**Description:** DMA base traffic orchestration sequence extending `uvm_sequence`. Coordinates three sub-sequences:

1. **`fptp_ptp_bridge_cfg_dma_seq`** (sequential) – Programs TCAM entries for all six channels using hard-coded per-channel MAC addresses; waits for `ptp_cfg_dma_done`.
2. **`fptp_data_traffic_cfg_seq`** (forked) – Configures TX/RX DMA channels and packet clients with `ch_en = 6'h3F` (all six enabled); waits for `h2f_cfg_done`.
3. **`fptp_axi_slave_host_response_seq`** (forked on `slave_sequencer[0]`) – Provides host memory responses with 3 descriptors per channel, varied packet lengths (512 / 271 / 1267 / 967 / 363 / 123 bytes), and a 100 µs response timeout.

Sub-sequences 2 and 3 run concurrently in a `fork…join`.

Per-channel MAC assignments:
| Channel | DA | SA | EtherType |
|---|---|---|---|
| 0 | `0xDDDD_DDDD_DDDD` | `0xAAAA_AAAA_AAAA` | `0x0800` |
| 1 | `0xFFFF_FFFF_FFFF` | `0xBBBB_BBBB_BBBB` | `0x8857` |
| 2 | `0xEEEE_EEEE_EEEE` | `0xCCCC_CCCC_CCCC` | `0x0800` |
| 3 | `0x3333_3333_3333` | `0x6666_6666_6666` | `0x8857` |
| 4 | `0x4444_4444_4444` | `0x7777_7777_7777` | `0x0800` |
| 5 | `0x5555_5555_5555` | `0x8888_8888_8888` | `0x8857` |

**Purpose:** Exercise the complete DMA data path end-to-end: host descriptor fetch → TX DMA → HSSI loopback → TCAM routing → RX DMA → host write-back. Used by `fptp_dma_base_test`.

---

#### `fptp_user_traffic_check_seq`
**File:** `sequences/fptp_user_traffic_check_seq.sv`

**Description:** Post-traffic checker sequence extending `fptp_base_seq`. After traffic completes:

1. Polls `PKTCLI0_CFG_PKT_CL_CTRL[0]` until bit 0 is set (traffic enabled).
2. Polls `PKTCLI1_CFG_PKT_CL_CTRL[0]` until bit 0 is set.
3. Reads `PKTCLI0_STAT_CHECKER_MISC` – if bit[0] is set, reports `UVM_ERROR("PKTCLIENT0", ...)`.
4. Reads `PKTCLI1_STAT_CHECKER_MISC` – if bit[0] is set, reports `UVM_ERROR("PKTCLIENT1", ...)`.

**Purpose:** Validate the data integrity of user-path traffic by checking hardware-generated mismatch indicators in the packet-client checker registers. Called at the end of `fptp_qos_usr_seq`.

---

#### `fptp_qos_usr_seq`
**File:** `sequences/fptp_qos_usr_seq.sv`

**Description:** Full QoS + user-traffic orchestration sequence extending `uvm_sequence`. Extends the DMA base flow by additionally exercising packet-client user traffic:

1. **`fptp_ptp_bridge_cfg_dma_seq`** (sequential) – Programs TCAM for all 6 DMA channels.
2. **`fptp_ptp_bridge_cfg_usr_seq`** (sequential, `usr_pri = 1`) – Programs TCAM for both user ports with priority configuration enabled.
3. **Fork:**
   - **`fptp_data_traffic_cfg_seq`** – `ch_en = 6'h3F`, `usr_en = 2'h3` (both packet clients enabled); waits for `h2f_cfg_done`.
   - **`fptp_axi_slave_host_response_seq`** – 3 descriptors per channel, default packet lengths, 200 µs response timeout.
4. **Wait 50 µs**, then run **`fptp_user_traffic_check_seq`** to validate packet-client data integrity.

**Purpose:** Simultaneously exercise DMA traffic and user (packet-client) traffic through the HSSI loopback, validating QoS arbitration and correct routing for both traffic classes, then confirm no data mismatches occurred.

---

## 8. Tests

### 8.1 Test Hierarchy

```
uvm_test
└── fptp_base_test           (fptp_base_test.svh)
    ├── fptp_csr_test         (fptp_csr_test.svh)
    ├── fptp_dma_base_test    (fptp_dma_base_test.svh)
    └── fptp_qos_usr_test     (fptp_qos_usr_test.svh)
```

All tests are registered with the UVM factory and are selected at runtime using the standard `+UVM_TESTNAME=<test_name>` plusarg. The sequence to run within a test is selected with `+seqname=<sequence_name>`.

### 8.2 Test Descriptions

---

#### `fptp_base_test`
**File:** `tests/fptp_base_test.svh`

**Description:** Root base test class for all FPTP tests. Implements all standard UVM phase handlers that are shared by derived tests:

- **`build_phase`** – Creates `fptp_env`, `fptp_tb_config`, and the AXI system configuration; sets null default sequences on all master sequencers and the reset sequence on `rst_sequencer`; configures the UVM max quit count (default 100, overridable via `+UVM_MAX_QUIT_COUNT`).
- **`end_of_elaboration_phase`** – Prints the full UVM topology.
- **`run_phase`** – Waits for `tb_reset` to assert, then reads `+seqname=<name>` and instantiates the named sequence via the UVM factory; starts it on `env.axi_system_env.sequencer`.
- **`timeout_watch`** – Background task monitoring simulation wall-time against `+TIMEOUT=<us>` (default 2000 µs); calls `uvm_fatal` on timeout unless `exp_timeout` is set.
- **`final_phase`** – Reports PASS/FAIL based on UVM error/fatal counts.

Key control fields:

| Field | Type | Default | Description |
|---|---|---|---|
| `dis_sb` | bit | 0 | Disable scoreboard when set |
| `exp_timeout` | bit | 0 | Suppress fatal on timeout (emit warning instead) |
| `timeout` | int | 0 (→ 2000 µs) | Override via `+TIMEOUT` plusarg |

**Purpose:** Provide a common test scaffold so derived tests only override the specific fields or phases they need, reducing code duplication.

---

#### `fptp_csr_test`
**File:** `tests/fptp_csr_test.svh`

**Description:** CSR verification test extending `fptp_base_test`. Overrides:

- `dis_sb = 1` in `build_phase` (scoreboard disabled; no DMA traffic).
- `run_phase` launches `fptp_csr_seq` on the AXI master sequencer.

**Sequence invoked:** `fptp_csr_seq`

**Simulation run command (example):**
```bash
make run TESTNAME=fptp_csr_test SEQNAME=fptp_csr_seq
```

**Purpose:** Verify the reset values and read/write functionality of all CSR registers in the DUT (MSGDMA, PTP Bridge, TCAM, Packet Clients, HSSI) without sending any data-path traffic.

**Pass criteria:**
- No UVM_ERROR or UVM_FATAL messages.
- All register default-value comparisons pass.
- All R/W register read-back values match written values.

---

#### `fptp_dma_base_test`
**File:** `tests/fptp_dma_base_test.svh`

**Description:** DMA base data-path test extending `fptp_base_test`. Overrides:

- `dis_sb = 0` in `build_phase` (scoreboard active).
- `run_phase` launches `fptp_dma_base_seq` on the AXI master sequencer.

**Sequence invoked:** `fptp_dma_base_seq`

**Simulation run command (example):**
```bash
make run TESTNAME=fptp_dma_base_test SEQNAME=fptp_dma_base_seq
```

**Purpose:** Verify the complete DMA data path end-to-end across all six channels:
1. TCAM is programmed with per-channel MAC-based routing rules.
2. TX DMA engines fetch descriptors and packet data from simulated host memory.
3. Packets traverse the HSSI in loopback mode.
4. The PTP Bridge TCAM classifies each arriving packet and routes it to the correct RX DMA channel.
5. RX DMA engines write received data back to simulated host memory.
6. The scoreboard confirms TX payload matches RX payload for every channel.

**Pass criteria:**
- No UVM_ERROR or UVM_FATAL messages.
- Scoreboard reports no payload mismatches for all six DMA channels.

---

#### `fptp_qos_usr_test`
**File:** `tests/fptp_qos_usr_test.svh`

**Description:** QoS + user-traffic test extending `fptp_base_test`. Overrides:

- `dis_sb = 0` in `build_phase` (scoreboard active).
- `run_phase` launches `fptp_qos_usr_seq` on the AXI master sequencer.

**Sequence invoked:** `fptp_qos_usr_seq`

**Simulation run command (example):**
```bash
make run TESTNAME=fptp_qos_usr_test SEQNAME=fptp_qos_usr_seq
```

**Purpose:** Simultaneously verify both the DMA data path and the user (packet-client) data path under QoS arbitration:
1. TCAM is programmed for all six DMA channels plus both user ports.
2. DMA traffic and packet-client traffic are driven concurrently.
3. Ingress arbitration between DMA and user traffic is exercised through the PTP Bridge arbiters (with user priority enabled).
4. After traffic completes, the packet-client hardware checker registers confirm no data mismatches on either user port.
5. The scoreboard validates DMA channel payload integrity.

**Pass criteria:**
- No UVM_ERROR or UVM_FATAL messages.
- Scoreboard reports no DMA payload mismatches.
- `fptp_user_traffic_check_seq` detects no data-mismatch flags in `STAT_CHECKER_MISC` for both packet clients.

---

## 9. Build and Simulation Flow

### Prerequisites

| Tool | Version |
|---|---|
| Synopsys VCS | Supporting UVM 1.2 |
| Synopsys DesignWare VIP | SVT AXI VIP |
| Intel Quartus Prime Pro | 25.1.1 |

### Environment Variables

| Variable | Description |
|---|---|
| `PTP_ROOTDIR` | Root of the `2P25G_DV` directory |
| `VCS_HOME` | VCS installation directory |
| `DESIGNWARE_HOME` | DesignWare VIP installation directory |
| `QUARTUS_HOME` / `QUARTUS_INSTALL_DIR` | Quartus Pro installation directory |
| `DESIGN_DIR` | Path to RTL design source |

### Build Steps

```bash
# 1. Generate IP simulation files and VIP
make cmplib

# 2. Compile RTL and testbench
make build HSSI_25G=1

# Alternatively, run compile and link separately:
make vlog HSSI_25G=1
make vcs
```

The `HSSI_25G=1` define activates 25G-specific RTL paths and sets:
- `+define+FTILE_PTP_HSSI_25G`
- `+define+MAC_SRD_CFG_25G`
- `+define+HSSI_2P25G`
- Payload/scoreboard configuration: `PAYLOAD_WIDTH=64`, `PAYLOAD_STRB=8`, `CH_WIDTH=6`

### Simulation Steps

```bash
# Run a specific test
make run TESTNAME=fptp_csr_test SEQNAME=fptp_csr_seq

make run TESTNAME=fptp_dma_base_test SEQNAME=fptp_dma_base_seq

make run TESTNAME=fptp_qos_usr_test SEQNAME=fptp_qos_usr_seq
```

Optional plusargs:

| Plusarg | Description |
|---|---|
| `+UVM_VERBOSITY=UVM_DEBUG` | Enable verbose logging |
| `+UVM_OBJECTION_TRACE` | Trace UVM phase objections |
| `+TIMEOUT=<us>` | Override simulation timeout (default 2000 µs) |
| `+ntb_random_seed=<N>` | Set a fixed random seed for reproducibility |
| `+DUMP` | Enable VPD waveform dump |
| `+COV` | Enable code coverage collection |

### Waveform Dump

Define `DUMP=1` during compilation to enable VPD waveform generation. The dump key file is located at `scripts/vpd_dump.key`.

---

## 10. Coverage and Debug

### Code Coverage

When compiled with `COV=1`, VCS collects:

| Coverage Type | Description |
|---|---|
| Line | Statement coverage |
| Condition | Branch condition coverage |
| FSM | Finite state machine state coverage |
| Toggle | Signal toggle (0→1 / 1→0) coverage |
| Branch | Branch decision coverage |

Coverage databases are merged into `../regression.vdb` across multiple test runs.

### UVM Verbosity

Default verbosity is `UVM_DEBUG` (set in `SIMV_OPT`). To reduce verbosity in regression:

```bash
make run TESTNAME=... SEQNAME=... UVM_VERBOSITY=UVM_LOW
```

### Log Files

| Log File | Content |
|---|---|
| `../sim/vlog.log` | VCS compilation log |
| `vcs.log` | VCS elaboration log |
| `simulate_<TESTNAME>.log` | Simulation run log for each test |

### Debugging Failed Tests

1. Check `simulate_<TESTNAME>.log` for `UVM_ERROR` / `UVM_FATAL` messages and their source IDs.
2. Use the scoreboard channel-specific error messages (e.g., `"PKTCLIENT0 CHECKER HAS DATA MISMATCH"`) to identify the failing channel.
3. Enable VPD dump and inspect the `fptp_top_tb.vpd` waveform in Verdi/DVE.
4. Use `+UVM_OBJECTION_TRACE` to diagnose premature test termination or hung phases.
5. The `fptp_err_demoter` in `fptp_env` will suppress `UVM_ERROR` from PKTCLIENT0/1 during normal teardown; disable it temporarily if unexpected checker errors are being masked.

---

*End of UVM Verification Document*
