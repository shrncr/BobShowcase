# COBOL Banking Masterclass - Build System
#
# Requires GnuCOBOL (cobc compiler)
# Install: apt install gnucobol | brew install gnucobol | choco install gnucobol

COBC = cobc
COBFLAGS = -x -fixed -I copybooks
SRCDIR = src
BINDIR = bin
DATADIR = data

# All programs
PROGRAMS = ACCTMSTR TXNPROC INTCALC RPTGEN AUDITLOG BATCHCTL VALENGN

# Callable subprograms (compiled as modules, not executables)
MODULES = VALENGN

# Executables
EXECUTABLES = ACCTMSTR TXNPROC INTCALC RPTGEN AUDITLOG BATCHCTL

.PHONY: all clean run-batch run-accounts run-txn run-interest run-reports run-audit help

all: $(BINDIR) $(addprefix $(BINDIR)/, $(EXECUTABLES))

$(BINDIR):
	mkdir -p $(BINDIR)

# Compile each program
$(BINDIR)/ACCTMSTR: $(SRCDIR)/ACCTMSTR.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/TXNPROC: $(SRCDIR)/TXNPROC.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/INTCALC: $(SRCDIR)/INTCALC.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/RPTGEN: $(SRCDIR)/RPTGEN.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/AUDITLOG: $(SRCDIR)/AUDITLOG.cbl copybooks/*.cpy
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/BATCHCTL: $(SRCDIR)/BATCHCTL.cbl
	$(COBC) $(COBFLAGS) -o $@ $<

$(BINDIR)/VALENGN: $(SRCDIR)/VALENGN.cbl copybooks/*.cpy
	$(COBC) -m -fixed -I copybooks -o $@ $<

# Run targets
run-accounts: $(BINDIR)/ACCTMSTR
	@echo "=== Running Account Master File Manager ==="
	cd $(BINDIR) && ACCTMSTR.exe

run-txn: $(BINDIR)/TXNPROC
	@echo "=== Running Transaction Processor ==="
	cd $(BINDIR) && TXNPROC.exe

run-interest: $(BINDIR)/INTCALC
	@echo "=== Running Interest Calculator ==="
	cd $(BINDIR) && INTCALC.exe

run-reports: $(BINDIR)/RPTGEN
	@echo "=== Running Report Generator ==="
	cd $(BINDIR) && RPTGEN.exe

run-audit: $(BINDIR)/AUDITLOG
	@echo "=== Running Audit Logger ==="
	cd $(BINDIR) && AUDITLOG.exe

# Run the full batch cycle in sequence
run-batch: all
	@echo ""
	@echo "============================================"
	@echo "  RUNNING FULL NIGHTLY BATCH CYCLE"
	@echo "  This is what happens at your bank every"
	@echo "  single night while you sleep."
	@echo "============================================"
	@echo ""
	cd $(BINDIR) && ACCTMSTR.exe
	@echo ""
	@echo "--- Step 1 Complete: Accounts Loaded ---"
	@echo ""
	cd $(BINDIR) && TXNPROC.exe
	@echo ""
	@echo "--- Step 2 Complete: Transactions Processed ---"
	@echo ""
	cd $(BINDIR) && INTCALC.exe
	@echo ""
	@echo "--- Step 3 Complete: Interest Calculated ---"
	@echo ""
	cd $(BINDIR) && RPTGEN.exe
	@echo ""
	@echo "--- Step 4 Complete: Reports Generated ---"
	@echo ""
	cd $(BINDIR) && AUDITLOG.exe
	@echo ""
	@echo "--- Step 5 Complete: Audit Verified ---"
	@echo ""
	@echo "============================================"
	@echo "  BATCH CYCLE COMPLETE"
	@echo "  Check bin/ for generated reports:"
	@echo "    ACCTLIST.RPT  - Account listing"
	@echo "    INTEREST.RPT  - Interest accrual"
	@echo "    FINREPORT.RPT - Financial position"
	@echo "    AUDITRPT.RPT  - Audit trail"
	@echo "============================================"

# Clean build artifacts
clean:
	-@if exist $(BINDIR) rmdir /s /q $(BINDIR)
	-@del /q *.DAT *.RPT *.TMP 2>nul

help:
	@echo "COBOL Banking Masterclass - Build Targets"
	@echo ""
	@echo "  make all          - Compile all programs"
	@echo "  make run-batch    - Run the full batch cycle"
	@echo "  make run-accounts - Run account manager only"
	@echo "  make run-txn      - Run transaction processor"
	@echo "  make run-interest - Run interest calculator"
	@echo "  make run-reports  - Run report generator"
	@echo "  make run-audit    - Run audit logger"
	@echo "  make clean        - Remove build artifacts"
	@echo ""
	@echo "Prerequisites: GnuCOBOL (cobc)"
	@echo "  Ubuntu:  sudo apt install gnucobol"
	@echo "  macOS:   brew install gnucobol"
	@echo "  Windows: choco install gnucobol"
