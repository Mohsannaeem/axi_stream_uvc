## AXI-Stream UVC â€” Simulation Makefile
## Supports QuestaSim (questa_*), VCS (vcs_*), Xcelium (xcelium_*)
##
## ============================================================
## QUICK START â€” read this section before running anything
## ============================================================
##
## OPTION A â€” EDA Buddy users (verification_ai_skills repo)
##   Re-run EDA Buddy from the parent repo to regenerate this
##   file with your local paths automatically. No manual edits needed.
##     cd <verification_ai_skills>/
##     python eda_buddy/eda_buddy.py --gen-makefile
##
## OPTION B â€” Standalone (no EDA Buddy)
##   Edit the two lines tagged [EDIT ME] in the USER VARIABLES
##   section below, then run:
##     make questa_build_axi_stream_master_vip
##     make questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test
##
## ============================================================
## USER VARIABLES â€” the only section you may need to edit
## ============================================================

SHELL      := /bin/bash
.SHELLFLAGS := -o pipefail -c

## [EDIT ME] Full path to the root of this repository.
## Default: auto-detected from this Makefile's location (works on Linux/Mac/Git-Bash).
## If auto-detection fails on your system, set it explicitly, e.g.:
##   REPO_ROOT := /home/user/projects/axi_stream_uvc
##   REPO_ROOT := C:/Users/you/projects/axi_stream_uvc
REPO_ROOT ?= $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

## [EDIT ME] Where simulator work libraries and run logs are written.
## Default: sim/work/ inside the repo. Change to any writable path outside
## the repo if you don't want build artifacts mixed with source.
##   SIM_WORK_ROOT := /scratch/$(USER)/axi_stream_uvc_work
SIM_WORK_ROOT ?= $(REPO_ROOT)/sim/work

## ============================================================
## DERIVED PATHS â€” no edits needed below this line
## ============================================================
ROOT      := $(SIM_WORK_ROOT)
FLIST_DIR := $(REPO_ROOT)/sim/filelists

## Disable EDA Buddy report/push scripts (not available standalone).
## The targets already guard these with 'if [ -f "$(REPORT_SCRIPT)" ]'
## so setting them empty causes a silent skip.
REPORT_SCRIPT :=
PUSH_SCRIPT   :=

## -- Component path variables (build/work/run derive from ROOT) --
AXI_STREAM_MASTER_VIP_BUILD_DIR := $(ROOT)/axi_stream_master_vip/build
AXI_STREAM_MASTER_VIP_WORK_DIR  := $(ROOT)/axi_stream_master_vip/work
AXI_STREAM_MASTER_VIP_RUN_DIR   := $(ROOT)/axi_stream_master_vip/run
AXI_STREAM_MASTER_VIP_SRC_DIR   := $(REPO_ROOT)/axi_stream_master_vip_tb

AXI_STREAM_SLAVE_VIP_BUILD_DIR  := $(ROOT)/axi_stream_slave_vip/build
AXI_STREAM_SLAVE_VIP_WORK_DIR   := $(ROOT)/axi_stream_slave_vip/work
AXI_STREAM_SLAVE_VIP_RUN_DIR    := $(ROOT)/axi_stream_slave_vip/run
AXI_STREAM_SLAVE_VIP_SRC_DIR    := $(REPO_ROOT)/axi_stream_slave_vip_tb

## -- Export source dirs so EDA tools expand ${VAR} in filelists --
export AXI_STREAM_MASTER_VIP_SRC_DIR
export AXI_STREAM_SLAVE_VIP_SRC_DIR

## ======================================================
## COMPONENT: axi_stream_master_vip
## ======================================================
axi_stream_master_vip_FLIST := $(FLIST_DIR)/axi_stream_master_vip.f
axi_stream_master_vip_TOP   := axi_stream_master_vip_tb_top

vcs_build_axi_stream_master_vip:
	@mkdir -p $(AXI_STREAM_MASTER_VIP_BUILD_DIR)
	@echo "[VCS] Building axi_stream_master_vip — log: $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/vcs.log"
	vlogan -sverilog -full64 -debug_access+all -lca -kdb +v2k -work axi_stream_master_vip_lib -f $(axi_stream_master_vip_FLIST) 2>&1 | tee $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/vcs.log && \
	vcs -top axi_stream_master_vip_tb_top -o $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv -Mdir=$(AXI_STREAM_MASTER_VIP_BUILD_DIR)/csrc 2>&1 | tee -a $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/vcs.log

questa_build_axi_stream_master_vip:
	@mkdir -p $(AXI_STREAM_MASTER_VIP_BUILD_DIR) $(AXI_STREAM_MASTER_VIP_WORK_DIR)
	@echo "[QUESTA] Building axi_stream_master_vip — log: $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/questa.log"
	vlib $(AXI_STREAM_MASTER_VIP_WORK_DIR) 2>&1 | tee $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/questa.log && \
	vlog -work $(AXI_STREAM_MASTER_VIP_WORK_DIR) -sv -mfcu -timescale 1ns/1ps -f $(axi_stream_master_vip_FLIST) 2>&1 | tee -a $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/questa.log && \
	vopt +acc axi_stream_master_vip_tb_top -o db_opt -work $(AXI_STREAM_MASTER_VIP_WORK_DIR) 2>&1 | tee -a $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/questa.log

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_001_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_001_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_001_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_001_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_001_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_001_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_001_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_001_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_001_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_001_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_001_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_001_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_001_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_001_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_001_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_001_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_001_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_001_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_002_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_002_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_002_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_002_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_002_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_002_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_002_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_002_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_002_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_002_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_002_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_002_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_002_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_002_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_002_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_002_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_002_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_002_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_002_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_002_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_002_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_003_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_003_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_003_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_003_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_003_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_003_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_003_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_003_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_003_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_003_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_003_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_003_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_003_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_003_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_003_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_003_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_003_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_003_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_003_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_003_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_003_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_004_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_004_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_004_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_004_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_004_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_004_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_004_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_004_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_004_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_004_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_004_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_004_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_004_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_004_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_004_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_004_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_004_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_004_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_004_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_004_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_004_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_005_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_005_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_005_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_005_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_005_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_005_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_005_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_005_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_005_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_005_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_005_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_005_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_005_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_005_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_005_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_005_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_005_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_005_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_006_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_006_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_006_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_006_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_006_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_006_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_006_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_006_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_006_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_006_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_006_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_006_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_006_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_006_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_006_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_006_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_006_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_006_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_006_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_006_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_006_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_007_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_007_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_007_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_007_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_007_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_007_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_007_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_007_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_007_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_007_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_007_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_007_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_007_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_007_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_007_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_007_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_007_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_007_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_007_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_007_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_007_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_008_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_008_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_008_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_008_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_008_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_008_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_008_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_008_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_008_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_008_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_008_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_008_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_008_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_008_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_008_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_008_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_008_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_008_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_008_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_008_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_008_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_009_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_009_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_009_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_009_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_009_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_009_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_009_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_009_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_009_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_009_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_009_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_009_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_009_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_009_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_009_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_009_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_009_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_009_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_010_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_010_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_010_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_010_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_010_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_010_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_010_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_010_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_010_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_010_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_010_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_010_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_010_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_010_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_010_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_010_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_010_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_010_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_010_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_010_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_010_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_011_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_011_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_011_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_011_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_011_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_011_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_011_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_011_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_011_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_011_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_011_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_011_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_011_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_011_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_011_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_011_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_011_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_011_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_011_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_011_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_011_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_012_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_012_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_012_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_012_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_012_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_012_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_012_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_012_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_012_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_012_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_012_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_012_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_012_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_012_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_012_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_012_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_012_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_012_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_012_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_012_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_012_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_013_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_013_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_013_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_013_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_013_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_013_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_013_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_013_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_013_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_013_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_013_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_013_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_013_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_013_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_013_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_013_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_013_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_013_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_014_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_014_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_014_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_014_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_014_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_014_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_014_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_014_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_014_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_014_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_014_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_014_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_014_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_014_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_014_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_014_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_014_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_014_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_014_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_014_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_014_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_015_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_015_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_015_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_015_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_015_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_015_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_015_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_015_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_015_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_015_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_015_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_015_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_015_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_015_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_015_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_015_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_015_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_015_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_015_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_015_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_015_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_016_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_016_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_016_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_016_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_016_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_016_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_016_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_016_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_016_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_016_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_016_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_016_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_016_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_016_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_016_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_016_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_016_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_016_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_016_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_016_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_016_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_017_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_017_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_017_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_017_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_017_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_017_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_017_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_017_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_017_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_017_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_017_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_017_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_017_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_017_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_017_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_017_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_017_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_017_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_018_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_018_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_018_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_018_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_018_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_018_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_018_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_018_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_018_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_018_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_018_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_018_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_018_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_018_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_018_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_018_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_018_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_018_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_018_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_018_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_018_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_019_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_019_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_019_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_019_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_019_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_019_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_019_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_019_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_019_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_019_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_019_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_019_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_019_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_019_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_019_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_019_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_019_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_019_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_019_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_019_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_019_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_020_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_020_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_020_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_020_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_020_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_020_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_020_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_020_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_020_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_020_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_020_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_020_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_020_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_020_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_020_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_020_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_020_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_020_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_020_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_020_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_020_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_021_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_021_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_021_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_021_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_021_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_021_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_021_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_021_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_021_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_021_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_021_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_021_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_021_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_021_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_021_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_021_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_021_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_021_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_022_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_022_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_022_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_022_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_022_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_022_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_022_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_022_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_022_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_022_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_022_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_022_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_022_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_022_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_022_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_022_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_022_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_022_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_022_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_022_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_022_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_023_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_023_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_023_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_023_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_023_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_023_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_023_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_023_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_023_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_023_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_023_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_023_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_023_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_023_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_023_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_023_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_023_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_023_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_023_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_023_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_023_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_024_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_024_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_024_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_024_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_024_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_024_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_024_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_024_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_024_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_024_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_024_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_024_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_024_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_024_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_024_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_024_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_024_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_024_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_024_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_024_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_024_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_025_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_025_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_025_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_025_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_025_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_025_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_025_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_025_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_025_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_025_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_025_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_025_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_025_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_025_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_025_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_025_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_025_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_025_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_025_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_025_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_025_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_026_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_026_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_026_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_026_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_026_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_026_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_026_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_026_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_026_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_026_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_026_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_026_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_026_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_026_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_026_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_026_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_026_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_026_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_026_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_026_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_026_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_027_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_027_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_027_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_027_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_027_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_027_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_027_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_027_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_027_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_027_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_027_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_027_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_027_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_027_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_027_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_027_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_027_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_027_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_027_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_027_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_027_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_028_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_028_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_028_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_028_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_028_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_028_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_028_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_028_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_028_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_028_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_028_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_028_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_028_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_028_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_028_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_028_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_028_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_028_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_028_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_028_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_028_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_029_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_029_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_029_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_029_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_029_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_029_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_029_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_029_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_029_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_029_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_029_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_029_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_029_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_029_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_029_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_029_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_029_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_029_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_029_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_029_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_029_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_030_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_030_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_030_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_030_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_030_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_030_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_030_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_030_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_030_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_030_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_030_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_030_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_030_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_030_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_030_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_030_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_030_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_030_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_030_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_030_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_030_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_031_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_031_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_031_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_031_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_031_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_031_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_031_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_031_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_031_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_031_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_031_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_031_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_031_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_031_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_031_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_031_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_031_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_031_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_031_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_031_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_031_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_032_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_032_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_032_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_032_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_032_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_032_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_032_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_032_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_032_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_032_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_032_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_032_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_032_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_032_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_032_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_032_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_032_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_032_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_032_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_032_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_032_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_033_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_033_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_033_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_033_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_033_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_033_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_033_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_033_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_033_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_033_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_033_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_033_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_033_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_033_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_033_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_033_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_033_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_033_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_033_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_033_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_033_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_034_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_034_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_034_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_034_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_034_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_034_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_034_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_034_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_034_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_034_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_034_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_034_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_034_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_034_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_034_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_034_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_034_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_034_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_034_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_034_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_034_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_035_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_035_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_035_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_035_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_035_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_035_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_035_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_035_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_035_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_035_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_035_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_035_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_035_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_035_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_035_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_035_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_035_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_035_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_035_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_035_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_035_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_036_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_036_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_036_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_036_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_036_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_036_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_036_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_036_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_036_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_036_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_036_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_036_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_036_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_036_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_036_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_036_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_036_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_036_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_036_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_036_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_036_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_037_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_037_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_037_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_037_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_037_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_037_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_037_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_037_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_037_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_037_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_037_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_037_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_037_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_037_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_037_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_037_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_037_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_037_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_038_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_038_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_038_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_038_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_038_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_038_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_038_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_038_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_038_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_038_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_038_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_038_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_038_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_038_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_038_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_038_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_038_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_038_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_038_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_038_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_038_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_039_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_039_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_039_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_039_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_039_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_039_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_039_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_039_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_039_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_039_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_039_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_039_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_039_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_039_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_039_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_039_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_039_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_039_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_039_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_039_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_039_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_040_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_040_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_040_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_040_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_040_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_040_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_040_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_040_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_040_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_040_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_040_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_040_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_040_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_040_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_040_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_040_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_040_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_040_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_040_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_040_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_040_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_041_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_041_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_041_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_041_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_041_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_041_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_041_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_041_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_041_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_041_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_041_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_041_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_041_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_041_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_041_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_041_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_041_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_041_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_042_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_042_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_042_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_042_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_042_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_042_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_042_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_042_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_042_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_042_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_042_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_042_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_042_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_042_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_042_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_042_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_042_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_042_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_042_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_042_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_042_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_043_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_043_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_043_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_043_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_043_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_043_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_043_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_043_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_043_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_043_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_043_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_043_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_043_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_043_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_043_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_043_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_043_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_043_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_043_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_043_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_043_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_044_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_044_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_044_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_044_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_044_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_044_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_044_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_044_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_044_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_044_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_044_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_044_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_044_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_044_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_044_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_044_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_044_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_044_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_044_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_044_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_044_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_045_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_045_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_045_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_045_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_045_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_045_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_045_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_045_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_045_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_045_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_045_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_045_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_045_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_045_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_045_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_045_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_045_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_045_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_045_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_045_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_045_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_046_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_046_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_046_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_046_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_046_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_046_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_046_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_046_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_046_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_046_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_046_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_046_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_046_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_046_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_046_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_046_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_046_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_046_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_047_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_047_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_047_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_047_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_047_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_047_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_047_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_047_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_047_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_047_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_047_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_047_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_047_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_047_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_047_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_047_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_047_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_047_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_047_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_047_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_047_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_048_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_048_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_048_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_048_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_master_vip_tc_mst_048_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_master_vip_tc_mst_048_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_048_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_048_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_048_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_048_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_048_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_master_vip_tc_mst_048_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_MASTER_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_master_vip_tc_mst_048_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_048_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_048_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_master_vip_tc_mst_048_test; else mkdir -p $(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_048_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_MASTER_VIP_RUN_DIR)/axi_stream_master_vip_tc_mst_048_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_master_vip_tc_mst_048_test"; \
	 $(AXI_STREAM_MASTER_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_master_vip_tc_mst_048_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_master_vip_tc_mst_048_test --total $(if $(TOTAL),$(TOTAL),48) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

.PHONY: vcs_run_axi_stream_master_vip_smoke_test
vcs_run_axi_stream_master_vip_smoke_test:
	@REGDIR="$(AXI_STREAM_MASTER_VIP_RUN_DIR)/smoke_test_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[SMOKE_TEST] Session dir: $$REGDIR  Total=9 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=9 vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_master_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_master_vip_tc_mst_001_test,axi_stream_master_vip_tc_mst_005_test,axi_stream_master_vip_tc_mst_009_test,axi_stream_master_vip_tc_mst_013_test,axi_stream_master_vip_tc_mst_017_test,axi_stream_master_vip_tc_mst_021_test,axi_stream_master_vip_tc_mst_037_test,axi_stream_master_vip_tc_mst_041_test,axi_stream_master_vip_tc_mst_046_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_MASTER_SMOKE_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: questa_run_axi_stream_master_vip_smoke_test
questa_run_axi_stream_master_vip_smoke_test:
	@REGDIR="$(AXI_STREAM_MASTER_VIP_RUN_DIR)/smoke_test_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[SMOKE_TEST] Session dir: $$REGDIR  Total=9 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=9 questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_master_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_master_vip_tc_mst_001_test,axi_stream_master_vip_tc_mst_005_test,axi_stream_master_vip_tc_mst_009_test,axi_stream_master_vip_tc_mst_013_test,axi_stream_master_vip_tc_mst_017_test,axi_stream_master_vip_tc_mst_021_test,axi_stream_master_vip_tc_mst_037_test,axi_stream_master_vip_tc_mst_041_test,axi_stream_master_vip_tc_mst_046_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_MASTER_SMOKE_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: xcelium_run_axi_stream_master_vip_smoke_test
xcelium_run_axi_stream_master_vip_smoke_test:
	@REGDIR="$(AXI_STREAM_MASTER_VIP_RUN_DIR)/smoke_test_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[SMOKE_TEST] Session dir: $$REGDIR  Total=9 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=9 xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_master_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_master_vip_tc_mst_001_test,axi_stream_master_vip_tc_mst_005_test,axi_stream_master_vip_tc_mst_009_test,axi_stream_master_vip_tc_mst_013_test,axi_stream_master_vip_tc_mst_017_test,axi_stream_master_vip_tc_mst_021_test,axi_stream_master_vip_tc_mst_037_test,axi_stream_master_vip_tc_mst_041_test,axi_stream_master_vip_tc_mst_046_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_MASTER_SMOKE_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: vcs_run_axi_stream_master_vip_regression
vcs_run_axi_stream_master_vip_regression:
	@REGDIR="$(AXI_STREAM_MASTER_VIP_RUN_DIR)/regression_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[REGRESSION] Session dir: $$REGDIR  Total=37 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=37 vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_002_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_003_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_007_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_010_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_011_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_012_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_014_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_015_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_016_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_018_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_019_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_022_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_023_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_025_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_026_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_027_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_030_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_031_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_032_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_033_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_034_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_039_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_040_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_042_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_043_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_044_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_047_test vcs_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_048_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_master_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_master_vip_tc_mst_001_test,axi_stream_master_vip_tc_mst_002_test,axi_stream_master_vip_tc_mst_003_test,axi_stream_master_vip_tc_mst_005_test,axi_stream_master_vip_tc_mst_007_test,axi_stream_master_vip_tc_mst_009_test,axi_stream_master_vip_tc_mst_010_test,axi_stream_master_vip_tc_mst_011_test,axi_stream_master_vip_tc_mst_012_test,axi_stream_master_vip_tc_mst_013_test,axi_stream_master_vip_tc_mst_014_test,axi_stream_master_vip_tc_mst_015_test,axi_stream_master_vip_tc_mst_016_test,axi_stream_master_vip_tc_mst_017_test,axi_stream_master_vip_tc_mst_018_test,axi_stream_master_vip_tc_mst_019_test,axi_stream_master_vip_tc_mst_021_test,axi_stream_master_vip_tc_mst_022_test,axi_stream_master_vip_tc_mst_023_test,axi_stream_master_vip_tc_mst_025_test,axi_stream_master_vip_tc_mst_026_test,axi_stream_master_vip_tc_mst_027_test,axi_stream_master_vip_tc_mst_030_test,axi_stream_master_vip_tc_mst_031_test,axi_stream_master_vip_tc_mst_032_test,axi_stream_master_vip_tc_mst_033_test,axi_stream_master_vip_tc_mst_034_test,axi_stream_master_vip_tc_mst_037_test,axi_stream_master_vip_tc_mst_039_test,axi_stream_master_vip_tc_mst_040_test,axi_stream_master_vip_tc_mst_041_test,axi_stream_master_vip_tc_mst_042_test,axi_stream_master_vip_tc_mst_043_test,axi_stream_master_vip_tc_mst_044_test,axi_stream_master_vip_tc_mst_046_test,axi_stream_master_vip_tc_mst_047_test,axi_stream_master_vip_tc_mst_048_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_MASTER_FULL_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: questa_run_axi_stream_master_vip_regression
questa_run_axi_stream_master_vip_regression:
	@REGDIR="$(AXI_STREAM_MASTER_VIP_RUN_DIR)/regression_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[REGRESSION] Session dir: $$REGDIR  Total=37 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=37 questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_002_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_003_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_007_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_010_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_011_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_012_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_014_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_015_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_016_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_018_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_019_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_022_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_023_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_025_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_026_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_027_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_030_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_031_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_032_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_033_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_034_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_039_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_040_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_042_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_043_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_044_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_047_test questa_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_048_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_master_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_master_vip_tc_mst_001_test,axi_stream_master_vip_tc_mst_002_test,axi_stream_master_vip_tc_mst_003_test,axi_stream_master_vip_tc_mst_005_test,axi_stream_master_vip_tc_mst_007_test,axi_stream_master_vip_tc_mst_009_test,axi_stream_master_vip_tc_mst_010_test,axi_stream_master_vip_tc_mst_011_test,axi_stream_master_vip_tc_mst_012_test,axi_stream_master_vip_tc_mst_013_test,axi_stream_master_vip_tc_mst_014_test,axi_stream_master_vip_tc_mst_015_test,axi_stream_master_vip_tc_mst_016_test,axi_stream_master_vip_tc_mst_017_test,axi_stream_master_vip_tc_mst_018_test,axi_stream_master_vip_tc_mst_019_test,axi_stream_master_vip_tc_mst_021_test,axi_stream_master_vip_tc_mst_022_test,axi_stream_master_vip_tc_mst_023_test,axi_stream_master_vip_tc_mst_025_test,axi_stream_master_vip_tc_mst_026_test,axi_stream_master_vip_tc_mst_027_test,axi_stream_master_vip_tc_mst_030_test,axi_stream_master_vip_tc_mst_031_test,axi_stream_master_vip_tc_mst_032_test,axi_stream_master_vip_tc_mst_033_test,axi_stream_master_vip_tc_mst_034_test,axi_stream_master_vip_tc_mst_037_test,axi_stream_master_vip_tc_mst_039_test,axi_stream_master_vip_tc_mst_040_test,axi_stream_master_vip_tc_mst_041_test,axi_stream_master_vip_tc_mst_042_test,axi_stream_master_vip_tc_mst_043_test,axi_stream_master_vip_tc_mst_044_test,axi_stream_master_vip_tc_mst_046_test,axi_stream_master_vip_tc_mst_047_test,axi_stream_master_vip_tc_mst_048_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_MASTER_FULL_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: xcelium_run_axi_stream_master_vip_regression
xcelium_run_axi_stream_master_vip_regression:
	@REGDIR="$(AXI_STREAM_MASTER_VIP_RUN_DIR)/regression_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[REGRESSION] Session dir: $$REGDIR  Total=37 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=37 xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_001_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_002_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_003_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_005_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_007_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_009_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_010_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_011_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_012_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_013_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_014_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_015_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_016_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_017_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_018_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_019_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_021_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_022_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_023_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_025_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_026_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_027_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_030_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_031_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_032_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_033_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_034_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_037_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_039_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_040_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_041_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_042_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_043_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_044_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_046_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_047_test xcelium_run_axi_stream_master_vip_axi_stream_master_vip_tc_mst_048_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_master_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_master_vip_tc_mst_001_test,axi_stream_master_vip_tc_mst_002_test,axi_stream_master_vip_tc_mst_003_test,axi_stream_master_vip_tc_mst_005_test,axi_stream_master_vip_tc_mst_007_test,axi_stream_master_vip_tc_mst_009_test,axi_stream_master_vip_tc_mst_010_test,axi_stream_master_vip_tc_mst_011_test,axi_stream_master_vip_tc_mst_012_test,axi_stream_master_vip_tc_mst_013_test,axi_stream_master_vip_tc_mst_014_test,axi_stream_master_vip_tc_mst_015_test,axi_stream_master_vip_tc_mst_016_test,axi_stream_master_vip_tc_mst_017_test,axi_stream_master_vip_tc_mst_018_test,axi_stream_master_vip_tc_mst_019_test,axi_stream_master_vip_tc_mst_021_test,axi_stream_master_vip_tc_mst_022_test,axi_stream_master_vip_tc_mst_023_test,axi_stream_master_vip_tc_mst_025_test,axi_stream_master_vip_tc_mst_026_test,axi_stream_master_vip_tc_mst_027_test,axi_stream_master_vip_tc_mst_030_test,axi_stream_master_vip_tc_mst_031_test,axi_stream_master_vip_tc_mst_032_test,axi_stream_master_vip_tc_mst_033_test,axi_stream_master_vip_tc_mst_034_test,axi_stream_master_vip_tc_mst_037_test,axi_stream_master_vip_tc_mst_039_test,axi_stream_master_vip_tc_mst_040_test,axi_stream_master_vip_tc_mst_041_test,axi_stream_master_vip_tc_mst_042_test,axi_stream_master_vip_tc_mst_043_test,axi_stream_master_vip_tc_mst_044_test,axi_stream_master_vip_tc_mst_046_test,axi_stream_master_vip_tc_mst_047_test,axi_stream_master_vip_tc_mst_048_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_MASTER_FULL_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

## ======================================================
## COMPONENT: axi_stream_slave_vip
## ======================================================
axi_stream_slave_vip_FLIST := $(FLIST_DIR)/axi_stream_slave_vip.f
axi_stream_slave_vip_TOP   := axi_stream_slave_vip_tb_top

vcs_build_axi_stream_slave_vip:
	@mkdir -p $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)
	@echo "[VCS] Building axi_stream_slave_vip — log: $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/vcs.log"
	vlogan -sverilog -full64 -debug_access+all -lca -kdb +v2k -work axi_stream_slave_vip_lib -f $(axi_stream_slave_vip_FLIST) 2>&1 | tee $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/vcs.log && \
	vcs -top axi_stream_slave_vip_tb_top -o $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv -Mdir=$(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/csrc 2>&1 | tee -a $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/vcs.log

questa_build_axi_stream_slave_vip:
	@mkdir -p $(AXI_STREAM_SLAVE_VIP_BUILD_DIR) $(AXI_STREAM_SLAVE_VIP_WORK_DIR)
	@echo "[QUESTA] Building axi_stream_slave_vip — log: $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/questa.log"
	vlib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) 2>&1 | tee $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/questa.log && \
	vlog -work $(AXI_STREAM_SLAVE_VIP_WORK_DIR) -sv -mfcu -timescale 1ns/1ps -f $(axi_stream_slave_vip_FLIST) 2>&1 | tee -a $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/questa.log && \
	vopt +acc axi_stream_slave_vip_tb_top -o db_opt -work $(AXI_STREAM_SLAVE_VIP_WORK_DIR) 2>&1 | tee -a $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/questa.log

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_001_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_001_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_001_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_001_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_001_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_001_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_001_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_001_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_001_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_001_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_001_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_001_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_001_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_001_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_001_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_001_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_001_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_001_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_002_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_002_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_002_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_002_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_002_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_002_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_002_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_002_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_002_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_002_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_002_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_002_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_002_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_002_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_002_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_002_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_002_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_002_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_003_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_003_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_003_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_003_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_003_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_003_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_003_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_003_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_003_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_003_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_003_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_003_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_003_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_003_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_003_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_003_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_003_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_003_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_003_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_003_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_003_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_004_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_004_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_004_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_004_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_004_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_004_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_004_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_004_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_004_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_004_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_004_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_004_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_004_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_004_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_004_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_004_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_004_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_004_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_004_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_004_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_004_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_005_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_005_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_005_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_005_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_005_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_005_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_005_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_005_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_005_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_005_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_005_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_005_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_005_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_005_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_005_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_005_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_005_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_005_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_005_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_005_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_005_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_006_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_006_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_006_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_006_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_006_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_006_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_006_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_006_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_006_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_006_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_006_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_006_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_006_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_006_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_006_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_006_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_006_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_006_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_006_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_006_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_006_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_007_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_007_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_007_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_007_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_007_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_007_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_007_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_007_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_007_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_007_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_007_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_007_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_007_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_007_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_007_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_007_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_007_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_007_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_007_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_007_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_007_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_008_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_008_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_008_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_008_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_008_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_008_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_008_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_008_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_008_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_008_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_008_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_008_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_008_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_008_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_008_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_008_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_008_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_008_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_008_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_008_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_008_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_009_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_009_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_009_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_009_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_009_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_009_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_009_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_009_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_009_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_009_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_009_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_009_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_009_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_009_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_009_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_009_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_009_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_009_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_009_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_009_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_009_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_010_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_010_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_010_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_010_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_010_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_010_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_010_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_010_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_010_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_010_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_010_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_010_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_010_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_010_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_010_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_010_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_010_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_010_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_010_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_010_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_010_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_011_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_011_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_011_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_011_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_011_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_011_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_011_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_011_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_011_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_011_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_011_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_011_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_011_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_011_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_011_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_011_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_011_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_011_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_011_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_011_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_011_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_012_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_012_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_012_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_012_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_012_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_012_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_012_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_012_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_012_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_012_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_012_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_012_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_012_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_012_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_012_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_012_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_012_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_012_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_013_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_013_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_013_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_013_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_013_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_013_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_013_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_013_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_013_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_013_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_013_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_013_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_013_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_013_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_013_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_013_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_013_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_013_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_013_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_013_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_013_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_014_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_014_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_014_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_014_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_014_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_014_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_014_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_014_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_014_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_014_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_014_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_014_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_014_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_014_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_014_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_014_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_014_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_014_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_014_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_014_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_014_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_015_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_015_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_015_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_015_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_015_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_015_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_015_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_015_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_015_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_015_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_015_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_015_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_015_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_015_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_015_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_015_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_015_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_015_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_015_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_015_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_015_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_016_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_016_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_016_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_016_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_016_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_016_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_016_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_016_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_016_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_016_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_016_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_016_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_016_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_016_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_016_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_016_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_016_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_016_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_016_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_016_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_016_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_017_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_017_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_017_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_017_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_017_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_017_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_017_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_017_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_017_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_017_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_017_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_017_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_017_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_017_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_017_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_017_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_017_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_017_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_018_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_018_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_018_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_018_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_018_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_018_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_018_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_018_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_018_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_018_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_018_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_018_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_018_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_018_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_018_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_018_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_018_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_018_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_018_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_018_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_018_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_019_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_019_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_019_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_019_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_019_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_019_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_019_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_019_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_019_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_019_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_019_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_019_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_019_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_019_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_019_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_019_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_019_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_019_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_019_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_019_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_019_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_020_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_020_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_020_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_020_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_020_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_020_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_020_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_020_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_020_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_020_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_020_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_020_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_020_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_020_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_020_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_020_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_020_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_020_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_020_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_020_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_020_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_021_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_021_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_021_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_021_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_021_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_021_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_021_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_021_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_021_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_021_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_021_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_021_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_021_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_021_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_021_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_021_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_021_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_021_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_022_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_022_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_022_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_022_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_022_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_022_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_022_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_022_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_022_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_022_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_022_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_022_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_022_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_022_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_022_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_022_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_022_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_022_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_022_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_022_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_022_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_023_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_023_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_023_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_023_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_023_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_023_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_023_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_023_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_023_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_023_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_023_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_023_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_023_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_023_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_023_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_023_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_023_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_023_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_023_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_023_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_023_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_024_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_024_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_024_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_024_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_024_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_024_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_024_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_024_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_024_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_024_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_024_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_024_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_024_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_024_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_024_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_024_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_024_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_024_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_024_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_024_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_024_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_025_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_025_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_025_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_025_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_025_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_025_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_025_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_025_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_025_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_025_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_025_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_025_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_025_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_025_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_025_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_025_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_025_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_025_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_025_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_025_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_025_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_026_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_026_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_026_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_026_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_026_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_026_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_026_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_026_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_026_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_026_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_026_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_026_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_026_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_026_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_026_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_026_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_026_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_026_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_026_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_026_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_026_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_027_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_027_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_027_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_027_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_027_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_027_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_027_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_027_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_027_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_027_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_027_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_027_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_027_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_027_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_027_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_027_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_027_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_027_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_027_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_027_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_027_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_028_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_028_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_028_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_028_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_028_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_028_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_028_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_028_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_028_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_028_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_028_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_028_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_028_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_028_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_028_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_028_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_028_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_028_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_028_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_028_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_028_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_029_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_029_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_029_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_029_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_029_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_029_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_029_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_029_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_029_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_029_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_029_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_029_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_029_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_029_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_029_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_029_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_029_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_029_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_029_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_029_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_029_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_030_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_030_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_030_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_030_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_030_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_030_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_030_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_030_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_030_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_030_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_030_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_030_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_030_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_030_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_030_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_030_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_030_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_030_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_030_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_030_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_030_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_031_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_031_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_031_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_031_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_031_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_031_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_031_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_031_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_031_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_031_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_031_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_031_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_031_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_031_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_031_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_031_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_031_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_031_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_031_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_031_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_031_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_032_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_032_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_032_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_032_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_032_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_032_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_032_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_032_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_032_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_032_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_032_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_032_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_032_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_032_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_032_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_032_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_032_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_032_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_032_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_032_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_032_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_033_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_033_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_033_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_033_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_033_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_033_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_033_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_033_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_033_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_033_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_033_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_033_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_033_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_033_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_033_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_033_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_033_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_033_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_034_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_034_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_034_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_034_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_034_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_034_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_034_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_034_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_034_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_034_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_034_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_034_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_034_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_034_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_034_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_034_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_034_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_034_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_034_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_034_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_034_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_035_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_035_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_035_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_035_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_035_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_035_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_035_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_035_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_035_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_035_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_035_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_035_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_035_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_035_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_035_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_035_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_035_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_035_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_035_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_035_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_035_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_036_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_036_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_036_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_036_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_036_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_036_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_036_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_036_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_036_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_036_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_036_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_036_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_036_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_036_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_036_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_036_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_036_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_036_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_036_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_036_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_036_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_037_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_037_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_037_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_037_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_037_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_037_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_037_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_037_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_037_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_037_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_037_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_037_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_037_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_037_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_037_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_037_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_037_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_037_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_038_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_038_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_038_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_038_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_038_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_038_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_038_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_038_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_038_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_038_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_038_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_038_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_038_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_038_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_038_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_038_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_038_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_038_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_038_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_038_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_038_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_039_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_039_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_039_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_039_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_039_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_039_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_039_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_039_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_039_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_039_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_039_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_039_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_039_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_039_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_039_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_039_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_039_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_039_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_039_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_039_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_039_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_040_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_040_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_040_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_040_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_040_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_040_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_040_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_040_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_040_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_040_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_040_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_040_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_040_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_040_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_040_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_040_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_040_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_040_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_040_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_040_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_040_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_041_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_041_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_041_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_041_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_041_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_041_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_041_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_041_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_041_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_041_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_041_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_041_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_041_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_041_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_041_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_041_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_041_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_041_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_041_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_041_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_041_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_042_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_042_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_042_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_042_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_042_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_042_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_042_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_042_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_042_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_042_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_042_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_042_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_042_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_042_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_042_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_042_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_042_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_042_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_042_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_042_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_042_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_043_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_043_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_043_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_043_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_043_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_043_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_043_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_043_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_043_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_043_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_043_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_043_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_043_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_043_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_043_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_043_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_043_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_043_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_043_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_043_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_043_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_044_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_044_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_044_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_044_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_044_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_044_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_044_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_044_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_044_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_044_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_044_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_044_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_044_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_044_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_044_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_044_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_044_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_044_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_044_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_044_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_044_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_045_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_045_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_045_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_045_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_045_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_045_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_045_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_045_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_045_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_045_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_045_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_045_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_045_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_045_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_045_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_045_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_045_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_045_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_045_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_045_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_045_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_046_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_046_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_046_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_046_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[VCS] Running axi_stream_slv_vip_tc_046_test"; \
	 VCD_ARGS=""; if [ "$(WAVES)" = "1" ]; then VCD_ARGS="+vcs+dumpvars+$$RUN_DIR/waves.vcd"; fi; \
	 GUI_FLAG=""; if [ "$(GUI)" = "1" ]; then GUI_FLAG="-gui"; fi; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv $$GUI_FLAG $$VCD_ARGS +UVM_TESTNAME=axi_stream_slv_vip_tc_046_test +ntb_random_seed=random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000 -l simv.log  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_046_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_046_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_046_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_046_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_046_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[QUESTA] Running axi_stream_slv_vip_tc_046_test"; \
	 DO_CMD="run -all; quit"; \
	 if [ "$(WAVES)" = "1" ]; then DO_CMD="vcd file $$RUN_DIR/waves.vcd; vcd add -r /*; run -all; quit"; fi; \
	 if [ "$(GUI)" = "1" ]; then DO_CMD="add wave -r /*; run -all"; fi; \
	 MODE="-c -batch"; if [ "$(GUI)" = "1" ]; then MODE="-gui"; fi; \
	 vsim $$MODE -do "$$DO_CMD" -batch -do 'run -all; quit' -lib $(AXI_STREAM_SLAVE_VIP_WORK_DIR) db_opt +UVM_TESTNAME=axi_stream_slv_vip_tc_046_test -sv_seed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000  > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_046_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_046_test:
	@if [ -n "$(REGDIR)" ]; then RUN_DIR=$(REGDIR)/axi_stream_slv_vip_tc_046_test; else mkdir -p $(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_046_test; RUN_ID=$$(date +%Y%m%d_%H%M%S); RUN_DIR=$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/axi_stream_slv_vip_tc_046_test/run_$$RUN_ID; fi; mkdir -p $$RUN_DIR; LOGFILE=$$RUN_DIR/sim.log; \
	 echo "[XCELIUM] Running axi_stream_slv_vip_tc_046_test"; \
	 $(AXI_STREAM_SLAVE_VIP_BUILD_DIR)/simv +UVM_TESTNAME=axi_stream_slv_vip_tc_046_test -svseed random +UVM_MAX_QUIT_COUNT=10 +UVM_TIMEOUT=100000000   > $$LOGFILE 2>&1; SIM_RC=$$?; if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --single-log $$LOGFILE --test-name axi_stream_slv_vip_tc_046_test --total $(if $(TOTAL),$(TOTAL),46) $(if $(REGDIR),--comp-run-dir $(REGDIR),); else printf '\033[1m[EDA Buddy] Per-test report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi; exit $$SIM_RC

.PHONY: vcs_run_axi_stream_slave_vip_smoke_test
vcs_run_axi_stream_slave_vip_smoke_test:
	@REGDIR="$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/smoke_test_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[SMOKE_TEST] Session dir: $$REGDIR  Total=7 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=7 vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_slave_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_slv_vip_tc_001_test,axi_stream_slv_vip_tc_002_test,axi_stream_slv_vip_tc_012_test,axi_stream_slv_vip_tc_017_test,axi_stream_slv_vip_tc_021_test,axi_stream_slv_vip_tc_033_test,axi_stream_slv_vip_tc_037_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_SLAVE_SMOKE_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: questa_run_axi_stream_slave_vip_smoke_test
questa_run_axi_stream_slave_vip_smoke_test:
	@REGDIR="$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/smoke_test_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[SMOKE_TEST] Session dir: $$REGDIR  Total=7 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=7 questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_slave_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_slv_vip_tc_001_test,axi_stream_slv_vip_tc_002_test,axi_stream_slv_vip_tc_012_test,axi_stream_slv_vip_tc_017_test,axi_stream_slv_vip_tc_021_test,axi_stream_slv_vip_tc_033_test,axi_stream_slv_vip_tc_037_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_SLAVE_SMOKE_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: xcelium_run_axi_stream_slave_vip_smoke_test
xcelium_run_axi_stream_slave_vip_smoke_test:
	@REGDIR="$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/smoke_test_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[SMOKE_TEST] Session dir: $$REGDIR  Total=7 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=7 xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_slave_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_slv_vip_tc_001_test,axi_stream_slv_vip_tc_002_test,axi_stream_slv_vip_tc_012_test,axi_stream_slv_vip_tc_017_test,axi_stream_slv_vip_tc_021_test,axi_stream_slv_vip_tc_033_test,axi_stream_slv_vip_tc_037_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_SLAVE_SMOKE_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: vcs_run_axi_stream_slave_vip_regression
vcs_run_axi_stream_slave_vip_regression:
	@REGDIR="$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/regression_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[REGRESSION] Session dir: $$REGDIR  Total=35 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=35 vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_003_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_004_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_005_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_008_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_010_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_011_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_013_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_014_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_015_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_018_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_019_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_022_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_023_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_025_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_026_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_027_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_029_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_030_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_031_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_034_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_035_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_036_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_039_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_040_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_041_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_042_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_043_test vcs_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_044_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_slave_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_slv_vip_tc_001_test,axi_stream_slv_vip_tc_002_test,axi_stream_slv_vip_tc_003_test,axi_stream_slv_vip_tc_004_test,axi_stream_slv_vip_tc_005_test,axi_stream_slv_vip_tc_008_test,axi_stream_slv_vip_tc_010_test,axi_stream_slv_vip_tc_011_test,axi_stream_slv_vip_tc_012_test,axi_stream_slv_vip_tc_013_test,axi_stream_slv_vip_tc_014_test,axi_stream_slv_vip_tc_015_test,axi_stream_slv_vip_tc_017_test,axi_stream_slv_vip_tc_018_test,axi_stream_slv_vip_tc_019_test,axi_stream_slv_vip_tc_021_test,axi_stream_slv_vip_tc_022_test,axi_stream_slv_vip_tc_023_test,axi_stream_slv_vip_tc_025_test,axi_stream_slv_vip_tc_026_test,axi_stream_slv_vip_tc_027_test,axi_stream_slv_vip_tc_029_test,axi_stream_slv_vip_tc_030_test,axi_stream_slv_vip_tc_031_test,axi_stream_slv_vip_tc_033_test,axi_stream_slv_vip_tc_034_test,axi_stream_slv_vip_tc_035_test,axi_stream_slv_vip_tc_036_test,axi_stream_slv_vip_tc_037_test,axi_stream_slv_vip_tc_039_test,axi_stream_slv_vip_tc_040_test,axi_stream_slv_vip_tc_041_test,axi_stream_slv_vip_tc_042_test,axi_stream_slv_vip_tc_043_test,axi_stream_slv_vip_tc_044_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_SLAVE_FULL_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: questa_run_axi_stream_slave_vip_regression
questa_run_axi_stream_slave_vip_regression:
	@REGDIR="$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/regression_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[REGRESSION] Session dir: $$REGDIR  Total=35 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=35 questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_003_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_004_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_005_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_008_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_010_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_011_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_013_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_014_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_015_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_018_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_019_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_022_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_023_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_025_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_026_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_027_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_029_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_030_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_031_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_034_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_035_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_036_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_039_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_040_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_041_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_042_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_043_test questa_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_044_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_slave_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_slv_vip_tc_001_test,axi_stream_slv_vip_tc_002_test,axi_stream_slv_vip_tc_003_test,axi_stream_slv_vip_tc_004_test,axi_stream_slv_vip_tc_005_test,axi_stream_slv_vip_tc_008_test,axi_stream_slv_vip_tc_010_test,axi_stream_slv_vip_tc_011_test,axi_stream_slv_vip_tc_012_test,axi_stream_slv_vip_tc_013_test,axi_stream_slv_vip_tc_014_test,axi_stream_slv_vip_tc_015_test,axi_stream_slv_vip_tc_017_test,axi_stream_slv_vip_tc_018_test,axi_stream_slv_vip_tc_019_test,axi_stream_slv_vip_tc_021_test,axi_stream_slv_vip_tc_022_test,axi_stream_slv_vip_tc_023_test,axi_stream_slv_vip_tc_025_test,axi_stream_slv_vip_tc_026_test,axi_stream_slv_vip_tc_027_test,axi_stream_slv_vip_tc_029_test,axi_stream_slv_vip_tc_030_test,axi_stream_slv_vip_tc_031_test,axi_stream_slv_vip_tc_033_test,axi_stream_slv_vip_tc_034_test,axi_stream_slv_vip_tc_035_test,axi_stream_slv_vip_tc_036_test,axi_stream_slv_vip_tc_037_test,axi_stream_slv_vip_tc_039_test,axi_stream_slv_vip_tc_040_test,axi_stream_slv_vip_tc_041_test,axi_stream_slv_vip_tc_042_test,axi_stream_slv_vip_tc_043_test,axi_stream_slv_vip_tc_044_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_SLAVE_FULL_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

.PHONY: xcelium_run_axi_stream_slave_vip_regression
xcelium_run_axi_stream_slave_vip_regression:
	@REGDIR="$(AXI_STREAM_SLAVE_VIP_RUN_DIR)/regression_$$(date +%Y%m%d_%H%M%S)"; \
	mkdir -p "$$REGDIR"; \
	echo "[REGRESSION] Session dir: $$REGDIR  Total=35 tests"; \
	$(MAKE) -k REGDIR=$$REGDIR TOTAL=35 xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_001_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_002_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_003_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_004_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_005_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_008_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_010_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_011_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_012_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_013_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_014_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_015_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_017_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_018_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_019_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_021_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_022_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_023_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_025_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_026_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_027_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_029_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_030_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_031_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_033_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_034_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_035_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_036_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_037_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_039_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_040_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_041_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_042_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_043_test xcelium_run_axi_stream_slave_vip_axi_stream_slv_vip_tc_044_test || true; \
	echo ""; \
	if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --component axi_stream_slave_vip --project-name "SMART_SOC_PROJECT" --tests axi_stream_slv_vip_tc_001_test,axi_stream_slv_vip_tc_002_test,axi_stream_slv_vip_tc_003_test,axi_stream_slv_vip_tc_004_test,axi_stream_slv_vip_tc_005_test,axi_stream_slv_vip_tc_008_test,axi_stream_slv_vip_tc_010_test,axi_stream_slv_vip_tc_011_test,axi_stream_slv_vip_tc_012_test,axi_stream_slv_vip_tc_013_test,axi_stream_slv_vip_tc_014_test,axi_stream_slv_vip_tc_015_test,axi_stream_slv_vip_tc_017_test,axi_stream_slv_vip_tc_018_test,axi_stream_slv_vip_tc_019_test,axi_stream_slv_vip_tc_021_test,axi_stream_slv_vip_tc_022_test,axi_stream_slv_vip_tc_023_test,axi_stream_slv_vip_tc_025_test,axi_stream_slv_vip_tc_026_test,axi_stream_slv_vip_tc_027_test,axi_stream_slv_vip_tc_029_test,axi_stream_slv_vip_tc_030_test,axi_stream_slv_vip_tc_031_test,axi_stream_slv_vip_tc_033_test,axi_stream_slv_vip_tc_034_test,axi_stream_slv_vip_tc_035_test,axi_stream_slv_vip_tc_036_test,axi_stream_slv_vip_tc_037_test,axi_stream_slv_vip_tc_039_test,axi_stream_slv_vip_tc_040_test,axi_stream_slv_vip_tc_041_test,axi_stream_slv_vip_tc_042_test,axi_stream_slv_vip_tc_043_test,axi_stream_slv_vip_tc_044_test --reg-dir $$REGDIR --save-to $$REGDIR/report.txt --post-cmd "python /cygdrive/d/Verification/VERIFICATION_PLANNER/eda_buddy/scripts/push_result.py --id AXI_SLAVE_FULL_REGRESSION --total {total} --passed {passed} --failed {failed}"; else printf '\033[1m[EDA Buddy] Final report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi

## ======================================================
## UTILITIES
## ======================================================
.PHONY: clean report
clean:
	rm -rf $(ROOT)/*/build $(ROOT)/*/work $(ROOT)/*/run
	@echo 'Cleaned per-component build/work/run dirs. Filelists and Makefile preserved.'

## REPORT — scan all run logs and print pass/fail summary
report:
	@if [ -f "$(REPORT_SCRIPT)" ]; then python $(REPORT_SCRIPT) --root $(ROOT) --project-name "SMART_SOC_PROJECT" --save-to $(ROOT)/logs/report.txt; else printf '\033[1m[EDA Buddy] Report skipped: run_report.py not found. Check EDA Buddy repository.\033[0m\n'; fi
