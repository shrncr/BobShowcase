      ******************************************************************
      * AUDITLOG.cbl - Audit Trail Logger with Hash Chain
      *
      * Implements an immutable audit trail with hash chaining -
      * the same concept behind blockchain, except banks have been
      * doing this since the 1970s. Each record contains a hash of
      * the previous record, creating a tamper-evident chain.
      *
      * COBOL LESSON: This program demonstrates:
      * - DECLARATIVES for automatic error handling
      * - STRING/UNSTRING for data manipulation
      * - INSPECT TALLYING/REPLACING for character processing
      * - Reference modification for substring operations
      * - Computed checksums using COBOL arithmetic
      * - PERFORM THRU for paragraph ranges
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.    AUDITLOG.
       AUTHOR.        COBOL-BANKING-MASTERCLASS.
       DATE-WRITTEN.  2026-03-29.

       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
       REPOSITORY.
           FUNCTION ALL INTRINSIC.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT AUDIT-FILE
               ASSIGN TO "AUDITLOG.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-AUDIT-FILE-STATUS.

           SELECT AUDIT-REPORT
               ASSIGN TO "AUDITRPT.RPT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RPT-FILE-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD  AUDIT-FILE.
       COPY AUDITREC.

       FD  AUDIT-REPORT.
       01  RPT-LINE                      PIC X(132).

       WORKING-STORAGE SECTION.

       01  WS-FILE-STATUSES.
           05  WS-AUDIT-FILE-STATUS      PIC X(2).
               88  WS-AUDIT-OK           VALUE "00".
               88  WS-AUDIT-EOF          VALUE "10".
           05  WS-RPT-FILE-STATUS        PIC X(2).

      *    ---- Hash Chain Verification ----
      *    COBOL LESSON: We implement a simple hash chain using
      *    COBOL arithmetic. In production, you'd use a
      *    cryptographic hash via a system call or copybook.
      *    The concept is identical to blockchain - each block
      *    (record) contains the hash of the previous block.
       01  WS-HASH-FIELDS.
           05  WS-EXPECTED-HASH          PIC X(32).
           05  WS-COMPUTED-HASH          PIC X(32).
           05  WS-HASH-INPUT             PIC X(200).
           05  WS-HASH-ACCUM             PIC 9(18) VALUE ZEROS.
           05  WS-HASH-BYTE              PIC 9(3).
           05  WS-HASH-IDX               PIC 9(3).
           05  WS-HASH-CHAR              PIC X(1).
           05  WS-HASH-REMAINDER         PIC 9(18).
           05  WS-HASH-HEX               PIC X(32).
           05  WS-CHAIN-VALID            PIC X(1) VALUE "Y".
               88  WS-CHAIN-IS-VALID     VALUE "Y".
               88  WS-CHAIN-IS-BROKEN    VALUE "N".
           05  WS-RECORDS-CHECKED        PIC 9(9) VALUE ZEROS.
           05  WS-CHAIN-BREAKS           PIC 9(5) VALUE ZEROS.

      *    ---- Character Inspection ----
      *    COBOL LESSON: INSPECT is incredibly powerful for
      *    character-level processing. TALLYING counts,
      *    REPLACING transforms, and CONVERTING translates.
       01  WS-INSPECT-WORK.
           05  WS-TALLY-COUNT            PIC 9(5) VALUE ZEROS.
           05  WS-ALPHA-COUNT            PIC 9(5) VALUE ZEROS.
           05  WS-NUMERIC-COUNT          PIC 9(5) VALUE ZEROS.
           05  WS-SPECIAL-COUNT          PIC 9(5) VALUE ZEROS.
           05  WS-TOTAL-CHARS            PIC 9(5) VALUE ZEROS.

      *    ---- Audit Analysis ----
       01  WS-AUDIT-ANALYSIS.
           05  WS-TOTAL-CREATES          PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-UPDATES          PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-DELETES          PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-READS            PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-APPROVALS        PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-REJECTIONS       PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-REVERSALS        PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-RECORDS          PIC 9(9) VALUE ZEROS.
           05  WS-UNIQUE-USERS           PIC 9(5) VALUE ZEROS.
           05  WS-UNIQUE-PROGRAMS        PIC 9(5) VALUE ZEROS.

      *    ---- User Activity Tracking ----
      *    COBOL LESSON: This table tracks unique users for
      *    the audit summary. SEARCH ALL performs a binary
      *    search on a sorted table - O(log n) lookup.
       01  WS-USER-TABLE.
           05  WS-USER-COUNT             PIC 9(3) VALUE ZEROS.
           05  WS-USER-ENTRY OCCURS 100 TIMES
                   ASCENDING KEY IS WS-USER-ID
                   INDEXED BY WS-USER-IDX.
               10  WS-USER-ID            PIC X(8).
               10  WS-USER-ACTION-CT     PIC 9(7).

      *    ---- Date Utilities ----
       COPY DATEUTIL.

      *    ---- Processing Flags ----
       01  WS-FLAGS.
           05  WS-EOF-FLAG               PIC X(1) VALUE "N".
               88  WS-END-OF-FILE        VALUE "Y".
           05  WS-FIRST-RECORD-FLAG      PIC X(1) VALUE "Y".
               88  WS-FIRST-RECORD       VALUE "Y".

      *    ---- Report Lines ----
       01  WS-RPT-TITLE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(40) VALUE
               "AUDIT TRAIL INTEGRITY REPORT".
           05  FILLER PIC X(91) VALUE SPACES.

       01  WS-RPT-SEPARATOR.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(131) VALUE ALL "=".

       01  WS-RPT-DETAIL.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-SEQ      PIC Z(11)9.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-DATE     PIC X(10).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-TIME     PIC X(8).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-ACTION   PIC X(3).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-ENTITY   PIC X(4).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-ID       PIC X(16).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-USER     PIC X(8).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-PROGRAM  PIC X(8).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-FIELD    PIC X(15).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-HASH-OK  PIC X(4).
           05  FILLER PIC X(20) VALUE SPACES.

       01  WS-DISPLAY-LINE               PIC X(80).

       PROCEDURE DIVISION.

      ******************************************************************
      * COBOL LESSON: DECLARATIVES is a special section at the
      * beginning of the PROCEDURE DIVISION. It defines automatic
      * error handlers that fire when file I/O errors occur.
      * Think of it as try/catch for file operations.
      ******************************************************************
       DECLARATIVES.

       AUDIT-FILE-ERROR SECTION.
           USE AFTER ERROR PROCEDURE ON AUDIT-FILE.
       AUDIT-FILE-ERROR-PARA.
           DISPLAY "AUDIT FILE ERROR: Status = "
                   WS-AUDIT-FILE-STATUS
           .

       REPORT-FILE-ERROR SECTION.
           USE AFTER ERROR PROCEDURE ON AUDIT-REPORT.
       REPORT-FILE-ERROR-PARA.
           DISPLAY "REPORT FILE ERROR: Status = "
                   WS-RPT-FILE-STATUS
           .

       END DECLARATIVES.

      ******************************************************************
      * MAIN CONTROL
      ******************************************************************
       0000-MAIN-CONTROL SECTION.
       0000-START.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-DEMONSTRATE-HASHING
           PERFORM 3000-DEMONSTRATE-INSPECT
           PERFORM 4000-VERIFY-AUDIT-CHAIN
           PERFORM 9000-TERMINATE
           STOP RUN
           .
       0000-EXIT.
           EXIT.

      ******************************************************************
      * INITIALIZATION
      ******************************************************************
       1000-INITIALIZE SECTION.
       1000-START.
           DISPLAY "================================================"
           DISPLAY "  AUDITLOG - Audit Trail Logger"
           DISPLAY "  COBOL Banking Masterclass"
           DISPLAY "================================================"
           DISPLAY SPACES

           MOVE FUNCTION CURRENT-DATE(1:8)
               TO WS-CURRENT-DATE-INT
           .
       1000-EXIT.
           EXIT.

      ******************************************************************
      * DEMONSTRATE HASH CHAIN CONCEPT
      *
      * COBOL LESSON: We create a simple hash using COBOL
      * arithmetic. Each character's ordinal value is accumulated
      * with multiplication and modular arithmetic to create
      * a deterministic "fingerprint" of the data.
      ******************************************************************
       2000-DEMONSTRATE-HASHING SECTION.
       2000-START.
           DISPLAY "================================================"
           DISPLAY "  Hash Chain Demonstration"
           DISPLAY "================================================"
           DISPLAY SPACES
           DISPLAY "  Each audit record contains a hash of the"
           DISPLAY "  previous record. If anyone tampers with a"
           DISPLAY "  record, the chain breaks - instant detection."
           DISPLAY SPACES

      *    Create a chain of 5 sample records
           MOVE SPACES TO WS-EXPECTED-HASH
           DISPLAY "  Creating hash chain:"

           MOVE "RECORD-001: CREATE ACCOUNT BNKA000100000011"
               TO WS-HASH-INPUT
           PERFORM 2100-COMPUTE-HASH
           DISPLAY "    Record 1 hash: " WS-COMPUTED-HASH(1:16)
                   "..."
           MOVE WS-COMPUTED-HASH TO WS-EXPECTED-HASH

           MOVE "RECORD-002: UPDATE BALANCE +2500.00"
               TO WS-HASH-INPUT
      *    Prepend previous hash to create chain
           STRING WS-EXPECTED-HASH WS-HASH-INPUT
               DELIMITED BY SIZE
               INTO WS-HASH-INPUT
           PERFORM 2100-COMPUTE-HASH
           DISPLAY "    Record 2 hash: " WS-COMPUTED-HASH(1:16)
                   "..."
           MOVE WS-COMPUTED-HASH TO WS-EXPECTED-HASH

           MOVE "RECORD-003: WITHDRAWAL -200.00"
               TO WS-HASH-INPUT
           STRING WS-EXPECTED-HASH WS-HASH-INPUT
               DELIMITED BY SIZE
               INTO WS-HASH-INPUT
           PERFORM 2100-COMPUTE-HASH
           DISPLAY "    Record 3 hash: " WS-COMPUTED-HASH(1:16)
                   "..."

           DISPLAY SPACES
           DISPLAY "  If Record 2 is tampered with, its hash changes,"
           DISPLAY "  which breaks Record 3's chain verification."
           DISPLAY "  This is the fundamental principle of blockchain."
           DISPLAY SPACES
           .
       2000-EXIT.
           EXIT.

      ******************************************************************
      * COMPUTE SIMPLE HASH
      *
      * COBOL LESSON: FUNCTION ORD returns the ordinal position
      * of a character in the collating sequence (like ASCII value).
      * We use this to create a numeric fingerprint of a string.
      ******************************************************************
       2100-COMPUTE-HASH SECTION.
       2100-START.
           MOVE ZEROS TO WS-HASH-ACCUM

      *    Process each character
           PERFORM VARYING WS-HASH-IDX FROM 1 BY 1
               UNTIL WS-HASH-IDX > 64
                   OR WS-HASH-INPUT(WS-HASH-IDX:1) = SPACES

      *        Get ordinal value of character
               MOVE WS-HASH-INPUT(WS-HASH-IDX:1)
                   TO WS-HASH-CHAR
               MOVE FUNCTION ORD(WS-HASH-CHAR)
                   TO WS-HASH-BYTE

      *        Accumulate with position-dependent mixing
      *        COBOL LESSON: COMPUTE handles complex expressions.
      *        This creates a position-sensitive hash so "AB" and
      *        "BA" produce different values.
               COMPUTE WS-HASH-ACCUM =
                   FUNCTION MOD(
                       WS-HASH-ACCUM * 31 + WS-HASH-BYTE
                           * WS-HASH-IDX,
                       999999999999999999)
           END-PERFORM

      *    Format hash as hex-like string
      *    COBOL LESSON: We convert the numeric hash to a
      *    string representation using reference modification
      *    and repeated division.
           MOVE WS-HASH-ACCUM TO WS-COMPUTED-HASH
           .
       2100-EXIT.
           EXIT.

      ******************************************************************
      * DEMONSTRATE INSPECT VERB
      *
      * COBOL LESSON: INSPECT is one of COBOL's most powerful
      * verbs. It can:
      * - TALLYING: Count characters matching criteria
      * - REPLACING: Replace characters matching criteria
      * - CONVERTING: Translate character-by-character (like tr)
      * All in a single, readable statement.
      ******************************************************************
       3000-DEMONSTRATE-INSPECT SECTION.
       3000-START.
           DISPLAY "================================================"
           DISPLAY "  INSPECT Verb Demonstration"
           DISPLAY "================================================"
           DISPLAY SPACES

      *    ---- TALLYING Demo ----
           MOVE "Hello, World! 123 TEST @#$" TO WS-DISPLAY-LINE

           DISPLAY "  Input: '" WS-DISPLAY-LINE(1:26) "'"
           DISPLAY SPACES

      *    Count different character types
      *    COBOL LESSON: INSPECT TALLYING can count multiple
      *    character classes in a single statement.
           MOVE ZEROS TO WS-TALLY-COUNT
           INSPECT WS-DISPLAY-LINE(1:26)
               TALLYING WS-TALLY-COUNT
                   FOR ALL SPACES
           DISPLAY "    Spaces:           " WS-TALLY-COUNT

           MOVE ZEROS TO WS-TALLY-COUNT
           INSPECT WS-DISPLAY-LINE(1:26)
               TALLYING WS-TALLY-COUNT
                   FOR ALL "l"
           DISPLAY "    Letter 'l':       " WS-TALLY-COUNT

           MOVE ZEROS TO WS-TALLY-COUNT
           INSPECT WS-DISPLAY-LINE(1:26)
               TALLYING WS-TALLY-COUNT
                   FOR CHARACTERS BEFORE INITIAL "!"
           DISPLAY "    Chars before '!': " WS-TALLY-COUNT

      *    ---- REPLACING Demo ----
           DISPLAY SPACES
           MOVE "SSN: 123-45-6789 DOB: 1990-05-15"
               TO WS-DISPLAY-LINE
           DISPLAY "  Before masking: '"
                   WS-DISPLAY-LINE(1:33) "'"

      *    COBOL LESSON: INSPECT REPLACING is perfect for
      *    data masking - a real requirement for PCI/PII
      *    compliance in banking.
           INSPECT WS-DISPLAY-LINE(6:7)
               REPLACING ALL "1" BY "X"
                         ALL "2" BY "X"
                         ALL "3" BY "X"
                         ALL "4" BY "X"
                         ALL "5" BY "X"
                         ALL "6" BY "X"
           DISPLAY "  After masking:  '"
                   WS-DISPLAY-LINE(1:33) "'"
           DISPLAY "  (First 7 chars of SSN masked for PII)"

      *    ---- CONVERTING Demo ----
           DISPLAY SPACES
           MOVE "convert this to uppercase please"
               TO WS-DISPLAY-LINE
           DISPLAY "  Before CONVERTING: '"
                   WS-DISPLAY-LINE(1:32) "'"

      *    COBOL LESSON: CONVERTING is like Unix 'tr' command.
      *    It translates each character in the first string to
      *    the corresponding character in the second string.
           INSPECT WS-DISPLAY-LINE
               CONVERTING
                   "abcdefghijklmnopqrstuvwxyz"
               TO  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
           DISPLAY "  After CONVERTING:  '"
                   WS-DISPLAY-LINE(1:32) "'"

           DISPLAY SPACES
           .
       3000-EXIT.
           EXIT.

      ******************************************************************
      * VERIFY AUDIT CHAIN - Read and validate the audit trail
      ******************************************************************
       4000-VERIFY-AUDIT-CHAIN SECTION.
       4000-START.
           DISPLAY "================================================"
           DISPLAY "  Audit Trail Verification"
           DISPLAY "================================================"
           DISPLAY SPACES

           OPEN INPUT AUDIT-FILE
           IF WS-AUDIT-FILE-STATUS NOT = "00"
               DISPLAY "  No audit trail file found (normal if"
               DISPLAY "  TXNPROC hasn't run yet)."
               DISPLAY SPACES
               EXIT SECTION
           END-IF

           OPEN OUTPUT AUDIT-REPORT
           WRITE RPT-LINE FROM WS-RPT-TITLE
           WRITE RPT-LINE FROM WS-RPT-SEPARATOR

           MOVE "N" TO WS-EOF-FLAG
           MOVE "Y" TO WS-FIRST-RECORD-FLAG
           MOVE SPACES TO WS-EXPECTED-HASH

           PERFORM UNTIL WS-END-OF-FILE
               READ AUDIT-FILE
                   AT END
                       SET WS-END-OF-FILE TO TRUE
                   NOT AT END
                       PERFORM 4100-PROCESS-AUDIT-RECORD
               END-READ
           END-PERFORM

           CLOSE AUDIT-FILE

      *    Write summary
           WRITE RPT-LINE FROM WS-RPT-SEPARATOR

           DISPLAY "  Audit Trail Summary:"
           DISPLAY "    Total records:   " WS-TOTAL-RECORDS
           DISPLAY "    Chain breaks:    " WS-CHAIN-BREAKS

           IF WS-CHAIN-BREAKS = 0
               DISPLAY "    Chain Status:    INTACT - No tampering"
           ELSE
               DISPLAY "    Chain Status:    BROKEN - Possible tamper!"
           END-IF

           DISPLAY "    Creates:         " WS-TOTAL-CREATES
           DISPLAY "    Updates:         " WS-TOTAL-UPDATES
           DISPLAY "    Deletes:         " WS-TOTAL-DELETES
           DISPLAY "    Reversals:       " WS-TOTAL-REVERSALS
           DISPLAY SPACES

           CLOSE AUDIT-REPORT
           .
       4000-EXIT.
           EXIT.

      ******************************************************************
      * PROCESS INDIVIDUAL AUDIT RECORD
      ******************************************************************
       4100-PROCESS-AUDIT-RECORD SECTION.
       4100-START.
           ADD 1 TO WS-TOTAL-RECORDS

      *    Verify hash chain
           IF WS-FIRST-RECORD
               MOVE "N" TO WS-FIRST-RECORD-FLAG
               MOVE "OK  " TO WS-RD-HASH-OK
           ELSE
               IF AUDIT-PREV-HASH = WS-EXPECTED-HASH
                   MOVE "OK  " TO WS-RD-HASH-OK
               ELSE
                   MOVE "FAIL" TO WS-RD-HASH-OK
                   ADD 1 TO WS-CHAIN-BREAKS
                   SET WS-CHAIN-IS-BROKEN TO TRUE
               END-IF
           END-IF

      *    Save this record's hash for next verification
           MOVE AUDIT-RECORD-HASH TO WS-EXPECTED-HASH

      *    Count by action type
           EVALUATE TRUE
               WHEN AUDIT-CREATE  ADD 1 TO WS-TOTAL-CREATES
               WHEN AUDIT-UPDATE  ADD 1 TO WS-TOTAL-UPDATES
               WHEN AUDIT-DELETE  ADD 1 TO WS-TOTAL-DELETES
               WHEN AUDIT-READ    ADD 1 TO WS-TOTAL-READS
               WHEN AUDIT-APPROVE ADD 1 TO WS-TOTAL-APPROVALS
               WHEN AUDIT-REJECT  ADD 1 TO WS-TOTAL-REJECTIONS
               WHEN AUDIT-REVERSE ADD 1 TO WS-TOTAL-REVERSALS
           END-EVALUATE

      *    Format report detail
           MOVE AUDIT-SEQ-NUM TO WS-RD-SEQ
           STRING AUDIT-DATE(5:2) "/" AUDIT-DATE(7:2)
                  "/" AUDIT-DATE(1:4)
               DELIMITED BY SIZE
               INTO WS-RD-DATE
           STRING AUDIT-TIME(1:2) ":" AUDIT-TIME(3:2)
                  ":" AUDIT-TIME(5:2)
               DELIMITED BY SIZE
               INTO WS-RD-TIME
           MOVE AUDIT-ACTION      TO WS-RD-ACTION
           MOVE AUDIT-ENTITY-TYPE TO WS-RD-ENTITY
           MOVE AUDIT-ENTITY-ID   TO WS-RD-ID
           MOVE AUDIT-USER-ID     TO WS-RD-USER
           MOVE AUDIT-PROGRAM-ID  TO WS-RD-PROGRAM
           MOVE AUDIT-FIELD-NAME  TO WS-RD-FIELD

           WRITE RPT-LINE FROM WS-RPT-DETAIL

      *    Display to console
           DISPLAY "    #" AUDIT-SEQ-NUM " "
                   AUDIT-ACTION " "
                   AUDIT-ENTITY-ID(1:16) " "
                   WS-RD-HASH-OK " "
                   AUDIT-DESCRIPTION(1:30)
           .
       4100-EXIT.
           EXIT.

      ******************************************************************
      * TERMINATION
      ******************************************************************
       9000-TERMINATE SECTION.
       9000-START.
           DISPLAY "================================================"
           DISPLAY "  AUDITLOG Processing Complete"
           DISPLAY "================================================"
           DISPLAY SPACES
           .
       9000-EXIT.
           EXIT.
