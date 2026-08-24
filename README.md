# Simplified Memory Controller — RTL Design & Verification

A synchronous memory controller designed and verified in **Verilog HDL** as an individual project for the **ENCS3310 Advanced Digital Systems Design** course at Birzeit University.

The project focuses on RTL design, finite-state-machine implementation, CPU–memory interfacing, request arbitration, and simulation-based functional verification at both the **memory-controller level** and **system level**.

---

## Project Overview

A memory controller acts as an interface between a CPU and memory. It receives high-level read and write requests from the CPU and translates them into operations performed by the memory.

This project implements a complete simplified system consisting of:

- **Simple CPU Model** — Generates memory read/write requests and receives responses.
- **Memory Controller** — Manages CPU requests and controls memory operations.
- **Memory Model** — Stores and retrieves data based on controller requests.

The complete system is implemented using modular **Verilog RTL**.

---

## Project Objectives

The main objectives of the project were to:

1. Design and implement a basic synchronous memory controller using Verilog.
2. Develop a comprehensive testbench for verifying the memory controller.
3. Develop a simple CPU model that generates memory requests.
4. Implement a memory model for storing and retrieving data.
5. Integrate the CPU, memory controller, and memory into a complete system.
6. Verify both the memory controller and the complete system through simulation.

---

## System Architecture

```text
                 ┌──────────────┐
                 │  Simple CPU  │
                 └──────┬───────┘
                        │
                  CPU Interface
                        │
                        ▼
              ┌─────────────────────┐
              │  Memory Controller  │
              └──────────┬──────────┘
                         │
                  Memory Interface
                         │
                         ▼
                   ┌──────────┐
                   │  Memory  │
                   └──────────┘
```

The CPU communicates only with the memory controller. The controller manages communication with the memory and returns the appropriate response to the CPU.

---

## Functional Requirements

### Read Operation

During a read operation:

1. The CPU provides a memory address.
2. The CPU asserts `read_enable`.
3. The controller accepts the request when `ready` is asserted.
4. The controller sends the address and read enable to the memory.
5. The memory returns the requested data.
6. The controller provides the data to the CPU through `rdata`.
7. The controller asserts `read_valid` to indicate that the returned data is valid.

### Write Operation

During a write operation:

1. The CPU provides a memory address and write data.
2. The CPU asserts `write_enable`.
3. The controller accepts the request when `ready` is asserted.
4. The controller sends the address, data, and write enable to the memory.
5. The memory stores the provided data.
6. The controller asserts `write_done` to indicate that the operation completed successfully.

### Controller Ready Signal

The CPU cannot send a new request to the memory controller unless the controller's `ready` signal is asserted.

This allows the controller to control when it can accept a new memory transaction.

### Simultaneous Read and Write

If the CPU asserts both `read_enable` and `write_enable` simultaneously:

> **The write operation has higher priority.**

The controller executes the write operation first and retains the read request so that it can be processed afterward.

---

## Memory Controller

The memory controller is implemented as an RTL finite-state machine.

The controller can operate in three primary states:

- `IDLE`
- `READ`
- `WRITE`

### FSM Overview

```text
                       ┌─────────┐
                       │  IDLE   │
                       └────┬────┘
                            │
                ┌───────────┴───────────┐
                │                       │
             Read                    Write
                │                       │
                ▼                       ▼
          ┌───────────┐           ┌───────────┐
          │   READ    │           │   WRITE   │
          └─────┬─────┘           └─────┬─────┘
                │                       │
                └───────────┬───────────┘
                            │
                            ▼
                         IDLE
```

The controller also handles pending read requests when a read and write request occur at the same time.

---

## Reset

The controller uses an **asynchronous active-low reset**.

When reset is asserted, the controller returns to the `IDLE` state.

The reset mechanism initializes the controller so that it can begin accepting requests correctly.

---

## Interfaces

### CPU → Memory Controller

| Signal | Width | Description |
|---|---:|---|
| `address` | 16 bits | Memory address provided by the CPU |
| `wdata` | 16 bits | Data provided by the CPU for a write |
| `read_enable` | 1 bit | Indicates a read request |
| `write_enable` | 1 bit | Indicates a write request |

### Memory Controller → CPU

| Signal | Width | Description |
|---|---:|---|
| `rdata` | 16 bits | Data returned from memory |
| `ready` | 1 bit | Indicates that the controller can accept a new request |
| `read_valid` | 1 bit | Indicates that read data is valid |
| `write_done` | 1 bit | Indicates that a write operation has completed |

### Memory Controller → Memory

| Signal | Width | Description |
|---|---:|---|
| `memory_address` | 16 bits | Address provided to memory |
| `write_data` | 16 bits | Data provided to memory for a write |
| `r_e` | 1 bit | Memory read enable |
| `w_e` | 1 bit | Memory write enable |

### Memory → Memory Controller

| Signal | Width | Description |
|---|---:|---|
| `read_data` | 16 bits | Data returned from memory |

---

## RTL Modules

The RTL design is divided into separate Verilog modules to provide a modular hardware architecture.

### `memory_controller.v`

The main controller module responsible for:

- FSM state management
- CPU request handling
- Read operations
- Write operations
- Request prioritization
- Pending read handling
- Memory interface control
- Controller status signals
- Reset behavior

### `cpu.v`

A simple CPU model that generates read and write requests to the memory controller and receives the corresponding responses.

The CPU model is used to demonstrate interaction with the controller rather than implementing a complete processor architecture.

### `memory.v`

A memory model used by the system to store and retrieve data.

The memory receives addresses and read/write control signals from the memory controller.

### `top_system.v`

The top-level system module that connects the CPU, memory controller, and memory into a complete system.

```text
CPU
 │
 ▼
Memory Controller
 │
 ▼
Memory
```

---

# Verification

Verification was performed using simulation-based Verilog testbenches.

The project contains two verification environments:

1. Memory Controller Testbench
2. Complete System Testbench

---

## Memory Controller Verification

### Testbench

```text
TestBenches/memory_controller_tb.v
```

The memory controller testbench focuses on verifying the controller independently.

The verification covers functional behavior such as:

- Asynchronous reset
- Initial controller state
- Controller ready behavior
- Read requests
- Write requests
- Read data handling
- Read-valid signaling
- Write completion signaling
- Memory interface control
- Simultaneous read/write requests
- Write-priority behavior
- Pending read requests
- FSM state transitions

The testbench provides stimulus to the controller and observes its outputs to determine whether the expected behavior occurs.

---

## System-Level Verification

### Testbench

```text
TestBenches/top_system_tb.v
```

The system-level testbench verifies the interaction between the complete system components:

```text
┌──────────────┐
│  Simple CPU  │
└──────┬───────┘
       │
       ▼
┌─────────────────────┐
│  Memory Controller  │
└──────────┬──────────┘
           │
           ▼
     ┌──────────┐
     │  Memory  │
     └──────────┘
```

System-level verification checks that requests and responses propagate correctly across the complete design.

The verification includes:

- CPU request generation
- Controller request acceptance
- Read transactions
- Write transactions
- Memory data storage
- Memory data retrieval
- Controller response generation
- CPU/controller synchronization
- Correct behavior of the complete integrated system

---

## Verification Flow

The general simulation and verification process is:

```text
                    Testbench
                       │
                       ▼
                Generate Stimulus
                       │
                       ▼
                CPU / Controller
                       │
                       ▼
                    Memory
                       │
                       ▼
                Generate Response
                       │
                       ▼
               Observe DUT Outputs
                       │
                       ▼
              Analyze Waveforms
                       │
                       ▼
             Verify Expected Behavior
```

Simulation waveforms can be used to inspect:

- Clock and reset behavior
- Controller state transitions
- CPU requests
- Memory addresses
- Read/write enable signals
- Write data
- Read data
- Ready signaling
- Read-valid signaling
- Write-done signaling
- Request sequencing

---

## Design Concepts Demonstrated

This project demonstrates practical application of several digital design concepts.

### RTL Design

The hardware system is described using Verilog RTL modules.

### Finite-State Machines

The memory controller uses multiple states to sequence memory transactions.

### Synchronous Digital Design

The controller operates according to clocked state transitions and memory operations.

### Request Arbitration

The controller handles simultaneous read and write requests by assigning priority to writes.

### Pending Requests

A read request can be retained when a simultaneous write request must be processed first.

### CPU–Memory Interface

The controller provides an interface between CPU-generated requests and memory operations.

### Reset Design

An asynchronous active-low reset initializes the controller to its idle state.

### Functional Verification

Dedicated testbenches are used to verify individual RTL modules and the complete integrated system.

---

## Project Structure

```text
Simplified-Memory-Controller-Design-Verification-Verilog/
│
├── RTL/
│   ├── cpu.v
│   ├── memory.v
│   ├── memory_controller.v
│   └── top_system.v
│
├── TestBenches/
│   ├── memory_controller_tb.v
│   └── top_system_tb.v
│
├── Report.pdf
├── README.md
└── .gitignore
```

---

## Technologies

- **Verilog HDL**
- **RTL Design**
- **Digital Logic Design**
- **Finite State Machines**
- **Synchronous Design**
- **Memory Controller Design**
- **CPU–Memory Interfaces**
- **Testbench Development**
- **Simulation-Based Verification**
- **Functional Verification**
- **Waveform Analysis**
- **RTL Debugging**
- **Git**
- **GitHub**

---

## Skills Demonstrated

Through this project, the following engineering skills were developed and applied:

- RTL hardware design
- FSM implementation
- Digital system architecture
- Hardware interface design
- Request arbitration
- Simulation-based verification
- Testbench development
- Functional debugging
- Waveform analysis
- Module-level verification
- System-level verification
- Technical documentation

---

## Project Deliverables

The repository contains:

### RTL Source Code

The complete Verilog implementation of:

- CPU model
- Memory
- Memory controller
- Top-level system

### Verification Environment

Dedicated testbenches for:

- Memory controller
- Complete system

### Documentation

The complete project report is included as:

```text
Report.pdf
```

---

## Academic Information

**Course:** ENCS3310 — Advanced Digital Systems Design

**Department:** Electrical & Computer Engineering

**Institution:** Birzeit University

**Project:** Design and Verification of a Simplified Memory Controller

**Semester:** Second Summer Course — 2024/2025

**Project Type:** Individual

---

## Author

**Batol Abu Samhadana**

Computer Engineering Student  
Birzeit University

- [LinkedIn](https://linkedin.com/in/batolabusamhadana)
- [GitHub](https://github.com/batolabusamhadana)

---

## Disclaimer

This repository contains an academic project developed for educational purposes as part of the ENCS3310 Advanced Digital Systems Design course at Birzeit University.
