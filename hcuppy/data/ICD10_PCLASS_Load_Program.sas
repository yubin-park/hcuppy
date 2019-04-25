/**********************************************************************/
/* Title:       ICD-10-PCS PROCEDURE CLASS LOAD SOFTWARE			  */
/*                                                                	  */
/* PROGRAM:     ICD10PCS_PCLASS_LOAD_PROGRAM.SAS                  	  */
/*                                                                    */
/* Description: This program creates ICD-10-PCS procedure classes     */
/*              for data using ICD-10-PCS procedure codes.            */
/*                                                                    */
/*              There are two general sections to this program:       */
/*                                                                    */
/*              1) The first section creates temporary SAS        	  */
/*                 informats using the ICD-10-PCS tool file.      	  */
/*                 The procedure classes are located in columns   	  */
/*                 3 and 4. These informats are used in step 2 to 	  */
/*				   create the procedure class variables.          	  */
/*              2) The second section loops through the procedure 	  */
/*                 arrays in your SAS dataset and assigns the     	  */
/*                 procedure classes.                             	  */
/*                                                                	  */
/**********************************************************************/
* Path & name for the ICD-10-PCS Procedure Classes tool ;
       
FILENAME INRAW1  'Location of CSV file: pc_icd10pcs_2018.csv' 	LRECL=300; 
LIBNAME  IN1     'Location of input discharge data';
LIBNAME  OUT1    'Directory to store output file'; 

TITLE1 'CREATE ICD-10-PCS PROCEDURE CLASSES';
TITLE2 'USE WITH DISCHARGE ADMINISTRATIVE DATA THAT HAS ICD-10-PCS CODES';
                                            
/******************************************************************/
/*  Macro Variables that must be set to define the characteristics*/
/*  of your SAS discharge data. Change these values to match the  */
/*  number of procedures in your dataset. Change CORE to match    */
/*  the name of your dataset.                                     */
/****************************************************************;*/

* Maximum number of PRs on any record;        %LET NUMPR=15;
* Input SAS file member name;                 %LET CORE=YOUR_SAS_FILE_HERE;




/******************* SECTION 1: CREATE INFORMATS ******************/
/*  SAS Load the ICD-10-PCS procedure classes tool & convert into */
/*  temporary SAS informats that will be used to assign the       */
/*  procedure class variable in the next step.                    */
/****************************************************************;*/

DATA PCLASS ;
    INFILE INRAW1 DSD DLM=',' END = EOF FIRSTOBS=3;
    INPUT
       START            : $CHAR7.
       ICD10PCS_label   : $CHAR100.
       LABEL            : 3.
       PCLASS_Label     : $CHAR100.
    ;
   RETAIN HLO " ";
   FMTNAME = "I10PCLASS" ;
   TYPE    = "I" ;
   OUTPUT;

   IF EOF THEN DO ;
      START = " " ;
      LABEL = 0 ;
      HLO   = "O";
      OUTPUT ;
   END ;
RUN;

PROC FORMAT LIB=WORK CNTLIN = PCLASS ;
RUN;


/*********** SECTION 2: CREATE ICD-10-PCS PROCEDURE CLASSES ***********/
/*  Create procedure classes for ICD-10-PCS using the SAS informat    */
/*  created above & the SAS file you wish to augment.      	          */
/*  Users can change the names of the output procedure class          */
/*  variables if needed here. It is also important to make sure       */
/*  that the correct ICD-10-PCS procedure names from your SAS file    */
/*  are used in the arrays 'PRS'. ICD version code PRVER takes a      */
/*  value of either 9 or 10 (for ICD-9-CM or ICD-10-CM/PCS)           */
/**********************************************************************/  

%Macro PCLASS;
DATA OUT1.PCLASS (DROP = i);
  SET IN1.&CORE;

  /****************************************************/
  /* Loop through the PCS procedure array in your SAS */
  /* dataset & create the procedure class variables.  */
  /**************************************************;*/
  %if &NUMPR > 0 %then %do;
    ARRAY I10_PCLASS (*)  3 I10_PCLASS1-I10_PCLASS&NUMPR;   * Suggested name for ICD-10-PCS procedure class variables;
    ARRAY PRS        (*)  $ PR1-PR&NUMPR;                   * Change ICD-10-PCS procedure variable names to match your file;
    IF PRVER=10 Then DO I = 1 TO &NUMPR;
        IF Not Missing(PRS(I)) Then I10_PCLASS(I) = INPUT(PRS(I), I10PCLASS.);
    END;  
  %end;

RUN;

PROC PRINT DATA=OUT1.PCLASS (OBS=10);
  WHERE PRVER=10;
  %if &NUMPR > 0 %then %do;
     VAR PRVER PR1 I10_PCLASS1;
  %end;
  title2 "Partial Print of the Output ICD-10-PCS Procedure Classes";
RUN;
%Mend PCLASS;
%PCLASS;


