//JLM0005 JOB (SYS),'USERMOD JLM0005',CLASS=S,MSGCLASS=A
//*
//*********************************************************************
//* INSTALL USERMOD JLM0005 - IKJEFLPA DATE/TIME ROUTINE              *
//********************************************************************3
//*
//IEBGENER EXEC PGM=IEBGENER
//SYSIN    DD  DUMMY
//SYSPRINT DD  DUMMY
//SYSUT1   DD  *
         TITLE 'IKJEFLPA -- TOD && DATE TEXT PREPARATION'               00000100
*         GENERATE;                                                     00000200
FLPA     TITLE 'IKJEFLPA -- TOD && TEXT PREPARATION -- MODULE PROLOGUE *00000300
               && SPECIFICATIONS'                                       00000400
         LCLA  &T,&SPN,&LDAY(12),&I,&LNDESCR                            00000500
         LCLC  &LUPDAT                                                  00000600
&SPN     SETA  1  OBTAIN DYNAMIC AREA FROM SUBPOOL 1                    00000700
&LUPDAT  SETC  '24139' DATE OF LAST MODULE UPDATE                       00000800
IKJEFLPA  START 0  FORCE ASSIGNMENT OF ADDRESSES TO IKJEFLPA FIRST      00000900
* /*******************************************************************/ 00001000
* /*                                                                 */ 00001100
* /* STATUS --                                                       */ 00001200
* /*    RELEASE 20, MODIFICATION LEVEL 01                            */ 00001300
* /*    A 0-999999                                            S20033 */ 00001400
* /*    C                                                      24139 */ 00001500
* /*                                                                 */ 00001600
* /* FUNCTION --                                                     */ 00001700
* /*    THIS MODULE ACCEPTS TWO BUFFERS AS INPUT AND FORMATS THE TWO */ 00001800
* /*    INTO THE FORM OF TEXT INSERTION BUFFERS CONTAINING THE TIME  */ 00001900
* /*    OF DAY IN THE FORMAT 'HH:MM:SS' AND THE DATE IN THE FORMAT   */ 00002000
* /*    'MONTH DAY, YEAR'                                            */ 00002100
* /*                                                                 */ 00002200
* /* ENTRY POINTS --                                                 */ 00002300
* /*         IKJEFLPA                                                */ 00002400
* /*                                                                 */ 00002500
* /* INPUT --                                                        */ 00002600
* /*    R1 = THE ADDRESS OF A TYPE I PARAMETER LIST CONSISTING OF TWO*/ 00002700
* /*         POINTERS, THE FIRST OF WHICH MUST CONTAIN THE ADDRESS OF*/ 00002800
* /*         A WRITABLE BUFFER AT LEAST 22 BYTES IN LENGTH; THIS     */ 00002900
* /*         BUFFER IS KNOWN AS THE TIME-OF-DAY OR TOD BUFFER WITHIN */ 00003000
* /*         THIS MODULE.  THE SECOND POINTER MUST CONTAIN THE       */ 00003100
* /*         ADDRESS OF A WRITABLE BUFFER AT LEAST 22 BYTES IN       */ 00003200
* /*         LENGTH; THIS BUFFER IS KNOWN AS THE DATE BUFFER WITHIN  */ 00003300
* /*         THIS MODULE.                                            */ 00003400
* /*    R13 = THE ADDRESS OF A 72-BYTE SAVE AREA                     */ 00003500
* /*    R14 = THE ADDRESS TO WHICH CONTROL SHOULD BE RETURNED        */ 00003600
* /*    R15 = THE ADDRESS OF THE ENTRY POINT OF IKJEFLPA             */ 00003700
* /*                                                                 */ 00003800
* /* OUTPUT --                                                       */ 00003900
* /*    R1 = ADDRESS OF INPUT PARAMETER LIST. THE TOD BUFFER HAS BEEN*/ 00004000
* /*         PROVIDED WITH A LENGTH FIELD AND TEXT DESCRIBING THE    */ 00004100
* /*         TIME OF DAY, AND THE DATE BUFFER HAS BEEN PROVIDED WITH */ 00004200
* /*         A LENGTH FIELD AND TEXT DESCRIBING THE DATE.            */ 00004300
* /*    R13 = THE SAME VALUE AS ON INPUT                             */ 00004400
* /*    R14 = THE SAME VALUE AS ON INPUT                             */ 00004500
* /*    R15 = THE SAME VALUE AS ON INPUT                             */ 00004600
* /*                                                                 */ 00004700
* /* EXTERNAL REFERENCES --                                          */ 00004800
* /*         NONE                                                    */ 00004900
* /*                                                                 */ 00005000
* /* EXITS, NORMAL --                                                */ 00005100
* /*         INVOKER                                                 */ 00005200
* /*                                                                 */ 00005300
* /* EXITS, ERROR --                                                 */ 00005400
* /*         NONE                                                    */ 00005500
* /*                                                                 */ 00005600
* /* TABLE/WORK AREAS --                                             */ 00005700
* /*         NONE                                                    */ 00005800
* /*                                                                 */ 00005900
* /* ATTRIBUTES --                                                   */ 00006000
* /*         REENTRANT, REFRESHABLE                                  */ 00006100
* /*                                                                 */ 00006200
* /* NOTES --                                                        */ 00006300
* /*    SEE THE FOLLOWING SPECIFICATIONS FOR A MORE DETAILED         */ 00006400
* /*    DESCRIPTION OF THE MODULE.  THIS MODULE IS CHARACTER CODE    */ 00006500
* /*    DEPENDENT ON THE INTERNAL CONFIGURATION OF THE EBCDIC        */ 00006600
* /*    CHARACTERS.  REASSEMBLY IS NECESSARY IF A DIFFERENT          */ 00006700
* /*    CHARACTER SET IS TO BE USED DURING EXECUTION.                */ 00006800
* /*                                                                 */ 00006900
*     MODIFIED BY JAY MOSELEY: USERMOD JLM0005     2024-05-20 (139) JLM 00007000
*                                                                   JLM 00007100
*        1. CALCULATE CORRECT CENTURY BY ADDING 19 TO CC BYTE       JLM 00007200
*           RETURNED BY SYSTEM TIME CALL.                           JLM 00007300
* /*                                                                 */ 00007400
* /*******************************************************************/ 00007500
* /* START OF SPECIFICATIONS ****                                       00007600
*1MODULE-NAME = IKJEFLPA                                                00007700
*  2PROCESSOR = BSL                                                     00007800
** THE RELEASE FOR WHICH THIS MODULE WAS MOST RECENTLY UPDATED          00007900
*1STATUS = 20 MODIFICATION LEVEL 00                                     00008000
*1DESCRIPTIVE-NAME = TOD & TEXT PREPARATION                             00008100
*1DESCRIPTION = THIS MODULE ACCEPTS TWO BUFFERS AS INPUT AND FORMATS -  00008200
*THE TWO INTO THE FORM OF TEXT INSERTION BUFFERS CONTAINING THE TIME -  00008300
*OF DAY IN THE FORMAT 'HH:MM:SS' AND THE DATE IN THE FORMAT 'MONTH   -  00008400
*DAY, YEAR'                                                             00008500
*1ASSUMPTIONS = OS/360 OPERATING ENVIRONMENT                            00008600
*1FUNCTION = SEE DESCRIPTION                                            00008700
*1MODULE-TYPE = PROCEDURE                                               00008800
*1MODULE-SIZE = 1024 BYTES                                              00008900
*1CODE-ATTRIBUTES = REENTERABLE                                         00009000
*1LOAD-ATTRIBUTES = SCATTER, REFRESHABLE                                00009100
*1ENTRY-POINT = IKJEFLPA                                                00009200
*  2LINKAGE = LINK                                                      00009300
*  * THE FOLLOWING DESCRIBES THE REQUIRED INPUT TO THIS MODULE.         00009400
*  * DATA MADE AVAILABLE THROUGH THE STANDARD INVOCATION SEQUENCE       00009500
*  * BUT NOT USED IN ANY WAY IS NOT NECESSARILY MENTIONED HERE.         00009600
*  2PARAMETER-RECEIVED = POINTER-TO-PARAMETER-LIST                      00009700
*  2HOW-PASSED = REGISTER 1                                             00009800
*  2LENGTH-OF-LIST = 8 BYTES                                            00009900
*    *****************************************************************/ 00010000
*    /***************************************************************** 00010100
*    3FIELD = PARAM1                                                    00010200
*      4REFERENCE-TYPE = READ                                           00010300
*      4DISPLACEMENT = 0 BYTES                                          00010400
*      4TYPE = ADDRESS                                                  00010500
*      4ADDRESS-LENGTH = 32 BITS                                        00010600
*      4ADDRESS-OF = TOD                                                00010700
*        5REFERENCE-TYPE = WRITE                                        00010800
*        5TYPE-ADDRESSED = TABLE                                        00010900
*        5PURPOSE = PROVIDE ADDRESSIBILITY TO A BUFFER TO BE         -  00011000
*        FORMATTED INTO A TEXT INSERTION BUFFER CONTAINING THE TIME  -  00011100
*        OF DAY                                                         00011200
*        5SCOPE = INTERNAL                                              00011300
*        5TABLE-SIZE = 12 BYTES                                         00011400
*        *************************************************************/ 00011500
*        /************************************************************* 00011600
*        5FIELD = TODLEN                                                00011700
*          6REFERENCE-TYPE = WRITE                                      00011800
*          6DISPLACEMENT = 0 BYTES                                      00011900
*          6TYPE = ARITHMETIC                                           00012000
*          6MODE = BINARY                                               00012100
*          6LENGTH = 15 BITS                                            00012200
*          6SIGN = SIGNED                                               00012300
*          6VALUE = IGNORED ON INPUT.                                   00012400
*        *************************************************************/ 00012500
*        /************************************************************* 00012600
*        5FIELD = TODOFF                                                00012700
*          6DISPLACEMENT = 2 BYTES                                      00012800
*          6TYPE = ARITHMETIC                                           00012900
*          6MODE = BINARY                                               00013000
*          6LENGTH = 15 BITS                                            00013100
*          6SIGN = SIGNED                                               00013200
*          6VALUE = IGNORED ON INPUT.                                   00013300
*        *************************************************************/ 00013400
*        /************************************************************* 00013500
*        5FIELD = TODTXT                                                00013600
*          6REFERENCE-TYPE = WRITE                                      00013700
*          6DISPLACEMENT = 4 BYTES                                      00013800
*          6TYPE = CHARACTER STRING                                     00013900
*          6LENGTH+MODE = 8 CHARACTERS                                  00014000
*          6VALUE = IGNORED ON INPUT.                                   00014100
*    *****************************************************************/ 00014200
*    /***************************************************************** 00014300
*    3FIELD = PARAM2                                                    00014400
*      4REFERENCE-TYPE = READ                                           00014500
*      4DISPLACEMENT = 4 BYTES                                          00014600
*      4TYPE = ADDRESS                                                  00014700
*      4ADDRESS-LENGTH = 32 BITS                                        00014800
*      4ADDRESS-OF = DATE                                               00014900
*        5REFERENCE-TYPE = WRITE                                        00015000
*        5TYPE-ADDRESSED = TABLE                                        00015100
*        5PURPOSE = PROVIDE ADDRESSIBILITY TO A BUFFER TO BE         -  00015200
*        FORMATTED INTO A TEXT INSERTION BUFFER CONTAINING THE DATE     00015300
*        5SCOPE = INTERNAL                                              00015400
*        5TABLE-SIZE = 22 BYTES                                         00015500
*        *************************************************************/ 00015600
*        /************************************************************* 00015700
*        5FIELD = DATELEN                                               00015800
*          6REFERENCE-TYPE = WRITE                                      00015900
*          6DISPLACEMENT = 0 BYTES                                      00016000
*          6TYPE = ARITHMETIC                                           00016100
*          6MODE = BINARY                                               00016200
*          6LENGTH = 15 BITS                                            00016300
*          6SIGN = SIGNED                                               00016400
*          6VALUE = IGNORED ON INPUT.                                   00016500
*        *************************************************************/ 00016600
*        /************************************************************* 00016700
*        5FIELD = DATEOFF                                               00016800
*          6DISPLACEMENT = 2 BYTES                                      00016900
*          6TYPE = ARITHMETIC                                           00017000
*          6MODE = BINARY                                               00017100
*          6LENGTH = 15 BITS                                            00017200
*          6SIGN = SIGNED                                               00017300
*          6VALUE = IGNORED ON INPUT.                                   00017400
*        *************************************************************/ 00017500
*        /************************************************************* 00017600
*        5FIELD = DATETXT                                               00017700
*          6REFERENCE-TYPE = WRITE                                      00017800
*          6DISPLACEMENT = 4 BYTES                                      00017900
*          6TYPE = CHARACTER STRING                                     00018000
*          6LENGTH+MODE = 18 CHARACTERS                                 00018100
*          6VALUE = IGNORED ON INPUT.                                   00018200
**********************************************************************/ 00018300
* /******************************************************************** 00018400
*1EXIT = INVOKER                                                        00018500
*  2CONDITIONS-WHEN-TAKEN = ALWAYS                                      00018600
*  2LINKAGE = RETURN                                                    00018700
*  * THE FOLLOWING DESCRIBES THE OUTPUT OF THIS MODULE.                 00018800
*  * DATA MADE AVAILABLE TO THE FOLLOWING MODULE AS A                   00018900
*  * RESULT OF THE CURRENT IMPLEMENTATION BUT NOT GUARANTEED            00019000
*  * TO THAT MODULE IS NOT ENUMERATED.                                  00019100
*  2PARAMETER-RETURNED = POINTER-TO-PARAMETER-LIST                      00019200
*  2HOW-PASSED = REGISTER 1                                             00019300
*  2LENGTH-OF-LIST = 8 BYTES                                            00019400
*    *****************************************************************/ 00019500
*    /***************************************************************** 00019600
*    3FIELD = PARAM1                                                    00019700
*      4REFERENCE-TYPE = READ                                           00019800
*      4DISPLACEMENT = 0 BYTES                                          00019900
*      4TYPE = ADDRESS                                                  00020000
*      4ADDRESS-LENGTH = 32 BITS                                        00020100
*      4ADDRESS-OF = TOD                                                00020200
*        5REFERENCE-TYPE = WRITE                                        00020300
*        5TYPE-ADDRESSED = TABLE                                        00020400
*        5PURPOSE = DESCRIBE THE TIME OF DAY IN THE FORM 'HH:MM:SS'.    00020500
*        5REMARKS-ON-USE = THIS BUFFER IS IN SUITABLE CONDITION TO   -  00020600
*        BE USED AS A TEXT-INSERTION BUFFER EXCEPT FOR THE TODOFF    -  00020700
*        FIELD WHICH MAY BE SUPPLIED BY THE INVOKER EITHER BEFORE    -  00020800
*        OR AFTER INVOKING IKJEFLPA.                                    00020900
*        5SCOPE = INTERNAL                                              00021000
*        5TABLE-SIZE = 12 BYTES                                         00021100
*        *************************************************************/ 00021200
*        /************************************************************* 00021300
*        5FIELD = TODLEN                                                00021400
*          6REFERENCE-TYPE = WRITE                                      00021500
*          6DISPLACEMENT = 0 BYTES                                      00021600
*          6TYPE = ARITHMETIC                                           00021700
*          6MODE = BINARY                                               00021800
*          6LENGTH = 15 BITS                                            00021900
*          6SIGN = SIGNED                                               00022000
*          6VALUE = 12                                                  00022100
*        *************************************************************/ 00022200
*        /************************************************************* 00022300
*        5FIELD = TODOFF                                                00022400
*          6DISPLACEMENT = 2 BYTES                                      00022500
*          6TYPE = ARITHMETIC                                           00022600
*          6MODE = BINARY                                               00022700
*          6LENGTH = 15 BITS                                            00022800
*          6SIGN = SIGNED                                               00022900
*          6VALUE = SAME AS ON INPUT.                                   00023000
*        *************************************************************/ 00023100
*        /************************************************************* 00023200
*        5FIELD = TODTXT                                                00023300
*          6REFERENCE-TYPE = WRITE                                      00023400
*          6DISPLACEMENT = 4 BYTES                                      00023500
*          6TYPE = CHARACTER STRING                                     00023600
*          6LENGTH+MODE = 8 CHARACTERS                                  00023700
*          6VALUE = TIME OF DAY IN THE FORM 'HH:MM:SS'.                 00023800
*    *****************************************************************/ 00023900
*    /***************************************************************** 00024000
*    3FIELD = PARAM2                                                    00024100
*      4REFERENCE-TYPE = READ                                           00024200
*      4DISPLACEMENT = 4 BYTES                                          00024300
*      4TYPE = ADDRESS                                                  00024400
*      4ADDRESS-LENGTH = 32 BITS                                        00024500
*      4ADDRESS-OF = DATE                                               00024600
*        5REFERENCE-TYPE = WRITE                                        00024700
*        5TYPE-ADDRESSED = TABLE                                        00024800
*        5PURPOSE = DESCRIBE THE DATE IN THE FORM 'MONTH DAY, YEAR'.    00024900
*        5REMARKS-ON-USE = THIS BUFFER IS IN SUITABLE CONDITION TO   -  00025000
*        BE USED AS A TEXT-INSERTION BUFFER EXCEPT FOR THE DATEOFF   -  00025100
*        FIELD WHICH MAY BE SUPPLIED BY THE INVOKER EITHER BEFORE    -  00025200
*        OR AFTER INVOKING IKJEFLPA.                                    00025300
*        5SCOPE = INTERNAL                                              00025400
*        5TABLE-SIZE = 22 BYTES                                         00025500
*        *************************************************************/ 00025600
*        /************************************************************* 00025700
*        5FIELD = DATELEN                                               00025800
*          6REFERENCE-TYPE = WRITE                                      00025900
*          6DISPLACEMENT = 0 BYTES                                      00026000
*          6TYPE = ARITHMETIC                                           00026100
*          6MODE = BINARY                                               00026200
*          6LENGTH = 15 BITS                                            00026300
*          6SIGN = SIGNED                                               00026400
*          6VALUE = LENGTH OF TEXT-INSERTION BUFFER CONTENTS.        -  00026500
*          15-22 BYTES                                                  00026600
*        *************************************************************/ 00026700
*        /************************************************************* 00026800
*        5FIELD = DATEOFF                                               00026900
*          6DISPLACEMENT = 2 BYTES                                      00027000
*          6TYPE = ARITHMETIC                                           00027100
*          6MODE = BINARY                                               00027200
*          6LENGTH = 15 BITS                                            00027300
*          6SIGN = SIGNED                                               00027400
*          6VALUE = SAME AS ON INPUT.                                   00027500
*        *************************************************************/ 00027600
*        /************************************************************* 00027700
*        5FIELD = DATETXT                                               00027800
*          6REFERENCE-TYPE = WRITE                                      00027900
*          6DISPLACEMENT = 4 BYTES                                      00028000
*          6TYPE = CHARACTER STRING                                     00028100
*          6LENGTH+MODE = 18 CHARACTERS                                 00028200
*          6VALUE = DATE IN THE FORM 'MONTH DAY, YEAR'                  00028300
**********************************************************************/ 00028400
* /******************************************************************** 00028500
*1EXTERNAL-MACRO = IEFDCL1                                              00028600
*  2PURPOSE = PROVIDE PRE-PROCESSOR VARIABLE DECLARATIONS               00028700
*  2PARAMETER-PASSED = NONE                                             00028800
**********************************************************************/ 00028900
* /******************************************************************** 00029000
*1EXTERNAL-MACRO = IEFDCL2                                              00029100
*  2PURPOSE = PROVIDE DECLARATIONS OF REGISTERS, A SAVEAREA, AND A   -  00029200
*  TYPE 1 PARAMETER LIST                                                00029300
*  *******************************************************************/ 00029400
*  /******************************************************************* 00029500
*  2PARAMETER-PASSED = REGISTER                                         00029600
*  2HOW-PASSED = KEYWORD                                                00029700
*  2TYPE = ARITHMETIC                                                   00029800
*  2MODE = BINARY                                                       00029900
*  2LENGTH = 31 BITS                                                    00030000
*  2SIGN = SIGNED                                                       00030100
*  2VALUE = 1. THIS CAUSES IEFDCL2 TO PROVIDE A MAPPING OF THE       -  00030200
*  GENERAL PURPOSE REGISTERS.                                           00030300
*  *******************************************************************/ 00030400
*  /******************************************************************* 00030500
*  2PARAMETER-PASSED = R0STAT                                           00030600
*  2HOW-PASSED = KEYWORD                                                00030700
*  2TYPE = CHARACTER STRING                                             00030800
*  2LENGTH+MODE = 32767 BYTES                                           00030900
*  2VALUE = 'RESTRICTED'                                                00031000
*  *******************************************************************/ 00031100
*  /******************************************************************* 00031200
*  2PARAMETER-PASSED = R1STAT                                           00031300
*  2HOW-PASSED = KEYWORD                                                00031400
*  2TYPE = CHARACTER STRING                                             00031500
*  2LENGTH+MODE = 32767 BYTES                                           00031600
*  2VALUE = 'RESTRICTED'                                                00031700
*  *******************************************************************/ 00031800
*  /******************************************************************* 00031900
*  2PARAMETER-PASSED = R4TYPE                                           00032000
*  2HOW-PASSED = KEYWORD                                                00032100
*  2TYPE = CHARACTER STRING                                             00032200
*  2LENGTH+MODE = 32767 BYTES                                           00032300
*  2VALUE = 'FIXED(15)'                                                 00032400
*  *******************************************************************/ 00032500
*  /******************************************************************* 00032600
*  2PARAMETER-PASSED = R5TYPE                                           00032700
*  2HOW-PASSED = KEYWORD                                                00032800
*  2TYPE = CHARACTER STRING                                             00032900
*  2LENGTH+MODE = 32767 BYTES                                           00033000
*  2VALUE = 'FIXED(15)'                                                 00033100
*  *******************************************************************/ 00033200
*  /******************************************************************* 00033300
*  2PARAMETER-PASSED = SAVEAREA                                         00033400
*  2HOW-PASSED = KEYWORD                                                00033500
*  2TYPE = ARITHMETIC                                                   00033600
*  2MODE = BINARY                                                       00033700
*  2LENGTH = 31 BITS                                                    00033800
*  2SIGN = SIGNED                                                       00033900
*  2VALUE = 1. THIS CAUSES IEFDCL2 TO PROVIDE A MAPPING OF A SAVEAREA.  00034000
*  *******************************************************************/ 00034100
*  /******************************************************************* 00034200
*  2PARAMETER-PASSED = PARAM                                            00034300
*  2HOW-PASSED = KEYWORD                                                00034400
*  2TYPE = ARITHMETIC                                                   00034500
*  2MODE = BINARY                                                       00034600
*  2LENGTH = 31 BITS                                                    00034700
*  2SIGN = SIGNED                                                       00034800
*  2VALUE = 1. THIS CAUSES IEFDCL2 TO PROVIDE A MAPPING OF A TYPE I  -  00034900
*  PARAMETER LIST.                                                      00035000
**********************************************************************/ 00035100
* /******************************************************************** 00035200
*1SYSTEM-MACROS = TIME, GETMAIN, FREEMAIN                               00035300
*1INTERNAL-PROCEDURES = NONE                                            00035400
*                                                                       00035500
**** END OF SPECIFICATIONS ***/                                         00035600
*/*IKJEFLPA: CHART (DTYPE,AMODE,IBM68,NSAVE,NSEQ)                    */ 00035700
*/*       HEADER                                                        00035800
*/*IKJEFLPA -- TOD & DATE TEXT INSERTION BUFFER PREPARATION          */ 00035900
*/*IKJEFLPA: E  BUFFER PREPARATION FUNCTION                          */ 00036000
*         GENERATE;                                                     00036100
IKJEFLPA CSECT                                                          00036200
PA000100 B     PA000300-PA000100(0,R15)   BRANCH AROUND IDENTIFIER      00036300
** /*                                                                   00036400
         DC    AL1(L'PA000200)            LENGTH OF IDENTIFIER          00036500
** */                                                                   00036600
PA000200 DC    C'IKJEFLPA&LUPDAT' IDENTIFIER                            00036700
PA000300 DS    0H                         BRANCH TARGET                 00036800
         AGO   .@001                                                    00036900
*IKJEFLPA:PROCEDURE/*(TOD, DATE)*/ OPTIONS(REENTRANT);                  00037000
         LCLA  &T,&SPN                                            0003  00037100
.@001    ANOP                                                     0003  00037200
IKJEFLPA CSECT ,                                                  0003  00037300
         STM   @E,@C,12(@D)                                       0003  00037400
         BALR  @B,0                                               0003  00037500
@PSTART  DS    0H                                                 0003  00037600
         USING @PSTART+00000,@B                                   0003  00037700
         L     @0,@SIZ001                                         0003  00037800
         GETMAIN  R,LV=(0)                                        0003  00037900
         LR    @C,@1                                              0003  00038000
         USING @DATD+00000,@C                                     0003  00038100
         LM    @0,@1,20(@D)                                       0003  00038200
         XC    @TEMPS(@L),@TEMPS                                  0003  00038300
         ST    @D,@SAV001+4                                       0003  00038400
         LA    @F,@SAV001                                         0003  00038500
         ST    @F,8(0,@D)                                         0003  00038600
         LR    @D,@F                                              0003  00038700
*         GENERATE;                                                     00038800
         TITLE     'IKJEFLPA -- TOD && DATE TEXT PREPARATION -- DEFINE *00038900
               VARIABLES'                                               00039000
         DS    0H                                                       00039100
*                                                                       00039200
*                                                                       00039300
* /*******************************************************************/ 00039400
* /*      DEFINE THE GENERAL PURPOSE REGISTERS                       */ 00039500
* /*******************************************************************/ 00039600
* DECLARE                                                               00039700
*         R0 POINTER(31) REGISTER(0) RESTRICTED,                        00039800
*         /***********************************************************/ 00039900
*         /*    STANDARD LINKAGE CONVENTION PARAMETER LIST POINTER   */ 00040000
*         /***********************************************************/ 00040100
*         R1 POINTER(31) REGISTER(1) RESTRICTED,                        00040200
*         R2 POINTER(31) REGISTER(2) UNRESTRICTED,                      00040300
*         R3 POINTER(31) REGISTER(3) UNRESTRICTED,                      00040400
*         R4 FIXED(15) REGISTER(4) UNRESTRICTED,                        00040500
*         R5 FIXED(15) REGISTER(5) UNRESTRICTED,                        00040600
*         R6 POINTER(31) REGISTER(6) UNRESTRICTED,                      00040700
*         R7 POINTER(31) REGISTER(7) UNRESTRICTED,                      00040800
*         R8 POINTER(31) REGISTER(8) UNRESTRICTED,                      00040900
*         R9 POINTER(31) REGISTER(9) UNRESTRICTED,                      00041000
*         R10 POINTER(31) REGISTER(10) UNRESTRICTED,                    00041100
*         R11 POINTER(31) REGISTER(11) UNRESTRICTED,                    00041200
*         R12 POINTER(31) REGISTER(12) UNRESTRICTED,                    00041300
*         /***********************************************************/ 00041400
*         /*   STANDARD LINKAGE CONVENTION SAVE AREA POINTER         */ 00041500
*         /***********************************************************/ 00041600
*         R13 POINTER(31) REGISTER(13) UNRESTRICTED,                    00041700
*         /***********************************************************/ 00041800
*         /*   STANDARD LINKAGE CONVENTION RETURN POINTER            */ 00041900
*         /***********************************************************/ 00042000
*         R14 POINTER(31) REGISTER(14) UNRESTRICTED,                    00042100
*         /***********************************************************/ 00042200
*         /*   STANDARD LINKAGE CONVENTION SUBROUTINE ENTRY POINTER  */ 00042300
*         /***********************************************************/ 00042400
*         R15 POINTER(31) REGISTER(15) UNRESTRICTED;                    00042500
*                                                                       00042600
* /*******************************************************************/ 00042700
* /*      DEFINE A SAVE AREA                                         */ 00042800
* /*******************************************************************/ 00042900
* DECLARE                                                               00043000
* 1       SAVEAREA  BASED( R13) BOUNDARY( WORD),                        00043100
*         /***********************************************************/ 00043200
*         /*    PL/I USES THIS WORD TO INDICATE THE LENGTH OF THE    */ 00043300
*         /*    DYNAMIC STORAGE AREA REPRESENTED BY THIS SAVE AREA   */ 00043400
*         /***********************************************************/ 00043500
*         2     SAVEWRD1 POINTER(32),                                   00043600
*               3  SAVEPFLG POINTER(8),                                 00043700
*               3  SAVEPLGH POINTER(24),                                00043800
*         /***********************************************************/ 00043900
*         /*    POINTER TO THE PREVIOUS SAVE AREA, THE SAVE AREA OF  */ 00044000
*         /*    THE INVOKER UNLESS THIS SUBROUTINE PROVIDES NO SAVE  */ 00044100
*         /*    AREA OF ITS OWN                                      */ 00044200
*         /***********************************************************/ 00044300
*         2     SAVELAST POINTER(32),                                   00044400
*         /***********************************************************/ 00044500
*         /*    POINTER TO THE NEXT SAVE AREA FOR ALL BUT THE LOWEST */ 00044600
*         /*    LEVEL SUBROUTINE ON THE STACK                        */ 00044700
*         /***********************************************************/ 00044800
*         2     SAVENEXT POINTER(32),                                   00044900
*         /***********************************************************/ 00045000
*         /*    SAVE AREA WORD FOR INPUT REGISTER 14, THE ADDRESS TO */ 00045100
*         /*    WHICH CONTROL IS NORMALLY TO BE RETURNED AFTER A     */ 00045200
*         /*    SUBROUTINE HAS CONCLUDED PROCESSING.  THE HIGH-ORDER */ 00045300
*         /*    BYTE OF THIS POINTER SHOULD BE SET TO 'FF'X IF THIS  */ 00045400
*         /*    ROUTINE HAS CONTROL AFTER A RETURN HAS BEEN MADE FROM*/ 00045500
*         /*    A SUBROUTINE.                                        */ 00045600
*         /***********************************************************/ 00045700
*         2     SAVER14 POINTER(32),                                    00045800
*               3  SAVERETF POINTER(8),                                 00045900
*         /***********************************************************/ 00046000
*         /*    SAVE AREA FOR INPUT REGISTERS 15 THROUGH 12          */ 00046100
*         /***********************************************************/ 00046200
*         2     SAVER15 POINTER(32),                                    00046300
*         2     SAVER0 POINTER(32),                                     00046400
*         2     SAVER1 POINTER(32),                                     00046500
*         2     SAVER2 POINTER(32),                                     00046600
*         2     SAVER3 POINTER(32),                                     00046700
*         2     SAVER4 POINTER(32),                                     00046800
*         2     SAVER5 POINTER(32),                                     00046900
*         2     SAVER6 POINTER(32),                                     00047000
*         2     SAVER7 POINTER(32),                                     00047100
*         2     SAVER8 POINTER(32),                                     00047200
*         2     SAVER9 POINTER(32),                                     00047300
*         2     SAVER10 POINTER(32),                                    00047400
*         2     SAVER11 POINTER(32),                                    00047500
*         2     SAVER12 POINTER(32),                                    00047600
*         /***********************************************************/ 00047700
*         /*   AREA USED BY PL/I AND BSL FOR TEMPORARY AND AUTOMATIC */ 00047800
*         /*   STORAGE AREAS                                         */ 00047900
*         /***********************************************************/ 00048000
*         2     SAVEXTNT CHARACTER( 8);                                 00048100
*                                                                       00048200
* /*******************************************************************/ 00048300
* /*      DEFINE A TYPE I PARAMETER LIST                             */ 00048400
* /*******************************************************************/ 00048500
* DECLARE                                                               00048600
* 1       PARAM BASED( R1) BOUNDARY( WORD),                             00048700
*         2     PARAM1 POINTER(32),                                     00048800
*         2     PARAM2 POINTER(32),                                     00048900
*         2     PARAM3 POINTER(32),                                     00049000
*         2     PARAM4 POINTER(32),                                     00049100
*         2     PARAM5 POINTER(32),                                     00049200
*         2     PARAM6 POINTER(32),                                     00049300
*         2     PARAM7 POINTER(32),                                     00049400
*         2     PARAM8 POINTER(32),                                     00049500
*         2     PARAM9 POINTER(32),                                     00049600
*         2     PARAM10 POINTER(32),                                    00049700
*         2     PARAM11 POINTER(32),                                    00049800
*         2     PARAM12 POINTER(32),                                    00049900
*         2     PARAM13 POINTER(32),                                    00050000
*         2     PARAM14 POINTER(32),                                    00050100
*         2     PARAM15 POINTER(32),                                    00050200
*         2     PARAM16 POINTER(32),                                    00050300
*         2     PARAM17 POINTER(32),                                    00050400
*         2     PARAM18 POINTER(32),                                    00050500
*         2     PARAM19 POINTER(32),                                    00050600
*         2     PARAM20 POINTER(32),                                    00050700
*         2     PARAM21 POINTER(32),                                    00050800
*         2     PARAM22 POINTER(32),                                    00050900
*         2     PARAM23 POINTER(32),                                    00051000
*         2     PARAM24 POINTER(32),                                    00051100
*         2     PARAM25 POINTER(32),                                    00051200
*         2     PARAM26 POINTER(32),                                    00051300
*         2     PARAM27 POINTER(32),                                    00051400
*         2     PARAM28 POINTER(32),                                    00051500
*         2     PARAM29 POINTER(32),                                    00051600
*         2     PARAM30 POINTER(32);                                    00051700
*                                                                       00051800
*         DECLARE                                                       00051900
*         /***********************************************************/ 00052000
*         /*    INTERNAL AUTOMATIC VARIABLES                         */ 00052100
*         /***********************************************************/ 00052200
*                                                                       00052300
*         CNVRT1 CHARACTER(8) AUTOMATIC BOUNDARY(DWORD), /*CONVERSION   00052400
*                                       BUFFER FOR CONVERSION FROM      00052500
*                                       DECIMAL TO BINARY, FROM DECIMAL 00052600
*                                       TO EBCDIC, & FROM BINARY TO     00052700
*                                       DECIMAL                      */ 00052800
*         CNVRT2 CHARACTER(4) AUTOMATIC BOUNDARY(WORD),  /*CONVERSION   00052900
*                                       BUFFER FOR CONVERSION FROM      00053000
*                                       DECIMAL TO EBCDIC            */ 00053100
*         /***********************************************************/ 00053200
*         /*    INTERNAL BASED VARIABLES, GENERATED CSECT VARIABLES, */ 00053300
*         /*    & ARGUMENTS PASSED INTO IKJEFLPA                     */ 00053400
*         /***********************************************************/ 00053500
*         1     TOD BASED BOUNDARY(BYTE),                               00053600
*               2  TODLEN FIXED(15) BOUNDARY(BYTE),                     00053700
*               2  TODOFF FIXED(15) BOUNDARY(BYTE),                     00053800
*               2  TODTXT CHARACTER(8) BOUNDARY(BYTE),                  00053900
*         DATEBUF CHARACTER(18) BASED BOUNDARY(BYTE),                   00054000
*         1     DATE BASED BOUNDARY(BYTE),                              00054100
*               2  DATELEN FIXED(15) BOUNDARY(BYTE),                    00054200
*               2  DATEOFF FIXED(15) BOUNDARY(BYTE),                    00054300
*               2  DATETXT CHARACTER(18) BOUNDARY(BYTE),                00054400
*         IKJEFLPB LABEL EXTERNAL,                                      00054500
*         PBORIGIN LABEL GENERATED,                                     00054600
*         PBCNTURY GENERATED CHARACTER(1) BOUNDARY(BYTE),               00054700
*         PBCOLON GENERATED CHARACTER(1) BOUNDARY(BYTE),                00054800
*         PBCOMBL GENERATED CHARACTER(2) BOUNDARY(BYTE),                00054900
*         PBCOMMA GENERATED CHARACTER(1) BOUNDARY(BYTE),                00055000
*         PBBLANK GENERATED CHARACTER(1) BOUNDARY(BYTE),                00055100
*         1     PBMDESCR(12) GENERATED BOUNDARY(HWORD),                 00055200
*               2  PBMLDAY FIXED(15) BOUNDARY(HWORD),                   00055300
*               2  PBMLEN FIXED(15) BOUNDARY(HWORD),                    00055400
*               2  PBMOFF FIXED(15) BOUNDARY(HWORD),                    00055500
*         PBMONTH CHARACTER(9) BASED BOUNDARY(BYTE);                    00055600
*/*       L     GET TIME OF DAY AND DATE FROM THE SYSTEM */             00055700
*         GENERATE;                                                     00055800
         TITLE 'IKJEFLPA -- TOD && TEXT PREPARATION -- IKJEFLPB EBCDIC *00055900
               CHARACTERS FOR TOD && DATE'                              00056000
* /******************************************************************/  00056100
* /*     DEFINE ALL CHARACTER-SET AND LANGUAGE-DEPENDENT DATA       */  00056200
* /*     REQUIRED FOR IKJEFLPA OPERATION                            */  00056300
* /******************************************************************/  00056400
IKJEFLPB CSECT                                                          00056500
PBORIGIN EQU   IKJEFLPB SYNONYM FOR IKJEFLPB                            00056600
PBCNTURY DC    X'19'    PACKED DECIMAL DIGITS FOR THE CURRENT CENTURY   00056700
PBCOLON  DC    C':'     IMAGE OF AN EBCDIC COLON                        00056800
PBCOMBL  DS    C', '    IMAGE OF COMMA AND BLANK                        00056900
         ORG   PBCOMBL                                                  00057000
PBCOMMA  DC    C','     IMAGE OF AN EBCDIC COMMA                        00057100
PBBLANK  DC    C' '     IMAGE OF AN EBCDIC BLANK                        00057200
&LNDESCR SETA  6        LENGTH OF PBMDESCR ARRAY ELEMENT                00057300
         SPACE                                                          00057400
* /******************************************************************/  00057500
* /*     ALLOW AT LEAST ENOUGH SPACE IN IKJEFLPB FOR 2 ARRAY        */  00057600
* /*     ELEMENTS BEFORE GENERATING THE PBMDESCR ARRAY              */  00057700
* /******************************************************************/  00057800
         ORG   IKJEFLPB RESET THE LOCATION COUNTER TO IKJEFLPB          00057900
         DS    CL(2*&LNDESCR) FORCE THE LOCATION COUNTER TO 2 TIMES    *00058000
                        THE LENGTH OF ONE PBDESCR ARRAY ELEMENT         00058100
         ORG   ,        SET THE LOCATION COUNTER TO THE HIGHEST VALUE  *00058200
                        IT HAS YET ASSUMED                              00058300
         DS    0H       ALIGN PBMDESCR ARRAY ON HALFWORD                00058400
PBMDESCR DS    CL&LNDESCR ARRAY ELEMENT                                 00058500
         ORG   PBMDESCR GENERATE INITIALIZED ARRAY OF                  *00058600
                        MONTH-DESCRIPTORS                               00058700
&LDAY(1) SETA  31             LAST DAY OF JANUARY                       00058800
&LDAY(2) SETA  &LDAY(1)+28    LAST DAY OF FEBRUARY                      00058900
&LDAY(3) SETA  &LDAY(2)+31    LAST DAY OF MARCH                         00059000
&LDAY(4) SETA  &LDAY(3)+30    LAST DAY OF APRIL                         00059100
&LDAY(5) SETA  &LDAY(4)+31    LAST DAY OF MAY                           00059200
&LDAY(6) SETA  &LDAY(5)+30    LAST DAY OF JUNE                          00059300
&LDAY(7) SETA  &LDAY(6)+31    LAST DAY OF JULY                          00059400
&LDAY(8) SETA  &LDAY(7)+31    LAST DAY OF AUGUST                        00059500
&LDAY(9) SETA  &LDAY(8)+30    LAST DAY OF SEPTEMBER                     00059600
&LDAY(10) SETA &LDAY(9)+31    LAST DAY OF OCTOBER                       00059700
&LDAY(11) SETA &LDAY(10)+30   LAST DAY OF NOVEMBER                      00059800
&LDAY(12) SETA &LDAY(11)+31   LAST DAY OF DECEMBER                      00059900
** /*                                                                   00060000
&I       SETA  0                                                        00060100
.PB00100 ANOP                                                           00060200
&I       SETA  &I+1                                                     00060300
         DC    H'&LDAY(&I)' LAST DAY OF MONTH                           00060400
         DC    AL2(L'PB&I) LENGTH OF THE NAME OF THE MONTH              00060500
         DC    AL2(PB&I-IKJEFLPB) OFFSET OF THE NAME OF THE MONTH       00060600
         AIF   (&I LT 12).PB00100                                       00060700
PB1      DC    C'JANUARY'     ENGLISH NAME FOR 1ST MONTH IN EBCDIC      00060800
PB2      DC    C'FEBRUARY'    ENGLISH NAME FOR 2ND MONTH IN EBCDIC      00060900
PB3      DC    C'MARCH'       ENGLISH NAME FOR 3RD MONTH IN EBCDIC      00061000
PB4      DC    C'APRIL'       ENGLISH NAME FOR 4TH MONTH IN EBCDIC      00061100
PB5      DC    C'MAY'         ENGLISH NAME FOR 5TH MONTH IN EBCDIC      00061200
PB6      DC    C'JUNE'        ENGLISH NAME FOR 6TH MONTH IN EBCDIC      00061300
PB7      DC    C'JULY'        ENGLISH NAME FOR 7TH MONTH IN EBCDIC      00061400
PB8      DC    C'AUGUST'      ENGLISH NAME FOR 8TH MONTH IN EBCDIC      00061500
PB9      DC    C'SEPTEMBER'   ENGLISH NAME FOR 9TH MONTH IN EBCDIC      00061600
PB10     DC    C'OCTOBER'     ENGLISH NAME FOR 10TH MONTH IN EBCDIC     00061700
PB11     DC    C'NOVEMBER'    ENGLISH NAME FOR 11TH MONTH IN EBCDIC     00061800
PB12     DC    C'DECEMBER'    ENGLISH NAME FOR 12TH MONTH IN EBCDIC     00061900
         TITLE    'IKJEFLPA -- TOD && DATE TEXT PREPARATION -- PREPARE *00062000
               TOD BUFFER'                                              00062100
IKJEFLPA CSECT                                                          00062200
** */                                                                   00062300
*        /***********************************************************/  00062400
*        /*     R0 = 'HHMMSSTQ' WHERE HH IS THE HOUR, MM IS THE     */  00062500
*        /*        MINUTE, SS IS THE SECOND, T IS THE TENTH OF A    */  00062600
*        /*        SECOND, AND Q IS THE HUNDREDTH                   */  00062700
*        /*     R1 = '00YYDDDZ' WHERE YY IS THE YEAR DDD IS THE DAY */  00062800
*        /*        AND Z IS A ZONE WHICH INDICATES A POSITIVE       */  00062900
*        /*        DECIMAL NUMBER                                   */  00063000
*        /***********************************************************/  00063100
         TIME  DEC      OBTAIN TIME IN R0, DATE IN R1                   00063200
         ST    R1,CNVRT2               STORE DATE IN WORK FIELD     JLM 00063300
         AP    CNVRT2(4),=PL4'1900000' ADD 19 TO CC PART OF FIELD   JLM 00063400
         MVC   CC(1),CNVRT2            SAVE CORRECT CC VALUE        JLM 00063500
         DS    0H                                                       00063600
*         CNVRT2 = R0;                /*CNVRT2 = '00HHMMSS' WHERE HH    00063700
*                                       IS THE HOUR, MM IS THE  MINUTE, 00063800
*                                       AND SS IS THE SECOND         */ 00063900
         ST    @0,CNVRT2                                          0010  00064000
*         RESPECIFY( R0) UNRESTRICTED; /*ALLOW IMPLICIT REFERENCES TO   00064100
*                                       R0                           */ 00064200
*         RESPECIFY( R2, R3) RESTRICTED; /*RESERVE VARIABLES FOR        00064300
*                                       EXPLICIT REFERENCES          */ 00064400
*         /***********************************************************/ 00064500
*         /*    ESTABLISH A POINTER TO THE TIME-OF-DAY (TOD) TEXT    */ 00064600
*         /*    INSERTION BUFFER                                     */ 00064700
*         /***********************************************************/ 00064800
*         R2 = SAVELAST -> SAVER1 -> PARAM1;                            00064900
         L     @8,4(0,@D)                                         0013  00065000
         L     @8,24(0,@8)         SAVEAREA                       0013  00065100
         L     @2,0(0,@8)                                         0013  00065200
*         RESPECIFY( TOD) BASED(R2);                                    00065300
*         R3 = ADDR(IKJEFLPB);         /*ESTABLISH A POINTER TO         00065400
*                                        IKJEFLPB                    */ 00065500
         L     @9,@V1              ADDRESS OF IKJEFLPB            0015  00065600
         LR    @3,@9                                              0015  00065700
*/*       P     PLACE TOD IN BYTES 7-12 OF BUFFER                    */ 00065800
*         GENERATE;                                                     00065900
         USING IKJEFLPB,R3          TELL THE ASSEMBLER HOW TO FIND     *00066000
                                    IKJEFLPB                            00066100
         SPACE                                                          00066200
*        /************************************************************  00066300
*             PLACE TOD IN BYTES 7-12 OF BUFFER                         00066400
*        ************************************************************/  00066500
         MVO  CNVRT1(4),CNVRT2(3)   SHIFT OUT TENTHS OF SECONDS DIGIT   00066600
         UNPK TODTXT+2-TOD(6,R2),CNVRT1(4)   CONVERT TIME OF DAY TO    *00066700
                                    CHARACTER FORMAT                    00066800
         MVZ  TODTXT+7-TOD(1,R2),TODTXT+2-TOD(R2)  INSERT PROPER ZONE  *00066900
                                    FIELD INTO THE FINAL SECONDS DIGIT  00067000
         DS    0H                                                       00067100
*         /***********************************************************/ 00067200
*/*       P     SET LENGTH OF TOD BUFFER                             */ 00067300
*         /***********************************************************/ 00067400
*         TODLEN = 12;                                                  00067500
         MVC   0(2,@2),@D1                                        0017  00067600
*                                                                       00067700
*         /***********************************************************/ 00067800
*/*       P     MOVE DIGITS OF HOUR TO BYTES 5-6 OF BUFFER           */ 00067900
*         /***********************************************************/ 00068000
*         TODTXT( 1: 2) = TODTXT( 3: 4);                                00068100
         MVC   4(2,@2),6(@2)                                      0018  00068200
*                                                                       00068300
*         /***********************************************************/ 00068400
*/*       P     MOVE COLON TO BYTE 7 OF BUFFER                       */ 00068500
*         /***********************************************************/ 00068600
*         TODTXT( 3) = PBCOLON;                                         00068700
         MVC   6(1,@2),PBCOLON                                    0019  00068800
*                                                                       00068900
*         /***********************************************************/ 00069000
*/*       P     MOVE DIGITS OF MINUTE TO BYTES 8-9 OF BUFFER         */ 00069100
*         /***********************************************************/ 00069200
*         TODTXT( 4: 5) = TODTXT( 5: 6);                                00069300
         MVC   7(2,@2),8(@2)                                      0020  00069400
*                                                                       00069500
*         /***********************************************************/ 00069600
*/*       P     MOVE COLON TO BYTE 10 OF BUFFER                      */ 00069700
*         /***********************************************************/ 00069800
*         TODTXT( 6) = PBCOLON;                                         00069900
         MVC   9(1,@2),PBCOLON                                    0021  00070000
*         GENERATE;                                                     00070100
         TITLE    'IKJEFLPA -- TOD && DATE TEXT PREPARATION -- PREPARE *00070200
               DATE BUFFER'                                             00070300
         DS    0H                                                       00070400
*                                                                       00070500
*         /***********************************************************/ 00070600
*         /*     DATE PROCESSING                                     */ 00070700
*         /***********************************************************/ 00070800
*         CNVRT2 = R1;                /*SET CNVRT2 TO THE DATE IN       00070900
*                                       DECIMAL                      */ 00071000
         ST    @1,CNVRT2                                          0023  00071100
*         RESPECIFY( R1) UNRESTRICTED; /*ALLOW IMPLICIT REFERENCES      00071200
*                                       TO R1                        */ 00071300
*                                                                       00071400
*         /***********************************************************/ 00071500
*         /*    ESTABLISH POINTER TO DATE TEXT INSERTION BUFFER      */ 00071600
*         /***********************************************************/ 00071700
*         R2 = SAVELAST -> SAVER1 -> PARAM2;                            00071800
         L     @2,4(0,@8)                                         0025  00071900
*         RESPECIFY( DATE) BASED(R2);                                   00072000
*                                                                       00072100
*         /***********************************************************/ 00072200
*         /*    CNVRT1 = '000000000000DDDZ'X                         */ 00072300
*         /***********************************************************/ 00072400
*         CNVRT1( 1: 6) = CNVRT1( 1: 6) && CNVRT1( 1: 6);               00072500
         XC    CNVRT1(6),CNVRT1                                   0027  00072600
*         CNVRT1( 7: 8) = CNVRT2( 3: 4);                                00072700
         MVC   CNVRT1+6(2),CNVRT2+2                               0028  00072800
*         RESPECIFY( R4, R5) RESTRICTED; /*RESERVE VARIABLES FOR        00072900
*                                       EXPLICIT REFERENCES          */ 00073000
*                                                                       00073100
*         /***********************************************************/ 00073200
*         /*    R4 = DAY OF YEAR IN BINARY                           */ 00073300
*         /*    R5 = YEAR IN BINARY                                  */ 00073400
*         /***********************************************************/ 00073500
*         GENERATE;                                                     00073600
         CVB   R4,CNVRT1               R4 = DAY OF YEAR IN BINARY       00073700
         MVO   CNVRT1+6(2),CNVRT2+1(1) CNVRT1 = YEAR IN DECIMAL         00073800
         CVB   R5,CNVRT1               R5 = YEAR IN BINARY              00073900
         DS    0H                                                       00074000
*                                                                       00074100
*         RESPECIFY( R7) RESTRICTED;  /*RESERVE VARIABLE FOR            00074200
*                                       EXPLICIT REFERENCES          */ 00074300
*                                                                       00074400
*         /***********************************************************/ 00074500
*/*       P     SET INDEX OF MONTH TO JANUARY                        */ 00074600
*         /***********************************************************/ 00074700
*         R7 = 1;                                                       00074800
         LA    @7,1                                               0032  00074900
*                                                                       00075000
*         /***********************************************************/ 00075100
*/*       D     (YES,PA000620,NO,)                                      00075200
*/*             MONTH = JANUARY                                      */ 00075300
*         /*    IF THE DAY IS WITHIN JANUARY, CONSTRUCT THE DATE TEXT*/ 00075400
*         /*    INSERTION BUFFER                                     */ 00075500
*         /***********************************************************/ 00075600
*         IF R4 <= PBMLDAY(1)                                           00075700
*         THEN                                                          00075800
         CH    @4,PBMDESCR                                        0033  00075900
*               GO TO PA000620;                                         00076000
         BC    12,PA000620                                        0034  00076100
*                                                                       00076200
*         /***********************************************************/ 00076300
*/*       D     (YES,,NO,PA000400)                                      00076400
*/*             LEAP YEAR?                                           */ 00076500
*         /*    IF THE DAY IS NOT WITHIN JANUARY AND THE YEAR IS     */ 00076600
*         /*    DIVISIBLE BY FOUR, TREAT THE YEAR AS A LEAP YEAR     */ 00076700
*         /***********************************************************/ 00076800
*         R5 = R5 // 4;                                                 00076900
         LR    @E,@5                                              0035  00077000
         SRDA  @E,32                                              0035  00077100
         LA    @0,4                                               0035  00077200
         DR    @E,@0                                              0035  00077300
         LR    @5,@E                                              0035  00077400
*         IF R5 = 0                                                     00077500
*         THEN                                                          00077600
         LTR   @5,@5                                              0036  00077700
         BC    07,@9FF                                            0036  00077800
*               /*****************************************************/ 00077900
*/*             P  DECREMENT DAY OF YEAR TO COMPENSATE FOR LONG         00078000
*/*                FEBRUARY                                          */ 00078100
*               /*****************************************************/ 00078200
*               R4 = R4 - 1;                                            00078300
         BCTR  @4,0                                               0037  00078400
*                                                                       00078500
*PA000400:/***********************************************************/ 00078600
*/*PA000400: P  INCREMENT INDEX OF MONTH                             */ 00078700
*         /***********************************************************/ 00078800
*         R7 = R7 + 1;                                                  00078900
@9FF     EQU   *                                                  0038  00079000
PA000400 AH    @7,@D2                                             0038  00079100
*                                                                       00079200
*         /***********************************************************/ 00079300
*/*       D     (YES,PA000600,NO,)                                      00079400
*/*             INDEX OF MONTH > 11                                  */ 00079500
*         /***********************************************************/ 00079600
*         IF R7 > 11                                                    00079700
*         THEN                                                          00079800
         CH    @7,@D3                                             0039  00079900
*               GO TO PA000600;                                         00080000
         BC    02,PA000600                                        0040  00080100
*                                                                       00080200
*         /***********************************************************/ 00080300
*/*       D     (YES,PA000400,NO,)                                      00080400
*/*             DAY OF YEAR > LAST DAY OF INDEXED MONTH              */ 00080500
*         /***********************************************************/ 00080600
*         IF R4 > PBMLDAY( R7)                                          00080700
*         THEN                                                          00080800
         LR    @1,@7                                              0041  00080900
         MH    @1,@D4                                             0041  00081000
         CH    @4,PBMDESCR-6(@1)                                  0041  00081100
*               GO TO PA000400;                                         00081200
         BC    02,PA000400                                        0042  00081300
*                                                                       00081400
*         /***********************************************************/ 00081500
*/*       D     (YES,,NO,PA000600)                                      00081600
*/*             MONTH = FEBRUARY & LEAP YEAR                         */ 00081700
*         /***********************************************************/ 00081800
*         IF R7 = 2 & R5 = 0                                            00081900
*         THEN                                                          00082000
         CH    @7,@D5                                             0043  00082100
         BC    07,@9FE                                            0043  00082200
         LTR   @5,@5                                              0043  00082300
         BC    07,@9FD                                            0043  00082400
*               /*****************************************************/ 00082500
*/*             P  INCREMENT DAY OF YEAR TO ALLOW FEBRUARY 29 DAYS   */ 00082600
*               /*****************************************************/ 00082700
*               R4 = R4 + 1;                                            00082800
         AH    @4,@D2                                             0044  00082900
*         RESPECIFY( R5) UNRESTRICTED; /*ALLOW IMPLICIT REFERENCES      00083000
*                                        TO R5                       */ 00083100
@9FD     EQU   *                                                  0045  00083200
@9FE     EQU   *                                                  0045  00083300
*                                                                       00083400
*PA000600:/***********************************************************/ 00083500
*/*PA000600: P  DAY OF MONTH = DAY OF YEAR - LAST DAY OF                00083600
*/*             PREVIOUS MONTH                                       */ 00083700
*         /***********************************************************/ 00083800
*         R4 = R4 - PBMLDAY( R7 - 1);                                   00083900
PA000600 LR    @1,@7                                              0046  00084000
         MH    @1,@D4                                             0046  00084100
         LH    @F,PBMDESCR-12(@1)                                 0046  00084200
         LCR   @F,@F                                              0046  00084300
         AR    @4,@F                                              0046  00084400
*         RESPECIFY( R5, R6) RESTRICTED; /*RESERVE VARIABLES FOR        00084500
*                                       EXPLICIT REFERENCES          */ 00084600
*PA000620:/***********************************************************/ 00084700
*/*PA000620: P  MOVE NAME OF THE MONTH TO DATE BUFFER                */ 00084800
*         /***********************************************************/ 00084900
*         R5 = PBMLEN( R7);           /*R5 = LENGTH OF THE NAME OF      00085000
*                                       THE MONTH                    */ 00085100
PA000620 LR    @1,@7                                              0048  00085200
         MH    @1,@D4                                             0048  00085300
         LH    @5,PBMDESCR-4(@1)                                  0048  00085400
*         R6 = ADDR( PBORIGIN) + PBMOFF( R7);/*R6 = ADDRESS OF THE NAME 00085500
*                                       OF THE MONTH                 */ 00085600
         LH    @F,PBMDESCR-2(@1)                                  0049  00085700
         LA    @0,PBORIGIN                                        0049  00085800
         AR    @F,@0                                              0049  00085900
         LR    @6,@F                                              0049  00086000
*         RESPECIFY( R7) UNRESTRICTED;/*ALLOW IMPLICIT REFERENCES TO A  00086100
*                                       VARIABLE                     */ 00086200
*                                                                       00086300
*         /***********************************************************/ 00086400
*         /*    MOVE NAME OF THE MONTH TO DATE BUFFER                */ 00086500
*         /***********************************************************/ 00086600
*         DATETXT( 1: R5) = R6 -> PBMONTH( 1: R5);                      00086700
         LR    @E,@6                                              0051  00086800
         LR    @7,@5                                              0051  00086900
         BCTR  @7,0                                               0051  00087000
         LA    @A,4(0,@2)                                         0051  00087100
         EX    @7,@MVC                                            0051  00087200
*         R6 = ADDR( DATETXT( R5 + 1)); /*R6 = ADDRESS OF FIRST UNUSED  00087300
*                                       CHARACTER OF DATE BUFFER     */ 00087400
         LA    @7,1                                               0052  00087500
         AR    @7,@5                                              0052  00087600
         LA    @6,3(@7,@2)                                        0052  00087700
*                                                                       00087800
*         /***********************************************************/ 00087900
*/*       P     MOVE BLANK AFTER THE NAME OF THE MONTH               */ 00088000
*         /***********************************************************/ 00088100
*         R6 -> DATEBUF( 1) = PBBLANK;                                  00088200
         MVC   0(1,@6),PBBLANK                                    0053  00088300
*                                                                       00088400
*         /***********************************************************/ 00088500
*         /*    CNVRT1 = '0000000000000DDZ'X WHERE DD IS THE DAY     */ 00088600
*         /*    WITHIN THE MONTH AND Z IS A POSITIVE ZONE FIELD      */ 00088700
*         /***********************************************************/ 00088800
*         GENERATE(CVD   R4,CNVRT1);                                    00088900
         CVD   R4,CNVRT1                                                00089000
         DS    0H                                                       00089100
*         RESPECIFY( R4) UNRESTRICTED; /*ALLOW IMPLICIT REFERENCES      00089200
*                                       TO R4                        */ 00089300
*         /***********************************************************/ 00089400
*         /*    CNVRT1 = '0000000DDZ000DDZ'X                         */ 00089500
*         /***********************************************************/ 00089600
*         CNVRT1( 4: 5) = CNVRT1( 7: 8);                                00089700
         MVC   CNVRT1+3(2),CNVRT1+6                               0056  00089800
*         GENERATE;                                                     00089900
         SPACE                                                          00090000
*        /***********************************************************/  00090100
*        /*    CNVRT1 = '0000000DDZ000YYZ'X                         */  00090200
*        /***********************************************************/  00090300
         MVO   CNVRT1+6(2),CNVRT2+1(1)                                  00090400
         SPACE                                                          00090500
*        /***********************************************************/  00090600
*        /*    CNVRT1 = '0000000DDZ0CCYYZ'X WHERE DD IS THE DAY OF  */  00090700
*        /*    THE MONTH, Z IS A POSITIVE ZONE, CC IS THE CENTURY,  */  00090800
*        /*    AND YY IS THE YEAR                                   */  00090900
*        /***********************************************************/  00091000
*        MVO   CNVRT1+5(2),PBCNTURY    IGNORE STATIC CONSTANT CC    JLM 00091100
         MVO   CNVRT1+5(2),CC          USE CALCULATED CC            JLM 00091200
         DS    0H                                                       00091300
*                                                                       00091400
*         /***********************************************************/ 00091500
*/*       D     (YES,PA000700,NO,PA000800)                              00091600
*/*             DAY OF MONTH < 10                                    */ 00091700
*         /***********************************************************/ 00091800
*         IF CNVRT1( 4) = '00'X                                         00091900
*         THEN                                                          00092000
         CLI   CNVRT1+3,X'00'                                     0058  00092100
         BC    07,@9FC                                            0058  00092200
*/*PA000700:    P  MOVE DIGITS OF DATE TO BUFFER. ONE DIGIT FOR DAY  */ 00092300
*                                                                       00092400
*PA000700:               DO;                                            00092500
*               /*****************************************************/ 00092600
*               /* DATE = '????MONTH D??CCY'    'ZY'X WHERE D IS THE */ 00092700
*               /* FINAL DIGIT OF THE DAY OF THE MONTH, CC IS THE    */ 00092800
*               /* CENTURY, Y IS THE FIRST DIGIT OF THE YEAR, Z IS A */ 00092900
*               /* POSITIVE ZONE DIGIT, AND Y IS THE SECOND DIGIT OF */ 00093000
*               /* THE YEAR                                          */ 00093100
*               /*****************************************************/ 00093200
*               GENERATE(UNPK  DATEBUF+1-DATEBUF(7,R6),CNVRT1+4(4));    00093300
PA000700 UNPK  DATEBUF+1-DATEBUF(7,R6),CNVRT1+4(4)                      00093400
         DS    0H                                                       00093500
*               /*****************************************************/ 00093600
*/*             P  (,%A000900)                                          00093700
*/*                SET DATE BUFFER LENGTH FIELD                      */ 00093800
*               /*****************************************************/ 00093900
*               DATELEN = R5 + 12;                                      00094000
         LA    @F,12                                              0061  00094100
         AR    @F,@5                                              0061  00094200
         ST    @F,@TEMP4                                          0061  00094300
         MVC   0(2,@2),@TEMP4+2                                   0061  00094400
*               /*****************************************************/ 00094500
*               /* R6 = ADDRESS OF THE LAST CHARACTER OF THE NAME OF */ 00094600
*               /* THE MONTH WITHIN THE DATE BUFFER                  */ 00094700
*               /*****************************************************/ 00094800
*               R6 = R6 - 1;                                            00094900
         BCTR  @6,0                                               0062  00095000
         BC    15,@9FB                                            0064  00095100
*               END PA000700;                                           00095200
*                                                                       00095300
*         /***********************************************************/ 00095400
*         /*  IF THE FIRST DIGIT OF THE DAY OF THE MONTH IS NONZERO, */ 00095500
*         /*  PLACE A TWO-DIGIT DAY OF THE MONTH IN THE DATE BUFFER  */ 00095600
*         /***********************************************************/ 00095700
*         ELSE                                                          00095800
*/*PA000800:    P  MOVE DIGITS OF DATE TO BUFFER. TWO DIGITS FOR DAY */ 00095900
*                                                                       00096000
*PA000800:               DO;                                            00096100
@9FC     EQU   *                                                  0064  00096200
*               /*****************************************************/ 00096300
*               /* DATE = '????MONTH DD??CCY'    'ZY'X WHERE DD IS   */ 00096400
*               /* THE DAY OF THE MONTH, CC IS THE CENTURY, Y IS     */ 00096500
*               /* THE FIRST DIGIT OF THE YEAR, Z IS A POSITIVE ZONE */ 00096600
*               /* DIGIT, AND Y IS THE SECOND DIGIT OF THE YEAR      */ 00096700
*               /*****************************************************/ 00096800
*                                                                       00096900
*               GENERATE(UNPK  DATEBUF+1-DATEBUF(8,R6),CNVRT1+3(5));    00097000
PA000800 UNPK  DATEBUF+1-DATEBUF(8,R6),CNVRT1+3(5)                      00097100
         DS    0H                                                       00097200
*                                                                       00097300
*               /*****************************************************/ 00097400
*/*             P  (,%A000900)                                          00097500
*/*                SET DATE BUFFER LENGTH FIELD                      */ 00097600
*               /*****************************************************/ 00097700
*               DATELEN = R5 + 13;                                      00097800
         LA    @F,13                                              0066  00097900
         AR    @F,@5                                              0066  00098000
         ST    @F,@TEMP4                                          0066  00098100
         MVC   0(2,@2),@TEMP4+2                                   0066  00098200
*               END PA000800;                                           00098300
*                                                                       00098400
*         /***********************************************************/ 00098500
*/*%A000900: P  MOVE COMMA AND BLANK AFTER DIGIT(S) OF MONTH         */ 00098600
*         /***********************************************************/ 00098700
*         R6 -> DATEBUF( 4: 5) = PBCOMBL;                               00098800
@9FB     MVC   3(2,@6),PBCOMBL                                    0068  00098900
*         GENERATE;                                                     00099000
         SPACE                                                          00099100
*        /***********************************************************/  00099200
*        /*    PROVIDE PROPER ZONE FIELD FOR FINAL DIGIT OF THE YEAR*/  00099300
*        /***********************************************************/  00099400
         MVZ   DATEBUF+8-DATEBUF(1,R6),DATEBUF+2-DATEBUF(R6)            00099500
         TITLE 'IKJEFLPA -- TOD && DATE TEXT PREPARATION -- EPILOGUE'   00099600
         DS    0H                                                       00099700
*         /***********************************************************/ 00099800
*/*       R     RETURN TO INVOKER                                    */ 00099900
*/*IKJEFLPA: END                                                     */ 00100000
*         /***********************************************************/ 00100100
*         RETURN;                                                       00100200
*         END IKJEFLPA                                                  00100300
*/* THE FOLLOWING INCLUDE STATEMENTS WERE FOUND IN THIS PROGRAM.      * 00100400
*/*%INCLUDE SYSLIB  (IEFDCL1 )                                        * 00100500
*/*%INCLUDE SYSLIB  (IEFDCL2 )                                        * 00100600
*;                                                                      00100700
@EL01    L     @D,4(0,@D)                                         0071  00100800
         LR    @1,@C                                              0071  00100900
         L     @0,@SIZ001                                         0071  00101000
         FREEMAIN R,LV=(0),A=(1)                                  0071  00101100
         LM    @E,@C,12(@D)                                       0071  00101200
         BCR   15,@E                                              0071  00101300
@DATA1   EQU   *                                                        00101400
@0       EQU   00                  EQUATES FOR REGISTERS 0-15           00101500
@1       EQU   01                                                       00101600
@2       EQU   02                                                       00101700
@3       EQU   03                                                       00101800
@4       EQU   04                                                       00101900
@5       EQU   05                                                       00102000
@6       EQU   06                                                       00102100
@7       EQU   07                                                       00102200
@8       EQU   08                                                       00102300
@9       EQU   09                                                       00102400
@A       EQU   10                                                       00102500
@B       EQU   11                                                       00102600
@C       EQU   12                                                       00102700
@D       EQU   13                                                       00102800
@E       EQU   14                                                       00102900
@F       EQU   15                                                       00103000
@D1      DC    H'12'                                                    00103100
@D2      DC    H'1'                                                     00103200
@D3      DC    H'11'                                                    00103300
@D4      DC    H'6'                                                     00103400
@D5      DC    H'2'                                                     00103500
@MVC     MVC   0(1,@A),0(@E)                                            00103600
@V1      DC    V(IKJEFLPB)                                              00103700
         DS    0F                                                       00103800
@SIZ001  DC    AL1(&SPN)                                                00103900
         DC    AL3(@DATEND-@DATD)                                       00104000
         DS    0F                                                       00104100
         DS    0D                                                       00104200
@DATA    EQU   *                                                        00104300
R0       EQU   00000000            FULLWORD POINTER REGISTER            00104400
R1       EQU   00000001            FULLWORD POINTER REGISTER            00104500
R2       EQU   00000002            FULLWORD POINTER REGISTER            00104600
R3       EQU   00000003            FULLWORD POINTER REGISTER            00104700
R4       EQU   00000004            FULLWORD INTEGER REGISTER            00104800
R5       EQU   00000005            FULLWORD INTEGER REGISTER            00104900
R6       EQU   00000006            FULLWORD POINTER REGISTER            00105000
R7       EQU   00000007            FULLWORD POINTER REGISTER            00105100
R8       EQU   00000008            FULLWORD POINTER REGISTER            00105200
R9       EQU   00000009            FULLWORD POINTER REGISTER            00105300
R10      EQU   00000010            FULLWORD POINTER REGISTER            00105400
R11      EQU   00000011            FULLWORD POINTER REGISTER            00105500
R12      EQU   00000012            FULLWORD POINTER REGISTER            00105600
R13      EQU   00000013            FULLWORD POINTER REGISTER            00105700
R14      EQU   00000014            FULLWORD POINTER REGISTER            00105800
R15      EQU   00000015            FULLWORD POINTER REGISTER            00105900
SAVEAREA EQU   00000000            80 BYTE(S) ON WORD                   00106000
SAVEWRD1 EQU   SAVEAREA+00000000   FULLWORD POINTER                     00106100
SAVEPFLG EQU   SAVEAREA+00000000   1  BYTE  POINTER                     00106200
SAVEPLGH EQU   SAVEAREA+00000001   3  BYTE  POINTER ON WORD+1           00106300
SAVELAST EQU   SAVEAREA+00000004   FULLWORD POINTER                     00106400
SAVENEXT EQU   SAVEAREA+00000008   FULLWORD POINTER                     00106500
SAVER14  EQU   SAVEAREA+00000012   FULLWORD POINTER                     00106600
SAVERETF EQU   SAVEAREA+00000012   1  BYTE  POINTER                     00106700
SAVER15  EQU   SAVEAREA+00000016   FULLWORD POINTER                     00106800
SAVER0   EQU   SAVEAREA+00000020   FULLWORD POINTER                     00106900
SAVER1   EQU   SAVEAREA+00000024   FULLWORD POINTER                     00107000
SAVER2   EQU   SAVEAREA+00000028   FULLWORD POINTER                     00107100
SAVER3   EQU   SAVEAREA+00000032   FULLWORD POINTER                     00107200
SAVER4   EQU   SAVEAREA+00000036   FULLWORD POINTER                     00107300
SAVER5   EQU   SAVEAREA+00000040   FULLWORD POINTER                     00107400
SAVER6   EQU   SAVEAREA+00000044   FULLWORD POINTER                     00107500
SAVER7   EQU   SAVEAREA+00000048   FULLWORD POINTER                     00107600
SAVER8   EQU   SAVEAREA+00000052   FULLWORD POINTER                     00107700
SAVER9   EQU   SAVEAREA+00000056   FULLWORD POINTER                     00107800
SAVER10  EQU   SAVEAREA+00000060   FULLWORD POINTER                     00107900
SAVER11  EQU   SAVEAREA+00000064   FULLWORD POINTER                     00108000
SAVER12  EQU   SAVEAREA+00000068   FULLWORD POINTER                     00108100
SAVEXTNT EQU   SAVEAREA+00000072   8 BYTE(S)                            00108200
PARAM    EQU   00000000            120 BYTE(S) ON WORD                  00108300
PARAM1   EQU   PARAM+00000000      FULLWORD POINTER                     00108400
PARAM2   EQU   PARAM+00000004      FULLWORD POINTER                     00108500
PARAM3   EQU   PARAM+00000008      FULLWORD POINTER                     00108600
PARAM4   EQU   PARAM+00000012      FULLWORD POINTER                     00108700
PARAM5   EQU   PARAM+00000016      FULLWORD POINTER                     00108800
PARAM6   EQU   PARAM+00000020      FULLWORD POINTER                     00108900
PARAM7   EQU   PARAM+00000024      FULLWORD POINTER                     00109000
PARAM8   EQU   PARAM+00000028      FULLWORD POINTER                     00109100
PARAM9   EQU   PARAM+00000032      FULLWORD POINTER                     00109200
PARAM10  EQU   PARAM+00000036      FULLWORD POINTER                     00109300
PARAM11  EQU   PARAM+00000040      FULLWORD POINTER                     00109400
PARAM12  EQU   PARAM+00000044      FULLWORD POINTER                     00109500
PARAM13  EQU   PARAM+00000048      FULLWORD POINTER                     00109600
PARAM14  EQU   PARAM+00000052      FULLWORD POINTER                     00109700
PARAM15  EQU   PARAM+00000056      FULLWORD POINTER                     00109800
PARAM16  EQU   PARAM+00000060      FULLWORD POINTER                     00109900
PARAM17  EQU   PARAM+00000064      FULLWORD POINTER                     00110000
PARAM18  EQU   PARAM+00000068      FULLWORD POINTER                     00110100
PARAM19  EQU   PARAM+00000072      FULLWORD POINTER                     00110200
PARAM20  EQU   PARAM+00000076      FULLWORD POINTER                     00110300
PARAM21  EQU   PARAM+00000080      FULLWORD POINTER                     00110400
PARAM22  EQU   PARAM+00000084      FULLWORD POINTER                     00110500
PARAM23  EQU   PARAM+00000088      FULLWORD POINTER                     00110600
PARAM24  EQU   PARAM+00000092      FULLWORD POINTER                     00110700
PARAM25  EQU   PARAM+00000096      FULLWORD POINTER                     00110800
PARAM26  EQU   PARAM+00000100      FULLWORD POINTER                     00110900
PARAM27  EQU   PARAM+00000104      FULLWORD POINTER                     00111000
PARAM28  EQU   PARAM+00000108      FULLWORD POINTER                     00111100
PARAM29  EQU   PARAM+00000112      FULLWORD POINTER                     00111200
PARAM30  EQU   PARAM+00000116      FULLWORD POINTER                     00111300
TOD      EQU   00000000            12 BYTE(S)                           00111400
TODLEN   EQU   TOD+00000000        2  BYTE  INTEGER                     00111500
TODOFF   EQU   TOD+00000002        2  BYTE  INTEGER                     00111600
TODTXT   EQU   TOD+00000004        8 BYTE(S)                            00111700
DATEBUF  EQU   00000000            18 BYTE(S)                           00111800
DATE     EQU   00000000            22 BYTE(S)                           00111900
DATELEN  EQU   DATE+00000000       2  BYTE  INTEGER                     00112000
DATEOFF  EQU   DATE+00000002       2  BYTE  INTEGER                     00112100
DATETXT  EQU   DATE+00000004       18 BYTE(S)                           00112200
PBMLDAY  EQU   PBMDESCR+00000000   HALFWORD INTEGER                     00112300
PBMLEN   EQU   PBMDESCR+00000002   HALFWORD INTEGER                     00112400
PBMOFF   EQU   PBMDESCR+00000004   HALFWORD INTEGER                     00112500
PBMONTH  EQU   00000000            9 BYTE(S)                            00112600
         DS    00000000C                                                00112700
@L       EQU   1                                                        00112800
@DATD    DSECT                                                          00112900
@SAV001  EQU   @DATD+00000000      72 BYTE(S) ON WORD                   00113000
CNVRT1   EQU   @DATD+00000072      8 BYTE(S) ON DWORD                   00113100
CNVRT2   EQU   @DATD+00000080      4 BYTE(S) ON WORD                    00113200
         DS    00000084C                                                00113300
@TEMPS   DS    0F                                                       00113400
@TEMP4   DC    F'0'                                                     00113500
CC       DS    XL1                 STORAGE FOR COMPUTED CENTURY     JLM 00113600
@DATEND  EQU   *                                                        00113700
IKJEFLPA CSECT ,                                                        00113800
         END   IKJEFLPA                                                 00113900
//SYSUT2   DD  DISP=SHR,DSN=SYS1.UMODSRC(IKJEFLPA)
//SMPAS003 EXEC SMPASM,M=IKJEFLPA
//UMOD001  EXEC SMPAPP,WORK=SYSALLDA
//SMPPTFIN DD  *
++USERMOD(JLM0005)       /* FIX DATE/TIME ROUTINE CENTURY */  .
++VER (Z038) FMID(EBB1102) PRE(UY17588) 
 /*
   PROBLEM DESCRIPTION:
     THE DATE/TIME ROUTINE (IKJEFLPA) RETURNS INCORRECT CENTURY.
       IKJEFLPA MAKES NO ATTEMPT TO DETERMINE THE CORRECT CENTURY,
       INSTEAD SIMPLY PLUGS IN A CONSTANT FOR THE CENTURY WHEN
       FORMATTING THE DATE RETURNED BY THE SYSTEM TIME MACRO.

       THE SOURCE FOR IKJEFLPA WAS RETRIEVED FROM THE OPTIONAL SOURCE
       MATERIALS AND WAS DETERMINED TO BE IDENTICAL TO THE INSTALLED
       LOAD MODULE. THE SOURCE WAS MODIFIED TO CALCULATE THE CORRECT
       CENTURY BY ADDING 19 TO THE CENTURY BYTE RETURNED BY THE
       SYSTEM TIME CALL.

     REWORK HISTORY:
       2024-05-20: INITIAL VERSION.

 */.
++MOD(IKJEFLPA) DISTLIB(AOST4) TXLIB(UMODOBJ).
//IKJEFLPA DD  *
//SMPCNTL  DD  *
  REJECT                  /* IN CASE ALREADY RECEIVED */
         SELECT(JLM0005)
         .
  RESETRC                 /* IN CASE NOT ALREADY RECEIVED */
         .
  RESTORE
         SELECT(ZUM0008 ZUM0007) 
         .
  RECEIVE
         SELECT(JLM0005)
         .
  APPLY
        SELECT(JLM0005)
        DIS(WRITE)
        COMPRESS(ALL)
        .
//* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
