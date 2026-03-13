//JLM0006  JOB (SYSGEN),'USERMOD: JLM0006',
//             CLASS=A,
//             MSGCLASS=X,
//             MSGLEVEL=(1,1),
//             REGION=4096K
/*JOBPARM LINES=100
//*
//*********************************************************************
//* INSTALL USERMOD JLM0006 - IKJEFT25 TSO TIME COMMAND               *
//********************************************************************3
//*
//IEBGENER EXEC PGM=IEBGENER
//SYSIN    DD  DUMMY
//SYSPRINT DD  DUMMY
//SYSUT1   DD  *
         TITLE 'TIME COMMAND PROCESSOR'
*
***********************************************************************
*                                                                     *
*    IIII   KK   KK      JJ EEEEEE  FFFFFFF TTTTTTTT   222    55555   *
*     II    KK  KK       JJ EE      FF         TT     2   2   5       *
*     II    KK KK        JJ EE      FF         TT         2   5       *
*     II    KKKK         JJ EEEE    FFFFF      TT         2   5555    *
*     II    KKKK         JJ EE      FF         TT      222        5   *
*     II    KK KK   JJ   JJ EE      FF         TT     2       5   5   *
*     II    KK  KK  JJ   JJ EE      FF         TT     2       5   5   *
*    IIII   KK   KK  JJJJJ  EEEEEEE FF         TT     22222    555    *
*                                                                     *
* FUNCTION - THIS MODULE PROCESSES THE TSO TIME COMMAND AND RETURNS   *
*    TO THE TSO USER'S SCREEN: TIME OF DAY, SESSION CPU TIME UTLIZED, *
*    SESSION SERVICE UNITS UTILIZED, SESSION TIME, AND SYSTEM DATE.   *
*                                                                     *
* EXIT - NORMAL = AT PROGRAM END VIA BRANCH REGISTER 14 (TO TSO)      *
*                                                                     *
* EXTERNAL REFERENCES - IKJEFLPA = TSO TIME OF DAY/DATE ACQUISITION   *
*                                                                     *
* DSECTS                                                              *
*    @EXTMEM - INTERNAL FIELDS STORED IN MEMORY EXTERNAL TO PROGRAM   *
*    IHAASCB - ADDRESS SPACE CONTROL BLOCK                            *
*    IKJCPPL - COMMAND PROCESSOR PARAMETER LIST                       *
*    IKJECT  - ENVIRONMENT CONTROL TABLE                              *
*    IKJUPT  - USER PROFILE TABLE                                     *
*                                                                     *
* ATTRIBUTES - REENTRANT, REFRESHABLE                                 *
*                                                                     *
* EXTERNAL MACROS USED: GETMAIN, FREEMAIN, PUTLINE, TSEVENT,          *
*                       SYSEVENT, TIME                                *
*                                                                     *
* REGISTER USAGE:                                                     *
*    R10 - INDEX FOR BUILDING PUTLINE OUTPUT MESSAGE TEXT             *
*    R12 - BASE REGISTER FOR CODE                                     *
*    R13 - BASE FOR ACQUIRED MEMORY AND MY SAVE AREA                  *
*    R14 - USED FOR INTERNAL SUBROUTINE AND EXTERNAL PROGRAM CALLS    *
*                                                                     *
* WRITTEN BY JAY MOSELEY IN MARCH, 2025                               *
*                                                                     *
*  UPDATE JULY, 2025 CORRECTED HOUR FORMAT FOR 12NOON TO 1PM     JM01 *
*                                                                     *
***********************************************************************
*
IKJEFT25 CSECT ,
         USING *,R15
         B     PROLOG                  BRANCH AROUND ID STRING
         DC    AL1(19)
         DC    C'IKJEFT25 2025/02/14'
         DROP  R15
PROLOG   ST    R14,12(,R13)            SAVE RETURN ADDR IN CALLER'S S/A
         STM   R0,R12,20(R13)          SAVE R0-R12 IN CALLER'S S/A
         LR    R12,R15                 LOAD BASE REGISTER
         USING IKJEFT25,R12
         LR    R11,R1                  PASSED CPPL PTR
         USING CPPL,R11
         LA    R0,@EXTMEML             LENGTH OF MEMORY TO ACQUIRE
         GETMAIN R,LV=(R0)             ACQUIRE ADDITIONAL MEMORY
         ST    R1,8(,R13)              SAVE MY S/A ADDR TO CALLER'S S/A
         ST    R13,4(,R1)              SAVE CALLER'S S/A ADDRESS
         LR    R13,R1                  SAVE NEW MEMORY BASE
         USING @EXTMEM,R13
*
***********************************************************************
* ISSUE TSEVENT CALL TO WRITE GTF RECORD.                             *
***********************************************************************
*
         MVC   PACKWK(4),=CL4'TIME'    1ST HALF OF COMMAND NAME
         L     R1,PACKWK                 INTO R1
         MVC   PACKWK(4),=CL4'    '    2ND HALF OF COMMAND NAME
         L     R15,PACKWK                INTO R15
         TSEVENT PPMODE                ISSUE TSEVENT CALL
*
***********************************************************************
* CLEAR OUTPUT BUFFER TO SPACES, INSERT "TIME=" INTO BUFFER, SET      *
* OFFSET FOR TIME-OF-DAY INSERTION.                                   *
***********************************************************************
*
         MVI   MSGBUFF,C' '            CLEAR MESSAGE BUFFER
         MVC   MSGBUFF+1(L'MSGBUFF-1),MSGBUFF  TO SPACES
         MVC   MSGBUFF(6),=CL6' TIME-' INSERT 1ST FIELD ID LITERAL
MSGIX    EQU   10                      R10 IS MESSAGE BUFFER OFFSET
         LA    MSGIX,6                 SET OFFSET TO NEXT INSERTION
*
***********************************************************************
* CALL TO IKJEFLPA (TSO TIME/DATE FORMATTER) TO RETRIEVE SYSTEM DATE  *
* AND TIME OF DAY.                                                    *
***********************************************************************
*
         LA    R1,FLPAP1               ADDRESS TO RECEIVE TOD
         ST    R1,FLPAPARM             STORE IN PARM LIST
         LA    R1,FLPAP2               ADDRESS TO RECEIVE DATE
         ST    R1,FLPAPARM+4           STORE IN PARM LIST
         L     R15,=V(IKJEFLPA)        ADDRESS OF IKJEFLPA
         LA    R1,FLPAPARM             ADDRESS OF PARM LIST
         BALR  R14,R15                 CALL IKJEFLPA
*
***********************************************************************
* ESTABLISH MERIDIEN INDIATOR (AM/PM): IF TOD HOUR IS GREATER THAN 12 *
* SUBTRACT 12 FROM HOUR AND INDICATE 'PM', ELSE INDICATE 'AM.         *
***********************************************************************
*
         MVC   MERIDIEN(3),=CL3' AM'   INIT DEFAULT OF AM
         PACK  PACKWK(2),FLPAH         CONVERT HOUR TO DECIMAL
         CP    PACKWK(2),=PL2'12'      IS HOUR < 12 ?
         BL    MIOK                      YES, DEFAULT CORRECT      JM01
         MVI   MERIDIEN+1,C'P'           NO, INDICATE PAST NOON    JM01
*                                      IS HOUR > 12 ?              JM01
MIOK     BNH   FLPAHXIT                  NO, HOUR IS CORRECT       JM01
         SP    PACKWK(2),=PL2'12'      SUBTRACT 12 FROM HOUR
         UNPK  UNPKWK(2),PACKWK(2)     UNPACK MODIFIED HOUR
         OI    UNPKWK+1,X'F0'          CLEAR SIGN
         MVC   FLPAH(2),UNPKWK         MOVE UPDATED HOUR BACK
FLPAHXIT EQU   *
*
***********************************************************************
* MOVE TOD TO OUTPUT BUFFER, INCREMENT INDEX FOR NEXT INSERTION.      *
***********************************************************************
*
         LA    R6,MSGBUFF(MSGIX)       ADDRESS NEXT OUTPUT POSITION
         MVC   0(11,R6),TIMEEDIT       MOVE TOD TO BUFFER
         LA    MSGIX,12(,MSGIX)        SET OFFSET TO NEXT INSERTION
*
***********************************************************************
* MOVE "CPU-" TO OUTPUT BUFFER, INCREMENT INDEX FOR NEXT INSERTION.   *
***********************************************************************
*
         LA    R6,MSGBUFF(MSGIX)       ADDRESS NEXT OUTPUT POSITION
         MVC   0(4,R6),=CL4'CPU-'      INSERT 2ND FIELD ID LITERAL
         LA    MSGIX,4(,MSGIX)         SET OFFSET TO NEXT INSERTION
*
***********************************************************************
* EXTRACT CUMULATIVE CPU TIME FROM THE ASCB, CONVERT TO PRINTABLE     *
* FORMAT, MOVE TO OUTPUT BUFFER, INCREMENT INDEX FOR NEXT INSERTION.  *
***********************************************************************
*
CVTPTR   EQU   16                      ADDRESS OF CVT
CVTTCBP  EQU   0                       ADDRESS OF TCB IN CVT
ASCBCUR  EQU   12                      ADDRESS OF CURRENT ASCB IN CVT
         L     R6,CVTPTR               R6->CVT
         L     R6,CVTTCBP(,R6)         R6->TCB/ASCB (4 DOUBLE WORDS)
         L     R6,ASCBCUR(,R6)         R6->CURRENT ASCB
         USING ASCB,R6
         MVC   VALASCB(8),ASCBEJST     SAVE ELAPSED CPU TIME
         DROP  R6
         L     R6,CPUASCB              LOAD TIME FOR CONVERSION
         BAL   R14,CONVERT             CONVERT TO FORM HH:MM:SS
         LA    R6,MSGBUFF(MSGIX)       ADDRESS NEXT OUTPUT POSITION
         MVC   0(8,R6),CNVBUFF         MOVE TO MESSAGE BUFFER
         LA    MSGIX,9(,MSGIX)         SET OFFSET TO NEXT INSERTION
*
***********************************************************************
* MOVE "SERVICE-" TO OUTPUT BUFFER, INCREMENT INDEX FOR NEXT          *
* INSERTION.                                                          *
***********************************************************************
*
         LA    R6,MSGBUFF(MSGIX)       ADDRESS NEXT OUTPUT POSITION
         MVC   0(8,R6),=CL8'SERVICE-'  INSERT 3RD FIELD ID LITERAL
         LA    MSGIX,8(,MSGIX)         SET OFFSET TO NEXT INSERTION
*
***********************************************************************
* OBTAIN SERVICE UNITS, CONVERT TO DECIMAL, LOCATE FIRST SIGNIFICANT  *
* (NON-ZERO) DIGIT, COMPUTE LENGTH TO MOVE, MOVE TO BUFFER, INCREMENT *
* INDEX FOR NEXT INSERTION.                                           *
***********************************************************************
*
         LA    R1,SERVICE              ADDRESS TO RETURN SERVICE UNITS
         SYSEVENT REQSERVC             REQUEST INFORMATION
         L     R1,SRUNITS              RETRIEVE BINARY COUNT
         CVD   R1,PACKWK               CONVERT TO DECIMAL
         UNPK  UNPKWK(8),PACKWK(8)     CONVERT TO DISPLAY
         OI    UNPKWK+7,X'F0'          CLEAR SIGN
         LA    R1,8                    R1=LENGTH TO SCAN
SUSCAN   LA    R2,8                    LENGTH OF FIELD
         SR    R2,R1                   OFFSET TO CHARACTER IN FIELD
         LA    R2,UNPKWK(R2)           ADDRESS OF DIGIT TO TEST
         CLI   0(R2),X'F0'             ZERO OR SIGNIFICANT?
         BNE   SUSCANX                 EXIT LOOP IF SIGNIFICANT
         BCT   R1,SUSCAN               CONTINUE WITH NEXT DIGIT
*                                        ELSE ALL DIGITS ARE ZERO
         LA    R1,1                    ALWAYS DISPLAY 1 DIGIT
         LA    R2,UNPKWK+7                --> DISPLAY RIGHTMOST DIGIT
SUSCANX  BCTR  R1,0                    DECREMENT FOR EXECUTE
         LA    R6,MSGBUFF(MSGIX)       ADDRESS NEXT OUTPUT POSITION
         EX    R1,SUMOVE               EXECUTE THE MOVE
SUMOVE   MVC   0(*-*,R6),0(R2)         EXECUTED MOVE
         LA    R1,2(,R1)               RESTORE LENGTH MOVED + 1
         AR    MSGIX,R1                SET OFFSET TO NEXT INSERTION
*
***********************************************************************
* MOVE "SESSION-" TO OUTPUT BUFFER, INCREMENT INDEX FOR NEXT          *
* INSERTION.                                                          *
***********************************************************************
*
         LA    R6,MSGBUFF(MSGIX)       ADDRESS NEXT OUTPUT POSITION
         MVC   0(8,R6),=CL8'SESSION-'  INSERT 4TH FIELD ID LITERAL
         LA    MSGIX,8(,MSGIX)         SET OFFSET TO NEXT INSERTION
*
***********************************************************************
* CALCULATE ELAPSED SESSION TIME, CONVERT TO PRINTABLE FORMAT, MOVE   *
* TO OUTPUT BUFFER, INCREMENT INDEX FOR NEXT INSERTION.               *
***********************************************************************
*
         TIME  STCK,TIMESTCK           GET TIME IN STCK UNITS
PSCBLTIM EQU   20                      ADDRESS OF LOGON TIME IN PSCB
         L     R7,CPPLPSCB             R7->PSCB
         L     R6,STCTIME              LOAD CURRENT TIME
         SL    R6,PSCBLTIM(,R7)        SUBTRACT LOGON TIME
         BAL   R14,CONVERT             CONVERT TO FORM HH:MM:SS
         LA    R6,MSGBUFF(MSGIX)       ADDRESS NEXT OUTPUT POSITION
         MVC   0(8,R6),CNVBUFF         MOVE TO MESSAGE BUFFER
         LA    MSGIX,9(,MSGIX)         SET OFFSET TO NEXT INSERTION
*
***********************************************************************
* MOVE CURRENT DATE (FROM IKJEFLPA) TO OUTPUT BUFFER.                 *
***********************************************************************
*
         LA    R6,MSGBUFF(MSGIX)       ADDRESS NEXT OUTPUT POSITION
         LH    R1,FLPAP2L              GET LENGTH OF RETURNED DATE
         SH    R1,=H'5'                SUBTRACT LENGTH OF HEADER + 1
         EX    R1,DATEMOVE             EXECUTE MOVE
DATEMOVE MVC   0(*-*,R6),FLPADATE      MOVE FORMATTED DATE TO BUFFER
*
***********************************************************************
* MAKE CPPL CONTROL BLOCKS AVAILABLE.                                 *
***********************************************************************
*
         L     R5,CPPLUPT              LOAD USER PROFILE TABLE ADDR
         USING UPT,R5
         L     R8,CPPLECT              ENVIRONMENT CONTROL TABLE ADDR
         USING ECT,R8
         XC    ECB,ECB                 CLEAR ECB FOR PUTLINE
*
***********************************************************************
* SET UP PUTLINE CONTROL BLOCKS, ISSUE PUTLINE.                       *
***********************************************************************
*
         LA    R1,MSGLEN               LENGTH OF MESSAGE
         STCM  R1,B'0011',MSGHDR+0     STORE LENGTH IN HEADER BYTE
         STCM  R1,B'1100',MSGHDR+2     CLEAR SECOND BYTE OF HEADER
         PUTLINE PARM=PUTLINE,         WRITE MESSAGE TO SCREEN         C
               MF=(E,IOPL),ECB=ECB,ECT=ECT,UPT=UPT,                    C
               TERMPUT=(EDIT,WAIT,NOHOLD,NOBREAK),                     C
               OUTPUT=(MSGOUT,TERM,SINGLE,DATA)
*
***********************************************************************
* ISSUE TSEVENT CALL TO WRITE GTF RECORD.                             *
***********************************************************************
*
         MVC   PACKWK(4),=CL4'TIME'    1ST HALF OF COMMAND NAME
         L     R1,PACKWK                 INTO R1
         MVC   PACKWK(4),=CL4'    '    2ND HALF OF COMMAND NAME
         L     R15,PACKWK                INTO R15
         TSEVENT PPMODE                ISSUE TSEVENT CALL
*
***********************************************************************
* FREE MEMORY, RESTORE REGISTERS, RETURN TO TSO WITH RC=0.            *
***********************************************************************
*
         LR    R1,R13                  ADDRESS OF MEMORY
         L     R13,4(,R1)              RESTORE CALLER'S SAVE AREA
         LA    R0,@EXTMEML             LENGTH OF MEMORY TO FREE
         FREEMAIN R,A=(R1),LV=(R0)     RELEASE IT
         L     R14,12(,R13)            RESTORE RETURN ADDRESS
         LM    R0,R12,20(R13)          RESTORE R0 THRU R12
         XR    R15,R15                 ZERO RETURN CODE
         BR    R14                     RETURN TO TSO
*
***********************************************************************
* CONVERT STORE-CLOCK UNITS (PASSED IN R6) INTO HOURS, MINUTES, AND   *
* SECONDS AND STORES INTO CONVERSION BUFFER.                          *
***********************************************************************
*
CONVERT  STM   R14,R12,INTSAVEA        SAVE REGISTERS
         MVC   CNVBUFF(8),=CL8'  :  :  ' INITIALZE CONVERSION BUFFER
         LA    R7,CNVBUFF              ADDRESS OF CONVERSION BUFFER
         LR    R5,R6                   VALUE TO CONVERT
         L     R6,STCKSEC              CONVERSION FACTOR
         MR    R4,R6                   CONVERT
         L     R6,DECFACTR             DECIMAL FACTOR
         DR    R4,R6                   CONVERT
         SLR   R4,R4                   CLEAR FOR REMAINDER
         L     R6,SECPERHR             SECONDS PER HOUR FACTOR
         DR    R4,R6
         CVD   R5,UNPKWK               CONVERT TO DECIMAL
         UNPK  0(2,R7),UNPKWK+6(2)     HOURS TO OUTPUT BUFFER
         OI    1(R7),X'F0'             CLEAR SIGN
         L     R6,SECPERMN             SECONDS PER MINUTE FACTOR
         LR    R5,R4                   MOVE REMAINDER
         SLR   R4,R4                   CLEAR FOR REMAINDER
         DR    R4,R6
         CVD   R5,UNPKWK               CONVERT TO DECIMAL
         UNPK  3(2,R7),UNPKWK+6(2)     MINUTES TO OUTPUT BUFFER
         OI    4(R7),X'F0'             CLEAR SIGN
         CVD   R4,UNPKWK               CONVERT TO DECIMAL
         UNPK  6(2,R7),UNPKWK+6(2)     SECONDS TO OUTPUT BUFFER
         OI    7(R7),X'F0'             CLEAR SIGN
         LM    R14,R12,INTSAVEA        RESTORE REGISTERS
         BR    R14                     RETURN
*
***********************************************************************
* DSECT FOR MAPPING EXTERNAL MEMORY                                   *
***********************************************************************
*
@EXTMEM  DSECT
         DS    18F                     MY SAVE AREA
INTSAVEA DS    15F                     INTERNAL CALL SAVE AREA
FLPAPARM DS    2A                      FOR CALL TO IKJEFLPA
VALASCB  DS    CL8                     CPU TIME RETRIEVED FROM ASCB
CPUASCB  EQU   VALASCB,4,C'F'            ONLY CPU TIME PORTION
TIMESTCK DS    CL8                     CURRENT TIME IN STCK VALUE
STCTIME  EQU   TIMESTCK,4,C'F'           ONLY CURRENT TIME PORTION
CNVBUFF  DS    CL8                     BUFFER FOR TIME CONVERSIONS
SERVICE  DS    CL12                    BUFFER FOR SYSEVENT REQSERVC
SRUNITS  EQU   SERVICE,4,C'A'            ONLY SERVICE UNITS COUNT
ECB      DS    F                       ECB FOR PUTLINE
IOPL     DS    10F                     IOPL FOR PUTLINE
PUTLINE  PUTLINE MF=L                  PUTLINE CONTROL BLOCK
MSGOUT   DS    0C                      MESSAGE BUILDING AREA
MSGHDR   DS    4X                        HEADER FOR PUTLINE
MSGBUFF  DS    CL80                      BUILD TIME OUTPUT MESSAGE HERE
MSGLEN   EQU   *-MSGOUT                LENGTH OF MESSAGE
FLPAP1   DS    0CL12                   TOD PARM FROM IKJEFLPA
FLPAP1L  DS    H                         LENGTH OF PARM (TOD+4)
         DS    H                         UNUSED
FLPATOD  DS    CL8                       TOD FROM IKJEFLPA (HH:MM:SS)
FLPAH    EQU   FLPATOD+0,2,C'C'            HOUR
FLPAM    EQU   FLPATOD+3,2,C'C'            MINUTE
FLPAS    EQU   FLPATOD+6,2,C'C'            SECOND
MERIDIEN DS    CL3                     AM/PM MERIDIEN AREA
TIMEEDIT EQU   FLPATOD,11,C'C'         REDEFINES TOD+MERIDIEN
         DS    0H
FLPAP2   DS    0CL22                   DATE PARM FROM IKJEFLPA
FLPAP2L  DS    H                         LENGTH OF PARM (DATE+4)
         DS    H                         UNUSED
FLPADATE DS    CL18                      DATE FROM IKJEFLPA
         DS    0D
PACKWK   DS    CL8                     WORK FIELD: CONVERT BIN/DEC
UNPKWK   DS    CL8                     WORK FIELD: CONVERT DISPLAY/DEC
@EXTMEMZ EQU   *                       END ADDRESS OF ACQUIRED MEMORY
*
IKJEFT25 CSECT ,
*
*
         DS    0F
@EXTMEML DC    AL1(1)                  ACQUIRE FROM SUBPOOL=1
         DC    AL3(@EXTMEMZ-@EXTMEM)   LENGTH OF ACQUIRED MEMORY
STCKSEC  DC    F'1048576'              STCK TO SECONDS FACTOR
DECFACTR DC    F'1000000'              DEC CONVERSION FACTOR
SECPERHR DC    F'3600'                 SECONDS IN AN HOUR
SECPERMN DC    F'60'                   SECONDS IN A MINUTE
*
         IHAASCB ,
         IKJCPPL ,
         IKJECT ,
         IKJUPT ,
*
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
*
         END   IKJEFT25
//SYSUT2   DD  DISP=SHR,DSN=SYS1.UMODSRC(IKJEFT25)
//SMPAS003 EXEC SMPASM,M=IKJEFT25
//ASM.SYSPUNCH DD UNIT=SYSDA,DSN=&&OBJMOD,DISP=(,PASS),SPACE=(TRK,(60))
//IEBGENER EXEC PGM=IEBGENER
//SYSPRINT DD  DUMMY
//SYSIN    DD  DUMMY
//SYSUT1   DD  DSN=&&OBJMOD,DISP=(OLD,DELETE)
//         DD  *
   IDENTIFY IKJEFT25('JLM0006')
   INCLUDE UMODOBJ(IKJEFLPA)
   ORDER (IKJEFT25,IKJEFLPA)
//SYSUT2   DD  DISP=SHR,DSN=SYS1.UMODOBJ(IKJEFT25)
//UMOD001  EXEC SMPAPP,WORK=SYSALLDA
//SMPPTFIN DD  *
++USERMOD(JLM0006)       /* FIX TIME COMMAND CENTURY      */  .
++VER (Z038) FMID(EBB1102) PRE(UZ27405,JLM0005)
 /*
  PROBLEM DESCRIPTION(S): TSO TIME COMMAND PROCESSOR DISPLAYS '19' FOR
                          CENTURY OF DATE REGARDLESS OF SYSTEM DATE
                          SETTING.
  SPECIAL CONDITIONS:     UPDATED VERSION WILL BE AVAILABLE UPON NEXT
                          LOGON FOLLOWING APPLICATION.
 */.
++MOD(IKJEFT25) DISTLIB(AOST4) TXLIB(UMODOBJ).
//SMPCNTL  DD  *
  REJECT
          SELECT(JLM0006)
          .
  RESETRC .               /* IN CASE NOT ALREADY RECEIVED */
  RECEIVE
          SELECT(JLM0006)
          .
//*
//APPLYCK  EXEC SMPAPP,WORK='SYSALLDA'
//SMPCNTL  DD  *
  APPLY
        SELECT(JLM0006)
        BYPASS(ID)
        CHECK
        .
  APPLY
        SELECT(JLM0006)
        DIS(WRITE)
        .
/*
//
