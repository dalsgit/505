options ls=78;
title "Factor Analysis - Pollution";
data pollution;
  infile "x:\505\hw10_pollution.dat";
  input wind solar CO NO NO2 O3 HC;
  run;
proc factor method=principal nfactors=3 rotate=varimax simple scree ev preplot
     plot residuals;
  var wind solar CO NO NO2 O3 HC;
  run;