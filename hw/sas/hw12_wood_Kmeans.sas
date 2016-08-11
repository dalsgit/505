options ls=78;
title 'Cluster Analysis - Woodyard Hammock - KMeans';
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
  by ident;
proc fastclus maxclusters=4 radius=20 maxiter=100 out=clust;
  var carcar corflo faggra ileopa liqsty maggra nyssyl ostvir oxyarb 
      pingla quenig quemic symtin;
  id ident;
  run;