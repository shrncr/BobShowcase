 ******************************************************************
      * RPTGEN.cbl - Report Generator with Control Breaks
      *
      * Generates a comprehensive financial report with control
      * break processing - the hallmark of COBOL report writing.
      *
      * COBOL LESSON: Control break reporting is one of COBOL's
      * signature capabilities. As you read records in sorted
      * order, you detect when a "control field" changes value
      * (the "break"). At each break, you print subtotals for
      * the group that just ended. This produces the hierarchical
      * reports that managers and auditors love.
      *
      * This report demonstrates a 3-level control break:
      *   Level 1: Bank Code (major break)
      *   Level 2: Branch Code (intermediate break)
      *   Level 3: Account Type (minor break)
      ******************************************************************

       IDENTIFICATION DIVISION.
       PROGRAM-ID.    RPTGEN.
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
               ACCESS MODE IS SEQUENTIAL
               RECORD KEY IS ACCT-NUMBER
               FILE STATUS IS WS-ACCT-FILE-STATUS.

           SELECT REPORT-FILE
               ASSIGN TO "FINREPORT.RPT"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-RPT-FILE-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD  ACCOUNT-FILE.
       COPY ACCTREC.

       FD  REPORT-FILE.
       01  RPT-LINE                      PIC X(132).

       WORKING-STORAGE SECTION.

       01  WS-FILE-STATUSES.
           05  WS-ACCT-FILE-STATUS       PIC X(2).
               88  WS-ACCT-OK            VALUE "00".
               88  WS-ACCT-EOF           VALUE "10".
           05  WS-RPT-FILE-STATUS        PIC X(2).

      *    ---- Control Break Fields ----
      *    COBOL LESSON: Control break processing requires
      *    saving the "previous" value of each control field.
      *    When current != previous, you've hit a break.
       01  WS-CONTROL-FIELDS.
           05  WS-PREV-BANK-CODE         PIC X(4) VALUE SPACES.
           05  WS-PREV-BRANCH-CODE       PIC X(4) VALUE SPACES.
           05  WS-PREV-ACCT-TYPE         PIC X(2) VALUE SPACES.
           05  WS-CURR-BANK-CODE         PIC X(4).
           05  WS-CURR-BRANCH-CODE       PIC X(4).
           05  WS-CURR-ACCT-TYPE         PIC X(2).
           05  WS-FIRST-RECORD           PIC X(1) VALUE "Y".
               88  WS-IS-FIRST-RECORD    VALUE "Y".

      *    ---- Subtotal Accumulators ----
      *    Three levels of accumulators for the three break levels
       01  WS-TYPE-TOTALS.
           05  WS-TYPE-COUNT             PIC 9(7) VALUE ZEROS.
           05  WS-TYPE-BALANCE           PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-TYPE-AVAIL             PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-TYPE-ACTIVE            PIC 9(7) VALUE ZEROS.
           05  WS-TYPE-FROZEN            PIC 9(7) VALUE ZEROS.
           05  WS-TYPE-DORMANT           PIC 9(7) VALUE ZEROS.
           05  WS-TYPE-CLOSED            PIC 9(7) VALUE ZEROS.

       01  WS-BRANCH-TOTALS.
           05  WS-BRANCH-COUNT           PIC 9(7) VALUE ZEROS.
           05  WS-BRANCH-BALANCE         PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-BRANCH-AVAIL           PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.

       01  WS-BANK-TOTALS.
           05  WS-BANK-COUNT             PIC 9(7) VALUE ZEROS.
           05  WS-BANK-BALANCE           PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-BANK-AVAIL            PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.

       01  WS-GRAND-TOTALS.
           05  WS-GRAND-COUNT            PIC 9(7) VALUE ZEROS.
           05  WS-GRAND-BALANCE          PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-GRAND-AVAIL            PIC S9(15)V99 COMP-3
                                         VALUE ZEROS.
           05  WS-GRAND-ACTIVE           PIC 9(7) VALUE ZEROS.
           05  WS-GRAND-FROZEN           PIC 9(7) VALUE ZEROS.
           05  WS-GRAND-DORMANT          PIC 9(7) VALUE ZEROS.
           05  WS-GRAND-CLOSED           PIC 9(7) VALUE ZEROS.

      *    ---- Page Control ----
       01  WS-PAGE-CONTROL.
           05  WS-LINE-COUNT             PIC 9(3) VALUE 99.
           05  WS-PAGE-COUNT             PIC 9(3) VALUE ZEROS.
           05  WS-LINES-PER-PAGE         PIC 9(3) VALUE 55.

      *    ---- Date Fields ----
       COPY DATEUTIL.

      *    ---- Report Lines ----
       01  WS-TITLE-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(45) VALUE
               "CONSOLIDATED FINANCIAL POSITION REPORT".
           05  FILLER PIC X(41) VALUE SPACES.
           05  FILLER PIC X(6)  VALUE "DATE: ".
           05  WS-TL-DATE PIC X(10).
           05  FILLER PIC X(5)  VALUE SPACES.
           05  FILLER PIC X(6)  VALUE "PAGE: ".
           05  WS-TL-PAGE PIC ZZ9.
           05  FILLER PIC X(15) VALUE SPACES.

       01  WS-SUBTITLE-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(45) VALUE
               "ACCOUNT SUMMARY BY BANK/BRANCH/TYPE".
           05  FILLER PIC X(86) VALUE SPACES.

       01  WS-SEPARATOR.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(131) VALUE ALL "-".

       01  WS-DBL-SEPARATOR.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(131) VALUE ALL "=".

       01  WS-COL-HEADER-1.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(16) VALUE "ACCOUNT NUMBER  ".
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(4)  VALUE " ST ".
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(20) VALUE " CUSTOMER NAME      ".
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(20) VALUE "   CURRENT BALANCE  ".
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(20) VALUE "  AVAILABLE BALANCE ".
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(10) VALUE "  OPENED  ".
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(10) VALUE " LAST TXN ".
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(6)  VALUE "  TXN ".
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(16) VALUE SPACES.

       01  WS-DETAIL-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-DL-ACCT     PIC X(16).
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-DL-STATUS   PIC X(1).
           05  FILLER PIC X(2)  VALUE SPACES.
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-DL-NAME     PIC X(19).
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-DL-BAL      PIC $$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-DL-AVAIL    PIC $$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-DL-OPENED   PIC X(10).
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-DL-LASTTXN  PIC X(10).
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-DL-TXNCNT   PIC ZZ,ZZ9.
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(16) VALUE SPACES.

       01  WS-TYPE-TOTAL-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(5)  VALUE "  ** ".
           05  WS-TT-LABEL    PIC X(12).
           05  FILLER PIC X(1)  VALUE SPACES.
           05  WS-TT-COUNT    PIC ZZ,ZZ9.
           05  FILLER PIC X(10) VALUE " accounts ".
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-TT-BAL      PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-TT-AVAIL    PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(36) VALUE SPACES.

       01  WS-BRANCH-TOTAL-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(5)  VALUE " *** ".
           05  FILLER PIC X(14) VALUE "BRANCH TOTAL: ".
           05  WS-BT-COUNT    PIC ZZ,ZZ9.
           05  FILLER PIC X(10) VALUE " accounts ".
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-BT-BAL      PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-BT-AVAIL    PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(36) VALUE SPACES.

       01  WS-BANK-TOTAL-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(5)  VALUE "**** ".
           05  FILLER PIC X(14) VALUE "BANK TOTAL:   ".
           05  WS-BKT-COUNT   PIC ZZ,ZZ9.
           05  FILLER PIC X(10) VALUE " accounts ".
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-BKT-BAL     PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-BKT-AVAIL   PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(36) VALUE SPACES.

       01  WS-GRAND-TOTAL-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(19) VALUE "GRAND TOTAL:       ".
           05  WS-GT-COUNT    PIC ZZ,ZZ9.
           05  FILLER PIC X(10) VALUE " accounts ".
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-GT-BAL      PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  WS-GT-AVAIL    PIC $$$,$$$,$$$,$$$,$$9.99-.
           05  FILLER PIC X(1)  VALUE "|".
           05  FILLER PIC X(36) VALUE SPACES.

       01  WS-STATUS-SUMMARY-LINE.
           05  FILLER PIC X(1)  VALUE SPACES.
           05  FILLER PIC X(25) VALUE "STATUS DISTRIBUTION:     ".
           05  FILLER PIC X(10) VALUE "Active:   ".
           05  WS-SS-ACTIVE   PIC ZZ,ZZ9.
           05  FILLER PIC X(3)  VALUE "   ".
           05  FILLER PIC X(10) VALUE "Frozen:   ".
           05  WS-SS-FROZEN   PIC ZZ,ZZ9.
           05  FILLER PIC X(3)  VALUE "   ".
           05  FILLER PIC X(10) VALUE "Dormant:  ".
           05  WS-SS-DORMANT  PIC ZZ,ZZ9.
           05  FILLER PIC X(3)  VALUE "   ".
           05  FILLER PIC X(10) VALUE "Closed:   ".
           05  WS-SS-CLOSED   PIC ZZ,ZZ9.
           05  FILLER PIC X(25) VALUE SPACES.

      *    ---- Account Type Description ----
       01  WS-ACCT-TYPE-DESC             PIC X(12).

      *    ---- Work Fields ----
       01  WS-EOF-FLAG                   PIC X(1) VALUE "N".
           88  WS-END-OF-FILE            VALUE "Y".
       01  WS-FORMATTED-DATE-W           PIC X(10).

       PROCEDURE DIVISION.

      ******************************************************************
      * MAIN CONTROL
      ******************************************************************
       0000-MAIN-CONTROL.
           PERFORM 1000-INITIALIZE
           PERFORM 2000-PROCESS-REPORT
           PERFORM 9000-TERMINATE
           STOP RUN
           .

      ******************************************************************
      * INITIALIZATION
      ******************************************************************
       1000-INITIALIZE.
           DISPLAY "================================================"
           DISPLAY "  RPTGEN - Financial Report Generator"
           DISPLAY "  COBOL Banking Masterclass"
           DISPLAY "================================================"
           DISPLAY SPACES

           MOVE FUNCTION CURRENT-DATE(1:8)
               TO WS-CURRENT-DATE-INT

           STRING WS-CURRENT-MM "/" WS-CURRENT-DD "/"
                  WS-CURRENT-YYYY
               DELIMITED BY SIZE
               INTO WS-TL-DATE

           OPEN INPUT ACCOUNT-FILE
           IF WS-ACCT-FILE-STATUS NOT = "00"
               DISPLAY "FATAL: Cannot open Account Master File"
               STOP RUN
           END-IF

           OPEN OUTPUT REPORT-FILE

           DISPLAY "Files opened. Generating report..."
           DISPLAY SPACES
           .

      ******************************************************************
      * MAIN REPORT PROCESSING
      *
      * COBOL LESSON: Control break logic follows this pattern:
      * 1. Read first record, save control fields
      * 2. Read next record
      * 3. Compare control fields to previous
      * 4. If different: print subtotals, reset accumulators
      * 5. Process current record
      * 6. Repeat until EOF
      * 7. At EOF: print final subtotals and grand totals
      ******************************************************************
       2000-PROCESS-REPORT.
           MOVE "N" TO WS-EOF-FLAG

           READ ACCOUNT-FILE
               AT END
                   DISPLAY "No accounts to report."
                   EXIT PARAGRAPH
           END-READ

      *    Initialize control fields from first record
           MOVE ACCT-BANK-CODE   TO WS-PREV-BANK-CODE
           MOVE ACCT-BRANCH-CODE TO WS-PREV-BRANCH-CODE
           MOVE ACCT-TYPE        TO WS-PREV-ACCT-TYPE
           MOVE "Y" TO WS-FIRST-RECORD

      *    Process this record and all subsequent
           PERFORM UNTIL WS-END-OF-FILE
               MOVE ACCT-BANK-CODE   TO WS-CURR-BANK-CODE
               MOVE ACCT-BRANCH-CODE TO WS-CURR-BRANCH-CODE
               MOVE ACCT-TYPE        TO WS-CURR-ACCT-TYPE

      *        Check for control breaks (major to minor)
               IF NOT WS-IS-FIRST-RECORD
                   PERFORM 3000-CHECK-CONTROL-BREAKS
               ELSE
      *            First record - print headers for first group
                   PERFORM 4000-PAGE-HEADER
                   PERFORM 3500-PRINT-GROUP-HEADER
                   MOVE "N" TO WS-FIRST-RECORD
               END-IF

      *        Process the detail record
               PERFORM 5000-PROCESS-DETAIL

      *        Save current control fields as previous
               MOVE WS-CURR-BANK-CODE   TO WS-PREV-BANK-CODE
               MOVE WS-CURR-BRANCH-CODE TO WS-PREV-BRANCH-CODE
               MOVE WS-CURR-ACCT-TYPE   TO WS-PREV-ACCT-TYPE

      *        Read next record
               READ ACCOUNT-FILE
                   AT END
                       SET WS-END-OF-FILE TO TRUE
               END-READ
           END-PERFORM

      *    Print final subtotals
           PERFORM 3100-TYPE-BREAK
           PERFORM 3200-BRANCH-BREAK
           PERFORM 3300-BANK-BREAK
           PERFORM 6000-GRAND-TOTALS
           .

      ******************************************************************
      * CHECK CONTROL BREAKS
      *
      * COBOL LESSON: Always check breaks from MAJOR to MINOR.
      * A major break implies all minor breaks too. If the bank
      * code changes, the branch and type totals must also print.
      ******************************************************************
       3000-CHECK-CONTROL-BREAKS.
      *    Major break: Bank Code changed
           IF WS-CURR-BANK-CODE NOT = WS-PREV-BANK-CODE
               PERFORM 3100-TYPE-BREAK
               PERFORM 3200-BRANCH-BREAK
               PERFORM 3300-BANK-BREAK
               PERFORM 3500-PRINT-GROUP-HEADER
               EXIT PARAGRAPH
           END-IF

      *    Intermediate break: Branch Code changed
           IF WS-CURR-BRANCH-CODE NOT = WS-PREV-BRANCH-CODE
               PERFORM 3100-TYPE-BREAK
               PERFORM 3200-BRANCH-BREAK
               PERFORM 3500-PRINT-GROUP-HEADER
               EXIT PARAGRAPH
           END-IF

      *    Minor break: Account Type changed
           IF WS-CURR-ACCT-TYPE NOT = WS-PREV-ACCT-TYPE
               PERFORM 3100-TYPE-BREAK
               EXIT PARAGRAPH
           END-IF
           .

      ******************************************************************
      * TYPE BREAK - Minor level subtotal
      ******************************************************************
       3100-TYPE-BREAK.
           IF WS-TYPE-COUNT > 0
               PERFORM 7100-GET-TYPE-DESC
               MOVE WS-ACCT-TYPE-DESC    TO WS-TT-LABEL
               MOVE WS-TYPE-COUNT        TO WS-TT-COUNT
               MOVE WS-TYPE-BALANCE      TO WS-TT-BAL
               MOVE WS-TYPE-AVAIL        TO WS-TT-AVAIL
               WRITE RPT-LINE FROM WS-TYPE-TOTAL-LINE
               ADD 1 TO WS-LINE-COUNT
               DISPLAY "      ** " WS-ACCT-TYPE-DESC ": "
                       WS-TYPE-COUNT " accounts"
           END-IF

      *    Reset type accumulators
           MOVE ZEROS TO WS-TYPE-COUNT
           MOVE ZEROS TO WS-TYPE-BALANCE
           MOVE ZEROS TO WS-TYPE-AVAIL
           MOVE ZEROS TO WS-TYPE-ACTIVE
           MOVE ZEROS TO WS-TYPE-FROZEN
           MOVE ZEROS TO WS-TYPE-DORMANT
           MOVE ZEROS TO WS-TYPE-CLOSED
           .

      ******************************************************************
      * BRANCH BREAK - Intermediate level subtotal
      ******************************************************************
       3200-BRANCH-BREAK.
           IF WS-BRANCH-COUNT > 0
               MOVE WS-BRANCH-COUNT   TO WS-BT-COUNT
               MOVE WS-BRANCH-BALANCE TO WS-BT-BAL
               MOVE WS-BRANCH-AVAIL   TO WS-BT-AVAIL
               WRITE RPT-LINE FROM WS-BRANCH-TOTAL-LINE
               WRITE RPT-LINE FROM WS-SEPARATOR
               ADD 2 TO WS-LINE-COUNT
               DISPLAY "     *** Branch " WS-PREV-BRANCH-CODE
                       " total: " WS-BRANCH-COUNT " accounts"
           END-IF

      *    Reset branch accumulators
           MOVE ZEROS TO WS-BRANCH-COUNT
           MOVE ZEROS TO WS-BRANCH-BALANCE
           MOVE ZEROS TO WS-BRANCH-AVAIL
           .

      ******************************************************************
      * BANK BREAK - Major level subtotal
      ******************************************************************
       3300-BANK-BREAK.
           IF WS-BANK-COUNT > 0
               MOVE WS-BANK-COUNT   TO WS-BKT-COUNT
               MOVE WS-BANK-BALANCE TO WS-BKT-BAL
               MOVE WS-BANK-AVAIL   TO WS-BKT-AVAIL
               WRITE RPT-LINE FROM WS-BANK-TOTAL-LINE
               WRITE RPT-LINE FROM WS-DBL-SEPARATOR
               ADD 2 TO WS-LINE-COUNT
               DISPLAY "    **** Bank " WS-PREV-BANK-CODE
                       " total: " WS-BANK-COUNT " accounts"
           END-IF

      *    Reset bank accumulators
           MOVE ZEROS TO WS-BANK-COUNT
           MOVE ZEROS TO WS-BANK-BALANCE
           MOVE ZEROS TO WS-BANK-AVAIL
           .

      ******************************************************************
      * PRINT GROUP HEADER
      ******************************************************************
       3500-PRINT-GROUP-HEADER.
      *    Check if we need a new page
           IF WS-LINE-COUNT + 10 > WS-LINES-PER-PAGE
               PERFORM 4000-PAGE-HEADER
           END-IF

           MOVE SPACES TO RPT-LINE
           STRING "  Bank: " WS-CURR-BANK-CODE
                  "  Branch: " WS-CURR-BRANCH-CODE
               DELIMITED BY SIZE
               INTO RPT-LINE
           WRITE RPT-LINE
           WRITE RPT-LINE FROM WS-COL-HEADER-1
           WRITE RPT-LINE FROM WS-SEPARATOR
           ADD 3 TO WS-LINE-COUNT
           .

      ******************************************************************
      * PAGE HEADER
      ******************************************************************
       4000-PAGE-HEADER.
           ADD 1 TO WS-PAGE-COUNT
           MOVE WS-PAGE-COUNT TO WS-TL-PAGE

           IF WS-PAGE-COUNT > 1
               MOVE SPACES TO RPT-LINE
               WRITE RPT-LINE BEFORE PAGE
           END-IF

           WRITE RPT-LINE FROM WS-TITLE-LINE
           WRITE RPT-LINE FROM WS-SUBTITLE-LINE
           WRITE RPT-LINE FROM WS-DBL-SEPARATOR
           MOVE 3 TO WS-LINE-COUNT
           .

      ******************************************************************
      * PROCESS DETAIL RECORD
      ******************************************************************
       5000-PROCESS-DETAIL.
      *    Check page overflow
           IF WS-LINE-COUNT >= WS-LINES-PER-PAGE
               PERFORM 4000-PAGE-HEADER
               PERFORM 3500-PRINT-GROUP-HEADER
           END-IF

      *    Format detail line
           MOVE SPACES TO WS-DETAIL-LINE
           MOVE ACCT-NUMBER       TO WS-DL-ACCT
           MOVE ACCT-STATUS       TO WS-DL-STATUS
           STRING ACCT-LAST-NAME DELIMITED BY "  "
                  ", " DELIMITED BY SIZE
                  ACCT-FIRST-NAME DELIMITED BY "  "
               INTO WS-DL-NAME
           MOVE ACCT-CURRENT-BAL  TO WS-DL-BAL
           MOVE ACCT-AVAILABLE-BAL TO WS-DL-AVAIL

      *    Format dates
           IF ACCT-OPEN-DATE > ZEROS
               STRING ACCT-OPEN-DATE(5:2) "/"
                      ACCT-OPEN-DATE(7:2) "/"
                      ACCT-OPEN-DATE(1:4)
                   DELIMITED BY SIZE
                   INTO WS-DL-OPENED
           ELSE
               MOVE "N/A       " TO WS-DL-OPENED
           END-IF

           IF ACCT-LAST-TXN-DATE > ZEROS
               STRING ACCT-LAST-TXN-DATE(5:2) "/"
                      ACCT-LAST-TXN-DATE(7:2) "/"
                      ACCT-LAST-TXN-DATE(1:4)
                   DELIMITED BY SIZE
                   INTO WS-DL-LASTTXN
           ELSE
               MOVE "N/A       " TO WS-DL-LASTTXN
           END-IF

           MOVE ACCT-TXN-COUNT-YTD TO WS-DL-TXNCNT

           WRITE RPT-LINE FROM WS-DETAIL-LINE
           ADD 1 TO WS-LINE-COUNT

      *    Accumulate totals at all levels
           ADD 1 TO WS-TYPE-COUNT
           ADD 1 TO WS-BRANCH-COUNT
           ADD 1 TO WS-BANK-COUNT
           ADD 1 TO WS-GRAND-COUNT

           ADD ACCT-CURRENT-BAL TO WS-TYPE-BALANCE
           ADD ACCT-CURRENT-BAL TO WS-BRANCH-BALANCE
           ADD ACCT-CURRENT-BAL TO WS-BANK-BALANCE
           ADD ACCT-CURRENT-BAL TO WS-GRAND-BALANCE

           ADD ACCT-AVAILABLE-BAL TO WS-TYPE-AVAIL
           ADD ACCT-AVAILABLE-BAL TO WS-BRANCH-AVAIL
           ADD ACCT-AVAILABLE-BAL TO WS-BANK-AVAIL
           ADD ACCT-AVAILABLE-BAL TO WS-GRAND-AVAIL

      *    Track status distribution
           EVALUATE TRUE
               WHEN ACCT-ACTIVE
                   ADD 1 TO WS-TYPE-ACTIVE
                   ADD 1 TO WS-GRAND-ACTIVE
               WHEN ACCT-FROZEN
                   ADD 1 TO WS-TYPE-FROZEN
                   ADD 1 TO WS-GRAND-FROZEN
               WHEN ACCT-DORMANT
                   ADD 1 TO WS-TYPE-DORMANT
                   ADD 1 TO WS-GRAND-DORMANT
               WHEN ACCT-CLOSED
                   ADD 1 TO WS-TYPE-CLOSED
                   ADD 1 TO WS-GRAND-CLOSED
           END-EVALUATE
           .

      ******************************************************************
      * GRAND TOTALS
      ******************************************************************
       6000-GRAND-TOTALS.
           WRITE RPT-LINE FROM WS-DBL-SEPARATOR
           MOVE WS-GRAND-COUNT   TO WS-GT-COUNT
           MOVE WS-GRAND-BALANCE TO WS-GT-BAL
           MOVE WS-GRAND-AVAIL   TO WS-GT-AVAIL
           WRITE RPT-LINE FROM WS-GRAND-TOTAL-LINE
           WRITE RPT-LINE FROM WS-DBL-SEPARATOR

      *    Status summary
           MOVE WS-GRAND-ACTIVE  TO WS-SS-ACTIVE
           MOVE WS-GRAND-FROZEN  TO WS-SS-FROZEN
           MOVE WS-GRAND-DORMANT TO WS-SS-DORMANT
           MOVE WS-GRAND-CLOSED  TO WS-SS-CLOSED
           WRITE RPT-LINE FROM WS-STATUS-SUMMARY-LINE

           DISPLAY SPACES
           DISPLAY "    GRAND TOTAL: " WS-GRAND-COUNT " accounts"
           .

      ******************************************************************
      * GET ACCOUNT TYPE DESCRIPTION
      ******************************************************************
       7100-GET-TYPE-DESC.
           EVALUATE WS-PREV-ACCT-TYPE
               WHEN "CH"  MOVE "Checking    " TO WS-ACCT-TYPE-DESC
               WHEN "SV"  MOVE "Savings     " TO WS-ACCT-TYPE-DESC
               WHEN "MM"  MOVE "Money Market" TO WS-ACCT-TYPE-DESC
               WHEN "CD"  MOVE "CD          " TO WS-ACCT-TYPE-DESC
               WHEN "LN"  MOVE "Loan        " TO WS-ACCT-TYPE-DESC
               WHEN "MG"  MOVE "Mortgage    " TO WS-ACCT-TYPE-DESC
               WHEN "CC"  MOVE "Credit Card " TO WS-ACCT-TYPE-DESC
               WHEN OTHER MOVE "Unknown     " TO WS-ACCT-TYPE-DESC
           END-EVALUATE
           .

      ******************************************************************
      * TERMINATION
      ******************************************************************
       9000-TERMINATE.
           CLOSE ACCOUNT-FILE
           CLOSE REPORT-FILE

           DISPLAY SPACES
           DISPLAY "================================================"
           DISPLAY "  Report Generation Complete"
           DISPLAY "================================================"
           DISPLAY "  Report written to: FINREPORT.RPT"
           DISPLAY "  Total accounts:    " WS-GRAND-COUNT
           DISPLAY "  Pages generated:   " WS-PAGE-COUNT
           DISPLAY "================================================"
           DISPLAY SPACES
           .