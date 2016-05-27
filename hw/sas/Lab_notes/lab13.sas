/*
We will illustrate the various methods of cluster 
analysis using ecological data from Woodyard Hammock, 
a beech-magnolia forest in northern Florida. The data 
involve counts of the numbers of trees of each species 
in n = 72 sites. A total of 31 species were identified 
and counted, however, only p = 13 most common species 
were retained and are listed below. They are:

carcar	Carpinus caroliniana	Ironwood
corflo	Cornus florida	Dogwood
faggra	Fagus grandifolia	Beech
ileopa	Ilex opaca	Holly
liqsty	Liquidambar styraciflua	Sweetgum
maggra	Magnolia grandiflora	Magnolia
nyssyl	Nyssa sylvatica	Blackgum
ostvir	Ostrya virginiana	Blue Beech
oxyarb	Oxydendrum arboreum	Sourwood
pingla	Pinus glabra	Spruce Pine
quenig	Quercus nigra	Water Oak
quemic	Quercus michauxii	Swamp Chestnut Oak
symtin	Symplocus tinctoria	Horse Sugar
*/

options ls=78;
data wood;
infile 'x:\wood.dat';
*infile 'v:\505\datasets\wood.dat';
  input x y acerub carcar carcor cargla cercan corflo faggra frapen
        ileopa liqsty lirtul maggra magvir morrub nyssyl osmame ostvir 
        oxyarb pingla pintae pruser quealb quehem quenig quemic queshu quevir 
        symtin ulmala araspi cyrrac;
  ident=_n_; *creates an id number for each site;
  drop acerub carcor cargla cercan frapen lirtul magvir morrub osmame pintae
       pruser quealb quehem queshu quevir ulmala araspi cyrrac;
  run;
proc sort data=wood;
  by ident;
  run;
/* 
  pca as exploratory technique:
  if the first two princomps explain large percent of the variability,
  can plot them to see roughly how many clusters are present
*/
proc princomp data=wood cov out=pca_out;
  var carcar corflo faggra ileopa liqsty maggra nyssyl ostvir oxyarb 
      pingla quenig quemic symtin;
  run;
proc gplot data=pca_out;
  axis1 length=5 in;
  axis2 length=5 in;
  plot prin2*prin1 / vaxis=axis1 haxis=axis2;
  symbol v=J f=special h=2 i=none color=black;
  run;

proc cluster data=wood method=ward outtree=clust1;
  var carcar corflo faggra ileopa liqsty maggra nyssyl ostvir oxyarb 
      pingla quenig quemic symtin;
  id ident;
  run;
/* 
  other methods considered as well (ward's seems preferable)
  link to plots: https://onlinecourses.science.psu.edu/stat505/node/144
*/
proc tree data=clust1 nclusters=4 out=clust2;
  id ident;
  run;
proc sort data=clust2;
  by ident;
  run;
data combine; *combines original observations with their cluster assignments;
  merge wood clust2;
  by ident;
  run;
proc glm data=combine;
  class cluster;
  model carcar corflo faggra ileopa liqsty maggra nyssyl ostvir oxyarb 
        pingla quenig quemic symtin = cluster;
  means cluster;
  run; quit;
/* 
  summary of means online: 
  https://onlinecourses.science.psu.edu/stat505/node/146
*/

* k-means procedure;
proc fastclus data=wood maxclusters=4 maxiter=100 out=clust replace=random;
*proc fastclus data=wood maxclusters=4 maxiter=100 out=clust radius=20;
  var carcar corflo faggra ileopa liqsty maggra nyssyl ostvir oxyarb 
      pingla quenig quemic symtin;
  id ident;
  run;
proc glm data=clust;
  class cluster;
  model carcar corflo faggra ileopa liqsty maggra nyssyl ostvir oxyarb 
        pingla quenig quemic symtin = cluster;
  means cluster;
  run; quit;

* comparison between discriminant and cluster analysis (lab9);
data insect;
  infile "v:\505\datasets\insect.dat";
  input species $ joint1 joint2 aedeagus;
  ident=_n_;
  run;
proc princomp cov out=pca2;
  var joint1 joint2 aedeagus; 
  run;
proc gplot data=pca2;
  axis1 length=5 in;
  axis2 length=5 in;
  plot prin2*prin1 / vaxis=axis1 haxis=axis2;
  symbol v=J f=special h=2 i=none color=black;
  run;

* discrim builds rule from known insect types;
proc discrim data=insect pool=test testdata=insect crossvalidate testout=b;
  class species;
  var joint1 joint2 aedeagus;
  priors 'a'=1 'b'=1;
  run;
proc print data=b;
  run;

* cluster builds rule from spatial separation on the variables;
proc cluster data=insect method=ward outtree=clust3;
  var joint1 joint2 aedeagus;
  id ident;
  run;
proc tree data=clust3 nclusters=2 out=clust4;
  id ident;
  run;
proc sort data=clust4;
  by ident;
  run;
data combine2;
  merge insect clust4;
  by ident;
  run;
proc print data=combine2;
  var species cluster;
  run;
proc freq data=combine2;
  tables species*cluster / nocol;
  run; quit;
