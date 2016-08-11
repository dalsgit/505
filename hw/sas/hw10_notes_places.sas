options ls=78;
title "Factor Analysis - Maximum Likelihood - Places Rated";
data places;
  infile "x:\505\hw9_places.dat" delimiter='09'x;  /* use hexidecimal code for tab delimiters */ 
  input climate housing health crime trans educate arts recreate econ id;
  climate=log10(climate);
  housing=log10(housing);
  health=log10(health);
  crime=log10(crime);
  trans=log10(trans);
  educate=log10(educate);
  arts=log10(arts);
  recreate=log10(recreate);
  econ=log10(econ);
  run;
proc factor method=ml nfactors=3;
  var climate housing health crime trans educate arts recreate econ;
  run;

