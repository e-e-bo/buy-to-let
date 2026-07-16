/******************************************
Adapted from prep/Export_taxdata.sas
Written by Erlend Eide Bø // eeb@ssb.no

Cleaning tax micro data from .sas file and
 exporting to .dta format.

Original input: skatt.selvh2005 / skatt.selvh2006,
 confidential Statistics Norway tax registers
 reached via `libname skatt '/data'`.

Jenner-check adaptation: the confidential
 registers are replaced by small inline
 samples (selvh2005, selvh2006) with the same
 columns the script reads. The RENAME-on-SET
 (bel3110 -> bel3114 for the 2005 vintage, so
 the two years stack cleanly), the per-year
 `aar=` tag, and the vertical SET stacking are
 all unchanged from upstream.

Output: tax.dta
******************************************/

data selvh2005;
  input fnr kjonn $ bokomnr bel21_1 bel28_2 bel29 bel3110 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18 ant_i_h studhus $ hushnr;
  datalines;
10001 M 301 120000 0 15000 45000 2000 380000 12000 0 5000 1200 0 2 N 5001
10002 K 301 95000 3000 8000 0 1500 210000 0 0 3000 800 1 1 J 5002
10003 M 1103 145000 0 22000 0 3200 410000 18000 500 6000 1500 0 3 N 5003
10004 K 301 88000 0 5000 12000 900 195000 0 0 2200 600 0 1 N 5004
10005 M 301 210000 0 40000 0 5100 520000 25000 0 8000 2100 2 4 N 5005
;
run;

data selv2005 (rename=(bel3110=bel3114));
  set selvh2005 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3110 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr);
  aar=2006;
run;

data selvh2006;
  input fnr kjonn $ bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18 ant_i_h studhus $ hushnr;
  datalines;
10001 M 301 125000 0 15500 46000 2050 385000 12200 0 5100 1220 0 2 N 5001
10002 K 301 97000 3100 8200 0 1520 214000 0 0 3050 810 1 1 J 5002
10003 M 1103 148000 0 22300 0 3250 415000 18300 520 6100 1520 0 3 N 5003
10004 K 301 90000 0 5100 12200 910 198000 0 0 2250 610 0 1 N 5004
10005 M 301 214000 0 40500 0 5150 525000 25300 0 8100 2130 2 4 N 5005
;
run;

data selv2006;
  set selvh2006 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr);
  aar=2007;
run;

data selv;
  set selv2005
      selv2006;
run;

*Export to Stata;
PROC EXPORT DATA=selv
            OUTFILE= "./tax.dta"
            DBMS=STATA REPLACE;
RUN;

proc print data=selv;
run;

proc means data=selv n mean;
  var bel21_1 bel29 bel41_1;
  class aar;
run;
