Grouping monthly checking account into clusters by year

github
https://tinyurl.com/yaqvr9tj
https://github.com/rogerjdeangelis/utl_grouping_monthly_checking_account_into_two_clusters_by_year

  Three examples

     1. Kmeans grouping of months by year

   On end
     2. Proc cluster on a very skewed distribution.
     3. Kmeans grouping on a very skewed distribution.


StackOverflow R
https://tinyurl.com/yav6wyat
https://stackoverflow.com/questions/49250159/using-kmeans-within-an-apply-function-in-r


INPUT
=====

 SD1.HAVE total obs=6

   YEAR    JAN    FEB    MAR    APR    MAY    JUN     JUL     AUG     SEP     OCT     NOV     DEC

   1901      1      2      3      4      5      6     -10     -11     -12     -13     -14     -15
   1901      1     11      2     12      3     13       4      14       5      15       6      17

   1902     12     14     16     18     20     22      52      54      56      58      60      62  *CHECK

   1903    300    800    301    891    302    802     303     803     304     804     305     805
   1904      1      1      1      1      1      1       2       2       2       2       2       2
   1905      0      1      3      3      1      0      10      11      13      13      11      10


   Here is what 1902 looks like. We expect two clusters.

   Stem Leaf
      6 02
      5 2468
      4
      3
      2 02
      1 2468
        ----+----+----+----+
    Multiply Stem.Leaf by 10**+1


  SD1.WANT

  YEAR   JAN    FEB    MAR    APR    MAY    JUN     JUL     AUG     SEP     OCT     NOV     DEC

  1902    12     14     16     18     20     22      52      54      56      58      60      62

 Cluster   1      1      1      1      1      1       2       2       2       2       2       2  * OK


PROCESS  (Working Code)
========================

   kmean<-apply(as.matrix(have), 1,  function(x) {kmeans(x, 2)});  * could reshape in SAS;
   want<-as.data.frame(do.call(rbind, lapply(1:length(kmean), function(x) kmean[[x]]$cluster)));


OUTPUT
======

 WORK.WANT total obs=6

  Obs    JAN    FEB    MAR    APR    MAY    JUN    JUL    AUG    SEP    OCT    NOV    DEC

   1      1      1      1      1      1      1      2      2      2      2      2      2
   2      2      1      2      1      2      1      2      1      2      1      2      1

   3      1      1      1      1      1      1      2      2      2      2      2      2

   4      2      1      2      1      2      1      2      1      2      1      2      1
   5      2      2      2      2      2      2      1      1      1      1      1      1
   6      2      2      2      2      2      2      1      1      1      1      1      1

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
  retain year 0;
  input jan feb mar apr may jun jul aug sep oct nov dec;
  year=1900+_n_;
cards4;
1 2 3 4 5 6 -10 -11 -12 -13 -14 -15
1  11 2  12 3 13 4 14  5  15 6 17
12 14 16 18 20 22 52 54 56 58 60 62
300 800 301 891 302 802 303 803 304 804 305 805
1 1 1 1 1 1 2 2 2 2 2 2
0 1 3 3 1 0 10 11 13 13 11 10
;;;;
run;quit;
*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.1";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.1/etc/Rprofile.site", echo=T);
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat")[,-1];
names(have);
kmean<-apply(as.matrix(have), 1,  function(x) {kmeans(x, 2)});
want<-as.data.frame(do.call(rbind, lapply(1:length(kmean), function(x) kmean[[x]]$cluster)));
names(want)<-names(have);
want;
endsubmit;
import r=want data=wrk.want;
run;quit;
');

proc print data=want;
run;quit;


/* T1005300 StackOverflow SAS: Bucket a continuous variable into 5 distinct clusters

Lets say I have 500 numbers with 302 1s, 120 2s and a bunch of other values that range
from 3 to 15

WORKING CODE
============

  SAS

      proc standard data=sd1.have mean=0 std=1 out=stan;
        var x;
      proc fastclus data=stan out=clust maxclusters=5;
        var x;

  WPS/R

      fit <- kmeans(x, 5);
      aggregate(x,by=list(fit$cluster),FUN=mean);
      want <- data.frame(have, fit$cluster);

I am very rusty with cluster analysis.
Very similar results from R and SAS with one slight differance.
I may have done something wrong (SAS and R using the same methods?)

R places X values 1 and 2 (the big groups) into one cluster
SAS places X values 1,2 and 3(small group) into one cluster

R looks alittle beter balanced but probably insignificant?

see
https://goo.gl/mXl9nM
https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_fastclus_sect016.htm


HAVE
====

The FREQ Procedure

                               Cumulative
 X    Frequency     Percent     Frequency
-------------------------------------------
 1         224       44.80           224
 2         198       39.60           422
 3           6        1.20           428
 4           6        1.20           434
 5           6        1.20           440
 6           6        1.20           446
 7           6        1.20           452
 8           6        1.20           458
 9           6        1.20           464
10           6        1.20           470
11           6        1.20           476
12           6        1.20           482
13           6        1.20           488
14           6        1.20           494
15           6        1.20           500

OBSERVATIONS FOR FREQUENCY ABOVE

Up to 40 obs SD1.HAVE total obs=500

Obs    REC    X

 1      1    4
 2      2    5
 3      3    6
 4      4    7
 5      5    8
 6      6    9
 7      7   10
 8      8   11
...
79     79    1
80     80    1
81     81    1
82     82    1
83     83    1
84     84    1
85     85    1
86     86    1

496   496    2
497   497    2
498   498    2
499   499    2
500   500    2


WANT
====

SAS


Up to 40 obs from wantwps total obs=500

The FREQ Procedure


CLUSTER     X    Frequency     Percent
-----------------------------------------
      1     1         224       44.80
      1     2         198       39.60
      1     3           6        1.20

      3    10           6        1.20
      3    11           6        1.20
      3    12           6        1.20
      3    13           6        1.20

      4     7           6        1.20
      4     8           6        1.20
      4     9           6        1.20

      5     4           6        1.20
      5     5           6        1.20
      5     6           6        1.20

      2    14           6        1.20
      2    15           6        1.20

WPS/R

FIT
CLUSTER     X    Frequency     Percent
---------------------------------------
      3     1         224       44.80
      3     2         198       39.60

      5     6           6        1.20
      5     7           6        1.20
      5     8           6        1.20
      5     9           6        1.20

      1     3           6        1.20
      1     4           6        1.20
      1     5           6        1.20

      2    13           6        1.20
      2    14           6        1.20
      2    15           6        1.20

      4    10           6        1.20
      4    11           6        1.20
      4    12           6        1.20

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|
;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;

 do rec=1 to 78;
   x=mod(rec,13) +3;
   y=mod(rec,13) +3;
   output;
 end;

 do rec=79 to 302;
   x=1;
   y=1;
   output;
 end;

 do rec=303 to 500;
   x=2;
   y=2;
   output;
 end;

run;quit;

*____    _    ____              _       _   _
/ ___|  / \  / ___|   ___  ___ | |_   _| |_(_) ___  _ __
\___ \ / _ \ \___ \  / __|/ _ \| | | | | __| |/ _ \| '_ \
 ___) / ___ \ ___) | \__ \ (_) | | |_| | |_| | (_) | | | |
|____/_/   \_\____/  |___/\___/|_|\__,_|\__|_|\___/|_| |_|
;

proc standard data=sd1.have mean=0 std=1 out=stan;
   var x;
run;

proc fastclus data=stan out=clust maxclusters=5;
   var x;
run;

proc freq data=clust;
tables y*cluster /list;
run;quit;

*_        ______  ____    ______              _       _   _
\ \      / /  _ \/ ___|  / /  _ \   ___  ___ | |_   _| |_(_) ___  _ __
 \ \ /\ / /| |_) \___ \ / /| |_) | / __|/ _ \| | | | | __| |/ _ \| '_ \
  \ V  V / |  __/ ___) / / |  _ <  \__ \ (_) | | |_| | |_| | (_) | | | |
   \_/\_/  |_|   |____/_/  |_| \_\ |___/\___/|_|\__,_|\__|_|\___/|_| |_|
;

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk "%sysfunc(pathname(work))";
libname hlp "C:\Program Files\SASHome\SASFoundation\9.4\core\sashelp";
proc r;
submit;
source("c:/Program Files/R/R-3.3.2/etc/Rprofile.site",echo=T);
library(haven);
have<-read_sas("d:/sd1/have.sas7bdat");
x<-have$X;
table(x);
x <- scale(x);
fit <- kmeans(x, 5);
aggregate(x,by=list(fit$cluster),FUN=mean);
want <- data.frame(have, fit$cluster);
endsubmit;
import r=want data=wrk.wantwps;
');

proc freq data=wantwps order=freq;
tables fit_cluster*x/list;
run;quit;


