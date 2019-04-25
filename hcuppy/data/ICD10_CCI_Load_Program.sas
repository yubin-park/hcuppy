/******************************************************************************/
/* Title:       ICD-10-CM CHRONIC CONDITION INDICATOR LOAD SOFTWARE			      */
/*                                                                            */
/* PROGRAM:     ICD10CM_CCI_LOAD_PROGRAM.SAS                                  */
/*                                                                            */
/* Description: This program creates ICD-10-CM chronic condition and          */
/*              body system indicators for data using ICD-10-CM diagnosis 	  */
/*				codes.        												                              */
/*                                                                            */
/*              There are two general sections to this program:               */
/*                                                                            */
/*              1) The first section creates temporary SAS informats using    */
/*                 the ICD-10-CM tool file.                                   */
/*                 The chronic condition indicator is located in column 3.    */
/*                 The body system indicator is located in column 4.          */
/*                 These informats are used in step 2 to create the chronic   */
/*                 condition and body system indicator variables.   		      */
/*              2) The second section loops through the diagnosis arrays in   */
/*                 your SAS dataset and assigns chronic condition 			      */
/*                 and body system indicators.                                */
/*                                                                            */
/******************************************************************************/
* Path & name for the ICD-10-CM CCI tool ;
       
FILENAME INRAW1  'Location of CSV file: cci_icd10cm_2019_1.csv' 	LRECL=300; 
LIBNAME  IN1     'Location of input discharge data';
LIBNAME  OUT1    'Directory to store output file';         

TITLE1 'CREATE ICD-10-CM CHRONIC CONDITION AND BODY SYSTEM INDICATORS';
TITLE2 'USE WITH DISCHARGE ADMINISTRATIVE DATA THAT HAS ICD-10-CM CODES';
                                            
/******************************************************************/
/*  Macro variables that must be set to define the characteristics*/
/*  of your SAS discharge data. Change these values to match the  */
/*  number of diagnoses in your dataset. Change CORE to match the */
/*  name of your dataset.                                         */
/****************************************************************;*/

* Maximum number of DXs on any record;        %LET NUMDX=30;
* Input SAS file member name;                 %LET CORE=YOUR_SAS_FILE_HERE;




/******************* SECTION 1: CREATE INFORMATS *******************/
/*  SAS Load the ICD-10-CM chronic condition indicator tool and    */
/*  convert into temporary SAS informats that will be used to 	   */
/*  assign the chronic condition and body system indicators in     */
/*  the next step.												   */
/*****************************************************************;*/

DATA CCI        (KEEP= FMTNAME START CCI        HLO TYPE) 
     BodySystem (KEEP= FMTNAME START BodySystem HLO TYPE)
;
    INFILE INRAW1 DSD DLM=',' END = EOF FIRSTOBS=2 ;
    INPUT
       START          : $CHAR7.
       ICD10CM_label  : $CHAR100.
       CCI            : 1.
       CBodySystem    : $CHAR4.
    ;
   RETAIN HLO " ";   
   TYPE    = "I" ;      
   FMTNAME = "I10BodySystem" ;
   /* Convert CBodySystem to numeric BodySystem */
   LENGTH BodySystem 3.;
   IF CBodySystem = 'None' THEN BodySystem = 0;
   ELSE BodySystem = Input(CBodySystem, 8.0);
   OUTPUT BodySystem;      
   FMTNAME = "I10CCI" ;
   OUTPUT CCI;

   IF EOF THEN DO ;
      START = " " ;
      HLO   = "O";
      BodySystem = . ;
      FMTNAME = "I10BodySystem" ;
      OUTPUT BodySystem;
      CCI = .;        
      FMTNAME = "I10CCI" ;
      OUTPUT CCI;
   END ;
RUN;

PROC FORMAT LIB=WORK CNTLIN = CCI (Rename=(CCI=Label));
RUN;
   
PROC FORMAT LIB=WORK CNTLIN = BodySystem (Rename=(BodySystem=Label));
RUN;

/****** SECTION 2: CREATE ICD-10-CM CHRONIC CONDITION INDICATORS *****/
/*  Create chronic condition and body system indicators for ICD-10-CM*/
/*  diagnoses using the SAS informats created above & the SAS file   */
/*  you wish to augment. Users can change the names of the output 	 */
/*  chronic condition and body system indicator variables if         */
/*  needed here. It is also important to make sure that the          */
/*  correct ICD-10-CM diagnosis names from your SAS file are used    */
/*  in the arrays 'DXS'. ICD version code DXVER takes a value        */
/*  of either 9 or 10 (for ICD-9-CM or ICD-10-CM/PCS).               */
/*********************************************************************/  

%Macro CCI;
DATA OUT1.CCI_BODYSYSTEM (DROP = i);
  SET IN1.&CORE ;

  /****************************************************/
  /* Loop through the ICD-10-CM diagnosis array in    */
  /* your SAS dataset & create the chronic condition  */
  /* and body system indicator variables.          	  */
  /****************************************************/
  %if &NUMDX > 0 %then %do;
    ARRAY I10_CCI        (*)  3 I10_CCI1       -I10_CCI&NUMDX       ; * Suggested name for ICD-10-CM chronic condition indicator variables;
    ARRAY I10_BodySystem (*)  3 I10_BodySystem1-I10_BodySystem&NUMDX; * Suggested name for ICD-10-CM body system indicator variables;
    ARRAY DXS            (*)  $ DX1-DX&NUMDX;                         * Change ICD-10-CM diagnosis variable names to match your file;
    IF DXVER=10 Then DO I = 1 TO &NUMDX;
        IF Not Missing(DXS(I)) Then DO;
            I10_CCI(I)        = INPUT(DXS(I), I10CCI.       );
            I10_BodySystem(I) = INPUT(DXS(I), I10BodySystem.);
        END;
    END;  
  %end;

RUN;

PROC PRINT DATA=OUT1.CCI_BODYSYSTEM (OBS=10);
  WHERE DXVER=10;
  %if &NUMDX > 0 %then %do;
     VAR DXVER DX1 I10_CCI1 I10_BodySystem1 ;
  %end;
  title2 "Partial Print of the Output ICD-10-CM Chronic Condition Indicators and Body Systems";
RUN;
%Mend CCI;
%CCI;



