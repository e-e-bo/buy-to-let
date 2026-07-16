/*******************************************
Adapted from prep/Export_housingid.sas
Written by Erlend Eide Bø // eeb@ssb.no

Cleaning data from .sas file and exporting
 to .dta format.

Original input: skatt.gabba, a confidential
 Statistics Norway property register reached
 via `libname skatt '/data'`.

Jenner-check adaptation: the confidential
 register is replaced by a small inline
 `gabba` sample with the same columns the
 script reads (matrikkelenhetid, kommunenr,
 gate_gaardsnr, hus_bruksnr, bokstav_festenr,
 gaardsnr, bruksnr, seksjonsnr, leilighetsnr,
 same) so the DATA step / WHERE / PROC EXPORT
 logic below is unchanged from upstream.

output: housingid.dta; housingid_oslo.dta.
*******************************************/

data gabba;
  length kommunenr $4 gate_gaardsnr $4 hus_bruksnr $4 bokstav_festenr $1
         gaardsnr $5 bruksnr $4 seksjonsnr $3 leilighetsnr $8;
  input matrikkelenhetid kommunenr $ gate_gaardsnr $ hus_bruksnr $
        bokstav_festenr $ gaardsnr $ bruksnr $ seksjonsnr $ leilighetsnr $
        same;
  datalines;
100001 0301 0102 0004 . 00102 0004 001 . 1
100002 0301 0210 0011 A 00210 0011 . . 1
100003 0301 0301 0022 . 00301 0022 002 . 1
100004 1103 0044 0002 . 00044 0002 . . 1
100005 0301 0455 0007 B 00455 0007 001 0001 1
100006 1201 0512 0015 . 00512 0015 . . 1
100007 0301 0601 0033 . 00601 0033 003 . 1
100008 0301 0702 0009 . 00702 0009 . . 1
100009 3005 0810 0021 . 00810 0021 . . 1
100010 0301 0915 0044 C 00915 0044 001 0002 1
;
run;

data housingid (drop=matrikkelenhetid);
  set gabba (keep=matrikkelenhetid kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr gaardsnr bruksnr seksjonsnr leilighetsnr same);
  where same and matrikkelenhetid ne .;
run;

*Export to Stata;
PROC EXPORT DATA=housingid
            OUTFILE= "./housingid.dta"
            DBMS=STATA REPLACE;
RUN;


*Only Oslo;
data housingid_oslo (drop=matrikkelenhetid kommunenr);
  set gabba (keep=matrikkelenhetid kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr gaardsnr bruksnr seksjonsnr leilighetsnr same);
  where kommunenr = '0301';
  where same and matrikkelenhetid ne .;
run;

*Export to Stata;
PROC EXPORT DATA=housingid_oslo
            OUTFILE= "./housingid_oslo.dta"
            DBMS=STATA REPLACE;
RUN;

proc print data=housingid;
run;

proc print data=housingid_oslo;
run;
