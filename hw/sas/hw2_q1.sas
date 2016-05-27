title "Example: Marsh - Descriptive Statistics";
data marsh;
	infile "x:\505\hw2_marsh.txt";
	input station $ lon lat thg mehg turbid tpw fish;
L_lon = log(lon);
S_lon = lon**.5;
S_S_lon = lon**.25;

L_lat = log(lat);
S_lat = lat**.5;
S_S_lat = lat**.25;

L_thg = log(thg);
S_thg = thg**.5;
S_S_thg = thg**.25;

L_mehg = log(mehg);
S_mehg = mehg**.5;
S_S_mehg = mehg**.25;

L_turbid = log(turbid);
S_turbid = turbid**.5;
S_S_turbid = turbid**.25;

L_tpw = log(tpw);
S_tpw = tpw**.5;
S_S_tpw = tpw**.25;

L_fish = log(fish);
S_fish = fish**.5;
S_S_fish = fish**.25;
run;

proc univariate data=marsh;
histogram thg mehg turbid tpw fish L_thg S_thg S_S_thg L_mehg S_mehg S_S_mehg L_turbid S_turbid S_S_turbid L_tpw S_tpw S_S_tpw L_fish S_fish S_S_fish;
run;

proc sgscatter data=marsh;
  title "Scatterplot Matrix";
  matrix L_thg L_mehg L_turbid L_tpw S_S_fish;
run;

proc corr data=marsh plots(maxpoints=75000)=matrix;
	var L_thg L_mehg L_turbid L_tpw S_S_fish;
run;
