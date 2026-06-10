      ******************************************************************
      * BATCHCTL.cbl - Batch Controller / Orchestrator
      *
      * This is the master control program that orchestrates the
      * entire nightly batch cycle. In real banks, a program like
      * this drives the sequence:
      *
      *   1. Validate input files
      *   2. Process transactions
      *   3. Calculate interest
      *   4. Generate reports
      *   5. Verify audit trail
      *   6. Produce batch control totals
      *
      * COBOL LESSON: This demonstrates:
      * - CALL statement for inter-program communication
      * - BY REFERENCE vs BY CONTENT parameter passing
      * - Return code handling
      * - Batch window management
      * - JCL-style step processing (without actual JCL)
      *
      * On a real mainframe, this would be driven by JCL (Job
      * Control Language) which defines the execution sequence,
      * file allocations, and conditional step execution.
      * This program simulates that orchestration in pure COBOL.
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.    BATCHCTL.
       AUTHOR.        COBOL-BANKING-MASTERCLASS.
       DATE-WRITTEN.  2026-03-29.

       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
       REPOSITORY.
           FUNCTION ALL INTRINSIC.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

      *    ---- Batch Control Record ----
       01  WS-BATCH-CONTROL.
           05  WS-BATCH-ID.
               10  WS-BATCH-DATE         PIC 9(8).
               10  WS-BATCH-SEQ          PIC 9(4) VALUE 0001.
           05  WS-BATCH-STATUS           PIC X(10).
               88  WS-BATCH-STARTING     VALUE "STARTING  ".
               88  WS-BATCH-RUNNING      VALUE "RUNNING   ".
               88  WS-BATCH-COMPLETED    VALUE "COMPLETED ".
               88  WS-BATCH-FAILED       VALUE "FAILED    ".
               88  WS-BATCH-ABENDED      VALUE "ABENDED   ".

      *    ---- Step Control ----
      *    COBOL LESSON: This simulates JCL step processing.
      *    Each step has a name, program, status, and return code.
      *    Steps can be conditionally skipped based on previous
      *    step return codes (like JCL COND parameter).
       01  WS-STEP-TABLE.
           05  WS-NUM-STEPS              PIC 9(2) VALUE 06.
           05  WS-CURRENT-STEP           PIC 9(2) VALUE ZEROS.
           05  WS-STEP-ENTRY OCCURS 10 TIMES.
               10  WS-STEP-NAME          PIC X(12).
               10  WS-STEP-PROGRAM       PIC X(8).
               10  WS-STEP-STATUS        PIC X(10).
                   88  WS-STEP-PENDING   VALUE "PENDING   ".
                   88  WS-STEP-RUNNING   VALUE "RUNNING   ".
                   88  WS-STEP-SUCCESS   VALUE "SUCCESS   ".
                   88  WS-STEP-WARNING   VALUE "WARNING   ".
                   88  WS-STEP-FAILED    VALUE "FAILED    ".
                   88  WS-STEP-SKIPPED   VALUE "SKIPPED   ".
               10  WS-STEP-RC            PIC 9(4).
               10  WS-STEP-START-TIME    PIC 9(8).
               10  WS-STEP-END-TIME      PIC 9(8).
               10  WS-STEP-ELAPSED       PIC 9(8).

      *    ---- Timing ----
       01  WS-TIMING.
           05  WS-BATCH-START            PIC 9(8).
           05  WS-BATCH-END              PIC 9(8).
           05  WS-BATCH-ELAPSED          PIC 9(8).

      *    ---- Return Codes ----
       01  WS-RETURN-CODES.
           05  WS-MAX-RC                 PIC 9(4) VALUE ZEROS.
           05  WS-STEP-RETURN            PIC 9(4) VALUE ZEROS.
           05  WS-ABEND-FLAG             PIC X(1) VALUE "N".
               88  WS-HAS-ABENDED        VALUE "Y".

      *    ---- Date/Time Fields ----
       01  WS-DATETIME.
           05  WS-FULL-DATETIME          PIC X(21).
           05  WS-DISP-DATE              PIC X(10).
           05  WS-DISP-TIME              PIC X(8).

      *    ---- Batch Statistics ----
       01  WS-BATCH-STATS.
           05  WS-STEPS-RUN              PIC 9(2) VALUE ZEROS.
           05  WS-STEPS-SUCCESS          PIC 9(2) VALUE ZEROS.
           05  WS-STEPS-FAILED           PIC 9(2) VALUE ZEROS.
           05  WS-STEPS-SKIPPED          PIC 9(2) VALUE ZEROS.
           05  WS-STEPS-WARNING          PIC 9(2) VALUE ZEROS.

      *    ---- Display Fields ----
       01  WS-SEPARATOR                  PIC X(60) VALUE ALL "=".
       01  WS-THIN-SEP                   PIC X(60) VALUE ALL "-".
       01  WS-STEP-IDX                   PIC 9(2).

       PROCEDURE DIVISION.

      ******************************************************************
      * MAIN CONTROL - Batch Orchestrator
      ******************************************************************
       0000-MAIN-CONTROL.
           PERFORM 1000-BATCH-INITIALIZE
           PERFORM 2000-EXECUTE-BATCH-STEPS
           PERFORM 3000-BATCH-SUMMARY
           PERFORM 9000-BATCH-TERMINATE
           STOP RUN
           .

      ******************************************************************
      * BATCH INITIALIZATION
      *
      * Sets up the batch control record and defines the
      * execution sequence.
      ******************************************************************
       1000-BATCH-INITIALIZE.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR
           DISPLAY "  BATCHCTL - Nightly Batch Controller"
           DISPLAY "  COBOL Banking Masterclass"
           DISPLAY WS-SEPARATOR
           DISPLAY SPACES
           DISPLAY "  This program simulates the nightly batch"
           DISPLAY "  cycle that runs at every bank in the world."
           DISPLAY "  Every night, while you sleep, COBOL programs"
           DISPLAY "  process every transaction, calculate interest,"
           DISPLAY "  generate reports, and verify audit trails."
           DISPLAY SPACES

      *    Get current date/time
           MOVE FUNCTION CURRENT-DATE TO WS-FULL-DATETIME
           MOVE WS-FULL-DATETIME(1:8) TO WS-BATCH-DATE

           STRING WS-FULL-DATETIME(5:2) "/"
                  WS-FULL-DATETIME(7:2) "/"
                  WS-FULL-DATETIME(1:4)
               DELIMITED BY SIZE
               INTO WS-DISP-DATE

           STRING WS-FULL-DATETIME(9:2) ":"
                  WS-FULL-DATETIME(11:2) ":"
                  WS-FULL-DATETIME(13:2)
               DELIMITED BY SIZE
               INTO WS-DISP-TIME

           MOVE WS-FULL-DATETIME(9:8) TO WS-BATCH-START

           DISPLAY "  Batch ID:    " WS-BATCH-ID
           DISPLAY "  Batch Date:  " WS-DISP-DATE
           DISPLAY "  Start Time:  " WS-DISP-TIME
           DISPLAY SPACES

      *    Define batch steps
      *    COBOL LESSON: In production, this sequence would be
      *    defined in JCL (Job Control Language) or a scheduler
      *    like CA-7, TWS, or Control-M. Each "step" runs a
      *    program with specific file allocations and parameters.

           MOVE "ACCT SETUP  " TO WS-STEP-NAME(1)
           MOVE "ACCTMSTR"     TO WS-STEP-PROGRAM(1)
           MOVE "PENDING   "   TO WS-STEP-STATUS(1)

           MOVE "PROCESS TXN " TO WS-STEP-NAME(2)
           MOVE "TXNPROC "     TO WS-STEP-PROGRAM(2)
           MOVE "PENDING   "   TO WS-STEP-STATUS(2)

           MOVE "CALC INTRST " TO WS-STEP-NAME(3)
           MOVE "INTCALC "     TO WS-STEP-PROGRAM(3)
           MOVE "PENDING   "   TO WS-STEP-STATUS(3)

           MOVE "GEN REPORTS " TO WS-STEP-NAME(4)
           MOVE "RPTGEN  "     TO WS-STEP-PROGRAM(4)
           MOVE "PENDING   "   TO WS-STEP-STATUS(4)

           MOVE "AUDIT VERFY " TO WS-STEP-NAME(5)
           MOVE "AUDITLOG"     TO WS-STEP-PROGRAM(5)
           MOVE "PENDING   "   TO WS-STEP-STATUS(5)

           MOVE "BATCH CLOSE " TO WS-STEP-NAME(6)
           MOVE "INTERNAL"     TO WS-STEP-PROGRAM(6)
           MOVE "PENDING   "   TO WS-STEP-STATUS(6)

           SET WS-BATCH-STARTING TO TRUE
           .

      ******************************************************************
      * EXECUTE BATCH STEPS
      *
      * COBOL LESSON: CALL statement invokes another COBOL
      * program. In a real mainframe environment, each CALL
      * loads the program from the link library and executes
      * it. Programs can be:
      * - Statically linked (bound at compile time)
      * - Dynamically loaded (loaded at runtime)
      *
      * BY REFERENCE passes a pointer to the caller's memory.
      * BY CONTENT passes a copy (callee can't modify caller's data).
      *
      * Note: In this demo, we simulate the calls with DISPLAY
      * statements since the programs are standalone executables.
      * In production, they would be CALLable subprograms.
      ******************************************************************
       2000-EXECUTE-BATCH-STEPS.
           SET WS-BATCH-RUNNING TO TRUE

           DISPLAY WS-SEPARATOR
           DISPLAY "  EXECUTING BATCH STEPS"
           DISPLAY WS-SEPARATOR
           DISPLAY SPACES

           PERFORM VARYING WS-CURRENT-STEP FROM 1 BY 1
               UNTIL WS-CURRENT-STEP > WS-NUM-STEPS
                   OR WS-HAS-ABENDED

      *        Check if we should skip based on previous failures
               IF WS-MAX-RC > 8
                   AND WS-CURRENT-STEP NOT = WS-NUM-STEPS
                   MOVE "SKIPPED   "
                       TO WS-STEP-STATUS(WS-CURRENT-STEP)
                   ADD 1 TO WS-STEPS-SKIPPED
                   DISPLAY "  STEP " WS-CURRENT-STEP
                           ": " WS-STEP-NAME(WS-CURRENT-STEP)
                           " - SKIPPED (max RC > 8)"
               ELSE
                   PERFORM 2100-EXECUTE-ONE-STEP
               END-IF
           END-PERFORM
           .

       2100-EXECUTE-ONE-STEP.
           MOVE "RUNNING   "
               TO WS-STEP-STATUS(WS-CURRENT-STEP)
           MOVE FUNCTION CURRENT-DATE(9:8)
               TO WS-STEP-START-TIME(WS-CURRENT-STEP)

           ADD 1 TO WS-STEPS-RUN

           DISPLAY WS-THIN-SEP
           DISPLAY "  STEP " WS-CURRENT-STEP ": "
                   WS-STEP-NAME(WS-CURRENT-STEP)
           DISPLAY "  Program: "
                   WS-STEP-PROGRAM(WS-CURRENT-STEP)
           DISPLAY "  Status:  RUNNING"
           DISPLAY WS-THIN-SEP

      *    COBOL LESSON: In production, this would be:
      *    CALL WS-STEP-PROGRAM(WS-CURRENT-STEP)
      *        USING WS-BATCH-CONTROL
      *    ON EXCEPTION
      *        SET WS-HAS-ABENDED TO TRUE
      *    END-CALL
      *    MOVE RETURN-CODE TO WS-STEP-RETURN
      *
      *    For this demo, we simulate execution:

           EVALUATE WS-CURRENT-STEP
               WHEN 1
                   DISPLAY SPACES
                   DISPLAY "  [Simulating ACCTMSTR execution]"
                   DISPLAY "  -> Creating account master file"
                   DISPLAY "  -> Loading 6 sample accounts"
                   DISPLAY "  -> Generating account listing"
                   DISPLAY "  -> Demonstrating CRUD operations"
                   MOVE 0000 TO WS-STEP-RETURN

               WHEN 2
                   DISPLAY SPACES
                   DISPLAY "  [Simulating TXNPROC execution]"
                   DISPLAY "  -> Generating 10 transactions"
                   DISPLAY "  -> Validating each transaction"
                   DISPLAY "  -> Applying to account balances"
                   DISPLAY "  -> Writing audit trail"
                   DISPLAY "  -> 7 posted, 3 rejected"
                   MOVE 0004 TO WS-STEP-RETURN

               WHEN 3
                   DISPLAY SPACES
                   DISPLAY "  [Simulating INTCALC execution]"
                   DISPLAY "  -> Day-count convention demo"
                   DISPLAY "  -> Compound interest schedule"
                   DISPLAY "  -> Processing all account interest"
                   MOVE 0000 TO WS-STEP-RETURN

               WHEN 4
                   DISPLAY SPACES
                   DISPLAY "  [Simulating RPTGEN execution]"
                   DISPLAY "  -> Control break report generation"
                   DISPLAY "  -> Bank/Branch/Type hierarchy"
                   DISPLAY "  -> Grand totals and status summary"
                   MOVE 0000 TO WS-STEP-RETURN

               WHEN 5
                   DISPLAY SPACES
                   DISPLAY "  [Simulating AUDITLOG execution]"
                   DISPLAY "  -> Hash chain demonstration"
                   DISPLAY "  -> INSPECT verb showcase"
                   DISPLAY "  -> Audit trail verification"
                   MOVE 0000 TO WS-STEP-RETURN

               WHEN 6
                   DISPLAY SPACES
                   DISPLAY "  [Batch closing procedures]"
                   DISPLAY "  -> Verifying batch control totals"
                   DISPLAY "  -> Archiving daily files"
                   DISPLAY "  -> Updating batch status"
                   MOVE 0000 TO WS-STEP-RETURN
           END-EVALUATE

      *    Record step completion
           MOVE FUNCTION CURRENT-DATE(9:8)
               TO WS-STEP-END-TIME(WS-CURRENT-STEP)
           MOVE WS-STEP-RETURN
               TO WS-STEP-RC(WS-CURRENT-STEP)

      *    Determine step status from return code
      *    COBOL LESSON: Return code conventions:
      *    0  = Success
      *    4  = Warning (processed with minor issues)
      *    8  = Error (some items failed)
      *    12 = Severe (major failure, subsequent steps risky)
      *    16 = Fatal (must stop immediately)
           EVALUATE TRUE
               WHEN WS-STEP-RETURN = 0
                   MOVE "SUCCESS   "
                       TO WS-STEP-STATUS(WS-CURRENT-STEP)
                   ADD 1 TO WS-STEPS-SUCCESS
               WHEN WS-STEP-RETURN = 4
                   MOVE "WARNING   "
                       TO WS-STEP-STATUS(WS-CURRENT-STEP)
                   ADD 1 TO WS-STEPS-WARNING
               WHEN WS-STEP-RETURN <= 8
                   MOVE "FAILED    "
                       TO WS-STEP-STATUS(WS-CURRENT-STEP)
                   ADD 1 TO WS-STEPS-FAILED
               WHEN OTHER
                   MOVE "FAILED    "
                       TO WS-STEP-STATUS(WS-CURRENT-STEP)
                   ADD 1 TO WS-STEPS-FAILED
                   SET WS-HAS-ABENDED TO TRUE
           END-EVALUATE

      *    Track maximum return code
           IF WS-STEP-RETURN > WS-MAX-RC
               MOVE WS-STEP-RETURN TO WS-MAX-RC
           END-IF

           DISPLAY SPACES
           DISPLAY "  Step RC: " WS-STEP-RETURN
                   "  Status: "
                   WS-STEP-STATUS(WS-CURRENT-STEP)
           .

      ******************************************************************
      * BATCH SUMMARY - Display execution results
      ******************************************************************
       3000-BATCH-SUMMARY.
           DISPLAY SPACES
           DISPLAY WS-SEPARATOR
           DISPLAY "  BATCH EXECUTION SUMMARY"
           DISPLAY WS-SEPARATOR
           DISPLAY SPACES

      *    Step-by-step results
           DISPLAY "  Step  Name          Program   Status"
                   "      RC    Start     End"
           DISPLAY "  ----  ------------  --------  ----------"
                   "  ----  --------  --------"

           PERFORM VARYING WS-STEP-IDX FROM 1 BY 1
               UNTIL WS-STEP-IDX > WS-NUM-STEPS
               DISPLAY "   "
                       WS-STEP-IDX "    "
                       WS-STEP-NAME(WS-STEP-IDX) "  "
                       WS-STEP-PROGRAM(WS-STEP-IDX) "  "
                       WS-STEP-STATUS(WS-STEP-IDX) "  "
                       WS-STEP-RC(WS-STEP-IDX) "  "
                       WS-STEP-START-TIME(WS-STEP-IDX)(1:2)
                       ":"
                       WS-STEP-START-TIME(WS-STEP-IDX)(3:2)
                       ":"
                       WS-STEP-START-TIME(WS-STEP-IDX)(5:2)
                       "  "
                       WS-STEP-END-TIME(WS-STEP-IDX)(1:2)
                       ":"
                       WS-STEP-END-TIME(WS-STEP-IDX)(3:2)
                       ":"
                       WS-STEP-END-TIME(WS-STEP-IDX)(5:2)
           END-PERFORM

           DISPLAY SPACES
           DISPLAY WS-THIN-SEP
           DISPLAY "  Steps Executed:  " WS-STEPS-RUN
           DISPLAY "  Steps Succeeded: " WS-STEPS-SUCCESS
           DISPLAY "  Steps Warning:   " WS-STEPS-WARNING
           DISPLAY "  Steps Failed:    " WS-STEPS-FAILED
           DISPLAY "  Steps Skipped:   " WS-STEPS-SKIPPED
           DISPLAY "  Maximum RC:      " WS-MAX-RC
           DISPLAY WS-THIN-SEP
           DISPLAY SPACES

      *    Overall batch status
           EVALUATE TRUE
               WHEN WS-MAX-RC = 0
                   SET WS-BATCH-COMPLETED TO TRUE
                   DISPLAY "  BATCH STATUS: *** COMPLETED "
                           "SUCCESSFULLY ***"
               WHEN WS-MAX-RC = 4
                   SET WS-BATCH-COMPLETED TO TRUE
                   DISPLAY "  BATCH STATUS: *** COMPLETED "
                           "WITH WARNINGS ***"
               WHEN WS-MAX-RC <= 8
                   SET WS-BATCH-FAILED TO TRUE
                   DISPLAY "  BATCH STATUS: *** COMPLETED "
                           "WITH ERRORS ***"
               WHEN OTHER
                   SET WS-BATCH-ABENDED TO TRUE
                   DISPLAY "  BATCH STATUS: *** ABENDED ***"
                   DISPLAY "  MANUAL INTERVENTION REQUIRED"
           END-EVALUATE
           DISPLAY SPACES
           .

      ******************************************************************
      * BATCH TERMINATION
      ******************************************************************
       9000-BATCH-TERMINATE.
           MOVE FUNCTION CURRENT-DATE(9:8) TO WS-BATCH-END

           DISPLAY WS-SEPARATOR
           DISPLAY "  Batch Start: "
                   WS-BATCH-START(1:2) ":"
                   WS-BATCH-START(3:2) ":"
                   WS-BATCH-START(5:2)
           DISPLAY "  Batch End:   "
                   WS-BATCH-END(1:2) ":"
                   WS-BATCH-END(3:2) ":"
                   WS-BATCH-END(5:2)
           DISPLAY WS-SEPARATOR
           DISPLAY SPACES
           DISPLAY "  In production, this batch runs every night"
           DISPLAY "  across every bank on the planet. While you"
           DISPLAY "  scroll Twitter, COBOL is moving trillions"
           DISPLAY "  of dollars. It's not legacy. It's critical"
           DISPLAY "  infrastructure."
           DISPLAY SPACES
           DISPLAY "  BATCHCTL completed. Return code: " WS-MAX-RC
           DISPLAY SPACES

           MOVE WS-MAX-RC TO RETURN-CODE
           .
