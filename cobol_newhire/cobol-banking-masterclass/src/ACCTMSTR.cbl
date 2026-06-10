      ******************************************************************
      * ACCTMSTR.cbl - Account Master File Manager
      *
      * This program demonstrates ISAM (Indexed Sequential Access
      * Method) file handling - the backbone of mainframe data
      * management. Before relational databases, ISAM files WERE
      * the database. Many banks still use them.
      *
      * Operations: CREATE, READ, UPDATE, DELETE, LIST
      *
      * COBOL LESSON: ISAM files have keys that allow both
      * sequential processing (read every record in order) and
      * random access (jump directly to a specific account).
      * This dual access mode is what made COBOL perfect for
      * banking: batch processing reads sequentially, online
      * systems access randomly.
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.    ACCTMSTR.
       AUTHOR.        COBOL-BANKING-MASTERCLASS.
       DATE-WRITTEN.  2026-03-29.
      *
      * This program manages the Account Master File using
      * indexed sequential (ISAM) file organization.
      * It demonstrates COBOL file handling at its finest.
      *

       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
       REPOSITORY.
      *    COBOL LESSON: REPOSITORY declares intrinsic functions
      *    we'll use. FUNCTION ALL makes all available.
           FUNCTION ALL INTRINSIC.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    COBOL LESSON: SELECT ties a logical file name to a
      *    physical file. ORGANIZATION IS INDEXED means this
      *    is an ISAM file. RECORD KEY defines the primary index.
      *    ALTERNATE RECORD KEY allows secondary lookups.
      *    FILE STATUS captures I/O result codes.

           SELECT ACCOUNT-FILE
               ASSIGN TO "ACCTMAST.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
      *        DYNAMIC = both sequential and random access
               RECORD KEY IS ACCT-NUMBER
               ALTERNATE RECORD KEY IS ACCT-CUST-ID
                   WITH DUPLICATES
      *        Multiple accounts can share a customer ID
               FILE STATUS IS WS-ACCT-FILE-STATUS.

           SELECT REPORT-FILE
               ASSIGN TO "ACCTLIST.RPT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RPT-FILE-STATUS.

           SELECT INPUT-FILE
               ASSIGN TO "ACCTINPT.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-INPUT-FILE-STATUS.

       DATA DIVISION.

       FILE SECTION.
      *    COBOL LESSON: FD (File Description) defines the
      *    record layout for each file. The COPY statement
      *    pulls in our shared copybook.

       FD  ACCOUNT-FILE.
       COPY ACCTREC.

       FD  REPORT-FILE.
       01  REPORT-LINE                   PIC X(132).

       FD  INPUT-FILE.
       01  INPUT-RECORD                  PIC X(200).

       WORKING-STORAGE SECTION.

      *    ---- File Status Codes ----
      *    COBOL LESSON: File status is a 2-byte field set after
      *    every I/O operation. "00" = success, "23" = not found,
      *    "22" = duplicate key, etc. ALWAYS check file status.
       01  WS-FILE-STATUSES.
           05  WS-ACCT-FILE-STATUS       PIC X(2).
               88  WS-ACCT-OK            VALUE "00".
               88  WS-ACCT-DUP-KEY       VALUE "22".
               88  WS-ACCT-NOT-FOUND     VALUE "23".
               88  WS-ACCT-EOF           VALUE "10".
           05  WS-RPT-FILE-STATUS        PIC X(2).
           05  WS-INPUT-FILE-STATUS      PIC X(2).
               88  WS-INPUT-EOF          VALUE "10".

      *    ---- Error Handling ----
       COPY ERRCODES.

      *    ---- Date Utilities ----
       COPY DATEUTIL.

      *    ---- Program Control ----
       01  WS-PROGRAM-FLAGS.
           05  WS-OPERATION              PIC X(6).
               88  WS-OP-CREATE          VALUE "CREATE".
               88  WS-OP-READ            VALUE "READ  ".
               88  WS-OP-UPDATE          VALUE "UPDATE".
               88  WS-OP-DELETE          VALUE "DELETE".
               88  WS-OP-LIST            VALUE "LIST  ".
               88  WS-OP-LOAD            VALUE "LOAD  ".
           05  WS-EOF-FLAG               PIC X(1) VALUE "N".
               88  WS-END-OF-FILE        VALUE "Y".
           05  WS-FILE-OPEN-FLAG         PIC X(1) VALUE "N".
               88  WS-FILE-IS-OPEN       VALUE "Y".

      *    ---- Counters ----
       01  WS-COUNTERS.
           05  WS-RECORDS-READ           PIC 9(7) VALUE ZEROS.
           05  WS-RECORDS-WRITTEN        PIC 9(7) VALUE ZEROS.
           05  WS-RECORDS-UPDATED        PIC 9(7) VALUE ZEROS.
           05  WS-RECORDS-DELETED        PIC 9(7) VALUE ZEROS.
           05  WS-RECORDS-ERRORS         PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-BALANCE          PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.

      *    ---- Report Lines ----
       01  WS-REPORT-HEADER-1.
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  FILLER  PIC X(50) VALUE
               "ACCOUNT MASTER FILE LISTING".
           05  FILLER  PIC X(20) VALUE SPACES.
           05  FILLER  PIC X(6)  VALUE "DATE: ".
           05  WS-RPT-DATE PIC X(10).
           05  FILLER  PIC X(45) VALUE SPACES.

       01  WS-REPORT-HEADER-2.
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  FILLER  PIC X(131) VALUE ALL "=".

       01  WS-REPORT-DETAIL.
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  WS-RPT-ACCT     PIC X(16).
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  WS-RPT-TYPE     PIC X(2).
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  WS-RPT-STATUS   PIC X(1).
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  WS-RPT-NAME     PIC X(30).
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  WS-RPT-BALANCE  PIC $$$,$$$,$$$,$$9.99-.
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  WS-RPT-AVAIL    PIC $$$,$$$,$$$,$$9.99-.
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  WS-RPT-OPENED   PIC X(10).
           05  FILLER  PIC X(20) VALUE SPACES.

       01  WS-REPORT-FOOTER.
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  FILLER  PIC X(131) VALUE ALL "-".

       01  WS-REPORT-TOTAL.
           05  FILLER  PIC X(1)  VALUE SPACES.
           05  FILLER  PIC X(25) VALUE "TOTAL ACCOUNTS: ".
           05  WS-RPT-TOTAL-CT PIC ZZ,ZZ9.
           05  FILLER  PIC X(10) VALUE SPACES.
           05  FILLER  PIC X(20) VALUE "TOTAL BALANCE: ".
           05  WS-RPT-TOTAL-BAL PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER  PIC X(41) VALUE SPACES.

      *    ---- Input Parsing ----
      *    COBOL LESSON: UNSTRING splits a delimited string
      *    into individual fields. This is how COBOL parses
      *    CSV-like input data.
       01  WS-INPUT-FIELDS.
           05  WS-INP-OPERATION          PIC X(6).
           05  WS-INP-ACCT-NUM           PIC X(16).
           05  WS-INP-ACCT-TYPE          PIC X(2).
           05  WS-INP-CUST-ID            PIC X(12).
           05  WS-INP-LAST-NAME          PIC X(30).
           05  WS-INP-FIRST-NAME         PIC X(20).
           05  WS-INP-BALANCE            PIC X(15).
           05  WS-INP-BALANCE-NUM        PIC S9(13)V99 COMP-3.

      *    ---- Inline Data for Demo ----
      *    COBOL LESSON: In production, data comes from tape,
      *    disk, or database. For this demo, we'll generate
      *    sample accounts programmatically.
       01  WS-SAMPLE-ACCOUNTS.
           05  WS-SAMPLE-COUNT           PIC 9(2) VALUE 10.
           05  WS-SAMPLE-IDX             PIC 9(2).

       01  WS-LINE-COUNT                 PIC 9(3) VALUE ZEROS.
       01  WS-PAGE-COUNT                 PIC 9(3) VALUE ZEROS.

       PROCEDURE DIVISION.

      ******************************************************************
      * MAIN CONTROL - Entry point
      *
      * COBOL LESSON: The PROCEDURE DIVISION is where the logic
      * lives. It's organized into paragraphs (like functions).
      * PERFORM is COBOL's subroutine call. PERFORM THRU lets
      * you execute a range of paragraphs.
      ******************************************************************
       0000-MAIN-CONTROL.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-LOAD-SAMPLE-DATA
           PERFORM 3000-LIST-ALL-ACCOUNTS
           PERFORM 4000-DEMONSTRATE-OPERATIONS
           PERFORM 9000-TERMINATE
           STOP RUN
           .

      ******************************************************************
      * INITIALIZATION
      ******************************************************************
       1000-INITIALIZE.
           DISPLAY "================================================"
           DISPLAY "  ACCTMSTR - Account Master File Manager"
           DISPLAY "  COBOL Banking Masterclass"
           DISPLAY "================================================"
           DISPLAY SPACES

      *    Get current date using intrinsic function
      *    COBOL LESSON: FUNCTION CURRENT-DATE returns a
      *    21-character string: YYYYMMDDHHMMSSHHGMTOFFSET
           MOVE FUNCTION CURRENT-DATE(1:8)
               TO WS-CURRENT-DATE-INT
           MOVE FUNCTION CURRENT-DATE(9:8)
               TO WS-CURRENT-TIME-FULL

           STRING WS-CURRENT-MM "/" WS-CURRENT-DD "/"
                  WS-CURRENT-YYYY
               DELIMITED BY SIZE
               INTO WS-RPT-DATE

           DISPLAY "Run Date: " WS-RPT-DATE
           DISPLAY "Run Time: " WS-CURRENT-HH ":"
                   WS-CURRENT-MI ":" WS-CURRENT-SS
           DISPLAY SPACES

      *    Open the account master file for I/O
           OPEN I-O ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS NOT = "00"
                   AND WS-ACCT-FILE-STATUS NOT = "05"
               DISPLAY "Account file not found, creating new..."
               OPEN OUTPUT ACCOUNT-FILE
               IF WS-ACCT-FILE-STATUS NOT = "00"
                   DISPLAY "FATAL: Cannot create account file"
                   DISPLAY "File Status: " WS-ACCT-FILE-STATUS
                   STOP RUN
               END-IF
               CLOSE ACCOUNT-FILE
               OPEN I-O ACCOUNT-FILE
           END-IF

           SET WS-FILE-IS-OPEN TO TRUE
           DISPLAY "Account Master File opened successfully."
           DISPLAY SPACES
           .

      ******************************************************************
      * LOAD SAMPLE DATA
      *
      * COBOL LESSON: This demonstrates WRITE with indexed files.
      * Each WRITE adds a record and updates the index automatically.
      * The INVALID KEY clause catches duplicate key errors.
      ******************************************************************
       2000-LOAD-SAMPLE-DATA.
           DISPLAY "Loading sample account data..."
           DISPLAY SPACES

           PERFORM 2100-CREATE-ACCOUNT-1
           PERFORM 2200-CREATE-ACCOUNT-2
           PERFORM 2300-CREATE-ACCOUNT-3
           PERFORM 2400-CREATE-ACCOUNT-4
           PERFORM 2500-CREATE-ACCOUNT-5
           PERFORM 2600-CREATE-ACCOUNT-6

           DISPLAY "Loaded " WS-RECORDS-WRITTEN " accounts."
           DISPLAY "Errors: " WS-RECORDS-ERRORS
           DISPLAY SPACES
           .

       2100-CREATE-ACCOUNT-1.
      *    Checking account - standard customer
           INITIALIZE ACCOUNT-MASTER-RECORD
           MOVE "BNKA000100000011" TO ACCT-NUMBER
           SET ACCT-IS-CHECKING         TO TRUE
           SET ACCT-ACTIVE               TO TRUE
           MOVE "CUST00000001"    TO ACCT-CUST-ID
           MOVE "JOHNSON"         TO ACCT-LAST-NAME
           MOVE "ROBERT"          TO ACCT-FIRST-NAME
           MOVE "M"               TO ACCT-MIDDLE-INIT
           MOVE "555-01-2345"     TO ACCT-CUST-SSN
           MOVE 19780315          TO ACCT-CUST-DOB
           MOVE "(555) 123-4567"  TO ACCT-CUST-PHONE
           MOVE "rjohnson@email.com" TO ACCT-CUST-EMAIL
           MOVE "123 Main Street" TO ACCT-ADDR-LINE1
           MOVE "Apt 4B"          TO ACCT-ADDR-LINE2
           MOVE "Springfield"     TO ACCT-ADDR-CITY
           MOVE "IL"              TO ACCT-ADDR-STATE
           MOVE "62701"           TO ACCT-ADDR-ZIP
           MOVE 15234.67          TO ACCT-CURRENT-BAL
           MOVE 14734.67          TO ACCT-AVAILABLE-BAL
           MOVE 500.00            TO ACCT-HOLD-AMOUNT
           MOVE 0.0025            TO ACCT-INTEREST-RATE
           MOVE 500.00            TO ACCT-OVERDRAFT-LIMIT
           MOVE 20150610          TO ACCT-OPEN-DATE
           MOVE 20260328          TO ACCT-LAST-TXN-DATE
           MOVE 47                TO ACCT-TXN-COUNT-MTD
           MOVE 523               TO ACCT-TXN-COUNT-YTD
           SET ACCT-STMT-ELECTRONIC      TO TRUE
           SET ACCT-OD-PROTECTED         TO TRUE
           PERFORM 2900-WRITE-ACCOUNT
           .

       2200-CREATE-ACCOUNT-2.
      *    Savings account - same customer
           INITIALIZE ACCOUNT-MASTER-RECORD
           MOVE "BNKA000100000028" TO ACCT-NUMBER
           SET ACCT-IS-SAVINGS            TO TRUE
           SET ACCT-ACTIVE                TO TRUE
           MOVE "CUST00000001"     TO ACCT-CUST-ID
           MOVE "JOHNSON"          TO ACCT-LAST-NAME
           MOVE "ROBERT"           TO ACCT-FIRST-NAME
           MOVE "M"                TO ACCT-MIDDLE-INIT
           MOVE 87432.15           TO ACCT-CURRENT-BAL
           MOVE 87432.15           TO ACCT-AVAILABLE-BAL
           MOVE 0.0425             TO ACCT-INTEREST-RATE
           MOVE 342.87             TO ACCT-ACCRUED-INT
           MOVE 1523.44            TO ACCT-YTD-INTEREST
           MOVE 100.00             TO ACCT-MIN-BALANCE
           MOVE 20150610           TO ACCT-OPEN-DATE
           MOVE 20260325           TO ACCT-LAST-TXN-DATE
           SET ACCT-STMT-ELECTRONIC       TO TRUE
           PERFORM 2900-WRITE-ACCOUNT
           .

       2300-CREATE-ACCOUNT-3.
      *    Money Market - high net worth
           INITIALIZE ACCOUNT-MASTER-RECORD
           MOVE "BNKA000200000035" TO ACCT-NUMBER
           SET ACCT-IS-MONEY-MARKET       TO TRUE
           SET ACCT-ACTIVE                TO TRUE
           MOVE "CUST00000002"     TO ACCT-CUST-ID
           MOVE "CHEN"             TO ACCT-LAST-NAME
           MOVE "LISA"             TO ACCT-FIRST-NAME
           MOVE "W"                TO ACCT-MIDDLE-INIT
           MOVE 523891.42          TO ACCT-CURRENT-BAL
           MOVE 523891.42          TO ACCT-AVAILABLE-BAL
           MOVE 0.0485             TO ACCT-INTEREST-RATE
           MOVE 2104.56            TO ACCT-ACCRUED-INT
           MOVE 8456.23            TO ACCT-YTD-INTEREST
           MOVE 10000.00           TO ACCT-MIN-BALANCE
           MOVE 20200115           TO ACCT-OPEN-DATE
           SET ACCT-IS-VIP                TO TRUE
           SET ACCT-STMT-BOTH             TO TRUE
           PERFORM 2900-WRITE-ACCOUNT
           .

       2400-CREATE-ACCOUNT-4.
      *    CD Account - locked term
           INITIALIZE ACCOUNT-MASTER-RECORD
           MOVE "BNKA000200000042" TO ACCT-NUMBER
           SET ACCT-IS-CD                 TO TRUE
           SET ACCT-ACTIVE                TO TRUE
           MOVE "CUST00000002"     TO ACCT-CUST-ID
           MOVE "CHEN"             TO ACCT-LAST-NAME
           MOVE "LISA"             TO ACCT-FIRST-NAME
           MOVE 250000.00          TO ACCT-CURRENT-BAL
           MOVE 0.00               TO ACCT-AVAILABLE-BAL
           MOVE 0.0510             TO ACCT-INTEREST-RATE
           MOVE 1062.50            TO ACCT-ACCRUED-INT
           MOVE 20250601           TO ACCT-OPEN-DATE
           MOVE 20260601           TO ACCT-MATURITY-DATE
           SET ACCT-STMT-ELECTRONIC       TO TRUE
           PERFORM 2900-WRITE-ACCOUNT
           .

       2500-CREATE-ACCOUNT-5.
      *    Frozen account - suspicious activity
           INITIALIZE ACCOUNT-MASTER-RECORD
           MOVE "BNKA000300000059" TO ACCT-NUMBER
           SET ACCT-IS-CHECKING           TO TRUE
           SET ACCT-FROZEN                TO TRUE
           MOVE "CUST00000003"     TO ACCT-CUST-ID
           MOVE "MARTINEZ"         TO ACCT-LAST-NAME
           MOVE "CARLOS"           TO ACCT-FIRST-NAME
           MOVE 8234.50            TO ACCT-CURRENT-BAL
           MOVE 0.00               TO ACCT-AVAILABLE-BAL
           MOVE 20180901           TO ACCT-OPEN-DATE
           MOVE 3                  TO ACCT-NSF-COUNT-YTD
           SET ACCT-STMT-PAPER            TO TRUE
           PERFORM 2900-WRITE-ACCOUNT
           .

       2600-CREATE-ACCOUNT-6.
      *    Dormant account - no activity
           INITIALIZE ACCOUNT-MASTER-RECORD
           MOVE "BNKA000400000066" TO ACCT-NUMBER
           SET ACCT-IS-SAVINGS            TO TRUE
           SET ACCT-DORMANT               TO TRUE
           MOVE "CUST00000004"     TO ACCT-CUST-ID
           MOVE "WILLIAMS"         TO ACCT-LAST-NAME
           MOVE "SARAH"            TO ACCT-FIRST-NAME
           MOVE "A"                TO ACCT-MIDDLE-INIT
           MOVE 156.33             TO ACCT-CURRENT-BAL
           MOVE 156.33             TO ACCT-AVAILABLE-BAL
           MOVE 0.0025             TO ACCT-INTEREST-RATE
           MOVE 20100305           TO ACCT-OPEN-DATE
           MOVE 20230101           TO ACCT-LAST-TXN-DATE
           SET ACCT-ESCHEAT-RISK          TO TRUE
           SET ACCT-STMT-PAPER            TO TRUE
           PERFORM 2900-WRITE-ACCOUNT
           .

       2900-WRITE-ACCOUNT.
      *    COBOL LESSON: WRITE with INVALID KEY handles the case
      *    where the record key already exists. This is how you
      *    prevent duplicate accounts.
           WRITE ACCOUNT-MASTER-RECORD
               INVALID KEY
                   IF WS-ACCT-DUP-KEY
                       DISPLAY "  SKIP: Account " ACCT-NUMBER
                               " already exists"
                   ELSE
                       DISPLAY "  ERROR: Write failed for "
                               ACCT-NUMBER
                               " Status: " WS-ACCT-FILE-STATUS
                       ADD 1 TO WS-RECORDS-ERRORS
                   END-IF
               NOT INVALID KEY
                   ADD 1 TO WS-RECORDS-WRITTEN
                   DISPLAY "  OK: Created account " ACCT-NUMBER
                           " (" ACCT-LAST-NAME ")"
           END-WRITE
           .

      ******************************************************************
      * LIST ALL ACCOUNTS - Demonstrates sequential reading
      *
      * COBOL LESSON: START positions the file pointer, then
      * READ NEXT walks through records in key sequence.
      * This is how batch reports are generated - read every
      * record, format it, write it to the report file.
      ******************************************************************
       3000-LIST-ALL-ACCOUNTS.
           DISPLAY SPACES
           DISPLAY "Generating Account Listing Report..."
           DISPLAY SPACES

           OPEN OUTPUT REPORT-FILE
           MOVE ZEROS TO WS-RECORDS-READ
           MOVE ZEROS TO WS-TOTAL-BALANCE
           MOVE "N" TO WS-EOF-FLAG

      *    Write report headers
           WRITE REPORT-LINE FROM WS-REPORT-HEADER-1
           WRITE REPORT-LINE FROM WS-REPORT-HEADER-2

      *    COBOL LESSON: START positions to the beginning
           MOVE LOW-VALUES TO ACCT-NUMBER
           START ACCOUNT-FILE KEY IS NOT LESS THAN ACCT-NUMBER
               INVALID KEY
                   DISPLAY "  No accounts found."
                   CLOSE REPORT-FILE
                   EXIT PARAGRAPH
           END-START

      *    Read all records sequentially
           PERFORM UNTIL WS-END-OF-FILE
               READ ACCOUNT-FILE NEXT
                   AT END
                       SET WS-END-OF-FILE TO TRUE
                   NOT AT END
                       PERFORM 3100-FORMAT-DETAIL-LINE
               END-READ
           END-PERFORM

      *    Write totals
           WRITE REPORT-LINE FROM WS-REPORT-FOOTER
           MOVE WS-RECORDS-READ TO WS-RPT-TOTAL-CT
           MOVE WS-TOTAL-BALANCE TO WS-RPT-TOTAL-BAL
           WRITE REPORT-LINE FROM WS-REPORT-TOTAL

           CLOSE REPORT-FILE

           DISPLAY "Report written to ACCTLIST.RPT"
           DISPLAY "Total accounts: " WS-RECORDS-READ
           DISPLAY "Total balance:  $" WS-TOTAL-BALANCE
           DISPLAY SPACES
           .

       3100-FORMAT-DETAIL-LINE.
           ADD 1 TO WS-RECORDS-READ
           ADD ACCT-CURRENT-BAL TO WS-TOTAL-BALANCE

      *    Format the detail line
      *    COBOL LESSON: MOVE with edited PIC ($ signs, commas,
      *    decimal points) automatically formats numbers for display.
      *    The $$$,$$$ pattern means the $ sign "floats" left.
           MOVE SPACES TO WS-REPORT-DETAIL
           MOVE ACCT-NUMBER      TO WS-RPT-ACCT
           MOVE ACCT-TYPE        TO WS-RPT-TYPE
           MOVE ACCT-STATUS      TO WS-RPT-STATUS
           MOVE ACCT-LAST-NAME   TO WS-RPT-NAME
           MOVE ACCT-CURRENT-BAL TO WS-RPT-BALANCE
           MOVE ACCT-AVAILABLE-BAL TO WS-RPT-AVAIL

      *    Format the open date
      *    COBOL LESSON: Reference modification (field(start:length))
      *    lets you access substrings. This is like substring() but
      *    with 1-based indexing.
           STRING ACCT-OPEN-DATE(5:2) "/"
                  ACCT-OPEN-DATE(7:2) "/"
                  ACCT-OPEN-DATE(1:4)
               DELIMITED BY SIZE
               INTO WS-RPT-OPENED

           WRITE REPORT-LINE FROM WS-REPORT-DETAIL

      *    Also display to console
           DISPLAY "  " ACCT-NUMBER " "
                   ACCT-TYPE " "
                   ACCT-STATUS " "
                   ACCT-LAST-NAME(1:15) " "
                   WS-RPT-BALANCE
           .

      ******************************************************************
      * DEMONSTRATE OPERATIONS - Shows CRUD operations
      ******************************************************************
       4000-DEMONSTRATE-OPERATIONS.
           DISPLAY "================================================"
           DISPLAY "  Demonstrating Account Operations"
           DISPLAY "================================================"
           DISPLAY SPACES

      *    ---- READ: Random access by key ----
           DISPLAY "--- READ Operation ---"
           MOVE "BNKA000100000011" TO ACCT-NUMBER
           READ ACCOUNT-FILE
               INVALID KEY
                   DISPLAY "Account not found: " ACCT-NUMBER
               NOT INVALID KEY
                   DISPLAY "Found: " ACCT-LAST-NAME
                           ", " ACCT-FIRST-NAME
                   DISPLAY "  Balance: " ACCT-CURRENT-BAL
                   DISPLAY "  Type:    " ACCT-TYPE
                   DISPLAY "  Status:  " ACCT-STATUS
           END-READ
           DISPLAY SPACES

      *    ---- UPDATE: Modify an existing record ----
      *    COBOL LESSON: To update an indexed file, you READ it
      *    (which locks the record), modify it, then REWRITE it.
           DISPLAY "--- UPDATE Operation ---"
           MOVE "BNKA000100000011" TO ACCT-NUMBER
           READ ACCOUNT-FILE
               INVALID KEY
                   DISPLAY "Cannot update: account not found"
               NOT INVALID KEY
                   DISPLAY "Before update - Balance: "
                           ACCT-CURRENT-BAL
                   ADD 1500.00 TO ACCT-CURRENT-BAL
                   ADD 1500.00 TO ACCT-AVAILABLE-BAL
                   MOVE WS-CURRENT-DATE-INT
                       TO ACCT-LAST-TXN-DATE
                   ADD 1 TO ACCT-TXN-COUNT-MTD
                   REWRITE ACCOUNT-MASTER-RECORD
                       INVALID KEY
                           DISPLAY "REWRITE failed: "
                                   WS-ACCT-FILE-STATUS
                       NOT INVALID KEY
                           DISPLAY "After update  - Balance: "
                                   ACCT-CURRENT-BAL
                           ADD 1 TO WS-RECORDS-UPDATED
                   END-REWRITE
           END-READ
           DISPLAY SPACES

      *    ---- READ: Verify the update ----
           DISPLAY "--- Verify Update ---"
           MOVE "BNKA000100000011" TO ACCT-NUMBER
           READ ACCOUNT-FILE
               INVALID KEY
                   DISPLAY "Verification failed!"
               NOT INVALID KEY
                   DISPLAY "Verified Balance: " ACCT-CURRENT-BAL
                   DISPLAY "Last Txn Date:    " ACCT-LAST-TXN-DATE
           END-READ
           DISPLAY SPACES

      *    ---- Demonstrate reading a frozen account ----
           DISPLAY "--- Business Rule: Frozen Account ---"
           MOVE "BNKA000300000059" TO ACCT-NUMBER
           READ ACCOUNT-FILE
               INVALID KEY
                   DISPLAY "Account not found"
               NOT INVALID KEY
      *            COBOL LESSON: Using 88-level conditions for
      *            business rules. This reads like English.
                   EVALUATE TRUE
                       WHEN ACCT-FROZEN
                           DISPLAY "BLOCKED: Account "
                                   ACCT-NUMBER " is FROZEN"
                           DISPLAY "  Owner: " ACCT-LAST-NAME
                                   ", " ACCT-FIRST-NAME
                           DISPLAY "  Balance: "
                                   ACCT-CURRENT-BAL
                           DISPLAY "  No transactions permitted"
                       WHEN ACCT-DORMANT
                           DISPLAY "WARNING: Account is DORMANT"
                       WHEN ACCT-CLOSED
                           DISPLAY "BLOCKED: Account is CLOSED"
                       WHEN ACCT-ACTIVE
                           DISPLAY "Account is active"
                   END-EVALUATE
           END-READ
           DISPLAY SPACES
           .

      ******************************************************************
      * TERMINATION - Close files and display summary
      ******************************************************************
       9000-TERMINATE.
           DISPLAY "================================================"
           DISPLAY "  Processing Summary"
           DISPLAY "================================================"
           DISPLAY "  Records Written:  " WS-RECORDS-WRITTEN
           DISPLAY "  Records Updated:  " WS-RECORDS-UPDATED
           DISPLAY "  Records Read:     " WS-RECORDS-READ
           DISPLAY "  Errors:           " WS-RECORDS-ERRORS
           DISPLAY "================================================"
           DISPLAY SPACES

           IF WS-FILE-IS-OPEN
               CLOSE ACCOUNT-FILE
               DISPLAY "Account Master File closed."
           END-IF

           DISPLAY "ACCTMSTR completed successfully."
           DISPLAY SPACES
           .
