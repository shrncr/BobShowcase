# COBOL Banking Masterclass

**A production-style banking transaction processing system written in COBOL.**

COBOL still processes **95% of ATM transactions**, runs on **95% of Fortune 500** business-critical systems, and handles an estimated **$3 trillion in daily commerce**. There are **220 billion lines** of COBOL in active production. It's not legacy — it's infrastructure.

This project is a fully functional banking transaction processor that demonstrates real-world COBOL patterns used in actual financial systems. It's designed to teach modern developers what COBOL looks like in practice, not in a textbook.

## What's Inside

| Program | Description |
|---------|-------------|
| `ACCTMSTR.cbl` | Account Master File Manager — CRUD operations on indexed sequential (ISAM) files |
| `TXNPROC.cbl` | Transaction Processor — Batch processing with audit trails, the bread and butter of banking |
| `RPTGEN.cbl` | Report Generator — Formatted financial reports with control breaks |
| `VALENGN.cbl` | Validation Engine — Input validation, check digits, Luhn algorithm |
| `INTCALC.cbl` | Interest Calculator — Compound interest with day-count conventions (ACT/360, ACT/365, 30/360) |
| `AUDITLOG.cbl` | Audit Logger — Immutable transaction audit trail with hash chaining |
| `BATCHCTL.cbl` | Batch Controller — Orchestrates the full nightly batch cycle |

## Copybooks (Shared Data Structures)

| Copybook | Description |
|----------|-------------|
| `ACCTREC.cpy` | Account record layout |
| `TXNREC.cpy` | Transaction record layout |
| `ERRCODES.cpy` | System error codes |
| `DATEUTIL.cpy` | Date handling utilities |
| `AUDITREC.cpy` | Audit record layout |

## Architecture

```
┌─────────────┐     ┌──────────────┐     ┌───────────┐
│  BATCHCTL   │────>│   TXNPROC    │────>│  AUDITLOG │
│  (Control)  │     │  (Process)   │     │  (Trail)  │
└──────┬──────┘     └──────┬───────┘     └───────────┘
       │                   │
       v                   v
┌─────────────┐     ┌──────────────┐     ┌───────────┐
│   VALENGN   │     │   ACCTMSTR   │     │  INTCALC  │
│  (Validate) │     │  (Accounts)  │     │ (Interest)│
└─────────────┘     └──────────────┘     └───────────┘
                           │
                           v
                    ┌──────────────┐
                    │    RPTGEN    │
                    │  (Reports)  │
                    └──────────────┘
```

This mirrors real mainframe batch architectures: a controller program drives validation, processing, account updates, interest calculations, audit logging, and report generation — all in a single nightly batch window.

## Key COBOL Concepts Demonstrated

- **Fixed-format source** (columns 1-6: sequence, 7: indicator, 8-11: Area A, 12-72: Area B)
- **Indexed Sequential Access Method (ISAM)** file handling
- **WORKING-STORAGE** vs **LOCAL-STORAGE** vs **LINKAGE SECTION**
- **COPY/REPLACE** for shared data structures (copybooks)
- **88-level condition names** for readable business logic
- **REDEFINES** for memory-efficient data views
- **OCCURS DEPENDING ON** for variable-length tables
- **Packed decimal (COMP-3)** for exact financial arithmetic
- **PERFORM VARYING** loops and **PERFORM THRU** paragraphs
- **Control break reporting** with subtotals and grand totals
- **STRING/UNSTRING** for data manipulation
- **INSPECT/TALLYING/REPLACING** for character processing
- **EVALUATE (COBOL's switch/case)** with ALSO for multi-condition logic
- **Nested programs** and **CALL** with BY REFERENCE/BY CONTENT
- **FILE STATUS** codes for robust error handling
- **SORT/MERGE** verbs for data ordering
- **DECLARATIVES** for file error handling
- **Reference modification** for substring operations

## Building & Running

### Using GnuCOBOL (Free, Open Source)

```bash
# Install GnuCOBOL
# Ubuntu/Debian:  sudo apt install gnucobol
# macOS:          brew install gnucobol
# Windows:        choco install gnucobol (or use WSL)

# Compile all programs
make all

# Run the demo batch cycle
make run-batch

# Run individual programs
make run-accounts
make run-reports
```

### Using Docker

```bash
docker build -t cobol-masterclass .
docker run -it cobol-masterclass
```

## Why COBOL Matters in 2026

- The IRS processes **150 million tax returns** on COBOL systems
- The Social Security Administration runs on **60 million lines** of COBOL
- During COVID, unemployment systems crashed because states couldn't find COBOL programmers
- Banks process **$3 trillion daily** through COBOL batch systems
- COBOL programs written in the 1970s are still running — try saying that about your Node.js app

The average COBOL programmer is **55+ years old**. The systems aren't going anywhere, but the people who understand them are retiring. Learning COBOL isn't nostalgia — it's job security.

## License

MIT — use it, learn from it, teach with it.
