/******************************************************************/
/* Title:       ICD-10-CM/PCS CCS MULTI-LEVEL LOAD SOFTWARE		  */
/*                                                                */
/* PROGRAM:     ICD10CMPCS_MULTI_CCS_LOAD_PROGRAM.SAS             */
/*                                                                */
/* Description: This program creates multi-level ICD-10-CM/PCS    */
/*              CCS categories for data using ICD-10-CM/PCS       */
/*              diagnosis or procedure codes. The multi-level CCS */
/*              categories are an expansion of the single-level   */
/*              ICD-10-CM/PCS CCS categories.                     */
/*																  */
/*              There are two general sections to this program:   */
/*                                                                */
/*              1) The first section creates temporary SAS        */
/*                 informats using ICD-10-CM and PCS tool files.  */
/*                 The multi-level categories are located in      */
/*                 columns 5-8.                                   */
/*                 These informats are used in step 2 to create   */
/*                 the multi-level CCS variables. To save         */
/*                 space, we used macros to call the same code    */
/*                 repeatedly for the two formats.                */
/*              2) The second section loops through the diagnosis */
/*                 and/or procedure arrays on your SAS dataset    */
/*                 and assigns the multi-level CCS categories.    */
/*                                                                */
/******************************************************************/
* Path & name of the ICD-10-CM and PCS tool files ;
FILENAME INRAW1  'C:\CCS\ccs_dx_icd10cm_2018.CSV' LRECL=300;  
FILENAME INRAW2  'C:\CCS\ccs_pr_icd10pcs_2018.CSV' LRECL=300;  
LIBNAME  IN1     'C:\SASDATA\';                 * Location of input discharge data;
LIBNAME  OUT1    'C:\SASDATA\';                 * Location of output data;

TITLE1 'CREATE ICD-10-CM/PCS CCS MULTI-LEVEL TOOL CATEGORIES';
TITLE2 'USE WITH DISCHARGE ADMINISTRATIVE DATA THAT HAS ICD-10-CM OR PCS CODES';

/******************************************************************/
/*  Macro Variables that must be set to define the characteristics*/
/*  of your SAS discharge data. Change these values to match the  */
/*  number of diagnoses and procedures in your dataset. Change    */
/*  CORE to match the name of your dataset.                       */
/******************************************************************/
* Maximum number of DXs on any record;        %LET NUMDX=15;
* Maximum number of PRs on any record;        %LET NUMPR=15;
* Input SAS file member name;                 %LET CORE=YOUR_SAS_FILE_HERE;

%Macro MultiCCS;
/******************* SECTION 1: CREATE INFORMATS ******************/
/*  SAS Load the ICD-10-CM/PCS CCS multi-level CM and PCS tools   */
/*  and convert them into temporary SAS informats used to assign  */
/*  the multi-level CCS variables in the next step.               */
/******************************************************************/

%macro multidxccs(fmt_,var1_,var2_,var3_,var4_,var5_,var6_,var7_);
DATA CCS_MULTI_DX;
   INFILE INRAW1 DSD DLM=',' END = EOF FIRSTOBS=2;
	INPUT
	   START       : $CHAR7.
	   &var1_      : $CHAR4.
	   &var2_      : $CHAR100.
	   &var3_      : $CHAR100.
	   &var4_      : $CHAR2.
	   &var5_      : $CHAR100.
	   &var6_      : $CHAR5.
	   &var7_      : $CHAR100.
	;
   RETAIN HLO " ";
   FMTNAME = "&fmt_" ;
   TYPE    = "J" ;
   OUTPUT;

   IF EOF THEN DO ;
      START = " " ;
	  LABEL = " " ;
      HLO   = "O";
      OUTPUT ;
   END ;
RUN;

PROC FORMAT LIB=WORK CNTLIN = CCS_MULTI_DX;
RUN;
%mend multidxccs;

%if &NUMDX > 0 %then %do;
%multidxccs($L1DCCS,SL,CL,SLL,LABEL,L1L,L2,L2L);
%multidxccs($L2DCCS,SL,CL,SLL,L1,L1L,LABEL,L2L);
%end;

%macro multiprccs(fmt_,var1_,var2_,var3_,var4_,var5_,var6_,var7_);
DATA CCS_MULTI_PR ;
   INFILE INRAW2 DSD DLM=',' END = EOF FIRSTOBS=2;
	INPUT
	   START       : $CHAR7.
	   &var1_      : $CHAR3.
	   &var2_      : $CHAR100.
	   &var3_      : $CHAR100.
	   &var4_      : $CHAR2.
	   &var5_      : $CHAR100.
	   &var6_      : $CHAR5.
	   &var7_      : $CHAR100.
	;
   RETAIN HLO " ";
   FMTNAME = "&fmt_" ;
   TYPE    = "J" ;
   OUTPUT;

   IF EOF THEN DO ;
      START = " " ;
		LABEL = " " ;
      HLO   = "O";
      OUTPUT ;
   END ;
RUN;

PROC FORMAT LIB=WORK CNTLIN = CCS_MULTI_PR ;
RUN;
%mend multiprccs;

%if &NUMPR > 0 %then %do;
%multiprccs($L1PCCS,SL,CL,SLL,LABEL,L1L,L2,L2L);
%multiprccs($L2PCCS,SL,CL,SLL,L1,L1L,LABEL,L2L);
%end;


/*********** SECTION 2: CREATE ICD-10-CM/PCS MULTI-LEVEL CCS CATS ********/
/*  Create multi-level CCS categories for CM/PCS using the SAS           */
/*  informats created above & the SAS file you wish to augment.          */
/*  Users can change the names of the output CCS variables if            */
/*  needed here. It is also important to make sure that the              */
/*  correct ICD-10-CM/PCS diagnosis or procedure names from your SAS     */
/*  file are used in the arrays 'DXS' and 'PRS'.                         */
/*************************************************************************/  

DATA OUT1.NEW_MULTI_CCS (DROP = i);
  SET IN1.&CORE;

  %if &NUMDX > 0 %then %do;
  ARRAY L1DCCS  (*)   $5 L1DCCS1-L1DCCS&NUMDX;   * Suggested name for ICD-10-CM Level 1 Multi-Level DX CCS variables;
  ARRAY L2DCCS  (*)   $5 L2DCCS1-L2DCCS&NUMDX;   * Suggested name for ICD-10-CM Level 2 Multi-Level DX CCS variables;
  ARRAY DXS     (*)   $  DX1-DX&NUMDX;           * Change ICD-10-CM diagnosis variable names to match your file;
  %end;

  %if &NUMPR > 0 %then %do;
  ARRAY L1PCCS  (*)   $5 L1PCCS1-L1PCCS&NUMPR;   * Suggested name for ICD-10-PCS Level 1 Multi-Level PR CCS variables;
  ARRAY L2PCCS  (*)   $5 L2PCCS1-L2PCCS&NUMPR;   * Suggested name for ICD-10-PCS Level 2 Multi-Level PR CCS variables;
  ARRAY PRS     (*)   $  PR1-PR&NUMPR;           * Change ICD-10-PCS procedure variable names to match your file;
  %end;
 
  /***************************************************/
  /*  Loop through the CM diagnosis array in your SAS*/
  /*  dataset and create the multi-level diagnosis   */
  /*  CCS variables.                                 */
  /***************************************************/
  %if &NUMDX > 0 %then %do;
  DO I = 1 TO &NUMDX;
	 L1DCCS(I) = INPUT(DXS(I),$L1DCCS.);
	 L2DCCS(I) = INPUT(DXS(I),$L2DCCS.);
  END;  
  %end;

  /***************************************************/
  /*  Loop through the PCS procedure array in your   */
  /*  SAS dataset & create the multi-level procedure */
  /*  CCS variables.                                 */
  /***************************************************/
  %if &NUMPR > 0 %then %do;
  DO I = 1 TO &NUMPR;
	 L1PCCS(I) = INPUT(PRS(I),$L1PCCS.);
	 L2PCCS(I) = INPUT(PRS(I),$L2PCCS.);
  END;  
  %end;

RUN;

PROC PRINT DATA=OUT1.NEW_MULTI_CCS (OBS=10);
  %if &NUMDX > 0 %then %do;
     VAR  DX1 L1DCCS1 L2DCCS1;
  %end;
  %else %if &NUMPR > 0 %then %do;
     VAR PR1 L1PCCS1 L2PCCS1;
  %end;
  title2 "Partial Print of the Output ICD-10-CM/PCS Multi-Level CCS File";
RUN;
%Mend MultiCCS;
%MultiCCS;


