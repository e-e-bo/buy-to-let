/*******************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 18.02.2026

Cleaning data from .sas file and exporting 
 to .dta format.
 
Input: .sas files from Statistics Norway 
 registers.

output: housingid.dta; housingid_oslo.dta.
*******************************************/

libname skatt '/data';

data housingid (drop=matrikkelenhetid);
  set skatt.gabba (keep=matrikkelenhetid kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr gaardsnr bruksnr seksjonsnr leilighetsnr);
  where same and matrikkelenhetid ne .;
run;

*Export to Stata;
PROC EXPORT DATA=housingid
            OUTFILE= "/data/housingid.dta"
            DBMS=STATA REPLACE;
RUN;


* Only Oslo
data housingid_oslo (drop=matrikkelenhetid kommunenr);
  set skatt.gabba (keep=matrikkelenhetid kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr gaardsnr bruksnr seksjonsnr leilighetsnr);
  where kommunenr = '0301';
  where same and matrikkelenhetid ne .;
run;

*Export to Stata;
PROC EXPORT DATA=housingid_oslo
            OUTFILE= "/data/wk24/housingid_oslo.dta"
            DBMS=STATA REPLACE;
RUN;
