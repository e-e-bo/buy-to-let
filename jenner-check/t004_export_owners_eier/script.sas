/******************************************
Adapted from prep/Export_owners.sas
Written by Erlend Eide Bø // eeb@ssb.no

"Adding owners" section: builds a per-property
 owner-share table (eier2) from the confidential
 ownership register, filling in a missing
 matrikkelenhetid (property id) from the
 previous row with LAG when consecutive rows
 share the same address key, computing an
 ownership share (andel), replacing the entry
 year with the land-registry (tinglysning) year
 when available, retaining the first ownership
 level per property with BY-group RETAIN, and
 finally removing "H" (household) level
 duplicates via a self anti-join (MERGE ... IN=;
 IF NOT ...).

Original input: skatt.gabei, a confidential
 Statistics Norway ownership register reached
 via `libname skatt '/data'`.

Jenner-check adaptation: the confidential
 register is replaced by an 8-row inline
 sample (gabei) with the columns this section
 reads. Two consecutive rows (3 and 4) share
 a missing matrikkelenhetid pattern so the
 LAG-based fill-in logic is genuinely exercised.
 The DATA-step logic itself (test13 through
 eier2) is unchanged from upstream.
*******************************************/

data gabei;
  length eiendomsnivaa $2 person_type_dsp $1;
  input matrikkelenhetid kommunenr $ gaardsnr bruksnr festenr seksjonsnr
        eiendomsnivaa $ same etablert_dato_ssb $ utgaatt_dato_ssb $
        person_type_dsp_gdato $ andel_teller andel_nevner dagbok_aar person_type_dsp $;
  datalines;
100001 0301 102 4 0 1 E 1 20010115 . 20010115 1 1 . M
100002 0301 210 11 0 0 E 1 19980301 . 19980301 1 2 1998 M
100003 0301 301 22 0 2 F 1 20050601 . 20050601 1 1 2005 K
.      0301 301 22 0 2 H 1 20050601 . 20050601 1 4 2005 M
100005 0301 455 7 0 1 E 1 19900101 20150301 20150301 1 1 2015 D
100005 0301 455 7 0 1 E 1 20150301 . 20150301 1 1 2015 M
100006 1201 512 15 0 0 F 1 20030415 . 20030415 1 1 . K
100006 1201 512 15 0 0 H 1 20030415 . 20030415 1 3 . M
;
run;

* Adding owners;
data test13 (drop=person_type_dsp_gdato etablert_dato_ssb utgaatt_dato_ssb andel_teller andel_nevner lmatid);
  set gabei;
  where eiendomsnivaa ne 'KE';  *Tar ut obs. med eiendomsnivå eiers/festers kontaktsinstans;
  where same and eiendomsnivaa ne 'KF';
  retain lmatid;
  if matrikkelenhetid=. and kommunenr=lag(kommunenr) and gaardsnr=lag(gaardsnr) and bruksnr=lag(bruksnr) and festenr=lag(festenr) and
    seksjonsnr=lag(seksjonsnr) then matrikkelenhetid=lmatid;
  innarei=substr(etablert_dato_ssb,1,4)+0;
  utarei=substr(utgaatt_dato_ssb,1,4)+0;
  perstar=substr(person_type_dsp_gdato,1,4)+0;
  andel=andel_teller/andel_nevner;
  n=_N_;
  lmatid=matrikkelenhetid;
run;

*Erstatt innår med tinglysningsdato hvis tinglysningsdato finnes, og utår med dødsår hvis det eksisterer;
data test14;
  set test13;
  if dagbok_aar ne . and dagbok_aar ne 0000 then innarei=dagbok_aar;
  if perstar ne . and person_type_dsp='D' and perstar<utarei and perstar>innarei & perstar>2003 then utarei=perstar;
run;

*Erstatt utår med neste observasjons dagbokår, hvis det eksisterer;
proc sort data=test14;
  by descending n;
run;

data test15 (drop=lagdar laguar felles);
  set test14;
  retain lagdar laguar;
  if matrikkelenhetid=lag(matrikkelenhetid) and eiendomsnivaa=lag(eiendomsnivaa) and innarei=lag(innarei) and utarei=lag(utarei)
    and andel<1 then felles=1;
  if matrikkelenhetid=lag(matrikkelenhetid) and eiendomsnivaa=lag(eiendomsnivaa) and lagdar>2003 then utarei=lagdar;
  lagdar=innarei;
  if felles=1 then utarei=laguar;
  laguar=utarei;
run;

proc sort data=test15;
  by matrikkelenhetid n;
run;

data eier;
  set test15;
  retain eniv;
  by matrikkelenhetid;
  if first.matrikkelenhetid then eniv=eiendomsnivaa;
run;

*Ta ut eiendomsnivå H hvis F finnes;
data nivh;
  set eier;
  if (eniv="F" or eniv="F1") and eiendomsnivaa="H";
run;

data eier2 (drop=n eniv);
  merge eier
        nivh (in=en);
  by matrikkelenhetid n;
  if not en;
run;

proc print data=eier2;
  var matrikkelenhetid eiendomsnivaa andel innarei utarei person_type_dsp;
run;
