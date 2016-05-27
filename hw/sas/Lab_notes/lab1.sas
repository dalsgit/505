options nodate ls=78; 
	*suppress date and set printer linesize to 78;

/* 

various comments

*/

title '505 lab, 8/29'; 
	*page title;

data temp; 
	*defines temporary dataset temp;
	*also stands for work.temp;
input v1 v2 v3 $ @@; 
	*$ tells sas that v3 is not numerical;
	*@@ allows for multiple v1 v2 v3 inputs on same line;
	*datalines is alternate word for cards;
s_v1 = v1**.5; 
	*s_v1 is the sqrt of v1;
cards; 
1 2 a 3 4 b 5 6 c
; 
run;

data temp2;
set temp;
	*uses the existing dataset temp;
ss_v1 = v1**.25;
l_v1 = log(v1);
e_v1 = exp(v1);
	*these new variables will be added to temp2, along with all the variables from temp
run;

proc print data=temp2;
var v1 ss_v1 l_v1 e_v1;
	*prints just the specified variable;
run;

data nutrient;
infile 'v:\505\datasets\nutrient.txt';
	*reads the data from the nutrient.txt file into a dataset called nutrient;
input id calcium iron protein vitA vitC;
l_cal = log(calcium);
s_cal = calcium*f*.5;
ss_cal = calcium**.25;
run;

ods graphics on;
*ods pdf file='v:\505\temp.pdf';
proc univariate data=nutrient;
histogram calcium s_cal ss_cal l_cal;
run;
*ods pdf close;

*ods pdf file='v:\505\temp2.pdf';
proc corr data=nutrient noprob plots(maxpoints=75000)=matrix;
	*noprob suppresses the p-values for the correlations;
	*maxpoints=75000 overrides the existing max points for plotting;
run;
*ods pdf close;
ods graphics off;

libname stat505 'v:\505\datasets';
	*defines a library associated with the folder datasets;
	*datasets created here will not be deleted at the end of the sas session;
data stat505.temp;
	*prefix stat505 directs to datasets folder;
input v1 v2;
cards; 
1 2
3 4
; 
run;
