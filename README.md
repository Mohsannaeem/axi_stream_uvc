# axi_stream_uvc

AXI4-Stream / AXI5-Stream UVM Verification IP — **AI-generated, simulation-verified.**

This repository contains two complete UVM testbenches:

| Component | Role | Test Cases | Result |
|-----------|------|-----------|--------|
| `axi_stream_master_vip_tb/` | Master VIP (drives bus) | 48 directed TCs | **48/48 PASS** |
| `axi_stream_slave_vip_tb/` | Slave VIP (receives bus) | 46 directed TCs | Plan complete |

Both were generated autonomously by the [verification_ai_skills](https://github.com/Mohsannaeem/verification_ai_skills) agent pipeline from the AMBA AXI5-Stream specification PDF — zero human-written SystemVerilog.

---

## Repository Layout

```
axi_stream_uvc/
│
├── axi_stream_master_vip_tb/          ← Master VIP source
│   ├── top/
│   │   ├── axi_stream_master_vip_defines.sv   ← all `define macros (widths, feature flags)
│   │   ├── axi_stream_master_vip_if.sv        ← interface + clocking blocks
│   │   ├── axi_stream_master_vip_pkg.sv        ← package (includes all files in order)
│   │   ├── axi_stream_master_vip_tb_top.sv     ← simulation top (clock, reset, DUT stub)
│   │   └── axi_stream_master_vip_test.sv       ← base test + 48 test classes
│   ├── master_agent/
│   │   ├── axi_stream_master_vip_driver.sv
│   │   ├── axi_stream_master_vip_monitor.sv
│   │   ├── axi_stream_master_vip_sequencer.sv
│   │   ├── axi_stream_master_vip_agent.sv
│   │   ├── axi_stream_master_vip_agent_config.sv
│   │   └── axi_stream_master_vip_callback.sv
│   ├── env/
│   │   ├── axi_stream_master_vip_scoreboard.sv
│   │   ├── axi_stream_master_vip_env.sv
│   │   └── axi_stream_master_vip_env_config.sv
│   ├── sequences/
│   │   ├── axi_stream_master_vip_seq_item.sv
│   │   ├── axi_stream_master_vip_base_sequence.sv
│   │   └── axi_stream_master_vip_test_sequences.sv
│   └── yamls/                                  ← EDA Buddy manifests (optional)
│       ├── axi_stream_master_vip_build.yaml
│       └── axi_stream_master_vip_run.yaml
│
├── axi_stream_slave_vip_tb/           ← Slave VIP source (same structure)
│   ├── top/
│   ├── slave_agent/
│   ├── env/
│   ├── sequences/
│   └── yamls/
│
└── sim/
    ├── Makefile                        ← portable sim driver (questa / vcs / xcelium)
    └── filelists/
        ├── axi_stream_master_vip.f     ← compile filelist for master VIP
        └── axi_stream_slave_vip.f     ← compile filelist for slave VIP
```

---

## Prerequisites

- **SystemVerilog simulator**: QuestaSim 2021.1+ (tested), VCS, or Xcelium
- **UVM**: QuestaSim built-in UVM 1.1d — **do not** compile `uvm_pkg.sv` separately
- **Shell**: bash (Git Bash on Windows, native on Linux/Mac)
- **Make**: GNU make 4.x+

---

## Option A — Using EDA Buddy (recommended if using verification_ai_skills)

If you cloned this repo as a submodule of `verification_ai_skills`, EDA Buddy manages
all paths for you. From the parent repo root:

```bash
# Regenerate Makefile with your local absolute paths
python eda_buddy/eda_buddy.py --gen-makefile

# Build the master VIP
make -f run/Makefile questa_build_axi_stream_master_vip

# Run a single test
make -f run/Makefile questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test

# Run the full 48-test regression
python .agent/skills/uvc_orchestrator/scripts/run_regression.py \
    --makefile run/Makefile \
    --component axi_stream_master_vip \
    --tool questa
```

EDA Buddy writes build artifacts to `run/axi_stream_master_vip/{build,work,run}/`.
The YAML manifests in `yamls/` declare all 48 test entry points and regression groups.

---

## Option B — Standalone (no EDA Buddy)

Only **two variables** in `sim/Makefile` may need editing. Everything else is
auto-derived from those two.

### Step 1 — Edit `sim/Makefile` (if auto-detection fails)

Open `sim/Makefile` and find the **USER VARIABLES** section near the top:

```makefile
## ============================================================
## USER VARIABLES — the only section you may need to edit
## ============================================================

## [EDIT ME] Full path to the root of this repository.
REPO_ROOT ?= $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

## [EDIT ME] Where simulator work libraries and run logs are written.
SIM_WORK_ROOT ?= $(REPO_ROOT)/sim/work
```

**What each variable controls:**

| Variable | Default | When to change |
|----------|---------|----------------|
| `REPO_ROOT` | Auto-detected from Makefile location | If `$(abspath ...)` doesn't resolve correctly on your OS/shell. Set an absolute path. |
| `SIM_WORK_ROOT` | `<repo>/sim/work` | If you want build artifacts (compiled libraries, logs) outside the repo — e.g. on a fast scratch disk. |

**Example for Windows (Git Bash):**
```makefile
REPO_ROOT     := D:/projects/axi_stream_uvc
SIM_WORK_ROOT := D:/scratch/axi_stream_uvc_work
```

**Example for Linux:**
```makefile
REPO_ROOT     := /home/user/projects/axi_stream_uvc
SIM_WORK_ROOT := /scratch/user/axi_stream_uvc_work
```

> All other paths (`FLIST_DIR`, `*_SRC_DIR`, `*_WORK_DIR`, `*_BUILD_DIR`, `*_RUN_DIR`) are derived automatically from these two variables. You do **not** need to touch them.

---

### Step 2 — Build

```bash
cd axi_stream_uvc/sim

# QuestaSim
make questa_build_axi_stream_master_vip

# VCS
make vcs_build_axi_stream_master_vip
```

What the build does:
1. `vlib` — creates the QuestaSim work library at `$SIM_WORK_ROOT/axi_stream_master_vip/work/`
2. `vlog` — compiles all SV files listed in `sim/filelists/axi_stream_master_vip.f`
3. `vopt` — elaborates `axi_stream_master_vip_tb_top` into `db_opt`

---

### Step 3 — Run a single test

```bash
# Run TC_001 (TVALID stability, single beat)
make questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test

# Run with waveform dump
make questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test WAVES=1

# Run in GUI
make questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test GUI=1
```

Log lands at: `$SIM_WORK_ROOT/axi_stream_master_vip/run/axi_stream_master_vip_tc_mst_001_test/run_<timestamp>/sim.log`

---

### Step 4 — Run the full regression

```bash
# Quick script: loop all 48 master tests
for i in $(seq -w 1 48); do
    make questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_$(printf "%03d" $i)_test
done

# Or run 8 tests in parallel
seq -w 1 48 | xargs -P 8 -I{} \
    make questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_{}_test
```

---

## All Available Make Targets

### Master VIP (`axi_stream_master_vip`)

| Target pattern | Tool | Description |
|---------------|------|-------------|
| `questa_build_axi_stream_master_vip` | QuestaSim | Compile + elaborate |
| `vcs_build_axi_stream_master_vip` | VCS | Compile + elaborate |
| `questa_run_axi_stream_master_vip_<TC_NAME>` | QuestaSim | Run one test |
| `vcs_run_axi_stream_master_vip_<TC_NAME>` | VCS | Run one test |
| `xcelium_run_axi_stream_master_vip_<TC_NAME>` | Xcelium | Run one test |

Test names follow the pattern `axi_stream_master_vip_tc_mst_NNN_test` where `NNN` is `001`–`048`.

### Slave VIP (`axi_stream_slave_vip`)

Same pattern replacing `master_vip` with `slave_vip` and `mst` with `slv`.

---

## How the Filelist Works

`sim/filelists/axi_stream_master_vip.f` uses an environment variable for portability:

```
+incdir+${AXI_STREAM_MASTER_VIP_SRC_DIR}/top
+incdir+${AXI_STREAM_MASTER_VIP_SRC_DIR}/master_agent
+incdir+${AXI_STREAM_MASTER_VIP_SRC_DIR}/sequences
+incdir+${AXI_STREAM_MASTER_VIP_SRC_DIR}/env
${AXI_STREAM_MASTER_VIP_SRC_DIR}/top/axi_stream_master_vip_if.sv
${AXI_STREAM_MASTER_VIP_SRC_DIR}/top/axi_stream_master_vip_pkg.sv
${AXI_STREAM_MASTER_VIP_SRC_DIR}/top/axi_stream_master_vip_tb_top.sv
```

`AXI_STREAM_MASTER_VIP_SRC_DIR` is exported by the Makefile as `$(REPO_ROOT)/axi_stream_master_vip_tb`.
The simulator expands `${VAR}` in the filelist at runtime. This means the filelist
itself never contains a hardcoded path — only the two Makefile variables do.

If you compile manually (without make), export the variable first:

```bash
export AXI_STREAM_MASTER_VIP_SRC_DIR=/path/to/axi_stream_uvc/axi_stream_master_vip_tb
vlog -sv -mfcu -timescale 1ns/1ps -f sim/filelists/axi_stream_master_vip.f
```

---

## Key Design Decisions

**Why `\`define` macros instead of `parameter`?**
All width and feature-flag knobs live in `axi_stream_master_vip_defines.sv` as `` `define ``
macros. They are globally visible across all files without package-scope qualifiers,
which avoids "undefined variable" errors when files are compiled in any order.

**Why timescale 1ns/1ps and `UVM_TIMEOUT=100000000`?**
`$time` in QuestaSim with `\`timescale 1ns/1ps` returns values in picoseconds.
`+UVM_TIMEOUT=100000000` is therefore 100 µs — enough headroom for the longest
test (TC_048: 15 packets × 8 beats max = ~1.2 µs). Setting it in nanoseconds
(e.g. `5000000`) would time out at 5 µs, killing most multi-packet tests.

**Why no explicit clocking block skew?**
The interface uses default edge-based sampling (no `#1step` output skew override).
An explicit `#1step` skew creates a 1ps window where monitor sampling at posedge-1step
races with driver output that doesn't propagate until posedge+1ps. Relying on
simulator defaults avoids this false-positive stability violation.

---

## Generated By

This UVC was generated autonomously by the [verification_ai_skills](https://github.com/Mohsannaeem/verification_ai_skills)
agent pipeline:

```
AMBA AXI5-Stream Spec PDF
        │  uvc_planning skill (LlamaIndex RAG + Claude)
        ▼
  verif_plan_axi_stream_master_vip_v1_0.yaml   (12 REQs, 48 TCs)
        │  uvc_generator skill
        ▼
  axi_stream_master_vip_tb/   (17 SV files)
        │  eda_yaml_generator skill
        ▼
  sim/Makefile + sim/filelists/
        │  uvc_orchestrator skill (QuestaSim 2021.1)
        ▼
  Regression: 48/48 PASS
```
