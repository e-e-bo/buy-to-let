/******************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 19.02.2026

Cleaning tax micro data from .sas file and
 exporting to .dta format.
 
Input: .sas files from Statistics Norway
 registers.

Output: tax.dta; tax2004.dta
******************************************/

libname skatt '/data';

/******************
Individual tax data
******************/
data selv2005 (rename=(bel3110=bel3114));
  set skatt.selvh2005 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3110 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr);
  aar=2006;
run;

data selv2006;
  set skatt.selvh2006 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr);
  aar=2007;
run;

data selv2007;
  set skatt.selvh2007 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr);
  aar=2008;
run;

data selv2008;
  set skatt.selvh2008 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr);
  aar=2009;
run;

data selv2009;
  set skatt.selvh2009 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr);
  aar=2010;
run;

data selv2010;
  set skatt.selvh2010 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel432_1 bel432_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr rename=(bel432_1=bel43_1 bel432_2=bel43_2));
  aar=2011;
run;

data selv2011;
  set skatt.selvh2011 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel432_1 bel432_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr rename=(bel432_1=bel43_1 bel432_2=bel43_2));
  aar=2012;
run;

data selv2012;
  set skatt.selvh2012 (keep=fnr kjonn bokomnr bel21_1 bel28_2 bel29 bel3114 bel34 bel41_1 bel432_1 bel432_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr rename=(bel432_1=bel43_1 bel432_2=bel43_2));
  aar=2013;
run;

data selv;
  set selv2005
      selv2006
      selv2007
      selv2008
      selv2009
      selv2010
      selv2011
      selv2012;
run;

*Export to Stata;
PROC EXPORT DATA=selv
            OUTFILE= "data/tax.dta"
            DBMS=STATA REPLACE;
RUN;

*Extra year of tax data;
data selv2004 (rename=(bel3110=bel3114));
  set skatt.selvh2004 (keep=fnr kjonn bokomnr bel21_1 bel28_4 bel29 bel3110 bel34 bel41_1 bel43_1 bel43_2 bel47 bel48_4 a_b_u18
   ant_i_h studhus hushnr);
  aar=2005;
run;

*Export to Stata;
PROC EXPORT DATA=selv2004
            OUTFILE= "data/tax2004.dta"
            DBMS=STATA REPLACE;
RUN;
