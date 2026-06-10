# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Build Commands

```bash
# Compile all programs (requires GnuCOBOL)
make all

# Compile VALENGN as module (not executable) - required for CALL statements
cobc -m -fixed -I copybooks -o bin/VALENGN src/VALENGN.cbl

# Run full batch cycle (must run from bin/ directory after compile)
cd bin && ./ACCTMSTR && ./TXNPROC && ./INTCALC && ./RPTGEN && ./AUDITLOG
```

## Critical Non-Obvious Patterns

### File Organization
- **Programs MUST run from `bin/` directory** - they expect data files (`.DAT`, `.RPT`) in current directory
- **Copybooks require `-I copybooks` flag** - compiler won't find them otherwise
- **VALENGN compiles differently** - uses `-m` flag (module) not `-x` (executable) because it's CALLed by other programs

### COBOL Column Rules (Fixed Format)
- Columns 1-6: Sequence numbers (ignored by compiler)
- Column 7: Indicator area (`*` = comment, `-` = continuation, `/` = page break)
- Columns 8-11: Area A (division/section/paragraph names, 01/77 level numbers)
- Columns 12-72: Area B (all other code)
- Columns 73-80: Ignored (originally for card sequence)
- **Violating column rules causes cryptic compile errors**

### Data Type Gotchas
- **COMP-3 (packed decimal) is mandatory for money** - never use COMP or display format for financial amounts
- **PIC S9(13)V99 COMP-3** = signed, 13 integer digits, 2 decimal places, packed decimal
- **REDEFINES doesn't allocate new memory** - it's a different view of same bytes (used for parsing account numbers)
- **88-level condition names** - test with `IF ACCT-IS-CHECKING` not `IF ACCT-TYPE = "CH"`

### File Handling
- **ORGANIZATION IS INDEXED** requires RECORD KEY - this is the primary index field
- **ACCESS MODE IS DYNAMIC** allows both sequential and random access in same program
- **FILE STATUS must be checked after EVERY I/O operation** - "00" = success, "23" = not found, "10" = EOF
- **ISAM files (.DAT) are binary** - don't edit with text editors

### Copybook Usage
- **COPY statement pulls in shared data structures** - changes to copybooks affect all programs
- **COPY REPLACING** can customize field prefixes per program
- **Copybooks define record layouts** - ACCTREC.cpy, TXNREC.cpy, ERRCODES.cpy, DATEUTIL.cpy, AUDITREC.cpy

### Program Execution Order
- **Batch cycle has dependencies** - ACCTMSTR must run before TXNPROC (creates account file)
- **VALENGN is a subprogram** - never executed directly, only via CALL from other programs
- **Programs expect specific file names** - ACCTMAST.DAT, TXNINPUT.DAT, AUDITLOG.DAT (hardcoded in SELECT statements)

### Date Handling
- **Dates stored as PIC 9(8) in YYYYMMDD format** - not ISO 8601, no separators
- **Use FUNCTION INTEGER-OF-DATE for date arithmetic** - converts YYYYMMDD to Julian day number
- **Day count conventions matter** - ACT/360, ACT/365, 30/360 affect interest calculations

### Error Handling
- **Error codes are 4-character strings** - "0000" = success, "1xxx" = validation, "2xxx" = account, "3xxx" = transaction, "9xxx" = system
- **ERRCODES.cpy centralizes all error codes** - don't hardcode error values in programs

## Testing
- No automated test framework - programs are tested by running with sample data files
- Check output files in `bin/` directory: `*.RPT` for reports, `*.DAT` for data files
- Validation errors go to `TXNREJECT.DAT`