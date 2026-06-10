      ******************************************************************
      * VALENGN.cbl - Validation Engine
      *
      * A callable subprogram that validates account numbers,
      * transaction data, and implements the Luhn algorithm
      * (the same checksum used by every credit card number).
      *
      * COBOL LESSON: This demonstrates COBOL's modular
      * programming features:
      * - LINKAGE SECTION for parameter passing
      * - CALL BY REFERENCE vs BY CONTENT
      * - Nested programs
      * - Reusable validation logic
      *
      * The Luhn algorithm was patented in 1960 by Hans Peter
      * Luhn of IBM. It's still used today on every Visa,
      * Mastercard, and Amex card you've ever used.
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.    VALENGN.
       AUTHOR.        COBOL-BANKING-MASTERCLASS.
       DATE-WRITTEN.  2026-03-29.

       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
       REPOSITORY.
           FUNCTION ALL INTRINSIC.

       DATA DIVISION.

       WORKING-STORAGE SECTION.

      *    ---- Luhn Algorithm Working Fields ----
      *    COBOL LESSON: The Luhn algorithm doubles every other
      *    digit from right to left, subtracts 9 if result > 9,
      *    then sums all digits. Valid if sum mod 10 = 0.
       01  WS-LUHN-WORK.
           05  WS-LUHN-INPUT             PIC X(20).
           05  WS-LUHN-LENGTH            PIC 9(2).
           05  WS-LUHN-SUM               PIC 9(5).
           05  WS-LUHN-DIGIT             PIC 9(1).
           05  WS-LUHN-DOUBLED           PIC 9(2).
           05  WS-LUHN-IDX               PIC 9(2).
           05  WS-LUHN-POSITION          PIC 9(2).
           05  WS-LUHN-DOUBLE-FLAG       PIC X(1).
               88  WS-SHOULD-DOUBLE      VALUE "Y".
               88  WS-NO-DOUBLE          VALUE "N".
           05  WS-LUHN-REMAINDER         PIC 9(1).
           05  WS-LUHN-CHECK-DIGIT       PIC 9(1).

      *    ---- Date Validation Working Fields ----
       01  WS-DATE-VAL-WORK.
           05  WS-DV-DATE                PIC 9(8).
           05  WS-DV-DATE-R REDEFINES WS-DV-DATE.
               10  WS-DV-YYYY            PIC 9(4).
               10  WS-DV-MM              PIC 9(2).
               10  WS-DV-DD              PIC 9(2).
           05  WS-DV-LEAP-FLAG           PIC X(1).
               88  WS-DV-IS-LEAP         VALUE "Y".
               88  WS-DV-NOT-LEAP        VALUE "N".
           05  WS-DV-MAX-DAYS            PIC 9(2).
           05  WS-DV-DAYS-IN-MONTHS.
               10  FILLER PIC 9(2) VALUE 31.
               10  FILLER PIC 9(2) VALUE 28.
               10  FILLER PIC 9(2) VALUE 31.
               10  FILLER PIC 9(2) VALUE 30.
               10  FILLER PIC 9(2) VALUE 31.
               10  FILLER PIC 9(2) VALUE 30.
               10  FILLER PIC 9(2) VALUE 31.
               10  FILLER PIC 9(2) VALUE 31.
               10  FILLER PIC 9(2) VALUE 30.
               10  FILLER PIC 9(2) VALUE 31.
               10  FILLER PIC 9(2) VALUE 30.
               10  FILLER PIC 9(2) VALUE 31.
           05  WS-DV-DAYS-TABLE REDEFINES WS-DV-DAYS-IN-MONTHS.
               10  WS-DV-MONTH-DAYS      PIC 9(2)
                                          OCCURS 12 TIMES.

      *    ---- String Validation Working Fields ----
       01  WS-STRING-WORK.
           05  WS-STR-TALLY              PIC 9(5).
           05  WS-STR-IDX                PIC 9(5).
           05  WS-STR-CHAR               PIC X(1).

      *    ---- Account Number Validation ----
       01  WS-ACCT-VAL-WORK.
           05  WS-AV-BANK-CODE           PIC X(4).
           05  WS-AV-BRANCH-CODE         PIC X(4).
           05  WS-AV-SEQUENCE            PIC X(7).
           05  WS-AV-CHECK-DIGIT         PIC 9(1).
           05  WS-AV-COMPUTED-CHECK      PIC 9(1).

      *    ---- Validation Result ----
       01  WS-RESULT                     PIC X(1).
       01  WS-ERROR-CODE                 PIC X(4).
       01  WS-ERROR-DESC                 PIC X(80).

      *    ---- Error Codes ----
       COPY ERRCODES.

      *    ---- Constants ----
       01  WS-VALID-BANK-CODES.
      *    COBOL LESSON: OCCURS with VALUE defines a
      *    pre-populated table (array). Each entry is a
      *    valid bank routing prefix.
           05  FILLER PIC X(4) VALUE "BNKA".
           05  FILLER PIC X(4) VALUE "BNKB".
           05  FILLER PIC X(4) VALUE "BNKC".
           05  FILLER PIC X(4) VALUE "CRDU".
           05  FILLER PIC X(4) VALUE "SAVL".
       01  WS-BANK-TABLE REDEFINES WS-VALID-BANK-CODES.
           05  WS-BANK-CODE              PIC X(4) OCCURS 5 TIMES.
       01  WS-BANK-IDX                   PIC 9(1).
       01  WS-BANK-FOUND                 PIC X(1).

      *    ---- Linkage Section ----
      *    COBOL LESSON: LINKAGE SECTION defines parameters
      *    passed from the calling program via CALL. These
      *    variables don't have their own storage - they map
      *    to memory owned by the caller (BY REFERENCE) or
      *    to a copy (BY CONTENT).
       LINKAGE SECTION.

       01  LS-FUNCTION-CODE              PIC X(4).
      *    VACT = Validate Account Number
      *    VDAT = Validate Date
      *    VAMT = Validate Amount
      *    LUHN = Luhn Check Digit
      *    FULL = Full Transaction Validation

       01  LS-INPUT-DATA                 PIC X(80).
       01  LS-RESULT-CODE                PIC X(1).
      *    Y = Valid, N = Invalid
       01  LS-ERROR-CODE                 PIC X(4).
       01  LS-ERROR-MESSAGE              PIC X(80).

       PROCEDURE DIVISION USING
           LS-FUNCTION-CODE
           LS-INPUT-DATA
           LS-RESULT-CODE
           LS-ERROR-CODE
           LS-ERROR-MESSAGE.

      ******************************************************************
      * MAIN DISPATCH
      *
      * COBOL LESSON: A callable subprogram uses PROCEDURE
      * DIVISION USING to receive parameters. The USING list
      * must match the CALL statement in the calling program
      * in order, size, and type.
      ******************************************************************
       0000-MAIN-DISPATCH.
           MOVE "Y" TO LS-RESULT-CODE
           MOVE SPACES TO LS-ERROR-CODE
           MOVE SPACES TO LS-ERROR-MESSAGE

           EVALUATE LS-FUNCTION-CODE
               WHEN "VACT"
                   PERFORM 1000-VALIDATE-ACCOUNT-NUMBER
               WHEN "VDAT"
                   PERFORM 2000-VALIDATE-DATE
               WHEN "VAMT"
                   PERFORM 3000-VALIDATE-AMOUNT
               WHEN "LUHN"
                   PERFORM 4000-LUHN-CHECK
               WHEN "FULL"
                   PERFORM 5000-FULL-VALIDATION
               WHEN OTHER
                   MOVE "N" TO LS-RESULT-CODE
                   MOVE "9999" TO LS-ERROR-CODE
                   MOVE "Unknown validation function"
                       TO LS-ERROR-MESSAGE
           END-EVALUATE

           GOBACK
           .

      ******************************************************************
      * VALIDATE ACCOUNT NUMBER
      *
      * Checks: bank code, branch code, numeric sequence,
      * and Luhn check digit.
      ******************************************************************
       1000-VALIDATE-ACCOUNT-NUMBER.
      *    Extract components
           MOVE LS-INPUT-DATA(1:4)  TO WS-AV-BANK-CODE
           MOVE LS-INPUT-DATA(5:4)  TO WS-AV-BRANCH-CODE
           MOVE LS-INPUT-DATA(9:7)  TO WS-AV-SEQUENCE
           MOVE LS-INPUT-DATA(16:1) TO WS-AV-CHECK-DIGIT

      *    Validate bank code against known codes
           MOVE "N" TO WS-BANK-FOUND
           PERFORM VARYING WS-BANK-IDX FROM 1 BY 1
               UNTIL WS-BANK-IDX > 5
               IF WS-AV-BANK-CODE = WS-BANK-CODE(WS-BANK-IDX)
                   MOVE "Y" TO WS-BANK-FOUND
               END-IF
           END-PERFORM

           IF WS-BANK-FOUND = "N"
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-INVALID-ACCT-NUM TO LS-ERROR-CODE
               MOVE "Invalid bank code in account number"
                   TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF

      *    Validate branch code is alphanumeric
      *    COBOL LESSON: INSPECT TALLYING counts occurrences
      *    of specific characters. Here we count how many
      *    characters are NOT alphanumeric.
           MOVE ZEROS TO WS-STR-TALLY
           INSPECT WS-AV-BRANCH-CODE
               TALLYING WS-STR-TALLY FOR ALL SPACES
           IF WS-STR-TALLY > 0
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-INVALID-ACCT-NUM TO LS-ERROR-CODE
               MOVE "Branch code contains spaces"
                   TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF

      *    Validate sequence is numeric
           IF WS-AV-SEQUENCE IS NOT NUMERIC
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-INVALID-ACCT-NUM TO LS-ERROR-CODE
               MOVE "Account sequence must be numeric"
                   TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF

      *    Validate Luhn check digit
           MOVE LS-INPUT-DATA(1:16) TO WS-LUHN-INPUT
           PERFORM 4100-CALCULATE-LUHN
           .

      ******************************************************************
      * VALIDATE DATE (YYYYMMDD format)
      *
      * COBOL LESSON: Date validation is a classic COBOL exercise.
      * You must handle leap years, varying month lengths, and
      * reasonable date ranges. Y2K bugs came from storing only
      * 2-digit years (PIC 99 instead of PIC 9999).
      ******************************************************************
       2000-VALIDATE-DATE.
           MOVE LS-INPUT-DATA(1:8) TO WS-DV-DATE

      *    Check if numeric
           IF WS-DV-DATE IS NOT NUMERIC
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-INVALID-DATE TO LS-ERROR-CODE
               MOVE "Date must be numeric (YYYYMMDD)"
                   TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF

      *    Check year range (1900-2099)
           IF WS-DV-YYYY < 1900 OR WS-DV-YYYY > 2099
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-INVALID-DATE TO LS-ERROR-CODE
               MOVE "Year must be between 1900 and 2099"
                   TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF

      *    Check month range
           IF WS-DV-MM < 01 OR WS-DV-MM > 12
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-INVALID-DATE TO LS-ERROR-CODE
               MOVE "Month must be between 01 and 12"
                   TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF

      *    Determine leap year
      *    COBOL LESSON: Leap year rules:
      *    - Divisible by 4 = leap year
      *    - EXCEPT divisible by 100 = not leap year
      *    - EXCEPT divisible by 400 = leap year
      *    These rules caused many Y2K bugs because programmers
      *    only checked divisibility by 4.
           SET WS-DV-NOT-LEAP TO TRUE
           IF FUNCTION MOD(WS-DV-YYYY, 4) = 0
               SET WS-DV-IS-LEAP TO TRUE
               IF FUNCTION MOD(WS-DV-YYYY, 100) = 0
                   SET WS-DV-NOT-LEAP TO TRUE
                   IF FUNCTION MOD(WS-DV-YYYY, 400) = 0
                       SET WS-DV-IS-LEAP TO TRUE
                   END-IF
               END-IF
           END-IF

      *    Get max days for month
           MOVE WS-DV-MONTH-DAYS(WS-DV-MM) TO WS-DV-MAX-DAYS
           IF WS-DV-MM = 2 AND WS-DV-IS-LEAP
               MOVE 29 TO WS-DV-MAX-DAYS
           END-IF

      *    Check day range
           IF WS-DV-DD < 01 OR WS-DV-DD > WS-DV-MAX-DAYS
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-INVALID-DATE TO LS-ERROR-CODE
               STRING "Day must be between 01 and "
                      WS-DV-MAX-DAYS
                      " for month " WS-DV-MM
                   DELIMITED BY SIZE
                   INTO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF
           .

      ******************************************************************
      * VALIDATE AMOUNT
      *
      * Ensures amount is numeric, positive (or zero for
      * reversals), and within system limits.
      ******************************************************************
       3000-VALIDATE-AMOUNT.
      *    COBOL LESSON: FUNCTION NUMVAL converts a string
      *    containing a formatted number to a numeric value.
      *    It handles commas, signs, and decimal points.
           IF LS-INPUT-DATA(1:15) IS NOT NUMERIC
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-INVALID-AMOUNT TO LS-ERROR-CODE
               MOVE "Amount must be numeric"
                   TO LS-ERROR-MESSAGE
               EXIT PARAGRAPH
           END-IF

      *    Check system maximum (10 billion)
           IF LS-INPUT-DATA(1:15) > "999999999999999"
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-EXCEEDS-LIMIT TO LS-ERROR-CODE
               MOVE "Amount exceeds system maximum"
                   TO LS-ERROR-MESSAGE
           END-IF
           .

      ******************************************************************
      * LUHN CHECK - The Credit Card Algorithm
      *
      * This is one of the most famous algorithms in banking.
      * Every credit/debit card number passes this check.
      *
      * Algorithm:
      * 1. Starting from rightmost digit, double every second digit
      * 2. If doubling results in > 9, subtract 9
      * 3. Sum all digits
      * 4. If total mod 10 = 0, the number is valid
      *
      * Example: 4539 1488 0343 6467
      *   Original:  4 5 3 9 1 4 8 8 0 3 4 3 6 4 6 7
      *   Doubled:   8 5 6 9 2 4 7 8 0 3 8 3 3 4 3 7
      *   Sum = 80, 80 mod 10 = 0 => VALID
      ******************************************************************
       4000-LUHN-CHECK.
           MOVE LS-INPUT-DATA TO WS-LUHN-INPUT

      *    Find the length (strip trailing spaces)
      *    COBOL LESSON: FUNCTION LENGTH returns the defined
      *    length. We use INSPECT to find actual content length.
           MOVE 20 TO WS-LUHN-LENGTH
           PERFORM UNTIL WS-LUHN-LENGTH < 1
               OR WS-LUHN-INPUT(WS-LUHN-LENGTH:1) NOT = SPACE
               SUBTRACT 1 FROM WS-LUHN-LENGTH
           END-PERFORM

           PERFORM 4100-CALCULATE-LUHN
           .

       4100-CALCULATE-LUHN.
           MOVE ZEROS TO WS-LUHN-SUM
           SET WS-NO-DOUBLE TO TRUE

      *    Process from right to left
      *    COBOL LESSON: PERFORM VARYING is COBOL's for loop.
      *    Here we count DOWN from the rightmost digit.
           PERFORM VARYING WS-LUHN-IDX
               FROM WS-LUHN-LENGTH BY -1
               UNTIL WS-LUHN-IDX < 1

      *        Get the digit at this position
      *        COBOL LESSON: Reference modification - field(pos:len)
      *        extracts a substring. 1-based indexing.
               MOVE WS-LUHN-INPUT(WS-LUHN-IDX:1)
                   TO WS-LUHN-DIGIT

      *        Skip non-numeric characters
               IF WS-LUHN-DIGIT IS NUMERIC
                   IF WS-SHOULD-DOUBLE
      *                Double this digit
                       MULTIPLY WS-LUHN-DIGIT BY 2
                           GIVING WS-LUHN-DOUBLED
      *                If result > 9, subtract 9
      *                (equivalent to summing the two digits)
                       IF WS-LUHN-DOUBLED > 9
                           SUBTRACT 9 FROM WS-LUHN-DOUBLED
                       END-IF
                       ADD WS-LUHN-DOUBLED TO WS-LUHN-SUM
                       SET WS-NO-DOUBLE TO TRUE
                   ELSE
                       ADD WS-LUHN-DIGIT TO WS-LUHN-SUM
                       SET WS-SHOULD-DOUBLE TO TRUE
                   END-IF
               END-IF
           END-PERFORM

      *    Check if sum is divisible by 10
           COMPUTE WS-LUHN-REMAINDER =
               FUNCTION MOD(WS-LUHN-SUM, 10)

           IF WS-LUHN-REMAINDER NOT = 0
               MOVE "N" TO LS-RESULT-CODE
               MOVE ERR-LUHN-CHECK-FAILED TO LS-ERROR-CODE
               STRING "Luhn check failed (sum="
                      WS-LUHN-SUM ", mod=" WS-LUHN-REMAINDER ")"
                   DELIMITED BY SIZE
                   INTO LS-ERROR-MESSAGE
           END-IF
           .

      ******************************************************************
      * FULL TRANSACTION VALIDATION
      *
      * Demonstrates calling internal paragraphs as a
      * validation pipeline - each check builds on the last.
      ******************************************************************
       5000-FULL-VALIDATION.
      *    Step 1: Validate account number
           MOVE "VACT" TO LS-FUNCTION-CODE
           PERFORM 1000-VALIDATE-ACCOUNT-NUMBER
           IF LS-RESULT-CODE = "N"
               EXIT PARAGRAPH
           END-IF

      *    Step 2: Validate date
           MOVE LS-INPUT-DATA(21:8) TO LS-INPUT-DATA
           PERFORM 2000-VALIDATE-DATE
           IF LS-RESULT-CODE = "N"
               EXIT PARAGRAPH
           END-IF

           DISPLAY "  Full validation passed for "
                   LS-INPUT-DATA(1:16)
           .
