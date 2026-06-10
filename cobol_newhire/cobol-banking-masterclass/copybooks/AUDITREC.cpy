      ******************************************************************
      * AUDITREC.cpy - Audit Trail Record Layout
      *
      * Every financial system needs an immutable audit trail.
      * Regulators (OCC, FDIC, Federal Reserve) require banks to
      * maintain complete transaction histories. This record format
      * captures who did what, when, and the before/after state.
      *
      * COBOL LESSON: Notice the hash chain field. Each audit
      * record contains a hash of the previous record, creating
      * a tamper-evident chain - blockchain before blockchain
      * was cool. Banks have been doing this since the 1970s.
      ******************************************************************

       01  AUDIT-TRAIL-RECORD.
      *    ---- Audit Record Identity ----
           05  AUDIT-SEQ-NUM              PIC 9(12).
           05  AUDIT-TIMESTAMP.
               10  AUDIT-DATE            PIC 9(8).
               10  AUDIT-TIME            PIC 9(8).
           05  AUDIT-PREV-HASH           PIC X(32).
      *        Hash of previous record - tamper detection

      *    ---- What Happened ----
           05  AUDIT-ACTION              PIC X(3).
               88  AUDIT-CREATE          VALUE "CRT".
               88  AUDIT-UPDATE          VALUE "UPD".
               88  AUDIT-DELETE          VALUE "DEL".
               88  AUDIT-READ            VALUE "RED".
               88  AUDIT-APPROVE         VALUE "APR".
               88  AUDIT-REJECT          VALUE "REJ".
               88  AUDIT-REVERSE         VALUE "RVS".

           05  AUDIT-ENTITY-TYPE         PIC X(4).
               88  AUDIT-ENTITY-ACCT     VALUE "ACCT".
               88  AUDIT-ENTITY-TXN      VALUE "TXN ".
               88  AUDIT-ENTITY-CUST     VALUE "CUST".

           05  AUDIT-ENTITY-ID           PIC X(20).
           05  AUDIT-TXN-ID              PIC X(20).

      *    ---- Who Did It ----
           05  AUDIT-OPERATOR.
               10  AUDIT-USER-ID         PIC X(8).
               10  AUDIT-PROGRAM-ID      PIC X(8).
               10  AUDIT-TERMINAL-ID     PIC X(12).

      *    ---- Before/After Image ----
      *    COBOL LESSON: Storing before and after values lets
      *    you reconstruct the state at any point in time.
      *    This is critical for dispute resolution and
      *    regulatory examinations.
           05  AUDIT-FIELD-NAME          PIC X(30).
           05  AUDIT-BEFORE-VALUE        PIC X(40).
           05  AUDIT-AFTER-VALUE         PIC X(40).

      *    ---- Additional Context ----
           05  AUDIT-RESULT-CODE         PIC X(4).
           05  AUDIT-DESCRIPTION         PIC X(60).

      *    ---- Record Hash ----
      *    Simple checksum of this record's contents
           05  AUDIT-RECORD-HASH         PIC X(32).

           05  AUDIT-FILLER              PIC X(15).
