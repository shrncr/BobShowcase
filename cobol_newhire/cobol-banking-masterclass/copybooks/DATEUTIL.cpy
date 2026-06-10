      ******************************************************************
      * DATEUTIL.cpy - Date Handling Utilities
      *
      * Date arithmetic in COBOL is notoriously tricky. Before
      * intrinsic functions were added, programmers wrote their
      * own leap year checks and Julian date converters. Y2K was
      * a massive effort precisely because of how dates were stored.
      *
      * COBOL LESSON: The FUNCTION keyword accesses intrinsic
      * functions added in COBOL-85 and expanded in COBOL-2002.
      * INTEGER-OF-DATE converts YYYYMMDD to a Julian day number
      * for easy date arithmetic.
      ******************************************************************

       01  WS-DATE-WORK-AREAS.
           05  WS-CURRENT-DATE-FULL.
               10  WS-CURRENT-YYYY       PIC 9(4).
               10  WS-CURRENT-MM         PIC 9(2).
               10  WS-CURRENT-DD         PIC 9(2).
           05  WS-CURRENT-DATE-INT REDEFINES
               WS-CURRENT-DATE-FULL      PIC 9(8).

           05  WS-CURRENT-TIME-FULL.
               10  WS-CURRENT-HH         PIC 9(2).
               10  WS-CURRENT-MI         PIC 9(2).
               10  WS-CURRENT-SS         PIC 9(2).
               10  WS-CURRENT-HS         PIC 9(2).

           05  WS-WORK-DATE-1            PIC 9(8).
           05  WS-WORK-DATE-2            PIC 9(8).
           05  WS-JULIAN-1               PIC 9(7).
           05  WS-JULIAN-2               PIC 9(7).
           05  WS-DAYS-BETWEEN           PIC S9(5) COMP-3.

      *    ---- Days in Month Table ----
      *    COBOL LESSON: OCCURS creates an array (table).
      *    This table holds the number of days in each month.
           05  WS-DAYS-IN-MONTHS.
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
           05  WS-DAYS-TABLE REDEFINES WS-DAYS-IN-MONTHS.
               10  WS-DAYS-IN-MONTH      PIC 9(2)
                                          OCCURS 12 TIMES.

      *    ---- Leap Year Work Fields ----
           05  WS-LEAP-YEAR-FLAG         PIC X(1).
               88  WS-IS-LEAP-YEAR       VALUE "Y".
               88  WS-NOT-LEAP-YEAR      VALUE "N".
           05  WS-WORK-YEAR              PIC 9(4).
           05  WS-WORK-MONTH             PIC 9(2).
           05  WS-WORK-DAY               PIC 9(2).
           05  WS-YEAR-DAYS              PIC 9(3).

      *    ---- Day Count Convention ----
      *    Used in interest calculations - different conventions
      *    for different product types
           05  WS-DAY-COUNT-CONV         PIC X(7).
               88  WS-ACTUAL-360         VALUE "ACT/360".
               88  WS-ACTUAL-365         VALUE "ACT/365".
               88  WS-30-360             VALUE "30/360 ".

      *    ---- Formatted Date Output ----
           05  WS-FORMATTED-DATE         PIC X(10).
      *        MM/DD/YYYY format
           05  WS-FORMATTED-DATE-LONG    PIC X(20).
      *        Month DD, YYYY format

           05  WS-MONTH-NAMES.
               10  FILLER PIC X(9) VALUE "January  ".
               10  FILLER PIC X(9) VALUE "February ".
               10  FILLER PIC X(9) VALUE "March    ".
               10  FILLER PIC X(9) VALUE "April    ".
               10  FILLER PIC X(9) VALUE "May      ".
               10  FILLER PIC X(9) VALUE "June     ".
               10  FILLER PIC X(9) VALUE "July     ".
               10  FILLER PIC X(9) VALUE "August   ".
               10  FILLER PIC X(9) VALUE "September".
               10  FILLER PIC X(9) VALUE "October  ".
               10  FILLER PIC X(9) VALUE "November ".
               10  FILLER PIC X(9) VALUE "December ".
           05  WS-MONTH-TABLE REDEFINES WS-MONTH-NAMES.
               10  WS-MONTH-NAME         PIC X(9)
                                          OCCURS 12 TIMES.
