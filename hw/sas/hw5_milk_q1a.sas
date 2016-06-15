options ls=78;
title "2-Sample Hotellings T2 - Milk Truck Cost";
data milk;
  infile "x:\505\hw5_milk.dat";
  input fuelCost repairCost capitalCost truckType $;
  run;
proc iml;
  start hotel2;
    n1=nrow(x1);
    n2=nrow(x2);
    k=ncol(x1);
    one1=j(n1,1,1);
    one2=j(n2,1,1);
    ident1=i(n1);
    ident2=i(n2);
    ybar1=x1`*one1/n1;
    s1=x1`*(ident1-one1*one1`/n1)*x1/(n1-1.0);
    print n1 ybar1;
    print s1;
    ybar2=x2`*one2/n2;
    s2=x2`*(ident2-one2*one2`/n2)*x2/(n2-1.0);
    print n2 ybar2;
    print s2;
    spool=((n1-1.0)*s1+(n2-1.0)*s2)/(n1+n2-2.0);
    print spool;
    t2=(ybar1-ybar2)`*inv(spool*(1/n1+1/n2))*(ybar1-ybar2);
    f=(n1+n2-k-1)*t2/k/(n1+n2-2);
    df1=k;
    df2=n1+n2-k-1;
    p=1-probf(f,df1,df2);
    print t2 f df1 df2 p;
  finish;
  use milk;
    read all var{fuelCost repairCost capitalCost} where (truckType="gasoline") into x1;
    read all var{fuelCost repairCost capitalCost} where (truckType="diesel") into x2;
  run hotel2;
  