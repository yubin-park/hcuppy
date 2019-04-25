/******************************************************************/
/* Title:       ICD-10-CM/PCS CCS SINGLE-LEVEL LOAD SOFTWARE      */
/*                                                                */
/* PROGRAM:     ICD10CMPCS_Single_CCS_LOAD_PROGRAM.SAS            */
/*                                                                */
/* Description: This program creates single-level ICD-10-CM/PCS   */
/*              CCS categories for data using ICD-10-CM/PCS       */
/*              diagnosis or procedure codes.                     */
/*                                                                */
/*              There are two general sections to this program:   */
/*                                                                */
/*              1) The first section creates temporary SAS        */
/*                 informats using the ICD-10-CM/PCS tool files.  */
/*                 The single-level categories are located in     */
/*                 columns 2 and 4.                               */
/*                 These informats are used in step 2 to create   */
/*                 the single-level CCS variables.                */
/*              2) The second section loops through the diagnosis */
/*                 and/or procedure arrays in your SAS dataset    */
/*                 and assigns the single-level CCS categories.   */
/*                                                                */
/******************************************************************/
* Path & name for the ICD-10-CM/PCS CCS tool ;
       
FILENAME INRAW1  'Location of CSV file: ccs_dx_icd10cm_2019_1.csv' 			LRECL=300; 
FILENAME INRAW1  'Location of CSV file: ccs_pr_icd10pcs_2019_1.csv' 		LRECL=300; 
LIBNAME  IN1     'Location of input discharge data';
LIBNAME  OUT1    'Directory to store output file';         

TITLE1 'CREATE ICD-10-CM/PCS CCS SINGLE-LEVEL TOOL CATEGORIES';
TITLE2 'USE WITH DISCHARGE ADMINISTRATIVE DATA THAT HAS ICD-10-CM/PCS CODES';
                                            
/******************************************************************/
/*  Macro Variables that must be set to define the characteristics*/
/*  of your SAS discharge data. Change these values to match the  */
/*  number of diagnoses and procedures in your dataset. Change    */
/*  CORE to match the name of your dataset.                       */
/******************************************************************/

* Maximum number of DXs on any record;        %LET NUMDX=30;
* Maximum number of PRs on any record;        %LET NUMPR=15;
* Input SAS file member name;                 %LET CORE=YOUR_SAS_FILE_HERE;




/******************* SECTION 1: CREATE INFORMATS ******************/
/*  SAS Load the ICD-10-CM/PCS CCS single-level tool & convert    */
/*  into temporary SAS informats that will be used to assign the  */
/*  single-level CCS variable in the next step.                   */
/******************************************************************/

/* Diagnoses CCS */
DATA DXCCS;
    INFILE INRAW1 DSD DLM=',' END = EOF FIRSTOBS=2;
    INPUT
       START            : $CHAR7.
       LABEL            : 4.
       ICD10CM_label    : $CHAR100.
       CCS_Label        : $CHAR100.
       Multi_lvl1       : $CHAR2.
       Multi_lvl1_label : $CHAR100.
       Multi_lvl2       : $CHAR5.
       Multi_lvl2_label : $CHAR100.
    ;
   RETAIN HLO " ";
   FMTNAME = "I10DXCCS" ;
   TYPE    = "I" ;
   OUTPUT;

   IF EOF THEN DO ;
      START = " " ;
      LABEL = 0 ;
      HLO   = "O";
      OUTPUT ;
   END ;
RUN;

PROC FORMAT LIB=WORK CNTLIN = DXCCS;
RUN;


/* Procedures CCS */
DATA PRCCS ;
    INFILE INRAW2 DSD DLM=',' END = EOF FIRSTOBS=2;
    INPUT
       START            : $CHAR7.
       LABEL            : 4.
       ICD10PCS_label   : $CHAR100.
       CCS_Label        : $CHAR100.
       Multi_lvl1       : $CHAR2.
       Multi_lvl1_label : $CHAR100.
       Multi_lvl2       : $CHAR5.
       Multi_lvl2_label : $CHAR100.
    ;
   RETAIN HLO " ";
   FMTNAME = "I10PRCCS" ;
   TYPE    = "I" ;
   OUTPUT;

   IF EOF THEN DO ;
      START = " " ;
      LABEL = 0 ;
      HLO   = "O";
      OUTPUT ;
   END ;
RUN;

PROC FORMAT LIB=WORK CNTLIN = PRCCS ;
RUN;


/*********** SECTION 2: CREATE ICD-10-CM/PCS SINGLE-LEVEL CCS CATS *******/
/*  Create single-level CCS categories for CM/PCS using the SAS   		 */
/*  informats created above & the SAS file you wish to augment.   		 */
/*  Users can change the names of the output CCS variables if     		 */
/*  needed here. It is also important to make sure that the       		 */
/*  correct ICD-10-CM/PCS diagnosis or procedure names from your SAS     */
/*  file are used in the arrays 'DXS' and 'PRS'. ICD version code 		 */
/*	DXVER or PRVER takes a value of either 9 or 10 (for ICD-9-CM or  	 */
/*	ICD-10-CM/PCS)                 									  	 */
/*************************************************************************/  

%Macro SingleCCS;
DATA OUT1.NEW_SINGLE_CCS (DROP = i);
  SET IN1.&CORE;
 
  /****************************************************/
  /*  Loop through the CM diagnosis array in your SAS */
  /*  dataset and create the single-level diagnosis   */
  /*  CCS variables.                                  */
  /**************************************************;*/
  %if &NUMDX > 0 %then %do;        
    ARRAY I10_DXCCS (*)  4 I10_DXCCS1-I10_DXCCS&NUMDX;   * Suggested name for ICD-10-CM Single-Level diagnosis CCS variables;
    ARRAY DXS   (*)  $  DX1-DX&NUMDX;        * Change ICD-10-CM diagnosis variable names to match your file;
    IF DXVER=10 Then DO I = 1 TO &NUMDX;
        IF Not Missing(DXS(I)) Then I10_DXCCS(I) = INPUT(DXS(I), I10DXCCS.);
    END;  
  %end;

  /****************************************************/
  /*  Loop through the PCS procedure array in your    */
  /*  SAS dataset & create the single-level procedure */
  /*  CCS variables.                                  */
  /**************************************************;*/
  %if &NUMPR > 0 %then %do;
    ARRAY I10_PRCCS (*)  4 I10_PRCCS1-I10_PRCCS&NUMPR;   * Suggested name for ICD-10-PCS Single-Level procedure CCS variables;
    ARRAY PRS   (*)  $  PR1-PR&NUMPR;        * Change ICD-10-PCS procedure variable names to match your file;
    IF PRVER=10 Then DO I = 1 TO &NUMPR;
        IF Not Missing(PRS(I)) Then I10_PRCCS(I) = INPUT(PRS(I), I10PRCCS.);
    END;  
  %end;

RUN;

PROC PRINT DATA=OUT1.NEW_SINGLE_CCS (OBS=10);
  WHERE DXVER=10 or PRVER=10;
  %if &NUMDX > 0 %then %do;
     VAR DXVER DX1 I10_DXCCS1;
  %end;
  %if &NUMPR > 0 %then %do;
     VAR PRVER PR1 I10_PRCCS1;
  %end;
  title2 "Partial Print of the Output ICD-10-CM/PCS Single-Level CCS File";
RUN;
%Mend SingleCCS;
%SingleCCS;


