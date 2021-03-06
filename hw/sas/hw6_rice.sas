options ls=78;
title "Two-Way MANOVA: Rice Data";
data rice;
  infile "x:\505\hw6_rice.txt";
  input block variety $ height tillers;
  run;
proc glm;
  class block variety;
  model height tillers=block variety;
  lsmeans variety;
  manova h=variety / printe printh;
  run;
