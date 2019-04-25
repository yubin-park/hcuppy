/*=================================================================================*/
/* Program     : ICD10PCS_UtilizationFlags.sas                                     */
/* Date        : 10/18/2018                                                        */
/* Description : This program creates 30 Utilization Flag variables using UB-04    */
/*             : revenue codes and ICD-10-PCS procedure codes from SAS data. The   */
/*             : program uses informats to map revenue codes and procedure codes   */
/*             : to the new variables. These programs were developed under the     */
/*             : HCUP contract, sponsored by AHRQ.                                 */
/*=================================================================================*/

/*=============================== Libname Statements ==============================*/
LIBNAME  INSAS     " Location of input files                                       "; 
LIBNAME  OUTSAS    " Directory to store output file                                "; 
FILENAME INRAW1    " Location of CSV file: ICD10PCS_utilizationflagformats_FY2019_1";  

/*=============================== Input File Options ==============================*/
/* The Utilization Flags are defined using both revenue codes and ICD-10-PCS codes.*/
/* If your input data has both revenue codes and ICD-10-PCS codes in one file then */
/* put the name of this file in the infile1_ macro and set the merge_ macro to 0.  */
/* If you will need to merge your revenue codes and ICD-10-PCS procedure codes     */
/* together (for example, HCUP Core and Charges files) then put the name of the    */
/* file with the revenue codes in infile1_, the name of the file with ICD-10-PCS   */
/* procedure codes in infile2_, and set the merge_ macro to 1. The key_ macro      */
/* should contain the name of the variable(s) that link the 2 data sets.           */
/* The program references the HCUP ICD-10-PCS procedure and CCS variables I10_PRn  */
/* and I10_PRCCSn. If the procedure and CCS variable names are different in your   */
/* input SAS Core file, you must change the names in lines 186-187.                */

%Let infile1_ = <CHARGES>  ;      /* Name of input file or if merging, name of     */
                                  /* file containing revenue codes                 */
%Let infile2_ = <CORE>     ;      /* Name of file containing ICD-10-PCS codes      */
%Let merge_   = 1          ;      /* Set to 1 if merging revenue and procedure data*/
%Let key_     = <KEY>      ;      /* Linking variable for merge                    */
%Let outfile_ = TestLoad   ;      /* Name of your output SAS Data Set              */
%Let revcdn_  = <##>       ;      /* Number of revenue codes on input data set     */
%Let prn_     = <##>       ;      /* Number of ICD-10-PCS codes on input dataset   */

TITLE1 "Utilization Flags" ; 

/*=================================================================================*/
/* STEP 1 : Load CSV Files and create Utilization Flag formats                     */
/*        : These files map revenue codes or procedure codes to a number           */
/*        : 1-30 which correspond to a specific utilization flag. The numbers are  */
/*        : assigned alphabetically. So U_BLOOD, is #1, U_CATH is #2 etc. These    */
/*        : numbers will correspond to the position in a utilization flag array.   */
/*=================================================================================*/


DATA RAW ; 
   INFILE INRAW1 dsd dlm=',' firstobs=2;
   INPUT 
      LABEL            : 4. 
      SAS_NAME         : $CHAR15.
      Utilization_Flag : $CHAR60.
      REVCODE          : $4.
      PRCCS            : 4. 
      ICD10PCS         : $CHAR7. 
      ICD10OPCS_Label  : $CHAR110.
      ;
RUN ;

DATA OUTSAS.Control
     OUTSAS.FlagList(KEEP = LABEL SAS_NAME Utilization_Flag); 
   SET RAW(WHERE = (START > ' ') RENAME = (REVCODE = START)) END = EOF;
   BY SAS_NAME NOTSORTED; 
   FMTNAME = "UFLAG" ;    
   TYPE = "I" ;
   OUTPUT OUTSAS.Control;
   IF LAST.SAS_NAME THEN OUTPUT OUTSAS.Flaglist; 
   IF EOF THEN DO;
      HLO = "O" ; 
      LABEL = 0 ;
      OUTPUT OUTSAS.CONTROL ;
   END;
RUN; 

DATA OUTSAS.Control2;
   SET RAW(WHERE = (START > 0) RENAME = (PRCCS = START)) END = EOF;
   BY SAS_NAME NOTSORTED; 
   FMTNAME = "CCSFLAG" ;    
   TYPE = "N" ;
   OUTPUT OUTSAS.Control2;
   IF EOF THEN DO;
      HLO = "O" ; 
      LABEL = 0 ;
      OUTPUT OUTSAS.CONTROL2 ;
   END;
RUN; 

DATA OUTSAS.Control3;
   SET RAW (WHERE = (START > " ") RENAME = (ICD10PCS = START)) END = EOF;
   BY SAS_NAME NOTSORTED; 
   FMTNAME = "PCSFlag" ;    
   TYPE = "I" ;
   OUTPUT OUTSAS.Control3;
   IF EOF THEN DO;
      HLO = "O" ; 
      LABEL = 0 ;
      OUTPUT OUTSAS.CONTROL3 ;
   END;
RUN; 

Proc Format cntlin=OUTSAS.CONTROL library=WORK  ;
Run ;
Proc Format cntlin=OUTSAS.CONTROL2 library=WORK  ;
Run ;
Proc Format cntlin=OUTSAS.CONTROL3 library=WORK  ;
Run ;


/*==================================================================================*/
/* STEP 2 : Create the macro "SASVARS" which contains a list of all the Utilization */
/* Flag SAS names, in alphabetical order. This Macro will be used to create an      */
/* array containing all 30 Flags, and the formats above, map revenue and procedure  */
/* codes, to a number corresponding to their position in that array.                */
/*==================================================================================*/

DATA SASVARS;
   LENGTH SASVARS $4000 ; 
   RETAIN SASVARS; 
   SET OUTSAS.FLAGLIST ;  
   SASvars = TRIM(LEFT(SASvars)) || ' ' || TRIM(LEFT(SAS_NAME)) ;
   CALL SYMPUT('sasvars',sasvars) ;
RUN;

%PUT ; 
%PUT HCUP NOTE: THE FOLLOWING IS THE LIST OF UTILIZATION FLAG SAS VARIABLES: ;
%PUT &SASVARS ;
%PUT ; 

/*=================================================================================*/
/* STEP 3 : Create the Utilization Flags using the formats.                        */
/* The values of the Utilization Flags are as follows.                             */
/* 1 = Flag identified by revenue code                                             */
/* 2 = Flag identified by either CCS or ICD-10-PCS procedure code                  */
/* 3 = Flag identified by both revenue codes and ICD-10-PCS procedure codes        */
/* 0 = Record does not have identifying revenue or ICD-10-PCS procedure code       */
/*=================================================================================*/

%MACRO AddFlags ; 

DATA OUTSAS.&OUTFILE_  ; 
   LABEL U_BLOOD         = 'Utilization Flag: Blood'
         U_CATH          = 'Utilization Flag: Cardiac Catheterization Lab'
         U_CCU           = 'Utilization Flag: Coronary Care Unit (CCU)'
         U_CHESTXRAY     = 'Utilization Flag: Chest X-Ray'
         U_CTSCAN        = 'Utilization Flag: Computed Tomography Scan'
         U_DIALYSIS      = 'Utilization Flag: Renal Dialysis'
         U_ECHO          = 'Utilization Flag: Echocardiology'
         U_ED            = 'Utilization Flag: Emergency Room'
         U_EEG           = 'Utilization Flag: Electroencephalogram'
         U_EKG           = 'Utilization Flag: Electrocardiogram'
         U_EPO           = 'Utilization Flag: EPO'
         U_ICU           = 'Utilization Flag: Intensive Care Unit (ICU)'
         U_LITHOTRIPSY   = 'Utilization Flag: Lithotripsy'
         U_MHSA          = 'Utilization Flag: Mental Health and Substance Abuse'
         U_MRT           = 'Utilization Flag: Magnetic Resonance Technology'
         U_NEWBN2L       = 'Utilization Flag: Nursery Level II'
         U_NEWBN3L       = 'Utilization Flag: Nursery Level III'
         U_NEWBN4L       = 'Utilization Flag: Nursery Level IV'
         U_NUCMED        = 'Utilization Flag: Nuclear Medicine'
         U_OBSERVATION   = 'Utilization Flag: Observation Room'
         U_OCCTHERAPY    = 'Utilization Flag: Occupational Therapy'
         U_ORGANACQ      = 'Utilization Flag: Organ Acquisition'
         U_OTHIMPLANTS   = 'Utilization Flag: Other Implants'
         U_PACEMAKER     = 'Utilization Flag: Pacemaker'
         U_PHYTHERAPY    = 'Utilization Flag: Physical Therapy'
         U_RADTHERAPY    = 'Utilization Flag: Radiology - Therapeutic and/or Chemotherapy Administration'
         U_RESPTHERAPY   = 'Utilization Flag: Respiratory Services'
         U_SPEECHTHERAPY = 'Utilization Flag: Speech - Language Pathology'
         U_STRESS        = 'Utilization Flag: Cardiac Stress Test'
         U_ULTRASOUND    = 'Utilization Flag: Ultrasound' ;   
   LENGTH &SASVARS 4. ;

%IF "&MERGE_" = "1" %THEN %DO ; 
   MERGE INSAS.&infile1_   /*Input file infile1 includes the revenue codes   */ 
         INSAS.&infile2_ ; /*Input file infile2 includes the ICD-10-PCS procedure codes */
   BY &KEY_ ; 
%END;                 
%ELSE %DO ; 
   SET INSAS.&infile1_ ;  /* Input file includes both revenue codes and ICD-10-PCS procedure codes */
%END ; 

   ARRAY A_UFLAGS(30) &SASVARS ; 
   ARRAY A_REVCODES (&REVCDN_) REVCD1-REVCD&REVCDN_ ;  
   ARRAY a_PR(&PRN_) I10_PR1-I10_PR&PRN_ ;           
   ARRAY a_PRCCS(&PRN_) I10_PRCCS1-I10_PRCCS&PRN_ ;   

   /* Initialize the Utilization Flags to zero */
   Do I = 1 TO 30;
      A_UFLAGS(I) = 0;
   End;

   DO I=1 TO &REVCDN_ ;
      INDEX = 0 ;
      IF A_REVCODES(I) NE "" THEN DO;
         /* PAD SHORT REVENUE CODES WITH LEADING ZEROES   */
         IF VERIFY (A_REVCODES(I), ' 0123456789') = 0 THEN DO ; 
            IF LENGTH(LEFT(A_REVCODES(I))) < 4 THEN DO ;
               A_REVCODES(I) = PUT (INPUT(A_REVCODES(I), 4.), Z4.) ; 
            END;
         END;
         /* ADD UTILIZATION FLAGS                         */
         INDEX = INPUT(A_REVCODES(I), UFLAG.);
         IF INDEX > 0 THEN A_UFLAGS(INDEX) = 1 ;
      END;
   END;
   

   DO I = 1 TO &PRN_;
      INDEXA = INPUT(A_PR(I), PCSFlag.);
      INDEXB = INPUT(PUT(A_PRCCS(I), CCSFlag.), 4.); 
      IF INDEXA > 0 THEN DO;
         IF A_UFLAGS(INDEXA) = 0 THEN A_UFLAGS(INDEXA) = 2 ; 
         ELSE IF A_UFLAGS(INDEXA) = 1 THEN A_UFLAGS(INDEXA) = 3 ; 
      END; 
      IF INDEXB > 0 THEN DO;
         IF A_UFLAGS(INDEXB) = 0 THEN A_UFLAGS(INDEXB) = 2 ; 
         ELSE IF A_UFLAGS(INDEXB) = 1 THEN A_UFLAGS(INDEXB) = 3 ; 
      END;         
        
   DROP I INDEX INDEXA INDEXB ; 
   END;
Run;

/*=================================================================================*/
/* STEP 4 : Data Summary                                                           */
/*=================================================================================*/
Proc Format ; 
   VALUE UFLAG 
       0 = "0" 
       1 - 3 = "1" ; 
Run;

Proc Freq Data=OUTSAS.&OUTFILE_ NOPRINT ; 
   %Do I_ = 1 %to 31 ;
      %Let VAR_ = %scan(&SASVARS, &I_) ;
      %If "&VAR_" = "" %then %Let I_ = 31 ;
      %Else %Do ;
         TABLES &VAR_ / LIST MISSING OUT=&VAR_._FREQ ; 
      %End;
   %End;
   FORMAT &SASVARS UFLAG. ; 
Run;

Data UFlag_Summary (KEEP = VARNAME COUNT PERCENT) ; 
    LENGTH VARNAME $20 ; 
   SET 
   %Do I_ = 1 %to 31 ;
      %Let Var_ = %scan(&SASVARS, &I_) ;
      %If "&Var_" = "" %then %Let I_ = 31 ;
      %Else %Do ;
          &Var_._Freq 
      %End;
    %End; ; 
   %Do I_ = 1 %to 31 ;
     %Let Var_ = %scan(&SASVARS, &I_) ;
     %If "&Var_" = "" %then %Let I_ = 31 ;
     %Else %Do ;
        IF &VAR_ = 1 THEN DO;
           VARNAME = "&VAR_" ; 
           OUTPUT; 
        END;
     %End;
   %End;
Run;

Proc Print Data = UFlag_Summary NOOBS SPLIT = '*' ; 
   VAR VARNAME COUNT PERCENT ; 
   LABEL VARNAME = "Utilization*Flag"
         COUNT   = "Number of*Records in*Utilization Flag"
         PERCENT = "Percent*of All*Records" ; 
   Title2 "Summary By Utilization Flag" ; 
Run;

Proc Freq Data = outsas.&outfile_ ; 
   Tables &sasvars / List Missing ; 
   Title2 "Utilization Flag Detail" ; 
Run; 

Proc Contents Data = outsas.&outfile_;
   Title2 "Contents of Output Data Set" ; 
Run;

%Mend;
%AddFlags;
