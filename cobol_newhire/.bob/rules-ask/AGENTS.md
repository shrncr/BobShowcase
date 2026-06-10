# COBOL Project Documentation Rules (Non-Obvious Only)

## Project Structure Context
- **cobol-banking-masterclass/** contains the actual COBOL project - not at root level
- **Copybooks are shared data structures** - changes affect all programs that COPY them
- **Programs are interdependent** - ACCTMSTR creates files that TXNPROC reads

## File Organization
- **bin/** directory is execution context - programs expect data files in current directory when run
- **src/** contains COBOL source (.cbl files)
- **copybooks/** contains shared record layouts (.cpy files)
- **.DAT files are binary ISAM** - not text files, contain indexed data structures
- **.RPT files are text reports** - generated output from batch processing

## COBOL-Specific Concepts
- **Fixed-format source code** - column positions matter (Area A vs Area B)
- **COPY statements** pull in copybooks at compile time (like C #include)
- **REDEFINES** provides alternate views of same memory without allocation
- **88-level condition names** are boolean tests on parent field values
- **COMP-3 packed decimal** stores financial data without floating point errors

## Batch Processing Architecture
- **Nightly batch cycle** runs programs in sequence: ACCTMSTR → TXNPROC → INTCALC → RPTGEN → AUDITLOG
- **VALENGN is a callable module** - not a standalone program, invoked via CALL statement
- **Programs are stateless** - each run processes files from start to finish

## Data Formats
- **Dates are YYYYMMDD** (PIC 9(8)) - no separators, not ISO 8601
- **Account numbers have structure** - bank code + branch code + sequence + check digit
- **Error codes are 4-character strings** - categorized by prefix (1xxx, 2xxx, 3xxx, 9xxx)

## Historical Context
- **ISAM predates relational databases** - this is how data was stored before SQL
- **Luhn algorithm from 1960** - still used on credit cards today
- **Audit trail with hash chaining** - blockchain concept from 1970s banking