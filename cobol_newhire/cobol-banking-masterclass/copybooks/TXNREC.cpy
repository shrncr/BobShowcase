      ******************************************************************
      * TXNREC.cpy - Transaction Record Layout
      *
      * Defines the transaction record format for all banking
      * transactions. In production, thousands of these flow through
      * the batch cycle every night.
      *
      * COBOL LESSON: Notice how every field has a precise size.
      * COBOL records map directly to bytes on disk. A COBOL
      * programmer always knows exactly how big their data is.
      * No JSON bloat, no variable-length surprises. This is why
      * COBOL is so efficient for high-volume processing.
      ******************************************************************

       01  TRANSACTION-RECORD.
      *    ---- Transaction Identification ----
           05  TXN-ID                     PIC X(20).
           05  TXN-ID-R REDEFINES TXN-ID.
               10  TXN-DATE-PART         PIC 9(8).
               10  TXN-BRANCH-PART       PIC X(4).
               10  TXN-SEQ-PART          PIC 9(8).

      *    ---- Transaction Classification ----
           05  TXN-TYPE                   PIC X(3).
               88  TXN-DEPOSIT            VALUE "DEP".
               88  TXN-WITHDRAWAL         VALUE "WDR".
               88  TXN-TRANSFER-OUT       VALUE "TRO".
               88  TXN-TRANSFER-IN        VALUE "TRI".
               88  TXN-PAYMENT            VALUE "PMT".
               88  TXN-FEE               VALUE "FEE".
               88  TXN-INTEREST           VALUE "INT".
               88  TXN-ADJUSTMENT         VALUE "ADJ".
               88  TXN-REVERSAL           VALUE "REV".
               88  TXN-CHECK              VALUE "CHK".
               88  TXN-ACH-CREDIT         VALUE "ACR".
               88  TXN-ACH-DEBIT          VALUE "ADB".
               88  TXN-WIRE-IN            VALUE "WRI".
               88  TXN-WIRE-OUT           VALUE "WRO".
               88  TXN-ATM-WDR            VALUE "ATM".
               88  TXN-POS-PURCHASE       VALUE "POS".
               88  TXN-TYPE-VALID         VALUE "DEP" "WDR" "TRO"
                                                "TRI" "PMT" "FEE"
                                                "INT" "ADJ" "REV"
                                                "CHK" "ACR" "ADB"
                                                "WRI" "WRO" "ATM"
                                                "POS".
      *        COBOL LESSON: Grouping valid values in an 88-level
      *        lets you validate with IF TXN-TYPE-VALID instead of
      *        a massive OR chain. Elegant.

           05  TXN-SUBTYPE                PIC X(2).
           05  TXN-CHANNEL                PIC X(3).
               88  TXN-CHANNEL-BRANCH     VALUE "BRN".
               88  TXN-CHANNEL-ATM        VALUE "ATM".
               88  TXN-CHANNEL-ONLINE     VALUE "ONL".
               88  TXN-CHANNEL-MOBILE     VALUE "MOB".
               88  TXN-CHANNEL-PHONE      VALUE "PHN".
               88  TXN-CHANNEL-ACH        VALUE "ACH".
               88  TXN-CHANNEL-WIRE       VALUE "WIR".

      *    ---- Account References ----
           05  TXN-ACCOUNT-NUM            PIC X(16).
           05  TXN-CONTRA-ACCT            PIC X(16).
      *        Contra account for transfers

      *    ---- Financial Data ----
           05  TXN-AMOUNT                 PIC S9(13)V99 COMP-3.
           05  TXN-FEE-AMOUNT             PIC S9(7)V99 COMP-3.
           05  TXN-RUNNING-BAL            PIC S9(13)V99 COMP-3.

      *    ---- Date/Time ----
           05  TXN-DATETIME.
               10  TXN-DATE               PIC 9(8).
               10  TXN-DATE-R REDEFINES TXN-DATE.
                   15  TXN-DATE-YYYY      PIC 9(4).
                   15  TXN-DATE-MM        PIC 9(2).
                   15  TXN-DATE-DD        PIC 9(2).
               10  TXN-TIME               PIC 9(8).
               10  TXN-TIME-R REDEFINES TXN-TIME.
                   15  TXN-TIME-HH        PIC 9(2).
                   15  TXN-TIME-MI        PIC 9(2).
                   15  TXN-TIME-SS        PIC 9(2).
                   15  TXN-TIME-HS        PIC 9(2).

      *    ---- Processing Fields ----
           05  TXN-STATUS                 PIC X(1).
               88  TXN-PENDING            VALUE "P".
               88  TXN-POSTED             VALUE "C".
               88  TXN-REJECTED           VALUE "R".
               88  TXN-REVERSED           VALUE "V".
               88  TXN-HELD               VALUE "H".

           05  TXN-REASON-CODE            PIC X(4).
           05  TXN-AUTH-CODE              PIC X(8).
           05  TXN-BATCH-NUM              PIC 9(8).
           05  TXN-CHECK-NUM              PIC 9(8).

      *    ---- Description ----
           05  TXN-DESCRIPTION            PIC X(40).
           05  TXN-MEMO                   PIC X(80).

      *    ---- Originator Info ----
           05  TXN-ORIGINATOR.
               10  TXN-TELLER-ID          PIC X(8).
               10  TXN-TERMINAL-ID        PIC X(12).
               10  TXN-IP-ADDRESS         PIC X(15).

      *    ---- Filler for future use ----
           05  TXN-FILLER                 PIC X(16).
