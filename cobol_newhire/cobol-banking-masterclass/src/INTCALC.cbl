      ******************************************************************
      * INTCALC.cbl - Interest Calculator
      *
      * Calculates compound interest using real banking day-count
      * conventions. Banks don't just multiply by a rate - they
      * use specific conventions that determine how many "days"
      * are in a year and how interest accrues daily.
      *
      * Day-Count Conventions:
      *   ACT/360 - Actual days, 360-day year (most commercial loans)
      *   ACT/365 - Actual days, 365-day year (UK bonds, some CDs)
      *   30/360  - 30 days/month, 360/year (US corporate bonds)
      *
      * COBOL LESSON: This program demonstrates:
      * - COMPUTE for complex formulas
      * - Packed decimal (COMP-3) for exact financial math
      * - ROUNDED phrase for proper rounding
      * - OCCURS DEPENDING ON for variable-length tables
      * - Nested PERFORM loops
      * - Day-count conventions used in real banking
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.    INTCALC.
       AUTHOR.        COBOL-BANKING-MASTERCLASS.
       DATE-WRITTEN.  2026-03-29.

       ENVIRONMENT DIVISION.

       CONFIGURATION SECTION.
       REPOSITORY.
           FUNCTION ALL INTRINSIC.

       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCOUNT-FILE
               ASSIGN TO "ACCTMAST.DAT"
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS ACCT-NUMBER
               FILE STATUS IS WS-ACCT-FILE-STATUS.

           SELECT INTEREST-REPORT
               ASSIGN TO "INTEREST.RPT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RPT-FILE-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD  ACCOUNT-FILE.
       COPY ACCTREC.

       FD  INTEREST-REPORT.
       01  RPT-LINE                      PIC X(132).

       WORKING-STORAGE SECTION.

       01  WS-FILE-STATUSES.
           05  WS-ACCT-FILE-STATUS       PIC X(2).
               88  WS-ACCT-OK            VALUE "00".
               88  WS-ACCT-EOF           VALUE "10".
           05  WS-RPT-FILE-STATUS        PIC X(2).

      *    ---- Interest Calculation Fields ----
      *    COBOL LESSON: PIC S9(x)V9(y) COMP-3 is the gold
      *    standard for financial arithmetic. S = signed,
      *    V = implied decimal point, COMP-3 = packed decimal.
      *    NEVER use COMP-1/COMP-2 (floating point) for money.
       01  WS-INTEREST-FIELDS.
           05  WS-PRINCIPAL              PIC S9(13)V99 COMP-3.
           05  WS-ANNUAL-RATE            PIC S9(3)V9(8) COMP-3.
           05  WS-DAILY-RATE             PIC S9(1)V9(12) COMP-3.
           05  WS-PERIOD-RATE            PIC S9(3)V9(8) COMP-3.
           05  WS-DAYS-IN-PERIOD         PIC S9(5) COMP-3.
           05  WS-DAYS-IN-YEAR           PIC S9(3) COMP-3.
           05  WS-INTEREST-AMOUNT        PIC S9(13)V99 COMP-3.
           05  WS-ACCRUED-TOTAL          PIC S9(13)V99 COMP-3.
           05  WS-COMPOUND-FACTOR        PIC S9(3)V9(12) COMP-3.
           05  WS-DAILY-INTEREST         PIC S9(13)V9(6) COMP-3.
           05  WS-RUNNING-BALANCE        PIC S9(13)V99 COMP-3.

      *    ---- Day Count Convention Fields ----
       01  WS-DAYCOUNT.
           05  WS-DC-CONVENTION          PIC X(7).
               88  WS-DC-ACT-360        VALUE "ACT/360".
               88  WS-DC-ACT-365        VALUE "ACT/365".
               88  WS-DC-30-360         VALUE "30/360 ".
           05  WS-DC-START-DATE          PIC 9(8).
           05  WS-DC-START-R REDEFINES WS-DC-START-DATE.
               10  WS-DC-START-YYYY      PIC 9(4).
               10  WS-DC-START-MM        PIC 9(2).
               10  WS-DC-START-DD        PIC 9(2).
           05  WS-DC-END-DATE            PIC 9(8).
           05  WS-DC-END-R REDEFINES WS-DC-END-DATE.
               10  WS-DC-END-YYYY        PIC 9(4).
               10  WS-DC-END-MM          PIC 9(2).
               10  WS-DC-END-DD          PIC 9(2).
           05  WS-DC-ACTUAL-DAYS         PIC S9(5) COMP-3.
           05  WS-DC-30-360-DAYS         PIC S9(5) COMP-3.
           05  WS-DC-D1                  PIC 9(2).
           05  WS-DC-D2                  PIC 9(2).
           05  WS-DC-M1                  PIC 9(2).
           05  WS-DC-M2                  PIC 9(2).
           05  WS-DC-Y1                  PIC 9(4).
           05  WS-DC-Y2                  PIC 9(4).

      *    ---- Compound Interest Schedule ----
      *    COBOL LESSON: OCCURS DEPENDING ON creates a
      *    variable-length table. The actual number of
      *    entries is determined at runtime. This is
      *    COBOL's version of a dynamic array.
       01  WS-SCHEDULE-CONTROL.
           05  WS-NUM-PERIODS            PIC 9(3) VALUE ZEROS.
           05  WS-PERIOD-IDX             PIC 9(3).
           05  WS-MAX-PERIODS            PIC 9(3) VALUE 60.

       01  WS-INTEREST-SCHEDULE.
           05  WS-SCHEDULE-ENTRY OCCURS 1 TO 60 TIMES
               DEPENDING ON WS-NUM-PERIODS.
               10  WS-SCHED-PERIOD       PIC 9(3).
               10  WS-SCHED-START-BAL    PIC S9(13)V99 COMP-3.
               10  WS-SCHED-INTEREST     PIC S9(13)V99 COMP-3.
               10  WS-SCHED-END-BAL      PIC S9(13)V99 COMP-3.
               10  WS-SCHED-RATE         PIC S9(3)V9(8) COMP-3.
               10  WS-SCHED-DAYS         PIC 9(3).

      *    ---- Tier Rate Table ----
      *    COBOL LESSON: Tiered interest rates are common in
      *    banking. Savings accounts often pay higher rates on
      *    higher balances. This table defines the tiers.
       01  WS-TIER-TABLE.
           05  WS-NUM-TIERS              PIC 9(1) VALUE 4.
           05  WS-TIER-ENTRY.
               10  WS-TIER-1.
                   15  WS-TIER-MIN-1     PIC S9(13)V99 COMP-3
                                         VALUE 0.
                   15  WS-TIER-MAX-1     PIC S9(13)V99 COMP-3
                                         VALUE 9999.99.
                   15  WS-TIER-RATE-1    PIC S9(3)V9(6) COMP-3
                                         VALUE 0.000100.
               10  WS-TIER-2.
                   15  WS-TIER-MIN-2     PIC S9(13)V99 COMP-3
                                         VALUE 10000.00.
                   15  WS-TIER-MAX-2     PIC S9(13)V99 COMP-3
                                         VALUE 49999.99.
                   15  WS-TIER-RATE-2    PIC S9(3)V9(6) COMP-3
                                         VALUE 0.020000.
               10  WS-TIER-3.
                   15  WS-TIER-MIN-3     PIC S9(13)V99 COMP-3
                                         VALUE 50000.00.
                   15  WS-TIER-MAX-3     PIC S9(13)V99 COMP-3
                                         VALUE 249999.99.
                   15  WS-TIER-RATE-3    PIC S9(3)V9(6) COMP-3
                                         VALUE 0.035000.
               10  WS-TIER-4.
                   15  WS-TIER-MIN-4     PIC S9(13)V99 COMP-3
                                         VALUE 250000.00.
                   15  WS-TIER-MAX-4     PIC S9(13)V99 COMP-3
                                         VALUE 9999999999999.99.
                   15  WS-TIER-RATE-4    PIC S9(3)V9(6) COMP-3
                                         VALUE 0.048500.

      *    ---- Date Utilities ----
       COPY DATEUTIL.

      *    ---- Processing Counters ----
       01  WS-COUNTERS.
           05  WS-ACCTS-PROCESSED        PIC 9(7) VALUE ZEROS.
           05  WS-TOTAL-INT-ACCRUED      PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.

      *    ---- Report Fields ----
       01  WS-RPT-HEADER-1.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(50) VALUE
               "INTEREST ACCRUAL REPORT".
           05  FILLER PIC X(81) VALUE SPACES.

       01  WS-RPT-HEADER-2.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(131) VALUE ALL "=".

       01  WS-RPT-COL-HDR.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(16) VALUE "ACCOUNT         ".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(4)  VALUE "TYPE".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(20) VALUE "BALANCE             ".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(10) VALUE "RATE      ".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(7)  VALUE "CONV   ".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(5)  VALUE "DAYS ".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(20) VALUE "INTEREST ACCRUED    ".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(20) VALUE "NEW BALANCE         ".
           05  FILLER PIC X(21) VALUE SPACES.

       01  WS-RPT-DETAIL.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-ACCT PIC X(16).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-TYPE PIC X(4).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-BAL  PIC $$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-RATE PIC Z9.999999.
           05  FILLER PIC X(1)  VALUE "%".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-CONV PIC X(7).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-DAYS PIC ZZ,ZZ9.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-INT  PIC $$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-RD-NEWBAL PIC $$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE SPACES.

       01  WS-RPT-FOOTER.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(131) VALUE ALL "-".

       01  WS-RPT-TOTAL-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(25) VALUE "TOTAL INTEREST ACCRUED:  ".
           05  WS-RT-TOTAL PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(5)  VALUE SPACES.
           05  FILLER PIC X(20) VALUE "ACCOUNTS PROCESSED: ".
           05  WS-RT-COUNT PIC ZZ,ZZ9.
           05  FILLER PIC X(33) VALUE SPACES.

      *    ---- Display Fields ----
       01  WS-DISPLAY-AMT               PIC $$$,$$$,$$$,$$9.99-.
       01  WS-DISPLAY-RATE              PIC Z9.999999.
       01  WS-EOF-FLAG                  PIC X(1) VALUE "N".
           88  WS-END-OF-FILE           VALUE "Y".

       PROCEDURE DIVISION.

      ******************************************************************
      * MAIN CONTROL
      ******************************************************************
       0000-MAIN-CONTROL.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-DEMONSTRATE-CONVENTIONS
           PERFORM 3000-PROCESS-ACCOUNTS
           PERFORM 9000-TERMINATE
           STOP RUN
           .

      ******************************************************************
      * INITIALIZATION
      ******************************************************************
       1000-INITIALIZE.
           DISPLAY "================================================"
           DISPLAY "  INTCALC - Interest Calculator"
           DISPLAY "  COBOL Banking Masterclass"
           DISPLAY "================================================"
           DISPLAY SPACES

           MOVE FUNCTION CURRENT-DATE(1:8)
               TO WS-CURRENT-DATE-INT

           DISPLAY "Calculation Date: "
                   WS-CURRENT-MM "/" WS-CURRENT-DD "/"
                   WS-CURRENT-YYYY
           DISPLAY SPACES
           .

      ******************************************************************
      * DEMONSTRATE DAY-COUNT CONVENTIONS
      *
      * Shows how the same date range produces different day counts
      * depending on the convention. This directly affects how much
      * interest you pay or earn.
      ******************************************************************
       2000-DEMONSTRATE-CONVENTIONS.
           DISPLAY "================================================"
           DISPLAY "  Day-Count Convention Demonstration"
           DISPLAY "================================================"
           DISPLAY SPACES
           DISPLAY "  Same dates, different conventions = different"
           DISPLAY "  interest amounts. This is real banking math."
           DISPLAY SPACES

      *    Example: Jan 31 to Mar 1 (crossing Feb)
           MOVE 20260131 TO WS-DC-START-DATE
           MOVE 20260301 TO WS-DC-END-DATE

           DISPLAY "  Period: 01/31/2026 to 03/01/2026"
           DISPLAY "  Principal: $100,000.00  Rate: 5.00%"
           DISPLAY SPACES

      *    ---- ACT/360 ----
           SET WS-DC-ACT-360 TO TRUE
           PERFORM 2100-CALC-ACTUAL-DAYS
           MOVE 360 TO WS-DAYS-IN-YEAR
           COMPUTE WS-INTEREST-AMOUNT ROUNDED =
               100000.00 * 0.05 * WS-DC-ACTUAL-DAYS / 360
           MOVE WS-INTEREST-AMOUNT TO WS-DISPLAY-AMT
           DISPLAY "  ACT/360: " WS-DC-ACTUAL-DAYS
                   " actual days / 360 = " WS-DISPLAY-AMT

      *    ---- ACT/365 ----
           SET WS-DC-ACT-365 TO TRUE
           PERFORM 2100-CALC-ACTUAL-DAYS
           MOVE 365 TO WS-DAYS-IN-YEAR
           COMPUTE WS-INTEREST-AMOUNT ROUNDED =
               100000.00 * 0.05 * WS-DC-ACTUAL-DAYS / 365
           MOVE WS-INTEREST-AMOUNT TO WS-DISPLAY-AMT
           DISPLAY "  ACT/365: " WS-DC-ACTUAL-DAYS
                   " actual days / 365 = " WS-DISPLAY-AMT

      *    ---- 30/360 ----
           SET WS-DC-30-360 TO TRUE
           PERFORM 2200-CALC-30-360-DAYS
           MOVE 360 TO WS-DAYS-IN-YEAR
           COMPUTE WS-INTEREST-AMOUNT ROUNDED =
               100000.00 * 0.05 * WS-DC-30-360-DAYS / 360
           MOVE WS-INTEREST-AMOUNT TO WS-DISPLAY-AMT
           DISPLAY "  30/360:  " WS-DC-30-360-DAYS
                   " calculated days / 360 = " WS-DISPLAY-AMT

           DISPLAY SPACES
           DISPLAY "  Notice how ACT/360 yields more interest than"
           DISPLAY "  ACT/365 - banks prefer it for loans (borrower"
           DISPLAY "  pays more). 30/360 smooths out month lengths."
           DISPLAY SPACES

      *    ---- Compound Interest Demo ----
           DISPLAY "================================================"
           DISPLAY "  Compound Interest Schedule (Monthly, 12 months)"
           DISPLAY "================================================"
           DISPLAY SPACES

           MOVE 100000.00 TO WS-PRINCIPAL
           MOVE 0.048500   TO WS-ANNUAL-RATE
           MOVE 12          TO WS-NUM-PERIODS
           MOVE WS-PRINCIPAL TO WS-RUNNING-BALANCE

           DISPLAY "  Principal: $100,000.00  Rate: 4.85% APY"
           DISPLAY "  Compounding: Monthly"
           DISPLAY SPACES
           DISPLAY "  Period  Start Balance     Interest     "
                   "  End Balance"
           DISPLAY "  ------  ----------------  -----------  "
                   "  ----------------"

      *    COBOL LESSON: COMPUTE can handle complex formulas.
      *    The ROUNDED phrase ensures proper banker's rounding
      *    (round half to even), which is different from
      *    standard rounding and prevents systematic bias.
           PERFORM VARYING WS-PERIOD-IDX FROM 1 BY 1
               UNTIL WS-PERIOD-IDX > WS-NUM-PERIODS

               MOVE WS-PERIOD-IDX TO WS-SCHED-PERIOD(WS-PERIOD-IDX)
               MOVE WS-RUNNING-BALANCE
                   TO WS-SCHED-START-BAL(WS-PERIOD-IDX)

      *        Monthly interest = balance * (annual rate / 12)
               COMPUTE WS-INTEREST-AMOUNT ROUNDED =
                   WS-RUNNING-BALANCE * (WS-ANNUAL-RATE / 12)
               MOVE WS-INTEREST-AMOUNT
                   TO WS-SCHED-INTEREST(WS-PERIOD-IDX)

      *        Add interest to running balance (compound)
               ADD WS-INTEREST-AMOUNT TO WS-RUNNING-BALANCE
               MOVE WS-RUNNING-BALANCE
                   TO WS-SCHED-END-BAL(WS-PERIOD-IDX)

               DISPLAY "  " WS-PERIOD-IDX "      "
                   WS-SCHED-START-BAL(WS-PERIOD-IDX) "    "
                   WS-SCHED-INTEREST(WS-PERIOD-IDX) "    "
                   WS-SCHED-END-BAL(WS-PERIOD-IDX)
           END-PERFORM

           COMPUTE WS-INTEREST-AMOUNT =
               WS-RUNNING-BALANCE - WS-PRINCIPAL
           MOVE WS-INTEREST-AMOUNT TO WS-DISPLAY-AMT
           DISPLAY SPACES
           DISPLAY "  Total Interest Earned: " WS-DISPLAY-AMT
           MOVE WS-RUNNING-BALANCE TO WS-DISPLAY-AMT
           DISPLAY "  Final Balance:        " WS-DISPLAY-AMT
           DISPLAY SPACES
           .

      ******************************************************************
      * CALCULATE ACTUAL DAYS BETWEEN TWO DATES
      *
      * COBOL LESSON: FUNCTION INTEGER-OF-DATE converts a
      * Gregorian date (YYYYMMDD) to a Julian day number.
      * Subtracting two Julian day numbers gives you the
      * actual days between them. Simple and elegant.
      ******************************************************************
       2100-CALC-ACTUAL-DAYS.
           COMPUTE WS-DC-ACTUAL-DAYS =
               FUNCTION INTEGER-OF-DATE(WS-DC-END-DATE) -
               FUNCTION INTEGER-OF-DATE(WS-DC-START-DATE)
           .

      ******************************************************************
      * CALCULATE 30/360 DAYS
      *
      * The 30/360 convention assumes every month has 30 days
      * and every year has 360 days. This creates a "standardized"
      * day count that simplifies interest calculations.
      *
      * US 30/360 rules:
      * - If D1 = 31, set D1 = 30
      * - If D1 = 30 and D2 = 31, set D2 = 30
      * - Days = (Y2-Y1)*360 + (M2-M1)*30 + (D2-D1)
      ******************************************************************
       2200-CALC-30-360-DAYS.
           MOVE WS-DC-START-DD   TO WS-DC-D1
           MOVE WS-DC-END-DD     TO WS-DC-D2
           MOVE WS-DC-START-MM   TO WS-DC-M1
           MOVE WS-DC-END-MM     TO WS-DC-M2
           MOVE WS-DC-START-YYYY TO WS-DC-Y1
           MOVE WS-DC-END-YYYY   TO WS-DC-Y2

      *    Apply 30/360 adjustment rules
           IF WS-DC-D1 = 31
               MOVE 30 TO WS-DC-D1
           END-IF
           IF WS-DC-D1 = 30 AND WS-DC-D2 = 31
               MOVE 30 TO WS-DC-D2
           END-IF

      *    Calculate days
           COMPUTE WS-DC-30-360-DAYS =
               (WS-DC-Y2 - WS-DC-Y1) * 360
             + (WS-DC-M2 - WS-DC-M1) * 30
             + (WS-DC-D2 - WS-DC-D1)
           .

      ******************************************************************
      * PROCESS ALL ACCOUNTS - Calculate interest for each
      ******************************************************************
       3000-PROCESS-ACCOUNTS.
           DISPLAY "================================================"
           DISPLAY "  Processing Interest for All Accounts"
           DISPLAY "================================================"
           DISPLAY SPACES

           OPEN I-O ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS NOT = "00"
               DISPLAY "Cannot open Account Master File"
               DISPLAY "Status: " WS-ACCT-FILE-STATUS
               EXIT PARAGRAPH
           END-IF

           OPEN OUTPUT INTEREST-REPORT
           WRITE RPT-LINE FROM WS-RPT-HEADER-1
           WRITE RPT-LINE FROM WS-RPT-HEADER-2
           WRITE RPT-LINE FROM WS-RPT-COL-HDR
           WRITE RPT-LINE FROM WS-RPT-HEADER-2

           MOVE "N" TO WS-EOF-FLAG
           MOVE LOW-VALUES TO ACCT-NUMBER
           START ACCOUNT-FILE KEY NOT < ACCT-NUMBER
               INVALID KEY
                   DISPLAY "No accounts in file"
                   CLOSE ACCOUNT-FILE
                   CLOSE INTEREST-REPORT
                   EXIT PARAGRAPH
           END-START

           PERFORM UNTIL WS-END-OF-FILE
               READ ACCOUNT-FILE NEXT
                   AT END
                       SET WS-END-OF-FILE TO TRUE
                   NOT AT END
                       PERFORM 3100-CALC-ACCOUNT-INTEREST
               END-READ
           END-PERFORM

      *    Write report totals
           WRITE RPT-LINE FROM WS-RPT-FOOTER
           MOVE WS-TOTAL-INT-ACCRUED TO WS-RT-TOTAL
           MOVE WS-ACCTS-PROCESSED   TO WS-RT-COUNT
           WRITE RPT-LINE FROM WS-RPT-TOTAL-LINE

           CLOSE ACCOUNT-FILE
           CLOSE INTEREST-REPORT

           DISPLAY SPACES
           DISPLAY "Interest processing complete."
           DISPLAY "Accounts processed: " WS-ACCTS-PROCESSED
           MOVE WS-TOTAL-INT-ACCRUED TO WS-DISPLAY-AMT
           DISPLAY "Total interest:     " WS-DISPLAY-AMT
           DISPLAY SPACES
           .

      ******************************************************************
      * CALCULATE INTEREST FOR ONE ACCOUNT
      *
      * Determines the appropriate day-count convention based on
      * account type and calculates accrued interest.
      ******************************************************************
       3100-CALC-ACCOUNT-INTEREST.
      *    Skip accounts that don't earn interest
           IF ACCT-INTEREST-RATE = ZEROS
               EXIT PARAGRAPH
           END-IF

      *    Skip closed accounts
           IF ACCT-CLOSED
               EXIT PARAGRAPH
           END-IF

           ADD 1 TO WS-ACCTS-PROCESSED

      *    Determine day-count convention by account type
      *    COBOL LESSON: Different product types use different
      *    conventions. This is real banking practice.
           EVALUATE TRUE
               WHEN ACCT-IS-CHECKING
               WHEN ACCT-IS-SAVINGS
                   SET WS-DC-ACT-365 TO TRUE
                   MOVE "ACT/365" TO WS-DC-CONVENTION
               WHEN ACCT-IS-MONEY-MARKET
               WHEN ACCT-IS-CD
                   SET WS-DC-ACT-360 TO TRUE
                   MOVE "ACT/360" TO WS-DC-CONVENTION
               WHEN ACCT-IS-LOAN
               WHEN ACCT-IS-MORTGAGE
                   SET WS-DC-30-360 TO TRUE
                   MOVE "30/360 " TO WS-DC-CONVENTION
               WHEN OTHER
                   SET WS-DC-ACT-365 TO TRUE
                   MOVE "ACT/365" TO WS-DC-CONVENTION
           END-EVALUATE

      *    Calculate days since last statement
           IF ACCT-LAST-STMT-DATE > ZEROS
               MOVE ACCT-LAST-STMT-DATE TO WS-DC-START-DATE
           ELSE
               MOVE ACCT-OPEN-DATE TO WS-DC-START-DATE
           END-IF
           MOVE WS-CURRENT-DATE-INT TO WS-DC-END-DATE

      *    Get day count based on convention
           EVALUATE TRUE
               WHEN WS-DC-ACT-360
               WHEN WS-DC-ACT-365
                   PERFORM 2100-CALC-ACTUAL-DAYS
                   MOVE WS-DC-ACTUAL-DAYS TO WS-DAYS-IN-PERIOD
               WHEN WS-DC-30-360
                   PERFORM 2200-CALC-30-360-DAYS
                   MOVE WS-DC-30-360-DAYS TO WS-DAYS-IN-PERIOD
           END-EVALUATE

      *    Set year basis
           IF WS-DC-ACT-365
               MOVE 365 TO WS-DAYS-IN-YEAR
           ELSE
               MOVE 360 TO WS-DAYS-IN-YEAR
           END-IF

      *    Calculate daily interest accrual
      *    Interest = Principal * Rate * Days / Year Basis
           MOVE ACCT-INTEREST-RATE TO WS-ANNUAL-RATE
           MOVE ACCT-CURRENT-BAL   TO WS-PRINCIPAL

           IF WS-PRINCIPAL > ZEROS AND WS-DAYS-IN-PERIOD > ZEROS
               COMPUTE WS-INTEREST-AMOUNT ROUNDED =
                   WS-PRINCIPAL
                   * WS-ANNUAL-RATE
                   * WS-DAYS-IN-PERIOD
                   / WS-DAYS-IN-YEAR
           ELSE
               MOVE ZEROS TO WS-INTEREST-AMOUNT
           END-IF

      *    Update account accrued interest
           ADD WS-INTEREST-AMOUNT TO ACCT-ACCRUED-INT
           ADD WS-INTEREST-AMOUNT TO WS-TOTAL-INT-ACCRUED

      *    Write report detail
           MOVE SPACES TO WS-RPT-DETAIL
           MOVE ACCT-NUMBER        TO WS-RD-ACCT
           MOVE ACCT-TYPE          TO WS-RD-TYPE
           MOVE ACCT-CURRENT-BAL   TO WS-RD-BAL
           COMPUTE WS-RD-RATE = WS-ANNUAL-RATE * 100
           MOVE WS-DC-CONVENTION   TO WS-RD-CONV
           MOVE WS-DAYS-IN-PERIOD  TO WS-RD-DAYS
           MOVE WS-INTEREST-AMOUNT TO WS-RD-INT
           COMPUTE WS-RD-NEWBAL =
               ACCT-CURRENT-BAL + WS-INTEREST-AMOUNT
           WRITE RPT-LINE FROM WS-RPT-DETAIL

      *    Display to console
           MOVE WS-INTEREST-AMOUNT TO WS-DISPLAY-AMT
           DISPLAY "  " ACCT-NUMBER " "
                   ACCT-TYPE " "
                   WS-DC-CONVENTION " "
                   WS-DAYS-IN-PERIOD " days "
                   WS-DISPLAY-AMT
           .

      ******************************************************************
      * TERMINATION
      ******************************************************************
       9000-TERMINATE.
           DISPLAY "================================================"
           DISPLAY "  INTCALC Processing Complete"
           DISPLAY "================================================"
           DISPLAY SPACES
           .
