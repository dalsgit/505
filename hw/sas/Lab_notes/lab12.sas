/*
The data to be analyzed comes from a firm that surveyed a random sample of n = 50
  of its employees in an attempt to determine what factors influence sales performance.
  Two collections of variables were measured:

Sales Performance:
        Sales Growth
        Sales Profitability
        New Account Sales
Test Scores as a Measure of Intelligence:
        Creativity
        Mechanical Reasoning
        Abstract Reasoning
        Mathematics
*/
options ls=78 nodate nonumber;
data sales;
  infile "v:\505\datasets\sales.dat";
  input growth profit new create mech abs math;
  run;
proc corr data=sales out=corr_out cov noprob;
  var growth profit new create mech abs math;
  run;
proc iml;
  use corr_out;
  read all var _NUM_ where(_TYPE_="N") into n;
  n=n[1];
  read all var _NUM_ where(_TYPE_="COV") into s;
  *read all var _NUM_ where(_TYPE_="CORR") into s;
  s11=s[1:3,1:3];
  s12=s[1:3,4:7];
  s21=s[4:7,1:3];
  s22=s[4:7,4:7];

  x=inv(s11)*s12*inv(s22)*s21;
  rho2x=eigval(x)[,1];
  rhox=sqrt(rho2x); *canonical correlations;
  a=eigvec(x);
  a1=a[,1]/sqrt(t(a[,1])*s11*a[,1]);
  a2=a[,2]/sqrt(t(a[,2])*s11*a[,2]);
  a3=a[,3]/sqrt(t(a[,3])*s11*a[,3]);
  a=a1||a2||a3; *coefficient matrix A for U=AX;
  print rhox rho2x a;

  y=inv(s22)*s21*inv(s11)*s12;
  rho2y=abs(eigval(y)[,1]);
  rhoy=sqrt(rho2y);
  b=eigvec(y);
  b1=b[,1]/sqrt(t(b[,1])*s22*b[,1]);
  b2=b[,2]/sqrt(t(b[,2])*s22*b[,2]);
  b3=b[,3]/sqrt(t(b[,3])*s22*b[,3]);
  b=b1||b2||b3;
  print rhoy rho2y b;

  p=3;
  q=4;
  i=2; *number of nonzero canonical correlations;
  df1=(p-i)*(q-i);
  bart=-(n-1-(p+q+1)/2)*log(prod(1-rho2x[i+1:p])); *authors test stat;
  bart_p = 1-probchi(bart,df1);
  
  if ((p-i)**2+(q-i)**2)<=5 then m=1;
    else m=sqrt( ((p-i)**2*(q-i)**2-4)/((p-i)**2+(q-i)**2-5) );
  df2=m*(n-(p+q+3)/2)-(df1-2)/2;
  rao=(1-prod(1-rho2x[i+1:p])**(1/m))/prod(1-rho2x[i+1:p])**(1/m)*(df2/df1); *sas test stat;
  rao_p = 1-probf(rao,df1,df2);
  print n df1 df2 bart bart_p rao rao_p;
  quit;

proc cancorr data=sales out=canout vprefix=sales vname="Sales Variables"
                       wprefix=scores wname="Test Scores";
  var growth profit new; *group of x-variables;
  with create mech abs math; *group of y-variables;
  run;
proc gplot data=canout;
  axis1 length=3 in;
  axis2 length=4.5 in;
  plot sales1*scores1 / vaxis=axis1 haxis=axis2; *first cancorr pair;
  symbol v=J f=special h=2 i=r color=black;
  run;

/*
  
Structural variables:
  penet - percentage of households making at least one category purchase
  pcycle - average interpurchase time
  price - average dollars spent in the category per purchase occasion
  pvtsh - combined market share for all private-label and generic products
  purhh - average number of purchase occasions per household during the year
Promotional variables:
  feat - percent of volume sold on feature
  disp - percent of volume sold on display
  pcut - percent of volume sold at a temporary reduced price
  scoup - percent of volume purchased using a retailers store coupon
  mcoup - percent of volume purchased using a manufacturers coupon
*/

data factbook; *original data;
  infile 'v:\505\datasets\factbook.dat';
  input type $ penet pcycle price pvtsh purhh feat disp pcut scoup mcoup;
  run;
data factbook1; *every odd numbered observation;
  infile 'v:\505\datasets\factbook1.dat';
  input type $ penet pcycle price pvtsh purhh feat disp pcut scoup mcoup;
  run;
data factbook2; *every even numbered observation;
  infile 'v:\505\datasets\factbook2.dat';
  input type $ penet pcycle price pvtsh purhh feat disp pcut scoup mcoup;
  run;
proc cancorr data=factbook 
	vprefix=struct vname="Structure Variables"
	wprefix=promo wname="Promotional Variables";
  var penet pcycle price pvtsh purhh;
  with feat disp pcut scoup mcoup;
  run;
*calibration data set, the scores represent the u-variables;
proc cancorr data=factbook1 out=scores1 outstat=stats1 
	vprefix=struct vname="Structure Variables"
	wprefix=promo wname="Promotional Variables";
  var penet pcycle price pvtsh purhh;
  with feat disp pcut scoup mcoup;
  run;
*validation data set, 
  scores here applied to calibration data represent u'-variables;
proc cancorr data=factbook2 out=scores2 outstat=stats2 
	vprefix=struct vname="Structure Variables"
	wprefix=promo wname="Promotional Variables";
  var penet pcycle price pvtsh purhh;
  with feat disp pcut scoup mcoup;
  run;
proc iml;
* getting coefficients from calibration data;
  use stats1; *outstat from calibration data;
  read all var {penet pcycle price pvtsh purhh} where(_TYPE_="SCORE") into aa;
  read all var {feat disp pcut scoup mcoup} where(_TYPE_="SCORE") into bb;
  aa=t(aa[1:3,]); *just significant coefficients for x-variables;
  bb=t(bb[6:8,]); *just significant coefficients for y-variables;
  print aa bb;

* getting coefficients from validation data;
  use stats2; *outstat from validation data;
  read all var {penet pcycle price pvtsh purhh} where(_TYPE_="SCORE") into a;
  read all var {feat disp pcut scoup mcoup} where(_TYPE_="SCORE") into b;
  a=t(a[1:3,]); *just significant coefficients for x-variables;
  b=t(b[6:8,]); *just significant coefficients for y-variables;
  print a b;

* getting calibration data and standardizing;
  use scores1;
  read all var {penet pcycle price pvtsh purhh} into x;
  read all var {feat disp pcut scoup mcoup} into y;
  use stats1;
  read all var {penet pcycle price pvtsh purhh} where(_TYPE_="MEAN") into xbar;
  read all var {penet pcycle price pvtsh purhh} where(_TYPE_="STD") into sx;
  read all var {feat disp pcut scoup mcoup} where(_TYPE_="MEAN") into ybar;
  read all var {feat disp pcut scoup mcoup} where(_TYPE_="STD") into sy;
  zx=(x-xbar)/sx; *standardized x-variables;
  zy=(y-ybar)/sy; *standardized y-variables;
  
* applying the validation coefficients to the calibration data;
  u_val=zx*a;
  v_val=zy*b;
  u=zx*aa;
  v=zy*bb;
  
  combined=u||u_val||v||v_val;
  uvcorrs=corr(combined); 
  ucorrs=uvcorrs[1:3,4:6];
  vcorrs=uvcorrs[7:9,10:12];
  print ucorrs vcorrs;

  quit;
