options ls=78;
title 'Cluster Analysis - Woodyard Hammock - Complete Linkage';
data wood;
  infile 'x:\505\hw12_wood.txt';
  input x y acerub carcar carcor cargla cercan corflo faggra frapen
        ileopa liqsty lirtul maggra magvir morrub nyssyl osmame ostvir 
        oxyarb pingla pintae pruser quealb quehem quenig quemic queshu quevir 
        symtin ulmala araspi cyrrac;
  ident=_n_;
  drop acerub carcor cargla cercan frapen lirtul magvir morrub osmame pintae
       pruser quealb quehem queshu quevir ulmala araspi cyrrac;
  run;
proc sort;
  by ident;
proc cluster method=complete outtree=clust1;
  var carcar corflo faggra ileopa liqsty maggra nyssyl ostvir oxyarb 
      pingla quenig quemic symtin;
  id ident;
  run;
proc tree horizontal nclusters=6 out=clust2;
  id ident;
  run;
proc sort;
  by ident;
  run;
proc print;
  run;
data combine;
  merge wood clust2;
  by ident;
  run;
proc glm;
  class cluster;
  model carcar corflo faggra ileopa liqsty maggra nyssyl ostvir oxyarb 
        pingla quenig quemic symtin = cluster;
  means cluster;
  run;