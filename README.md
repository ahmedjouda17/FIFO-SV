# Synchronous FIFO Verification — SystemVerilog SV 

A class-based verification project for a synchronous FIFO, combining
constrained-random stimulus, reference-model checking, SystemVerilog
Assertions (SVA), and functional coverage.

The project includes a verification plan and a report documenting the
implementation, RTL changes, simulation screenshots, and coverage results.

## FIFO Overview

The FIFO stores data in first-in, first-out order using internal read and
write pointers.

| Parameter | Default |
|---|---:|
| Data width | 16 bits |
| FIFO depth | 8 words |
| Clocking | Single-clock, synchronous operation |
| Reset | Active-low asynchronous reset |

### Interface

| Signal | Direction | Purpose |
|---|---|---|
| `clk` | Input | FIFO clock |
| `rst_n` | Input | Active-low asynchronous reset |
| `data_in` | Input | Word presented for writing |
| `wr_en` | Input | Write request |
| `rd_en` | Input | Read request |
| `data_out` | Output | Registered read data |
| `wr_ack` | Output | Successful write acknowledgment |
| `full` / `empty` | Output | FIFO occupancy flags |
| `almostfull` / `almostempty` | Output | Near-boundary occupancy flags |
| `overflow` / `underflow` | Output | Rejected-operation indicators |

Addresses are managed internally. The user supplies data and operation
enables rather than selecting a memory address.

### Simultaneous Read and Write

Acceptance is determined by the FIFO state before the active clock edge.

| Initial state | Accepted operation | Occupancy change |
|---|---|---:|
| Empty | Write only | +1 |
| Partially occupied | Read and write | 0 |
| Full | Read only | −1 |

Reset clears the pointers and occupancy, making the FIFO logically empty.

## Verification Environment

The environment uses SystemVerilog classes and modules rather than the
UVM framework.

| Component | Responsibility |
|---|---|
| Interface | Groups DUT signals and provides modports |
| Transaction class | Represents FIFO inputs and outputs |
| Testbench | Applies reset and randomized stimulus |
| Monitor | Samples interface activity |
| Scoreboard | Checks read data against a reference model |
| Coverage class | Collects coverpoints and cross coverage |
| Shared package | Holds completion status, result counters, and a synchronization event |
| Top module | Connects the DUT and verification environment |
| Assertions | Check control flags, reset, counters, and pointer behavior |

## Stimulus Strategy

The transaction class randomizes `data_in`, `rst_n`, `wr_en`, and `rd_en`.

The default distributions are:

- Reset deasserted: 95%.
- Write enable asserted: 70%.
- Read enable asserted: 30%.

The read and write distributions are configurable through the transaction
constructor.

## Verification Plan

The supplied plan contains 17 requirements covering:

- Reset of internal pointers and occupancy.
- Asynchronous reset behavior.
- Write acknowledgment.
- Overflow and underflow.
- Full, empty, and almost-full/almost-empty flags.
- Read and write pointer wraparound.
- Pointer and occupancy bounds.
- FIFO data ordering.
- Simultaneous read/write at empty and full boundaries.

Data ordering is assigned to the reference-model scoreboard. Control and
internal-state requirements are primarily assigned to assertions.

## Assertions

The reported RTL includes assertion and cover-property checks for:

- Reset behavior.
- Write acknowledgment.
- Overflow and underflow.
- Occupancy flags.
- Read and write pointer wraparound.
- Pointer bounds and maximum occupancy.

The assertion code is guarded by `SIM`. Enable it during compilation with:

```tcl
+define+SIM
```

## Functional Coverage

The coverage model includes individual coverpoints and seven crosses.
Each cross combines `wr_en` and `rd_en` with one of:

- `wr_ack`
- `overflow`
- `full`
- `empty`
- `almostfull`
- `almostempty`
- `underflow`

The underflow cross declares the combination `rd_en = 0` and
`underflow = 1` illegal in the submitted implementation.

### Reported Result

| Metric | Result |
|---|---:|
| Functional coverage | 98.43% |

This value comes from the submitted report, not a newly executed regression.

The report identifies two uncovered combinations in the full-flag cross:

- `wr_en = 1`, `rd_en = 1`, `full = 1`
- `wr_en = 0`, `rd_en = 1`, `full = 1`

Coverage closure should account for whether `full` is sampled before or
after the operation. A read from a full FIFO deasserts `full` after the
edge, so a post-operation cross does not directly represent the
pre-operation full condition.

## RTL Changes Documented in the Report

The RTL screenshots identify changes to:

1. Reset `data_out` to zero.
2. Update occupancy correctly when read and write are both requested at
   the empty or full boundary.

## Known Specification Differences

The submitted RTL screenshots show several points requiring follow-up:

| Item | Specification | Reported RTL |
|---|---|---|
| `almostfull` | Assert at `FIFO_DEPTH - 1` | Uses `FIFO_DEPTH - 2`; its assertion uses the same threshold |
| `underflow` | Sequential rejection indicator | Combinational `empty && rd_en` |
| Write status on reset | Requires explicit review | `wr_ack` and `overflow` are not assigned in the shown reset branch |
| Overflow after an accepted write | Requires explicit review | Not assigned in the shown successful-write branch |

These differences are documented separately from the recorded coverage
result. Coverage percentages alone do not establish specification compliance.

## Running the Verification

Use a SystemVerilog simulator supporting classes, covergroups, and SVA,
such as QuestaSim.

1. Open the project in the simulator.
2. Run the supplied `.do` script from the directory expected by its paths.
3. Confirm that compilation enables `SIM` when assertion checking is needed.
4. Inspect the transcript, waveform, assertion results, and coverage reports.

The submitted report includes the simulator script and screenshots.
Exact script paths and commands should match the files in this repository.

## Project Documents

- `Project.pdf` — FIFO specification and verification requirements.
- `FIFO_Verification_Plan.xlsx` — requirement-to-check mapping.
- `Ahmed_goda_ali_final_project_1.pdf` — implementation and simulation report.

## Tools and Concepts

SystemVerilog · Constrained Randomization · Reference Models · Scoreboards ·
Functional Coverage · Cross Coverage · SVA · QuestaSim
