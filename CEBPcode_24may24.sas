/*====================================================================*\
Call Analytical Dataset
\*====================================================================*/

 Data MrgedClean_1;
 set UserData.MrgedClean_2;
 run; 

 proc sort data=MrgedClean_1 ; by month year ; run; 
 proc contents data=MrgedClean_1  ; run; 

 Proc freq data= MrgedClean_1; 
 tables keepAgeorDrop*age_group*ICD_10_113_Cause_List_Code/list missing;
 run; 

/*====================================================================*\
		Fit a Poisson Regression Model

\*====================================================================*/

%macro PoissonSQL(Title	,	CancerCode	,	Outdataset	,	agesub	,	agesubname);
 proc sort data=MrgedClean_1 ; by age_group ; run; 
 
 title1 "&Title.";

 proc genmod data=MrgedClean_1 order=data; 
 where  ICD_10_113_Cause_List_Code="&CancerCode."; 
 by age_group; 
 class Covid19/param=ref ref=first; 
 model Deaths_sum= Covid19  T    Sine Cosine Covid19*Sine  Covid19*Cosine /offset=logPersonDays dist=poisson 
		link=log type3 scale=pearson covb;  
		output out=&Outdataset. pred=predicted;
 contrast 'JOINT TEST ' covid19 1, Sine*covid19 1, Cosine*covid19 1; 	
 ODS OUTPUT ParameterEstimates=est_&Outdataset.; 
 ODS OUTPUT contrasts=Pval_&Outdataset.;
 ODS OUTPUT covb=MTRX_&Outdataset.;
 run; 


ods output close;
title; 


data &Outdataset.;
set &Outdataset.;
predicted=round(predicted,1); 
predicted_rates=(predicted/PersonDay)*100000; 
label predicted="Predicted Deaths"; 
label Deaths_sum="Observed Deaths"; 
label predicted_rates="Predicted Death Rates";
label DthRatesPersonDay= "Obsereved Death Rates"; 
run; 
proc  sort data= &Outdataset.  ; by age_group Year month ; run; 

 


data MTRX_&Outdataset._&agesubname. ;
set MTRX_&Outdataset.;
where age_group=&agesub.;

if age_group=	&agesub.	and rowname=	"Prm1"	then 	VAR_1vs1 	=	prm1	;
if age_group=	&agesub.	and rowname=	"Prm2"	then 	covar_1vs2	=	prm1	;
if age_group=	&agesub.	and rowname=	"Prm3"	then 	covar_1vs3	=	prm1	;
if age_group=	&agesub.	and rowname=	"Prm4"	then 	covar_1vs4	=	prm1	;
if age_group=	&agesub.	and rowname=	"Prm5"	then 	covar_1vs5	=	prm1	;
if age_group=	&agesub.	and rowname=	"Prm6"	then 	covar_1vs6	=	prm1	;
if age_group=	&agesub.	and rowname=	"Prm7"	then 	covar_1vs7	=	prm1	;
								
if age_group=	&agesub.	and rowname=	"Prm2"	then 	VAR_2vs2	=	prm2	;
if age_group=	&agesub.	and rowname=	"Prm3"	then 	covar_2vs3	=	prm2	;
if age_group=	&agesub.	and rowname=	"Prm4"	then 	covar_2vs4	=	prm2	;
if age_group=	&agesub.	and rowname=	"Prm5"	then 	covar_2vs5	=	prm2	;
if age_group=	&agesub.	and rowname=	"Prm6"	then 	covar_2vs6	=	prm2	;
if age_group=	&agesub.	and rowname=	"Prm7"	then 	covar_2vs7	=	prm2	;
								
								
if age_group=	&agesub.	and rowname=	"Prm3"	then 	VAR_3vs3	=	prm3	;
if age_group=	&agesub.	and rowname=	"Prm4"	then 	covar_3vs4	=	prm3	;
if age_group=	&agesub.	and rowname=	"Prm5"	then 	covar_3vs5	=	prm3	;
if age_group=	&agesub.	and rowname=	"Prm6"	then 	covar_3vs6	=	prm3	;
if age_group=	&agesub.	and rowname=	"Prm7"	then 	covar_3vs7	=	prm3	;
								
								
if age_group=	&agesub.	and rowname=	"Prm4"	then 	VAR_4vs4	=	prm4	;
if age_group=	&agesub.	and rowname=	"Prm5"	then 	covar_4vs5	=	prm4	;
if age_group=	&agesub.	and rowname=	"Prm6"	then 	covar_4vs6	=	prm4	;
if age_group=	&agesub.	and rowname=	"Prm7"	then 	covar_4vs7	=	prm4	;
								
								
if age_group=	&agesub.	and rowname=	"Prm5"	then 	VAR_5vs5	=	prm5	;
if age_group=	&agesub.	and rowname=	"Prm6"	then 	covar_5vs6	=	prm5	;
if age_group=	&agesub.	and rowname=	"Prm7"	then 	covar_5vs7	=	prm5	;
								
								
if age_group=	&agesub.	and rowname=	"Prm6"	then 	VAR_6vs6	=	prm6	;
if age_group=	&agesub.	and rowname=	"Prm7"	then 	covar_6vs7	=	prm6	;
								
								
if age_group=	&agesub.	and rowname=	"Prm7"	then 	VAR_7vs7	=	prm7	;


run;


proc sql; 
create table L_covb_&Outdataset._&agesubname. 
(drop=Prm1	Prm2	Prm3	Prm4	Prm5	Prm6	Prm7 rowname
VAR_1vs1 	covar_1vs2	covar_1vs3	covar_1vs4	covar_1vs5	covar_1vs6	covar_1vs7
VAR_2vs2	covar_2vs3	covar_2vs4	covar_2vs5	covar_2vs6	covar_2vs7	
VAR_3vs3	covar_3vs4	covar_3vs5	covar_3vs6	covar_3vs7		
VAR_4vs4	covar_4vs5	covar_4vs6	covar_4vs7			
VAR_5vs5	covar_5vs6	covar_5vs7				
VAR_6vs6	covar_6vs7					
VAR_7vs7						
)as
select *, 
max(	VAR_1vs1	) 	as	VAR_1vs1_L	,
max(	covar_1vs2	) 	as	covar_1vs2_L	,
max(	covar_1vs3	) 	as	covar_1vs3_L	,
max(	covar_1vs4	) 	as	covar_1vs4_L	,
max(	covar_1vs5	) 	as	covar_1vs5_L	,
max(	covar_1vs6	) 	as	covar_1vs6_L	,
max(	covar_1vs7	) 	as	covar_1vs7_L	,
					
max(	VAR_2vs2	) 	as	VAR_2vs2_L	,
max(	covar_2vs3	) 	as	covar_2vs3_L	,
max(	covar_2vs4	) 	as	covar_2vs4_L	,
max(	covar_2vs5	) 	as	covar_2vs5_L	,
max(	covar_2vs6	) 	as	covar_2vs6_L	,
max(	covar_2vs7	) 	as	covar_2vs7_L	,
					
max(	VAR_3vs3	) 	as	VAR_3vs3_L	,
max(	covar_3vs4	) 	as	covar_3vs4_L	,
max(	covar_3vs5	) 	as	covar_3vs5_L	,
max(	covar_3vs6	) 	as	covar_3vs6_L	,
max(	covar_3vs7	) 	as	covar_3vs7_L	,
					
max(	VAR_4vs4	) 	as	VAR_4vs4_L	,
max(	covar_4vs5	) 	as	covar_4vs5_L	,
max(	covar_4vs6	) 	as	covar_4vs6_L	,
max(	covar_4vs7	) 	as	covar_4vs7_L	,
					
max(	VAR_5vs5	) 	as	VAR_5vs5_L	,
max(	covar_5vs6	) 	as	covar_5vs6_L	,
max(	covar_5vs7	) 	as	covar_5vs7_L	,
					
max(	VAR_6vs6	) 	as	VAR_6vs6_L	,
max(	covar_6vs7	) 	as	covar_6vs7_L	,
					
max(	VAR_7vs7	) 	as	VAR_7vs7_L	


from MTRX_&Outdataset._&agesubname. ; 
quit; 




data L2_covb_&Outdataset._&agesubname.  ;
set L_covb_&Outdataset._&agesubname. (obs=1);
run; 


%mend PoissonSQL; 
%PoissonSQL(	Malignant neoplasms (C00-C97)	,	GR113-019	,	All_Cancers	,	0	,	0_14	);
%PoissonSQL(	Malignant neoplasms (C00-C97)	,	GR113-019	,	All_Cancers	,	1	,	15_24 	);
%PoissonSQL(	Malignant neoplasms (C00-C97)	,	GR113-019	,	All_Cancers	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms (C00-C97)	,	GR113-019	,	All_Cancers	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms (C00-C97)	,	GR113-019	,	All_Cancers	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms (C00-C97)	,	GR113-019	,	All_Cancers	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms (C00-C97)	,	GR113-019	,	All_Cancers	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms (C00-C97)	,	GR113-019	,	All_Cancers	,	12	,	75_plus	);
										
%PoissonSQL(	All other and unspecified malignant neoplasms	,	GR113-043	,	Other	,	2	,	25_34 	);
%PoissonSQL(	All other and unspecified malignant neoplasms	,	GR113-043	,	Other	,	3	,	35_44 	);
%PoissonSQL(	All other and unspecified malignant neoplasms	,	GR113-043	,	Other	,	4	,	45_54 	);
%PoissonSQL(	All other and unspecified malignant neoplasms	,	GR113-043	,	Other	,	5	,	55_64 	);
%PoissonSQL(	All other and unspecified malignant neoplasms	,	GR113-043	,	Other	,	6	,	65_74 	);
%PoissonSQL(	All other and unspecified malignant neoplasms	,	GR113-043	,	Other	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant melanoma of skin (C43)	,	GR113-028	,	Skin	,	2	,	25_34 	);
%PoissonSQL(	Malignant melanoma of skin (C43)	,	GR113-028	,	Skin	,	3	,	35_44 	);
%PoissonSQL(	Malignant melanoma of skin (C43)	,	GR113-028	,	Skin	,	4	,	45_54 	);
%PoissonSQL(	Malignant melanoma of skin (C43)	,	GR113-028	,	Skin	,	5	,	55_64 	);
%PoissonSQL(	Malignant melanoma of skin (C43)	,	GR113-028	,	Skin	,	6	,	65_74 	);
%PoissonSQL(	Malignant melanoma of skin (C43)	,	GR113-028	,	Skin	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of bladder (C67)	,	GR113-035	,	Bladder	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasm of bladder (C67)	,	GR113-035	,	Bladder	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of bladder (C67)	,	GR113-035	,	Bladder	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of bladder (C67)	,	GR113-035	,	Bladder	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of bladder (C67)	,	GR113-035	,	Bladder	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of bladder (C67)	,	GR113-035	,	Bladder	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of breast (C50)	,	GR113-029	,	Breast	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasm of breast (C50)	,	GR113-029	,	Breast	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of breast (C50)	,	GR113-029	,	Breast	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of breast (C50)	,	GR113-029	,	Breast	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of breast (C50)	,	GR113-029	,	Breast	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of breast (C50)	,	GR113-029	,	Breast	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of cervix uteri (C53)	,	GR113-030	,	Cervix	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasm of cervix uteri (C53)	,	GR113-030	,	Cervix	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of cervix uteri (C53)	,	GR113-030	,	Cervix	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of cervix uteri (C53)	,	GR113-030	,	Cervix	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of cervix uteri (C53)	,	GR113-030	,	Cervix	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of cervix uteri (C53)	,	GR113-030	,	Cervix	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of esophagus (C15)	,	GR113-021	,	Esophagus	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasm of esophagus (C15)	,	GR113-021	,	Esophagus	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of esophagus (C15)	,	GR113-021	,	Esophagus	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of esophagus (C15)	,	GR113-021	,	Esophagus	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of esophagus (C15)	,	GR113-021	,	Esophagus	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of esophagus (C15)	,	GR113-021	,	Esophagus	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of larynx (C32)	,	GR113-026	,	Larynx	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasm of larynx (C32)	,	GR113-026	,	Larynx	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of larynx (C32)	,	GR113-026	,	Larynx	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of larynx (C32)	,	GR113-026	,	Larynx	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of larynx (C32)	,	GR113-026	,	Larynx	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of larynx (C32)	,	GR113-026	,	Larynx	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of ovary (C56)	,	GR113-032	,	Ovary	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasm of ovary (C56)	,	GR113-032	,	Ovary	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of ovary (C56)	,	GR113-032	,	Ovary	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of ovary (C56)	,	GR113-032	,	Ovary	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of ovary (C56)	,	GR113-032	,	Ovary	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of ovary (C56)	,	GR113-032	,	Ovary	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of pancreas (C25)	,	GR113-025	,	Pancreas	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasm of pancreas (C25)	,	GR113-025	,	Pancreas	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of pancreas (C25)	,	GR113-025	,	Pancreas	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of pancreas (C25)	,	GR113-025	,	Pancreas	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of pancreas (C25)	,	GR113-025	,	Pancreas	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of pancreas (C25)	,	GR113-025	,	Pancreas	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of prostate (C61)	,	GR113-033	,	Prostate	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of prostate (C61)	,	GR113-033	,	Prostate	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of prostate (C61)	,	GR113-033	,	Prostate	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of prostate (C61)	,	GR113-033	,	Prostate	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of prostate (C61)	,	GR113-033	,	Prostate	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasm of stomach (C16)	,	GR113-022	,	Stomach	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasm of stomach (C16)	,	GR113-022	,	Stomach	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasm of stomach (C16)	,	GR113-022	,	Stomach	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasm of stomach (C16)	,	GR113-022	,	Stomach	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasm of stomach (C16)	,	GR113-022	,	Stomach	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasm of stomach (C16)	,	GR113-022	,	Stomach	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasms of colon rectum and anus (C18-C21)	,	GR113-023	,	Colon	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms of colon rectum and anus (C18-C21)	,	GR113-023	,	Colon	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms of colon rectum and anus (C18-C21)	,	GR113-023	,	Colon	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms of colon rectum and anus (C18-C21)	,	GR113-023	,	Colon	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms of colon rectum and anus (C18-C21)	,	GR113-023	,	Colon	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms of colon rectum and anus (C18-C21)	,	GR113-023	,	Colon	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasms of corpus uteri and uterus  part unspecified (C54-C55)	,	GR113-031	,	Uterus	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms of corpus uteri and uterus  part unspecified (C54-C55)	,	GR113-031	,	Uterus	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms of corpus uteri and uterus  part unspecified (C54-C55)	,	GR113-031	,	Uterus	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms of corpus uteri and uterus  part unspecified (C54-C55)	,	GR113-031	,	Uterus	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms of corpus uteri and uterus  part unspecified (C54-C55)	,	GR113-031	,	Uterus	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms of corpus uteri and uterus  part unspecified (C54-C55)	,	GR113-031	,	Uterus	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasms of kidney and renal pelvis (C64-C65)	,	GR113-034	,	Kidney	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms of kidney and renal pelvis (C64-C65)	,	GR113-034	,	Kidney	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms of kidney and renal pelvis (C64-C65)	,	GR113-034	,	Kidney	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms of kidney and renal pelvis (C64-C65)	,	GR113-034	,	Kidney	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms of kidney and renal pelvis (C64-C65)	,	GR113-034	,	Kidney	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms of kidney and renal pelvis (C64-C65)	,	GR113-034	,	Kidney	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasms of lip oral cavity and pharynx (C00-C14)	,	GR113-020	,	Lip	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms of lip oral cavity and pharynx (C00-C14)	,	GR113-020	,	Lip	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms of lip oral cavity and pharynx (C00-C14)	,	GR113-020	,	Lip	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms of lip oral cavity and pharynx (C00-C14)	,	GR113-020	,	Lip	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms of lip oral cavity and pharynx (C00-C14)	,	GR113-020	,	Lip	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms of lip oral cavity and pharynx (C00-C14)	,	GR113-020	,	Lip	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasms of liver and intrahepatic bile ducts (C22)	,	GR113-024	,	Liver	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms of liver and intrahepatic bile ducts (C22)	,	GR113-024	,	Liver	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms of liver and intrahepatic bile ducts (C22)	,	GR113-024	,	Liver	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms of liver and intrahepatic bile ducts (C22)	,	GR113-024	,	Liver	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms of liver and intrahepatic bile ducts (C22)	,	GR113-024	,	Liver	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms of liver and intrahepatic bile ducts (C22)	,	GR113-024	,	Liver	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasms of lymphoid hematopoietic and related tissue (C81-C96)	,	GR113-037	,	Lymphoid	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms of lymphoid hematopoietic and related tissue (C81-C96)	,	GR113-037	,	Lymphoid	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms of lymphoid hematopoietic and related tissue (C81-C96)	,	GR113-037	,	Lymphoid	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms of lymphoid hematopoietic and related tissue (C81-C96)	,	GR113-037	,	Lymphoid	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms of lymphoid hematopoietic and related tissue (C81-C96)	,	GR113-037	,	Lymphoid	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms of lymphoid hematopoietic and related tissue (C81-C96)	,	GR113-037	,	Lymphoid	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasms of meninges brain and other parts of central nervous system (C70-C72)	,	GR113-036	,	CNS	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms of meninges brain and other parts of central nervous system (C70-C72)	,	GR113-036	,	CNS	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms of meninges brain and other parts of central nervous system (C70-C72)	,	GR113-036	,	CNS	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms of meninges brain and other parts of central nervous system (C70-C72)	,	GR113-036	,	CNS	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms of meninges brain and other parts of central nervous system (C70-C72)	,	GR113-036	,	CNS	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms of meninges brain and other parts of central nervous system (C70-C72)	,	GR113-036	,	CNS	,	12	,	75_plus	);
										
%PoissonSQL(	Malignant neoplasms of trachea bronchus and lung (C33-C34)	,	GR113-027	,	Lung	,	2	,	25_34 	);
%PoissonSQL(	Malignant neoplasms of trachea bronchus and lung (C33-C34)	,	GR113-027	,	Lung	,	3	,	35_44 	);
%PoissonSQL(	Malignant neoplasms of trachea bronchus and lung (C33-C34)	,	GR113-027	,	Lung	,	4	,	45_54 	);
%PoissonSQL(	Malignant neoplasms of trachea bronchus and lung (C33-C34)	,	GR113-027	,	Lung	,	5	,	55_64 	);
%PoissonSQL(	Malignant neoplasms of trachea bronchus and lung (C33-C34)	,	GR113-027	,	Lung	,	6	,	65_74 	);
%PoissonSQL(	Malignant neoplasms of trachea bronchus and lung (C33-C34)	,	GR113-027	,	Lung	,	12	,	75_plus	);

%PoissonSQL(	Hodgkin disease (C81)	,	GR113-038	,	Hodgkin	,	2	,	25_34 	);
%PoissonSQL(	Hodgkin disease (C81)	,	GR113-038	,	Hodgkin	,	3	,	35_44 	);
%PoissonSQL(	Hodgkin disease (C81)	,	GR113-038	,	Hodgkin	,	4	,	45_54 	);
%PoissonSQL(	Hodgkin disease (C81)	,	GR113-038	,	Hodgkin	,	5	,	55_64 	);
%PoissonSQL(	Hodgkin disease (C81)	,	GR113-038	,	Hodgkin	,	6	,	65_74 	);
%PoissonSQL(	Hodgkin disease (C81)	,	GR113-038	,	Hodgkin	,	12	,	75_plus	);
										
%PoissonSQL(	Leukemia (C91-C95)	,	GR113-040	,	Leukemia	,	2	,	25_34 	);
%PoissonSQL(	Leukemia (C91-C95)	,	GR113-040	,	Leukemia	,	3	,	35_44 	);
%PoissonSQL(	Leukemia (C91-C95)	,	GR113-040	,	Leukemia	,	4	,	45_54 	);
%PoissonSQL(	Leukemia (C91-C95)	,	GR113-040	,	Leukemia	,	5	,	55_64 	);
%PoissonSQL(	Leukemia (C91-C95)	,	GR113-040	,	Leukemia	,	6	,	65_74 	);
%PoissonSQL(	Leukemia (C91-C95)	,	GR113-040	,	Leukemia	,	12	,	75_plus	);
										
%PoissonSQL(	Multiple myeloma and immunoproliferative neoplasms (C88,C90)	,	GR113-041	,	Myeloma	,	2	,	25_34 	);
%PoissonSQL(	Multiple myeloma and immunoproliferative neoplasms (C88,C90)	,	GR113-041	,	Myeloma	,	3	,	35_44 	);
%PoissonSQL(	Multiple myeloma and immunoproliferative neoplasms (C88,C90)	,	GR113-041	,	Myeloma	,	4	,	45_54 	);
%PoissonSQL(	Multiple myeloma and immunoproliferative neoplasms (C88,C90)	,	GR113-041	,	Myeloma	,	5	,	55_64 	);
%PoissonSQL(	Multiple myeloma and immunoproliferative neoplasms (C88,C90)	,	GR113-041	,	Myeloma	,	6	,	65_74 	);
%PoissonSQL(	Multiple myeloma and immunoproliferative neoplasms (C88,C90)	,	GR113-041	,	Myeloma	,	12	,	75_plus	);
										
%PoissonSQL(	Non-Hodgkin lymphoma (C82-C85)	,	GR113-039	,	NHL	,	2	,	25_34 	);
%PoissonSQL(	Non-Hodgkin lymphoma (C82-C85)	,	GR113-039	,	NHL	,	3	,	35_44 	);
%PoissonSQL(	Non-Hodgkin lymphoma (C82-C85)	,	GR113-039	,	NHL	,	4	,	45_54 	);
%PoissonSQL(	Non-Hodgkin lymphoma (C82-C85)	,	GR113-039	,	NHL	,	5	,	55_64 	);
%PoissonSQL(	Non-Hodgkin lymphoma (C82-C85)	,	GR113-039	,	NHL	,	6	,	65_74 	);
%PoissonSQL(	Non-Hodgkin lymphoma (C82-C85)	,	GR113-039	,	NHL	,	12	,	75_plus	);
										
/*%PoissonSQL(	Other and unspecified malignant neoplasms of lymphoid hematopoietic and related tissue (C96)	,	GR113-042	,	OtherLymph	,	2	,	25_34 	);*/
/*%PoissonSQL(	Other and unspecified malignant neoplasms of lymphoid hematopoietic and related tissue (C96)	,	GR113-042	,	OtherLymph	,	3	,	35_44 	);*/
/*%PoissonSQL(	Other and unspecified malignant neoplasms of lymphoid hematopoietic and related tissue (C96)	,	GR113-042	,	OtherLymph	,	4	,	45_54 	);*/
/*%PoissonSQL(	Other and unspecified malignant neoplasms of lymphoid hematopoietic and related tissue (C96)	,	GR113-042	,	OtherLymph	,	5	,	55_64 	);*/
/*%PoissonSQL(	Other and unspecified malignant neoplasms of lymphoid hematopoietic and related tissue (C96)	,	GR113-042	,	OtherLymph	,	6	,	65_74 	);*/
/*%PoissonSQL(	Other and unspecified malignant neoplasms of lymphoid hematopoietic and related tissue (C96)	,	GR113-042	,	OtherLymph	,	12	,	75_plus	);*/





/* all_cancers has no age restriction    */
Data Covb_All_Cancers; 
set 
L2_covb_All_Cancers_0_14
L2_covb_All_Cancers_15_24 
L2_covb_All_Cancers_25_34 
L2_covb_All_Cancers_35_44 
L2_covb_All_Cancers_45_54 
L2_covb_All_Cancers_55_64 
L2_covb_All_Cancers_65_74 
L2_covb_All_Cancers_75_plus
;

run; 

/*  Prostate restricted to 35+   */
Data Covb_Prostate; 
set 
L2_covb_Prostate_35_44 
L2_covb_Prostate_45_54 
L2_covb_Prostate_55_64 
L2_covb_Prostate_65_74 
L2_covb_Prostate_75_plus
;
run; 


/*====================================================================*\
Create dataset for the covariance and variance
with ALL age groups combined/concatenated

25+ AGE RESTRICTION
\*====================================================================*/

%macro age25plus (Outdataset);

Data Covb_&Outdataset.; 
set 
L2_covb_&Outdataset._25_34 
L2_covb_&Outdataset._35_44 
L2_covb_&Outdataset._45_54 
L2_covb_&Outdataset._55_64 
L2_covb_&Outdataset._65_74 
L2_covb_&Outdataset._75_plus
;

run; 

%mend age25plus; 

%age25plus(	Other	);
%age25plus(	Skin	);
%age25plus(	Bladder	);
%age25plus(	Breast	);
%age25plus(	Cervix	);
%age25plus(	Esophagus	);
%age25plus(	Larynx	);
%age25plus(	Ovary	);
%age25plus(	Pancreas	);
%age25plus(	Stomach	);
%age25plus(	Colon	);
%age25plus(	Uterus	);
%age25plus(	Kidney	);
%age25plus(	Lip	);
%age25plus(	Liver	);
%age25plus(	Lymphoid	);
%age25plus(	CNS	);
%age25plus(	Lung	);
%age25plus(	Hodgkin	);
%age25plus(	Leukemia	);
%age25plus(	Myeloma	);
%age25plus(	NHL	);
/*%age25plus(	OtherLymph	);*/


/*===================================*\
 Merged (co)Variance dataset with overalldataset
\*===================================*/

%macro CovbMrg (Outdataset);
proc sort data=&Outdataset.; by age_group ; run; 
proc sort data=Covb_&Outdataset.; by age_group  ; run; 


data CovbMrg_&Outdataset. ;
merge &Outdataset. Covb_&Outdataset.;
by age_group;
run; 

%mend CovbMrg; 

%CovbMrg(	All_Cancers	);
%CovbMrg(	Other	);
%CovbMrg(	Skin	);
%CovbMrg(	Bladder	);
%CovbMrg(	Breast	);
%CovbMrg(	Cervix	);
%CovbMrg(	Esophagus	);
%CovbMrg(	Larynx	);
%CovbMrg(	Ovary	);
%CovbMrg(	Pancreas	);
%CovbMrg(	Prostate	);
%CovbMrg(	Stomach	);
%CovbMrg(	Colon	);
%CovbMrg(	Uterus	);
%CovbMrg(	Kidney	);
%CovbMrg(	Lip	);
%CovbMrg(	Liver	);
%CovbMrg(	Lymphoid	);
%CovbMrg(	CNS	);
%CovbMrg(	Lung	);
%CovbMrg(	Hodgkin	);
%CovbMrg(	Leukemia	);
%CovbMrg(	Myeloma	);
%CovbMrg(	NHL	);
/*%CovbMrg(	OtherLymph	);*/





/*====================================================================*\
 Transpose coefficient estimates 
\*====================================================================*/

%macro TransposeEstimate (Title, Outdataset);

data Est_&Outdataset. (keep=age_group Parameter Estimate);
set Est_&Outdataset.;
run; 

proc sort data=Est_&Outdataset.; by age_group Parameter Estimate; run; 
proc transpose data=Est_&Outdataset. out=TranEst_&Outdataset.;
by  age_group  ;
id Parameter; 
var Estimate; 
run;



data TranEst_&Outdataset. (drop=scale _name_);
retain age_group intercept covid19 t sine cosine Sine_Covid19 Cosine_Covid19; 
set TranEst_&Outdataset.;

rename 

Cosine=Coef_cosine

Covid19=Coef_covid19

Sine=Coef_Sine

t=Coef_T

Sine_Covid19=Coef_Sine_Covid19
Cosine_Covid19=Coef_Cosine_Covid19

;


label Sine_Covid19="Coef_Sine*Covid19";
label Cosine_Covid19= "Coef_Cosine*Covid19";
run; 




data MergeC_&Outdataset.;
merge CovbMrg_&Outdataset. TranEst_&Outdataset.;
by age_group;

 
IRR_1=exp(Coef_covid19 + (Coef_Cosine_Covid19*cosine) + (Coef_Sine_Covid19*Sine) ); 

rename
VAR_1vs1_L	=	Intercept_vs_Intercept 
covar_1vs2_L	=	Intercept_vs_b4
covar_1vs3_L	=	Intercept_vs_b1
covar_1vs4_L	=	Intercept_vs_b3
covar_1vs5_L	=	Intercept_vs_b2
covar_1vs6_L	=	Intercept_vs_b6
covar_1vs7_L	=	Intercept_vs_b5
		
VAR_2vs2_L	=	b4_vs_b4
covar_2vs3_L	=	b4_vs_b1
covar_2vs4_L	=	b4_vs_b3
covar_2vs5_L	=	b4_vs_b2
covar_2vs6_L	=	b4_vs_b6
covar_2vs7_L	=	b4_vs_b5
		
VAR_3vs3_L	=	b1_vs_b1
covar_3vs4_L	=	b1_vs_b3
covar_3vs5_L	=	b1_vs_b2
covar_3vs6_L	=	b1_vs_b6
covar_3vs7_L	=	b1_vs_b5
		
VAR_4vs4_L	=	b3_vs_b3_
covar_4vs5_L	=	b3_vs_b2
covar_4vs6_L	=	b3_vs_b6
covar_4vs7_L	=	b3_vs_b5
		
VAR_5vs5_L	=	b2_vs_b2
covar_5vs6_L	=	b2_vs_b6
covar_5vs7_L	=	b2_vs_b5
		
VAR_6vs6_L	=	b6_vs_b6
covar_6vs7_L	=	b6_vs_b5
		
VAR_7vs7_L	=	b5_vs_b5

;

label IRR_1="Incidence Rate Ratios";
run; 








%mend TransposeEstimate; 
%TransposeEstimate(	Malignant neoplasms (C00-C97)	,	All_Cancers	);
%TransposeEstimate(	All other and unspecified malignant neoplasms	,	Other	);
%TransposeEstimate(	Malignant melanoma of skin (C43)	,	Skin	);
%TransposeEstimate(	Malignant neoplasm of bladder (C67)	,	Bladder	);
%TransposeEstimate(	Malignant neoplasm of breast (C50)	,	Breast	);
%TransposeEstimate(	Malignant neoplasm of cervix uteri (C53)	,	Cervix	);
%TransposeEstimate(	Malignant neoplasm of esophagus (C15)	,	Esophagus	);
%TransposeEstimate(	Malignant neoplasm of larynx (C32)	,	Larynx	);
%TransposeEstimate(	Malignant neoplasm of ovary (C56)	,	Ovary	);
%TransposeEstimate(	Malignant neoplasm of pancreas (C25)	,	Pancreas	);
%TransposeEstimate(	Malignant neoplasm of prostate (C61)	,	Prostate	);
%TransposeEstimate(	Malignant neoplasm of stomach (C16)	,	Stomach	);
%TransposeEstimate(	Malignant neoplasms of colon rectum and anus (C18-C21)	,	Colon	);
%TransposeEstimate(	Malignant neoplasms of corpus uteri and uterus  part unspecified (C54-C55)	,	Uterus	);
%TransposeEstimate(	Malignant neoplasms of kidney and renal pelvis (C64-C65)	,	Kidney	);
%TransposeEstimate(	Malignant neoplasms of lip oral cavity and pharynx (C00-C14)	,	Lip	);
%TransposeEstimate(	Malignant neoplasms of liver and intrahepatic bile ducts (C22)	,	Liver	);
%TransposeEstimate(	Malignant neoplasms of lymphoid hematopoietic and related tissue (C81-C96)	,	Lymphoid	);
%TransposeEstimate(	Malignant neoplasms of meninges brain and other parts of central nervous system (C70-C72)	,	CNS	);
%TransposeEstimate(	Malignant neoplasms of trachea bronchus and lung (C33-C34)	,	Lung	);
%TransposeEstimate(	Hodgkin disease (C81)	,	Hodgkin	);
%TransposeEstimate(	Leukemia (C91-C95)	,	Leukemia	);
%TransposeEstimate(	Multiple myeloma and immunoproliferative neoplasms (C88,C90)	,	Myeloma	);
%TransposeEstimate(	Non-Hodgkin lymphoma (C82-C85)	,	NHL	);
/*%TransposeEstimate(	Other and unspecified malignant neoplasms of lymphoid hematopoietic and related tissue (C96)	,	OtherLymph	);*/





/*====================================================================*\
 confidence interval
\*====================================================================*/


%macro IRRci (Outdataset);
data IRRci_&Outdataset.;
set MergeC_&Outdataset.;
where year=2020 and month GE 3;

std= b4_vs_b4 + (b5_vs_b5*(Cosine**2))+(b6_vs_b6*(Sine**2))+(2*b4_vs_b5*Cosine)+(2*b4_vs_b6*Sine)+(2*b6_vs_b5*Cosine*Sine); 



LogIRR=(Coef_covid19 + (Coef_Cosine_Covid19*cosine) + (Coef_Sine_Covid19*Sine) ); 

Lower_limit= exp(LogIRR-1.96*sqrt(std)); 
Upper_limit= exp(LogIRR+1.96*sqrt(std)); 

run; 
proc contents data= MergeC_&Outdataset. ; run; 



data check_IRRci_&Outdataset.(keep=age_group month year ICD_10_113_Cause_List_Code s pi sine cosine covid19 
INTERCEPT Coef_covid19 Coef_T Coef_cosine Coef_Sine Coef_Sine_Covid19 Coef_Cosine_Covid19 IRR_1
Intercept_vs_Intercept 	Intercept_vs_b4	Intercept_vs_b1	Intercept_vs_b3	Intercept_vs_b2	Intercept_vs_b6	Intercept_vs_b5		
b4_vs_b4	b4_vs_b1	b4_vs_b3	b4_vs_b2	b4_vs_b6	b4_vs_b5		b1_vs_b1	b1_vs_b3	b1_vs_b2	b1_vs_b6	
b1_vs_b5		b3_vs_b3_	b3_vs_b2	b3_vs_b6	b3_vs_b5		b2_vs_b2	b2_vs_b6	b2_vs_b5		b6_vs_b6	
b6_vs_b5		b5_vs_b5 std Lower_limit Upper_limit
);

retain age_group month year ICD_10_113_Cause_List_Code s pi sine cosine covid19 
INTERCEPT Coef_covid19 Coef_T Coef_cosine Coef_Sine Coef_Sine_Covid19 Coef_Cosine_Covid19 IRR_1 std Lower_limit Upper_limit; 
set IRRci_&Outdataset.;
run; 


/*only looking at variables needed to check confidence interval calculation   */
data check2_irrCI_&Outdataset.(drop=s pi INTERCEPT covid19 Coef_covid19 Coef_T Coef_cosine Coef_Sine Coef_Sine_Covid19 Coef_Cosine_Covid19
Intercept_vs_Intercept 	Intercept_vs_b4	Intercept_vs_b1	Intercept_vs_b3	Intercept_vs_b2	Intercept_vs_b6	Intercept_vs_b5	
b4_vs_b1	b4_vs_b3	b4_vs_b2 b1_vs_b1	b1_vs_b3	b1_vs_b2	b1_vs_b6	
b1_vs_b5 b3_vs_b3_	b3_vs_b2	b3_vs_b6	b3_vs_b5 b2_vs_b2	b2_vs_b6	b2_vs_b5	);
set check_IRRci_&Outdataset.;
run; 

		
%mend IRRci; 

%IRRci(	All_Cancers	);
%IRRci(	Other	);
%IRRci(	Skin	);
%IRRci(	Bladder	);
%IRRci(	Breast	);
%IRRci(	Cervix	);
%IRRci(	Esophagus	);
%IRRci(	Larynx	);
%IRRci(	Ovary	);
%IRRci(	Pancreas	);
%IRRci(	Prostate	);
%IRRci(	Stomach	);
%IRRci(	Colon	);
%IRRci(	Uterus	);
%IRRci(	Kidney	);
%IRRci(	Lip	);
%IRRci(	Liver	);
%IRRci(	Lymphoid	);
%IRRci(	CNS	);
%IRRci(	Lung	);
%IRRci(	Hodgkin	);
%IRRci(	Leukemia	);
%IRRci(	Myeloma	);
%IRRci(	NHL	);
/*%IRRci(	OtherLymph	);*/


		 











