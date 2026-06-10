      ******************************************************************
      * TXNPROC.cbl - Transaction Processor
      *
      * The heart of any banking system. This program reads a batch
      * of transactions, validates them, applies them to accounts,
      * and generates an audit trail. In real banks, this runs in
      * the "nightly batch window" - typically 11 PM to 5 AM.
      *
      * COBOL LESSON: Batch processing is COBOL's superpower.
      * While modern systems process one request at a time,
      * COBOL batch systems tear through millions of records
      * with incredible efficiency. No connection overhead,
      * no serialization, no garbage collection pauses.
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.    TXNPROC.
       AUTHOR.        COBOL-BANKING-MASTERCLASS.
       DATE-WRITTEN.  2026-03-29.

       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
       REPOSITORY.
           FUNCTION ALL INTRINSIC.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TRANSACTION-FILE
               ASSIGN TO "TXNINPUT.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-TXN-FILE-STATUS.

           SELECT ACCOUNT-FILE
               ASSIGN TO "ACCTMAST.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS RANDOM
               RECORD KEY IS ACCT-NUMBER
               FILE STATUS IS WS-ACCT-FILE-STATUS.

           SELECT AUDIT-FILE
               ASSIGN TO "AUDITLOG.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-AUDIT-FILE-STATUS.

           SELECT REJECT-FILE
               ASSIGN TO "TXNREJECT.DAT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-REJ-FILE-STATUS.

           SELECT SORT-FILE
               ASSIGN TO "TXNSORT.TMP".

       DATA DIVISION.

       FILE SECTION.

       FD  TRANSACTION-FILE.
       01  TXN-INPUT-RECORD              PIC X(400).

       FD  ACCOUNT-FILE.
       COPY ACCTREC.

       FD  AUDIT-FILE.
       COPY AUDITREC.

       FD  REJECT-FILE.
       01  REJECT-RECORD.
           05  REJ-ORIGINAL-TXN          PIC X(400).
           05  REJ-ERROR-CODE            PIC X(4).
           05  REJ-ERROR-DESC            PIC X(80).

      *    COBOL LESSON: SD (Sort Description) defines the work
      *    file used by the SORT verb. COBOL has built-in sorting -
      *    no need for external sort utilities.
       SD  SORT-FILE.
       01  SORT-RECORD.
           05  SORT-TXN-DATE             PIC 9(8).
           05  SORT-TXN-TIME             PIC 9(8).
           05  SORT-TXN-TYPE             PIC X(3).
           05  SORT-TXN-REST             PIC X(381).

       WORKING-STORAGE SECTION.

      *    ---- File Status Codes ----
       01  WS-FILE-STATUSES.
           05  WS-TXN-FILE-STATUS        PIC X(2).
               88  WS-TXN-OK             VALUE "00".
               88  WS-TXN-EOF            VALUE "10".
           05  WS-ACCT-FILE-STATUS       PIC X(2).
               88  WS-ACCT-OK            VALUE "00".
               88  WS-ACCT-NOT-FOUND     VALUE "23".
           05  WS-AUDIT-FILE-STATUS      PIC X(2).
           05  WS-REJ-FILE-STATUS        PIC X(2).

      *    ---- Transaction Working Record ----
       COPY TXNREC.
       01  WS-PREV-BALANCE              PIC S9(13)V99 COMP-3.

      *    ---- Error Handling ----
       COPY ERRCODES.

      *    ---- Date Utilities ----
       COPY DATEUTIL.

      *    ---- Batch Control ----
       01  WS-BATCH-CONTROL.
           05  WS-BATCH-NUMBER           PIC 9(8).
           05  WS-BATCH-DATE             PIC 9(8).
           05  WS-BATCH-START-TIME       PIC 9(8).
           05  WS-BATCH-END-TIME         PIC 9(8).

      *    ---- Processing Counters ----
       01  WS-COUNTERS.
           05  WS-TXN-READ              PIC 9(9) VALUE ZEROS.
           05  WS-TXN-PROCESSED         PIC 9(9) VALUE ZEROS.
           05  WS-TXN-REJECTED          PIC 9(9) VALUE ZEROS.
           05  WS-TXN-DEPOSITS          PIC 9(9) VALUE ZEROS.
           05  WS-TXN-WITHDRAWALS       PIC 9(9) VALUE ZEROS.
           05  WS-TXN-TRANSFERS         PIC 9(9) VALUE ZEROS.
           05  WS-TXN-PAYMENTS          PIC 9(9) VALUE ZEROS.
           05  WS-TXN-FEES              PIC 9(9) VALUE ZEROS.
           05  WS-TXN-REVERSALS         PIC 9(9) VALUE ZEROS.

      *    ---- Financial Totals ----
      *    COBOL LESSON: Maintaining running totals is critical
      *    for batch balancing. At end of day, total debits must
      *    equal total credits (double-entry bookkeeping).
       01  WS-FINANCIAL-TOTALS.
           05  WS-TOTAL-DEBITS           PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-TOTAL-CREDITS          PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-TOTAL-FEES             PIC S9(13)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-NET-POSITION           PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.

      *    ---- Validation Flags ----
       01  WS-VALIDATION.
           05  WS-VALID-FLAG             PIC X(1).
               88  WS-TXN-IS-VALID       VALUE "Y".
               88  WS-TXN-IS-INVALID     VALUE "N".
           05  WS-VAL-ERROR-CODE         PIC X(4).
           05  WS-VAL-ERROR-MSG          PIC X(80).

      *    ---- Processing Control ----
       01  WS-FLAGS.
           05  WS-EOF-FLAG               PIC X(1) VALUE "N".
               88  WS-END-OF-INPUT       VALUE "Y".
           05  WS-DEBIT-FLAG             PIC X(1).
               88  WS-IS-DEBIT           VALUE "Y".
               88  WS-IS-CREDIT          VALUE "N".

      *    ---- Audit Fields ----
       01  WS-AUDIT-SEQ                  PIC 9(12) VALUE ZEROS.
       01  WS-AUDIT-HASH                 PIC X(32) VALUE SPACES.

      *    ---- Display Formatting ----
       01  WS-DISPLAY-AMT               PIC $$$,$$$,$$$,$$9.99-.
       01  WS-DISPLAY-BAL               PIC $$$,$$$,$$$,$$9.99-.
       01  WS-DISPLAY-CNT               PIC ZZZ,ZZZ,ZZ9.

       PROCEDURE DIVISION.

      ******************************************************************
      * MAIN CONTROL
      ******************************************************************
       0000-MAIN-CONTROL.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-GENERATE-TRANSACTIONS
           PERFORM 3000-PROCESS-TRANSACTIONS
           PERFORM 8000-DISPLAY-BATCH-TOTALS
           PERFORM 9000-TERMINATE
           STOP RUN
           .

      ******************************************************************
      * INITIALIZATION
      ******************************************************************
       1000-INITIALIZE.
           DISPLAY "================================================"
           DISPLAY "  TXNPROC - Transaction Processor"
           DISPLAY "  COBOL Banking Masterclass"
           DISPLAY "================================================"
           DISPLAY SPACES

           MOVE FUNCTION CURRENT-DATE(1:8)
               TO WS-CURRENT-DATE-INT
           MOVE FUNCTION CURRENT-DATE(1:8)
               TO WS-BATCH-DATE
           MOVE FUNCTION CURRENT-DATE(9:8)
               TO WS-BATCH-START-TIME

      *    Generate batch number from date + sequence
           STRING WS-CURRENT-DATE-INT
               DELIMITED BY SIZE
               INTO WS-BATCH-NUMBER

           DISPLAY "Batch Number: " WS-BATCH-NUMBER
           DISPLAY "Batch Date:   " WS-BATCH-DATE
           DISPLAY SPACES

      *    Open account file for I/O
           OPEN I-O ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS NOT = "00"
               DISPLAY "FATAL: Cannot open Account Master File"
               DISPLAY "Status: " WS-ACCT-FILE-STATUS
               STOP RUN
           END-IF

      *    Open audit trail file
           OPEN OUTPUT AUDIT-FILE
           IF WS-AUDIT-FILE-STATUS NOT = "00"
               DISPLAY "WARNING: Cannot open Audit File"
           END-IF

      *    Open reject file
           OPEN OUTPUT REJECT-FILE

           DISPLAY "Files opened successfully."
           DISPLAY SPACES
           .

      ******************************************************************
      * GENERATE SAMPLE TRANSACTIONS
      *
      * In production, transactions come from ATMs, online banking,
      * branch tellers, ACH networks, and wire transfer systems.
      * We generate a realistic batch for demonstration.
      ******************************************************************
       2000-GENERATE-TRANSACTIONS.
           DISPLAY "Generating sample transactions..."

           OPEN OUTPUT TRANSACTION-FILE

      *    ---- Deposit to checking ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000001" TO TXN-ID
           SET TXN-DEPOSIT              TO TRUE
           SET TXN-CHANNEL-BRANCH       TO TRUE
           MOVE "BNKA000100000011"      TO TXN-ACCOUNT-NUM
           MOVE 2500.00                 TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "14230000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "Payroll Direct Deposit" TO TXN-DESCRIPTION
           MOVE "TLR00042"              TO TXN-TELLER-ID
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- ATM Withdrawal ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000002" TO TXN-ID
           SET TXN-ATM-WDR              TO TRUE
           SET TXN-CHANNEL-ATM          TO TRUE
           MOVE "BNKA000100000011"      TO TXN-ACCOUNT-NUM
           MOVE 200.00                  TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "18450000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "ATM WDR - 123 OAK ST"  TO TXN-DESCRIPTION
           MOVE "ATM00789"              TO TXN-TERMINAL-ID
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- Transfer between accounts ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000003" TO TXN-ID
           SET TXN-TRANSFER-OUT         TO TRUE
           SET TXN-CHANNEL-ONLINE       TO TRUE
           MOVE "BNKA000100000011"      TO TXN-ACCOUNT-NUM
           MOVE "BNKA000100000028"      TO TXN-CONTRA-ACCT
           MOVE 5000.00                 TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "20150000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "Online Transfer to Savings" TO TXN-DESCRIPTION
           MOVE "192.168.1.42"          TO TXN-IP-ADDRESS
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- Transfer IN (other side) ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000004" TO TXN-ID
           SET TXN-TRANSFER-IN          TO TRUE
           SET TXN-CHANNEL-ONLINE       TO TRUE
           MOVE "BNKA000100000028"      TO TXN-ACCOUNT-NUM
           MOVE "BNKA000100000011"      TO TXN-CONTRA-ACCT
           MOVE 5000.00                 TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "20150000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "Transfer from Checking" TO TXN-DESCRIPTION
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- Large wire transfer ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000005" TO TXN-ID
           SET TXN-WIRE-OUT             TO TRUE
           SET TXN-CHANNEL-WIRE         TO TRUE
           MOVE "BNKA000200000035"      TO TXN-ACCOUNT-NUM
           MOVE 150000.00               TO TXN-AMOUNT
           MOVE 25.00                   TO TXN-FEE-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "10300000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "Wire: Property Purchase Down Pmt"
                                        TO TXN-DESCRIPTION
           MOVE "AUTH8823"              TO TXN-AUTH-CODE
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- Transaction on FROZEN account (should reject) ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000006" TO TXN-ID
           SET TXN-WITHDRAWAL           TO TRUE
           SET TXN-CHANNEL-BRANCH       TO TRUE
           MOVE "BNKA000300000059"      TO TXN-ACCOUNT-NUM
           MOVE 500.00                  TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "09150000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "Branch Withdrawal"     TO TXN-DESCRIPTION
           MOVE "TLR00015"              TO TXN-TELLER-ID
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- Insufficient funds (should reject) ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000007" TO TXN-ID
           SET TXN-WITHDRAWAL           TO TRUE
           SET TXN-CHANNEL-ONLINE       TO TRUE
           MOVE "BNKA000400000066"      TO TXN-ACCOUNT-NUM
           MOVE 99999.99                TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "22000000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "Online Withdrawal"     TO TXN-DESCRIPTION
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- POS Purchase ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000008" TO TXN-ID
           SET TXN-POS-PURCHASE         TO TRUE
           SET TXN-CHANNEL-MOBILE       TO TRUE
           MOVE "BNKA000100000011"      TO TXN-ACCOUNT-NUM
           MOVE 89.47                   TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "12300000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "WHOLE FOODS MKT #1042" TO TXN-DESCRIPTION
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- Monthly maintenance fee ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000009" TO TXN-ID
           SET TXN-FEE                  TO TRUE
           SET TXN-CHANNEL-BRANCH       TO TRUE
           MOVE "BNKA000300000059"      TO TXN-ACCOUNT-NUM
           MOVE 12.00                   TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           MOVE "23590000"              TO TXN-TIME
           SET TXN-PENDING              TO TRUE
           MOVE "Monthly Maintenance Fee" TO TXN-DESCRIPTION
           MOVE "SYSTEM"                TO TXN-TELLER-ID
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

      *    ---- Account not found (should reject) ----
           INITIALIZE TRANSACTION-RECORD
           MOVE "20260329000100000010" TO TXN-ID
           SET TXN-DEPOSIT              TO TRUE
           SET TXN-CHANNEL-BRANCH       TO TRUE
           MOVE "BNKA999999999999"      TO TXN-ACCOUNT-NUM
           MOVE 100.00                  TO TXN-AMOUNT
           MOVE WS-BATCH-DATE           TO TXN-DATE
           SET TXN-PENDING              TO TRUE
           MOVE "Cash Deposit"          TO TXN-DESCRIPTION
           WRITE TXN-INPUT-RECORD FROM TRANSACTION-RECORD

           CLOSE TRANSACTION-FILE
           DISPLAY "Generated 10 sample transactions."
           DISPLAY SPACES
           .

      ******************************************************************
      * PROCESS TRANSACTIONS - Main processing loop
      *
      * COBOL LESSON: This is the classic batch processing pattern:
      * 1. Read a transaction
      * 2. Validate it
      * 3. Read the target account
      * 4. Apply business rules
      * 5. Update the account
      * 6. Write audit trail
      * 7. Repeat until end of file
      ******************************************************************
       3000-PROCESS-TRANSACTIONS.
           DISPLAY "================================================"
           DISPLAY "  Processing Transactions"
           DISPLAY "================================================"
           DISPLAY SPACES

           OPEN INPUT TRANSACTION-FILE
           IF WS-TXN-FILE-STATUS NOT = "00"
               DISPLAY "FATAL: Cannot open transaction file"
               STOP RUN
           END-IF

           MOVE "N" TO WS-EOF-FLAG

           PERFORM UNTIL WS-END-OF-INPUT
               READ TRANSACTION-FILE INTO TRANSACTION-RECORD
                   AT END
                       SET WS-END-OF-INPUT TO TRUE
                   NOT AT END
                       ADD 1 TO WS-TXN-READ
                       PERFORM 4000-VALIDATE-TRANSACTION
                       IF WS-TXN-IS-VALID
                           PERFORM 5000-APPLY-TRANSACTION
                       ELSE
                           PERFORM 7000-REJECT-TRANSACTION
                       END-IF
               END-READ
           END-PERFORM

           CLOSE TRANSACTION-FILE
           DISPLAY SPACES
           DISPLAY "Transaction processing complete."
           DISPLAY SPACES
           .

      ******************************************************************
      * VALIDATE TRANSACTION
      *
      * COBOL LESSON: EVALUATE TRUE is COBOL's pattern matching.
      * Unlike a switch/case, you can test completely different
      * conditions in each WHEN clause. EVALUATE TRUE ALSO TRUE
      * lets you test multiple conditions simultaneously.
      ******************************************************************
       4000-VALIDATE-TRANSACTION.
           SET WS-TXN-IS-VALID TO TRUE
           MOVE SPACES TO WS-VAL-ERROR-CODE
           MOVE SPACES TO WS-VAL-ERROR-MSG

      *    Check transaction type is valid
           IF NOT TXN-TYPE-VALID
               SET WS-TXN-IS-INVALID TO TRUE
               MOVE ERR-INVALID-TXN-TYPE TO WS-VAL-ERROR-CODE
               MOVE "Invalid transaction type"
                   TO WS-VAL-ERROR-MSG
               EXIT PARAGRAPH
           END-IF

      *    Check amount is valid
           IF TXN-AMOUNT <= ZEROS AND NOT TXN-REVERSAL
               SET WS-TXN-IS-INVALID TO TRUE
               MOVE ERR-INVALID-AMOUNT TO WS-VAL-ERROR-CODE
               MOVE "Transaction amount must be positive"
                   TO WS-VAL-ERROR-MSG
               EXIT PARAGRAPH
           END-IF

      *    Check account exists
           MOVE TXN-ACCOUNT-NUM TO ACCT-NUMBER
           READ ACCOUNT-FILE
               INVALID KEY
                   SET WS-TXN-IS-INVALID TO TRUE
                   MOVE ERR-ACCT-NOT-FOUND TO WS-VAL-ERROR-CODE
                   STRING "Account not found: "
                          TXN-ACCOUNT-NUM
                       DELIMITED BY "  "
                       INTO WS-VAL-ERROR-MSG
                   EXIT PARAGRAPH
           END-READ

      *    COBOL LESSON: EVALUATE TRUE ALSO TRUE tests
      *    two independent conditions at once. This is
      *    incredibly powerful for complex business rules.
           EVALUATE TRUE ALSO TRUE
      *        Frozen accounts - only fees allowed
               WHEN ACCT-FROZEN ALSO NOT TXN-FEE
                   SET WS-TXN-IS-INVALID TO TRUE
                   MOVE ERR-ACCT-FROZEN TO WS-VAL-ERROR-CODE
                   MOVE "Account is frozen - transaction blocked"
                       TO WS-VAL-ERROR-MSG

      *        Closed accounts - nothing allowed
               WHEN ACCT-CLOSED ALSO ANY
                   SET WS-TXN-IS-INVALID TO TRUE
                   MOVE ERR-ACCT-CLOSED TO WS-VAL-ERROR-CODE
                   MOVE "Account is closed"
                       TO WS-VAL-ERROR-MSG

      *        Dormant + large withdrawal = flag
               WHEN ACCT-DORMANT ALSO TXN-WITHDRAWAL
                   IF TXN-AMOUNT > 1000.00
                       SET WS-TXN-IS-INVALID TO TRUE
                       MOVE ERR-ACCT-DORMANT TO WS-VAL-ERROR-CODE
                       MOVE "Dormant acct: large withdrawal blocked"
                           TO WS-VAL-ERROR-MSG
                   END-IF

      *        All other cases are OK at this level
               WHEN OTHER
                   CONTINUE
           END-EVALUATE

      *    Check sufficient funds for debits
           IF WS-TXN-IS-VALID
               PERFORM 4100-CHECK-DEBIT-TYPE
               IF WS-IS-DEBIT
                   PERFORM 4200-CHECK-SUFFICIENT-FUNDS
               END-IF
           END-IF
           .

       4100-CHECK-DEBIT-TYPE.
      *    Determine if this transaction debits the account
      *    COBOL LESSON: SET with 88-levels is cleaner than
      *    MOVE "Y" TO WS-DEBIT-FLAG
           EVALUATE TRUE
               WHEN TXN-WITHDRAWAL
               WHEN TXN-TRANSFER-OUT
               WHEN TXN-WIRE-OUT
               WHEN TXN-ATM-WDR
               WHEN TXN-POS-PURCHASE
               WHEN TXN-CHECK
               WHEN TXN-ACH-DEBIT
               WHEN TXN-PAYMENT
                   SET WS-IS-DEBIT TO TRUE
               WHEN OTHER
                   SET WS-IS-CREDIT TO TRUE
           END-EVALUATE
           .

       4200-CHECK-SUFFICIENT-FUNDS.
      *    COBOL LESSON: Financial calculations use COMPUTE
      *    with packed decimal (COMP-3) for exact arithmetic.
      *    No floating point rounding errors.
           IF TXN-AMOUNT > ACCT-AVAILABLE-BAL
               IF ACCT-OD-PROTECTED
                   IF TXN-AMOUNT >
                       (ACCT-AVAILABLE-BAL + ACCT-OVERDRAFT-LIMIT)
                       SET WS-TXN-IS-INVALID TO TRUE
                       MOVE ERR-INSUFFICIENT-FUNDS
                           TO WS-VAL-ERROR-CODE
                       MOVE "Insufficient funds (exceeds OD limit)"
                           TO WS-VAL-ERROR-MSG
                   END-IF
               ELSE
                   SET WS-TXN-IS-INVALID TO TRUE
                   MOVE ERR-INSUFFICIENT-FUNDS
                       TO WS-VAL-ERROR-CODE
                   MOVE "Insufficient funds - no OD protection"
                       TO WS-VAL-ERROR-MSG
               END-IF
           END-IF
           .

      ******************************************************************
      * APPLY TRANSACTION
      *
      * COBOL LESSON: This is where the money moves. Notice
      * the before/after audit capture - every change to a
      * financial record must be traceable.
      ******************************************************************
       5000-APPLY-TRANSACTION.
      *    Re-read account (may have been read in validation)
           MOVE TXN-ACCOUNT-NUM TO ACCT-NUMBER
           READ ACCOUNT-FILE
               INVALID KEY
                   DISPLAY "SYSTEM ERROR: Account vanished!"
                   EXIT PARAGRAPH
           END-READ

      *    Save pre-transaction balance for audit
           MOVE ACCT-CURRENT-BAL TO WS-PREV-BALANCE

      *    Apply the transaction based on type
      *    COBOL LESSON: EVALUATE is far cleaner than
      *    nested IF/ELSE chains for multi-way branching.
           EVALUATE TRUE
               WHEN TXN-DEPOSIT
               WHEN TXN-TRANSFER-IN
               WHEN TXN-ACH-CREDIT
               WHEN TXN-WIRE-IN
               WHEN TXN-INTEREST
                   ADD TXN-AMOUNT TO ACCT-CURRENT-BAL
                   ADD TXN-AMOUNT TO ACCT-AVAILABLE-BAL
                   ADD TXN-AMOUNT TO WS-TOTAL-CREDITS
                   ADD 1 TO WS-TXN-DEPOSITS

               WHEN TXN-WITHDRAWAL
               WHEN TXN-TRANSFER-OUT
               WHEN TXN-ATM-WDR
               WHEN TXN-POS-PURCHASE
               WHEN TXN-CHECK
               WHEN TXN-ACH-DEBIT
               WHEN TXN-WIRE-OUT
               WHEN TXN-PAYMENT
                   SUBTRACT TXN-AMOUNT FROM ACCT-CURRENT-BAL
                   SUBTRACT TXN-AMOUNT FROM ACCT-AVAILABLE-BAL
                   ADD TXN-AMOUNT TO WS-TOTAL-DEBITS
                   ADD 1 TO WS-TXN-WITHDRAWALS

               WHEN TXN-FEE
      *            Fees can apply to frozen accounts
                   SUBTRACT TXN-AMOUNT FROM ACCT-CURRENT-BAL
                   ADD TXN-AMOUNT TO ACCT-YTD-FEES
                   ADD TXN-AMOUNT TO WS-TOTAL-FEES
                   ADD 1 TO WS-TXN-FEES

               WHEN TXN-REVERSAL
                   ADD TXN-AMOUNT TO ACCT-CURRENT-BAL
                   ADD TXN-AMOUNT TO ACCT-AVAILABLE-BAL
                   ADD 1 TO WS-TXN-REVERSALS

               WHEN TXN-ADJUSTMENT
                   ADD TXN-AMOUNT TO ACCT-CURRENT-BAL
                   ADD TXN-AMOUNT TO ACCT-AVAILABLE-BAL
           END-EVALUATE

      *    Apply wire fee if applicable
           IF TXN-FEE-AMOUNT > ZEROS
               SUBTRACT TXN-FEE-AMOUNT FROM ACCT-CURRENT-BAL
               ADD TXN-FEE-AMOUNT TO ACCT-YTD-FEES
               ADD TXN-FEE-AMOUNT TO WS-TOTAL-FEES
           END-IF

      *    Update activity counters
           ADD 1 TO ACCT-TXN-COUNT-MTD
           ADD 1 TO ACCT-TXN-COUNT-YTD
           MOVE TXN-DATE TO ACCT-LAST-TXN-DATE

      *    Check for overdraft
           IF ACCT-CURRENT-BAL < ZEROS
               ADD 1 TO ACCT-OD-COUNT-YTD
           END-IF

      *    Check for NSF (even if we processed it with OD protection)
           IF ACCT-AVAILABLE-BAL < ZEROS
               IF NOT ACCT-OD-PROTECTED
                   ADD 1 TO ACCT-NSF-COUNT-YTD
               END-IF
           END-IF

      *    Rewrite the updated account
           REWRITE ACCOUNT-MASTER-RECORD
               INVALID KEY
                   DISPLAY "FATAL: Cannot update account "
                           ACCT-NUMBER
                   DISPLAY "Status: " WS-ACCT-FILE-STATUS
                   EXIT PARAGRAPH
           END-REWRITE

           ADD 1 TO WS-TXN-PROCESSED

      *    Display transaction details
           MOVE TXN-AMOUNT TO WS-DISPLAY-AMT
           MOVE ACCT-CURRENT-BAL TO WS-DISPLAY-BAL
           DISPLAY "  POSTED: " TXN-TYPE " "
                   TXN-ACCOUNT-NUM(5:12) " "
                   WS-DISPLAY-AMT " -> Bal: "
                   WS-DISPLAY-BAL
                   "  " TXN-DESCRIPTION(1:30)

      *    Write audit trail
           PERFORM 6000-WRITE-AUDIT-TRAIL

      *    Mark transaction as posted
           SET TXN-POSTED TO TRUE
           .

      ******************************************************************
      * WRITE AUDIT TRAIL
      *
      * COBOL LESSON: Every financial transaction must have an
      * immutable audit record. This is not optional - it's
      * required by law (Bank Secrecy Act, SOX, etc).
      ******************************************************************
       6000-WRITE-AUDIT-TRAIL.
           ADD 1 TO WS-AUDIT-SEQ

           INITIALIZE AUDIT-TRAIL-RECORD
           MOVE WS-AUDIT-SEQ             TO AUDIT-SEQ-NUM
           MOVE FUNCTION CURRENT-DATE(1:8)
                                          TO AUDIT-DATE
           MOVE FUNCTION CURRENT-DATE(9:8)
                                          TO AUDIT-TIME
           MOVE WS-AUDIT-HASH            TO AUDIT-PREV-HASH
           SET AUDIT-UPDATE               TO TRUE
           SET AUDIT-ENTITY-ACCT          TO TRUE
           MOVE TXN-ACCOUNT-NUM          TO AUDIT-ENTITY-ID
           MOVE TXN-ID                   TO AUDIT-TXN-ID
           MOVE "TXNPROC"                TO AUDIT-PROGRAM-ID
           MOVE TXN-TELLER-ID            TO AUDIT-USER-ID
           MOVE TXN-TERMINAL-ID          TO AUDIT-TERMINAL-ID
           MOVE "CURRENT-BAL"            TO AUDIT-FIELD-NAME
           MOVE WS-PREV-BALANCE          TO WS-DISPLAY-BAL
           MOVE WS-DISPLAY-BAL           TO AUDIT-BEFORE-VALUE
           MOVE ACCT-CURRENT-BAL         TO WS-DISPLAY-BAL
           MOVE WS-DISPLAY-BAL           TO AUDIT-AFTER-VALUE
           MOVE ERR-SUCCESS              TO AUDIT-RESULT-CODE
           MOVE TXN-DESCRIPTION          TO AUDIT-DESCRIPTION

      *    COBOL LESSON: Simple hash chain for tamper detection.
      *    Each record's hash depends on the previous record.
      *    In production, this would use proper cryptographic hashing.
      *    INSPECT TALLYING counts characters - we use it to
      *    create a simple checksum.
           MOVE SPACES TO AUDIT-RECORD-HASH
           STRING WS-AUDIT-SEQ AUDIT-DATE AUDIT-TIME
               DELIMITED BY SIZE
               INTO AUDIT-RECORD-HASH
           MOVE AUDIT-RECORD-HASH TO WS-AUDIT-HASH

           WRITE AUDIT-TRAIL-RECORD
           .

      ******************************************************************
      * REJECT TRANSACTION
      ******************************************************************
       7000-REJECT-TRANSACTION.
           ADD 1 TO WS-TXN-REJECTED

           MOVE TXN-AMOUNT TO WS-DISPLAY-AMT
           DISPLAY "  REJECT: " TXN-TYPE " "
                   TXN-ACCOUNT-NUM(5:12) " "
                   WS-DISPLAY-AMT
                   " [" WS-VAL-ERROR-CODE "] "
                   WS-VAL-ERROR-MSG(1:40)

      *    Write to reject file for manual review
           INITIALIZE REJECT-RECORD
           MOVE TRANSACTION-RECORD TO REJ-ORIGINAL-TXN
           MOVE WS-VAL-ERROR-CODE  TO REJ-ERROR-CODE
           MOVE WS-VAL-ERROR-MSG   TO REJ-ERROR-DESC
           WRITE REJECT-RECORD
           .

      ******************************************************************
      * DISPLAY BATCH TOTALS
      *
      * COBOL LESSON: Batch balancing is critical. At end of
      * processing, you verify that everything adds up. If
      * debits != credits + fees, something went wrong and
      * the entire batch may need to be reversed.
      ******************************************************************
       8000-DISPLAY-BATCH-TOTALS.
           COMPUTE WS-NET-POSITION =
               WS-TOTAL-CREDITS - WS-TOTAL-DEBITS - WS-TOTAL-FEES

           DISPLAY SPACES
           DISPLAY "================================================"
           DISPLAY "  BATCH PROCESSING SUMMARY"
           DISPLAY "================================================"
           DISPLAY "  Batch Number:    " WS-BATCH-NUMBER
           DISPLAY "  Batch Date:      " WS-BATCH-DATE
           DISPLAY "------------------------------------------------"

           MOVE WS-TXN-READ      TO WS-DISPLAY-CNT
           DISPLAY "  Transactions Read:      " WS-DISPLAY-CNT
           MOVE WS-TXN-PROCESSED TO WS-DISPLAY-CNT
           DISPLAY "  Transactions Processed: " WS-DISPLAY-CNT
           MOVE WS-TXN-REJECTED  TO WS-DISPLAY-CNT
           DISPLAY "  Transactions Rejected:  " WS-DISPLAY-CNT
           DISPLAY "------------------------------------------------"
           DISPLAY "  By Type:"
           MOVE WS-TXN-DEPOSITS    TO WS-DISPLAY-CNT
           DISPLAY "    Credits:      " WS-DISPLAY-CNT
           MOVE WS-TXN-WITHDRAWALS TO WS-DISPLAY-CNT
           DISPLAY "    Debits:       " WS-DISPLAY-CNT
           MOVE WS-TXN-FEES        TO WS-DISPLAY-CNT
           DISPLAY "    Fees:         " WS-DISPLAY-CNT
           MOVE WS-TXN-REVERSALS   TO WS-DISPLAY-CNT
           DISPLAY "    Reversals:    " WS-DISPLAY-CNT
           DISPLAY "------------------------------------------------"

           MOVE WS-TOTAL-CREDITS TO WS-DISPLAY-AMT
           DISPLAY "  Total Credits:   " WS-DISPLAY-AMT
           MOVE WS-TOTAL-DEBITS  TO WS-DISPLAY-AMT
           DISPLAY "  Total Debits:    " WS-DISPLAY-AMT
           MOVE WS-TOTAL-FEES    TO WS-DISPLAY-AMT
           DISPLAY "  Total Fees:      " WS-DISPLAY-AMT
           MOVE WS-NET-POSITION  TO WS-DISPLAY-AMT
           DISPLAY "  Net Position:    " WS-DISPLAY-AMT
           DISPLAY "================================================"
           DISPLAY SPACES
           .

      ******************************************************************
      * TERMINATION
      ******************************************************************
       9000-TERMINATE.
           CLOSE ACCOUNT-FILE
           CLOSE AUDIT-FILE
           CLOSE REJECT-FILE

           MOVE FUNCTION CURRENT-DATE(9:8) TO WS-BATCH-END-TIME
           DISPLAY "Batch Start: " WS-BATCH-START-TIME(1:2) ":"
                   WS-BATCH-START-TIME(3:2) ":"
                   WS-BATCH-START-TIME(5:2)
           DISPLAY "Batch End:   " WS-BATCH-END-TIME(1:2) ":"
                   WS-BATCH-END-TIME(3:2) ":"
                   WS-BATCH-END-TIME(5:2)
           DISPLAY SPACES
           DISPLAY "TXNPROC completed successfully."
           .
