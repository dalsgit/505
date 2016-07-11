options ls=78;
title "Discriminant Analysis - Insect Data";
data insect;
  infile "x:\505\hw8_insect.dat";
  input species $ joint1 joint2 aedeagus;
  run;
data test;
  input joint1 joint2 aedeagus;
  cards;
194 124 49
;
proc discrim data=insect pool=test crossvalidate testdata=test testout=a;
  class species;
  var joint1 joint2 aedeagus;
  run;
proc print;
  run;
