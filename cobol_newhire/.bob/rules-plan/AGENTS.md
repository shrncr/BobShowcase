# COBOL Project Architecture Rules (Non-Obvious Only)

## System Architecture Constraints
- **Batch processing model** - programs process entire files sequentially, not individual requests
- **File-based data flow** - programs communicate via files (.DAT), not APIs or databases
- **Stateless execution** - each program run is independent, state persists only in files

## Program Dependencies
- **ACCTMSTR creates ACCTMAST.DAT** - must run first in batch cycle
- **TXNPROC reads ACCTMAST.DAT** - depends on ACCTMSTR output
- **VALENGN is library code** - compiled as module (-m flag), CALLed by other programs
- **Programs must execute from bin/** - hardcoded file paths expect current directory

## Data Architecture
- **ISAM files provide dual access** - sequential for batch, random for lookups
- **Copybooks enforce schema** - all programs share same record layouts via COPY statements
- **REDEFINES enables parsing** - account numbers decomposed without data duplication
- **Packed decimal (COMP-3) for precision** - financial calculations never use floating point

## Execution Model
- **Fixed batch window** - all processing happens in sequence during nightly cycle
- **No rollback mechanism** - forward-only processing with audit trail
- **File locking via FILE STATUS** - "9005" indicates record locked by another process
- **Error handling via reject files** - invalid transactions written to TXNREJECT.DAT

## Performance Patterns
- **Sequential reads are optimized** - ISAM files designed for batch throughput
- **Random access via indexed keys** - ACCT-NUMBER is primary key, ACCT-CUST-ID is alternate
- **SORT verb is built-in** - no external sort utilities needed
- **Packed decimal arithmetic is fast** - hardware support on mainframes

## Audit and Compliance
- **Hash chaining prevents tampering** - each audit record contains hash of previous
- **Before/after values captured** - enables point-in-time reconstruction
- **Immutable audit trail** - append-only, never modified
- **Regulatory requirement** - OCC/FDIC mandate complete transaction history

## Non-Standard Patterns
- **Column-sensitive source format** - Area A (8-11) vs Area B (12-72) affects compilation
- **Date format is YYYYMMDD** - not ISO 8601, no separators
- **Error codes are strings** - "0000" not integers, categorized by prefix
- **File names hardcoded in SELECT** - not configurable at runtime