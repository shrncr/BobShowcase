# COBOL Project Coding Rules (Non-Obvious Only)

## Critical Compilation Patterns
- **VALENGN must compile with `-m` flag** (module, not executable) - it's CALLed by other programs, not run directly
- **All programs need `-I copybooks` flag** - compiler won't find COPY statements otherwise
- **Programs must run from `bin/` directory** - they expect `.DAT` and `.RPT` files in current working directory

## COBOL Column Rules (Fixed Format)
- **Columns 8-11 (Area A)**: Division/section/paragraph names, 01/77 level numbers ONLY
- **Columns 12-72 (Area B)**: All other code statements
- **Column 7**: Indicator (`*` = comment, `-` = continuation)
- **Violating these causes cryptic compile errors** - not syntax errors, but "invalid area" errors

## Data Type Requirements
- **COMP-3 (packed decimal) is MANDATORY for all money fields** - PIC S9(13)V99 COMP-3
- **Never use COMP or display format for financial amounts** - causes rounding errors
- **REDEFINES creates alternate view of same memory** - doesn't allocate new space (used for parsing account numbers into components)

## File I/O Patterns
- **FILE STATUS must be checked after EVERY I/O operation** - "00" = success, "23" = not found, "10" = EOF
- **ISAM files (.DAT) are binary** - never edit with text editors, will corrupt index
- **ACCESS MODE IS DYNAMIC** required for both sequential and random access in same program

## Program Dependencies
- **ACCTMSTR must run before TXNPROC** - TXNPROC reads ACCTMAST.DAT created by ACCTMSTR
- **VALENGN is never executed directly** - only via CALL from other programs
- **File names are hardcoded in SELECT statements** - ACCTMAST.DAT, TXNINPUT.DAT, AUDITLOG.DAT

## Date Handling
- **Dates are PIC 9(8) in YYYYMMDD format** - not ISO 8601, no separators or hyphens
- **Use FUNCTION INTEGER-OF-DATE for date arithmetic** - converts to Julian day number

## Error Codes
- **Error codes are 4-character strings** - "0000" = success, "1xxx" = validation, "2xxx" = account, "3xxx" = transaction, "9xxx" = system
- **All error codes defined in ERRCODES.cpy** - never hardcode error values in programs