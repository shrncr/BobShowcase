      ******************************************************************
      * ACCTREC.cpy - Account Master Record Layout
      *
      * This copybook defines the account master record used across
      * all programs. In real banking systems, copybooks like this
      * are maintained by a data administration team and shared
      * across hundreds of programs.
      *
      * COBOL LESSON: Copybooks are the original "shared types."
      * The COPY statement pulls this into any program that needs
      * it, ensuring consistent data layouts across the system.
      * REPLACE allows customizing prefixes per program.
      ******************************************************************

       01  ACCOUNT-MASTER-RECORD.
      *    ---- Account Identification ----
           05  ACCT-NUMBER                PIC X(16).
           05  ACCT-NUMBER-R REDEFINES ACCT-NUMBER.
      *        COBOL LESSON: REDEFINES lets you view the same
      *        memory differently. Here we break the account
      *        number into its components without extra storage.
               10  ACCT-BANK-CODE        PIC X(4).
               10  ACCT-BRANCH-CODE      PIC X(4).
               10  ACCT-SEQUENCE         PIC 9(7).
               10  ACCT-CHECK-DIGIT      PIC 9(1).

      *    ---- Account Classification ----
           05  ACCT-TYPE                  PIC X(2).
      *        COBOL LESSON: 88-level condition names make code
      *        read like English. Instead of IF ACCT-TYPE = "CH"
      *        you write IF ACCT-IS-CHECKING. Self-documenting.
               88  ACCT-IS-CHECKING       VALUE "CH".
               88  ACCT-IS-SAVINGS        VALUE "SV".
               88  ACCT-IS-MONEY-MARKET   VALUE "MM".
               88  ACCT-IS-CD             VALUE "CD".
               88  ACCT-IS-LOAN           VALUE "LN".
               88  ACCT-IS-MORTGAGE       VALUE "MG".
               88  ACCT-IS-CREDIT-CARD    VALUE "CC".
               88  ACCT-TYPE-VALID        VALUE "CH" "SV" "MM"
                                                "CD" "LN" "MG"
                                                "CC".
           05  ACCT-STATUS                PIC X(1).
               88  ACCT-ACTIVE            VALUE "A".
               88  ACCT-CLOSED            VALUE "C".
               88  ACCT-FROZEN            VALUE "F".
               88  ACCT-DORMANT           VALUE "D".
               88  ACCT-STATUS-VALID      VALUE "A" "C" "F" "D".

      *    ---- Customer Information ----
           05  ACCT-CUSTOMER-INFO.
               10  ACCT-CUST-ID           PIC X(12).
               10  ACCT-CUST-NAME.
                   15  ACCT-LAST-NAME     PIC X(30).
                   15  ACCT-FIRST-NAME    PIC X(20).
                   15  ACCT-MIDDLE-INIT   PIC X(1).
               10  ACCT-CUST-SSN          PIC X(11).
      *            SSN stored as XXX-XX-XXXX format
               10  ACCT-CUST-DOB          PIC 9(8).
      *            Date stored as YYYYMMDD - standard mainframe format
               10  ACCT-CUST-PHONE        PIC X(14).
               10  ACCT-CUST-EMAIL        PIC X(60).

      *    ---- Address Block ----
           05  ACCT-ADDRESS.
               10  ACCT-ADDR-LINE1        PIC X(40).
               10  ACCT-ADDR-LINE2        PIC X(40).
               10  ACCT-ADDR-CITY         PIC X(30).
               10  ACCT-ADDR-STATE        PIC X(2).
               10  ACCT-ADDR-ZIP          PIC X(10).

      *    ---- Financial Data ----
      *        COBOL LESSON: COMP-3 (packed decimal) stores two
      *        digits per byte plus a sign nibble. PIC S9(13)V99
      *        means: signed, 13 integer digits, 2 decimal places.
      *        This is EXACT arithmetic - no floating point errors.
      *        Banks NEVER use floating point for money.
           05  ACCT-FINANCIAL-DATA.
               10  ACCT-CURRENT-BAL       PIC S9(13)V99 COMP-3.
               10  ACCT-AVAILABLE-BAL      PIC S9(13)V99 COMP-3.
               10  ACCT-PENDING-BAL        PIC S9(13)V99 COMP-3.
               10  ACCT-HOLD-AMOUNT        PIC S9(13)V99 COMP-3.
               10  ACCT-CREDIT-LIMIT       PIC S9(13)V99 COMP-3.
               10  ACCT-INTEREST-RATE      PIC S9(3)V9(6) COMP-3.
               10  ACCT-ACCRUED-INT        PIC S9(13)V99 COMP-3.
               10  ACCT-YTD-INTEREST       PIC S9(13)V99 COMP-3.
               10  ACCT-YTD-FEES           PIC S9(11)V99 COMP-3.
               10  ACCT-OVERDRAFT-LIMIT    PIC S9(11)V99 COMP-3.
               10  ACCT-MIN-BALANCE        PIC S9(11)V99 COMP-3.

      *    ---- Date Tracking ----
           05  ACCT-DATES.
               10  ACCT-OPEN-DATE         PIC 9(8).
               10  ACCT-CLOSE-DATE        PIC 9(8).
               10  ACCT-LAST-TXN-DATE     PIC 9(8).
               10  ACCT-LAST-STMT-DATE    PIC 9(8).
               10  ACCT-MATURITY-DATE     PIC 9(8).
               10  ACCT-NEXT-REVIEW       PIC 9(8).

      *    ---- Activity Counters ----
      *        COBOL LESSON: COMP (pure binary) is used for
      *        counters and indices where exact decimal math
      *        isn't needed. It's faster for arithmetic.
           05  ACCT-ACTIVITY.
               10  ACCT-TXN-COUNT-MTD     PIC 9(7) COMP.
               10  ACCT-TXN-COUNT-YTD     PIC 9(9) COMP.
               10  ACCT-NSF-COUNT-YTD     PIC 9(3) COMP.
               10  ACCT-OD-COUNT-YTD      PIC 9(3) COMP.

      *    ---- Flags and Indicators ----
           05  ACCT-FLAGS.
               10  ACCT-STMT-FLAG         PIC X(1).
                   88  ACCT-STMT-PAPER    VALUE "P".
                   88  ACCT-STMT-ELECTRONIC VALUE "E".
                   88  ACCT-STMT-BOTH     VALUE "B".
               10  ACCT-OD-PROTECT-FLAG   PIC X(1).
                   88  ACCT-OD-PROTECTED  VALUE "Y".
               10  ACCT-ESCHEAT-FLAG      PIC X(1).
                   88  ACCT-ESCHEAT-RISK  VALUE "Y".
               10  ACCT-VIP-FLAG          PIC X(1).
                   88  ACCT-IS-VIP        VALUE "Y".
               10  ACCT-FILLER            PIC X(20).
      *            Reserved for future use - standard practice
      *            in mainframe systems to avoid file rebuilds
