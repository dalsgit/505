data corp;
  infile "x:\505\hw1_corporations.dat" delimiter='09'x;
  input name :$20. sales profits assets;
  run;
proc means;
	var sales profits assets;
	run;