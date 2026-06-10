      ******************************************************************
      * ERRCODES.cpy - System Error Codes
      *
      * Centralized error code definitions used across all programs.
      * In real mainframe shops, error codes like these are often
      * documented in multi-hundred-page reference manuals.
      *
      * COBOL LESSON: Centralizing error codes in a copybook
      * ensures consistency. When a new error condition is added,
      * every program picks it up on next compile.
      ******************************************************************

       01  ERROR-CODE-TABLE.
      *    ---- Success ----
           05  ERR-SUCCESS                PIC X(4) VALUE "0000".
           05  ERR-SUCCESS-WARN           PIC X(4) VALUE "0004".

      *    ---- Input Validation Errors (1xxx) ----
           05  ERR-INVALID-ACCT-NUM       PIC X(4) VALUE "1001".
           05  ERR-INVALID-ACCT-TYPE      PIC X(4) VALUE "1002".
           05  ERR-INVALID-TXN-TYPE       PIC X(4) VALUE "1003".
           05  ERR-INVALID-AMOUNT         PIC X(4) VALUE "1004".
           05  ERR-INVALID-DATE           PIC X(4) VALUE "1005".
           05  ERR-INVALID-CHECK-DIGIT    PIC X(4) VALUE "1006".
           05  ERR-MISSING-REQUIRED       PIC X(4) VALUE "1007".
           05  ERR-INVALID-STATUS         PIC X(4) VALUE "1008".
           05  ERR-INVALID-CHANNEL        PIC X(4) VALUE "1009".
           05  ERR-LUHN-CHECK-FAILED      PIC X(4) VALUE "1010".

      *    ---- Account Errors (2xxx) ----
           05  ERR-ACCT-NOT-FOUND         PIC X(4) VALUE "2001".
           05  ERR-ACCT-CLOSED            PIC X(4) VALUE "2002".
           05  ERR-ACCT-FROZEN            PIC X(4) VALUE "2003".
           05  ERR-ACCT-DORMANT           PIC X(4) VALUE "2004".
           05  ERR-ACCT-EXISTS            PIC X(4) VALUE "2005".
           05  ERR-ACCT-TYPE-MISMATCH     PIC X(4) VALUE "2006".

      *    ---- Transaction Errors (3xxx) ----
           05  ERR-INSUFFICIENT-FUNDS     PIC X(4) VALUE "3001".
           05  ERR-EXCEEDS-LIMIT          PIC X(4) VALUE "3002".
           05  ERR-DUPLICATE-TXN          PIC X(4) VALUE "3003".
           05  ERR-TXN-TOO-OLD            PIC X(4) VALUE "3004".
           05  ERR-CONTRA-ACCT-INVALID    PIC X(4) VALUE "3005".
           05  ERR-SAME-ACCOUNT           PIC X(4) VALUE "3006".
           05  ERR-DAILY-LIMIT-EXCEEDED   PIC X(4) VALUE "3007".
           05  ERR-HOLD-EXCEEDS-BALANCE   PIC X(4) VALUE "3008".
           05  ERR-NEG-BALANCE-NOT-ALLOW  PIC X(4) VALUE "3009".

      *    ---- File/System Errors (9xxx) ----
           05  ERR-FILE-OPEN-FAIL         PIC X(4) VALUE "9001".
           05  ERR-FILE-READ-FAIL         PIC X(4) VALUE "9002".
           05  ERR-FILE-WRITE-FAIL        PIC X(4) VALUE "9003".
           05  ERR-FILE-NOT-FOUND         PIC X(4) VALUE "9004".
           05  ERR-RECORD-LOCKED          PIC X(4) VALUE "9005".
           05  ERR-SYSTEM-ERROR           PIC X(4) VALUE "9999".

      *    ---- Return Code Working Storage ----
       01  WS-RETURN-CODE                 PIC X(4).
           88  WS-RC-SUCCESS              VALUE "0000".
           88  WS-RC-WARNING              VALUE "0004".
           88  WS-RC-ERROR                VALUE "0008".
           88  WS-RC-SEVERE               VALUE "0012".
           88  WS-RC-FATAL                VALUE "0016".

       01  WS-ERROR-MESSAGE               PIC X(80).
       01  WS-ERROR-PROGRAM              PIC X(8).
       01  WS-ERROR-PARAGRAPH            PIC X(30).
