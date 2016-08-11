options ls=78;
title "Canonical Correlation Analysis - Paper Data";
data paper;
  infile "x:\505\HW11_paper.dat" delimiter='09'x;  /* use hexidecimal code for tab delimiters */ 
  input breaking_length elastic_modulus stress_at_failure burst_strength arithmetic_fiber_length long_fiber_fraction fine_fiber_fraction zero_span_tensile;
  run;
proc cancorr out=canout vprefix=paper vname="Paper Variables" 
                       wprefix=pulp wname="Pulp Variables";
  var breaking_length elastic_modulus stress_at_failure burst_strength;
  with arithmetic_fiber_length long_fiber_fraction fine_fiber_fraction zero_span_tensile;
  run;
proc gplot;
  axis1 length=3 in;
  axis2 length=4.5 in;
  plot paper1*pulp1 / vaxis=axis1 haxis=axis2;
  symbol v=J f=special h=2 i=r color=black;
  run;
proc gplot;
  axis1 length=3 in;
  axis2 length=4.5 in;
  plot paper2*pulp2 / vaxis=axis1 haxis=axis2;
  symbol v=J f=special h=2 i=r color=red;
  run;  