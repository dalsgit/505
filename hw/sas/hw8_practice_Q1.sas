options ls=78;
title "IRIS Data";
data iris;
  infile "x:\505\hw8_practice_iris.dat";
  input slength swidth plength pwidth type;
  run;
proc print;
  run;
proc glm data=iris;
	class type;
	model swidth pwidth = type / clparm alpha=.00833;
	estimate '1 vs 2' type 1 -1 0;
	estimate '1 vs 3' type 1 0 -1;
	estimate '2 vs 3' type 0 1 -1;
	manova h=type / printe printh;
	lsmeans type / stderr;
	run; quit;