/******************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 01.03.2026

Cleaning data from .sas file and exporting 
 to .dta format.
 
Input: .sas files from Statistics Norway
 registers.

Output: oslobuildings.dta; owners.dta.
******************************************/

libname skatt '/data';

*********************;
*Connecting data sets;
*********************;
data test1 (drop=etablert_dato_ssb utgaatt_dato_ssb);
  set skatt.gabbo (drop=bruksareal_kilde antall_rom_kilde kjokkenkode_: antall_bad_kilde antall_wc_kilde oppv: energi:
    sentralfyr_fob fjernvarme_fob);
  where matrikkelenhetid ne .;
  where same and bruksenhetstype not in ('A','I');
  innarbo=substr(etablert_dato_ssb,1,4)+0;
  utarbo=substr(utgaatt_dato_ssb,1,4)+0;
run;

data test2 (drop=etablert_dato_ssb utgaatt_dato_ssb);
  set skatt.gabba (drop=adresseid bygningid kommunenr etasje_type etasjenr leilighetsnr bygningsnr bygning_lopenr
    inngangsnr rename=(bruksenhetid=id));
  innarba=substr(etablert_dato_ssb,1,4)+0;
  utarba=substr(utgaatt_dato_ssb,1,4)+0;
run;

proc sort data=test1;
  by id innarbo;
proc sort data=test2;
  by id innarba;
data testm;
  merge test1 (in=en)
        test2 (in=to drop=matrikkelenhetid);
  by id;
  if en and to;
run;

data test3;
  set testm;
  where utarba >2010 and utarbo=.;
run;

*Tar ut 664044 observasjoner som er dubletter i gabba men ikke gabbo;
proc sort data=testm;
  by id gate_gaardsnr hus_bruksnr bokstav_festenr undernr gaardsnr bruksnr festenr seksjonsnr;
proc sort data=test3;
  by id gate_gaardsnr hus_bruksnr bokstav_festenr undernr gaardsnr bruksnr festenr seksjonsnr;
data testm2;
  merge testm
        test3 (in=en);
  by id gate_gaardsnr hus_bruksnr bokstav_festenr undernr gaardsnr bruksnr festenr seksjonsnr;
  if not en;
run;

data test4;
  set skatt.gabby (keep=id kommunenr bygningsnr bygningsstatus bygningstype bygningstype_gdato antall_etasjer
    antall_boliger antall_boliger_gdato byggeaar_sf tidskode_sf vannforsyning kloakk kode_paabygg_tilbygg kode_paabygg_tilbygg_gdato
    oppdateringsdato_bygg godkjent_dato igangsatt_dato tattibruk_dato bruksareal_totalt bruksareal_bolig  bruksareal_bolig_gdato
    ant_leil_1rom ant_leil_1rom_gdato ant_leil_2rom ant_leil_3rom ant_leil_4rom ant_leil_5rom ant_leil_6_fler_rom ant_hybler
    ant_klosett_agr ant_bad_agr ant_leil_m_bad ant_hybl_m_bad ant_leil_m_klosett ant_hybl_m_klosett sum_bruksareal_leiligheter
    sum_bruksareal_leil_gdato sum_bruksareal_hybler byggeaar_fob heis_fob eiendom_antall bebygd_areal har_heis
    etablert_dato_ssb utgaatt_dato_ssb);
  boligtype=substr(bygningstype,1,2);
run;

data test5 (drop=bygningstype etablert_dato_ssb utgaatt_dato_ssb);
  set test4 (rename=(kommunenr=knrby id=bygningid bygningsnr=bnr));
  where boligtype in ('11','12','13','14') or boligtype ne '15' and antall_boliger > 0;
  innarby=substr(etablert_dato_ssb,1,4)+0;
  utarby=substr(utgaatt_dato_ssb,1,4)+0;
run;

proc sort data=testm2;
  by bygningid;
proc sort data=test5;
  by bygningid;
data testm3 (drop=kommunenr);
  merge testm2 (in=en)
        test5 (in=to);
  by bygningid;
  if en and to;
run;

data test7 (drop=tett_spredt_kode_gdato etablert_dato_ssb utgaatt_dato_ssb);
  set skatt.gabad (keep=id kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr undernr tett_spredt_kode tett_spredt_kode_gdato
    bydel etablert_dato_ssb utgaatt_dato_ssb
    rename=(id=adresseid kommunenr=knrad));
  where adresseid ne .;
  innarad=substr(etablert_dato_ssb,1,4)+0;
  utarad=substr(utgaatt_dato_ssb,1,4)+0;
  tettar=substr(tett_spredt_kode_gdato,1,4)+0;
run;

*Fjerner repetisjoner av adresse (hovedsaklig obs. hvor gatenr eller lignende har blitt endret);
proc sort data=test7;
  by adresseid innarad;
data test8;
  set test7;
  if adresseid ne lag(adresseid);
run;


proc sort data=testm3;
  by adresseid;
proc sort data=test8;
  by adresseid;
data testm4;
  merge testm3 (in=en)
        test8;
  by adresseid;
  if en;
run;

data test9 (drop=dato);
  set skatt.gabfiar (rename=(bruksenhetid=id));
  innarfi=substr(dato,1,4)+0;
run;

data test10 (drop=aarmnd idt);
  set skatt.gabsear (rename=(bruksenhetid=id p_rom=p_romse id=idt));
  id=idt+0;
run;

proc sort data=testm4;
  by id;
proc sort data=test9;
  by id;
proc sort data=test10;
  by id;
data testm5;
  merge testm4 (in=en)
        test9
        test10;
  by id;
  if en;
run;

data test11 (drop=aarmnd);
  set skatt.gabfiaar;
run;

data test12 (drop=aarmnd rename=(byggeaar=baar));
  set skatt.gabseaar;
run;

proc sort data=testm5;
  by bygningsnr;
proc sort data=test11;
  by bygningsnr;
proc sort data=test12;
  by bygningsnr;
data testm6;
  merge testm5 (in=en)
        test11
        test12;
  by bygningsnr;
  if en;
run;

* Datasett of Oslo buildings;
data oslo1 (drop=knrad tilgang_rullestol_fob); *knrby dekker litt flere obs enn knrad;
  set testm6;
  where knrby = '0301';
run;

data skatt.oslobygg (drop=bnr bruksenhetstype_kilde antall_wc_gdato);
  set oslo1;
run;

data oslo2;
  set skatt.oslobygg;
run;

*Export to stata;
PROC EXPORT DATA= WORK.oslo2
            OUTFILE= "data/oslobuildings.dta"
            DBMS=STATA REPLACE;
RUN;


* Adding owners;
data test13 (drop=person_type_dsp_gdato etablert_dato_ssb utgaatt_dato_ssb andel_teller andel_nevner lmatid);
  set skatt.gabei (drop=person_id_kilde person_idtype_: andel_teller_kilde andel_nevner_kilde eiertype_: adresse_pers: postnummer_:
    person_type_dsp_kilde embetnr dagboknr rettsstiftelsesnr);
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
  set test15 (drop=andel_teller_gdato);
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

*Diverse metoder for å fjerne repetisjoner av matrikkelenhetid;
data testm6a (drop=kode_paabygg_tilbygg);
  set testm6;
  where kode_paabygg_tilbygg='';
run;

proc sort data=testm6a;
  by matrikkelenhetid;
data antall;
  set testm6a (keep=matrikkelenhetid);
  retain antenh;
  by matrikkelenhetid;
  if first.matrikkelenhetid then antenh=0;
  antenh=antenh+1;
  if last.matrikkelenhetid then output antall;
run;

data testm6b;
  merge testm6a
        antall;
  by matrikkelenhetid;
run;

data testm6c;
  set testm6b;
  if antenh<2 or (antenh>1 and boligtype not in ('16','18','19'));
run;

data antall2;
  set testm6c (keep=matrikkelenhetid);
  retain antenh2;
  by matrikkelenhetid;
  if first.matrikkelenhetid then antenh2=0;
  antenh2=antenh2+1;
  if last.matrikkelenhetid then output antall2;
run;

data testm6d;
  merge testm6c
        antall2;
  by matrikkelenhetid;
run;

data testm6e;
  set testm6d;
  if antenh2<2 or (antenh2>1 and bruksenhetstype ne 'F');
run;

data antall3;
  set testm6e (keep=matrikkelenhetid);
  retain antenh3;
  by matrikkelenhetid;
  if first.matrikkelenhetid then antenh3=0;
  antenh3=antenh3+1;
  if last.matrikkelenhetid then output antall3;
run;

data testm6f;
  merge testm6e
        antall3;
  by matrikkelenhetid;
run;

data testm6g;
  set testm6f;
  if antenh3<2 or (antenh3>1 and antall_boliger ne 0);
run;

data antall4;
  set testm6g (keep=matrikkelenhetid);
  retain antenh4;
  by matrikkelenhetid;
  if first.matrikkelenhetid then antenh4=0;
  antenh4=antenh4+1;
  if last.matrikkelenhetid then output antall4;
run;

data testm6h;
  merge testm6g
        antall4;
  by matrikkelenhetid;
run;

proc sort data=testm6h;
  by matrikkelenhetid descending antall_bosatte;
run;

data testm6i;
  set testm6h (drop=antenh antenh2 antenh3);
  if matrikkelenhetid=lag(matrikkelenhetid) and antall_bosatte=. then delete;
run;

proc sort data=testm6i;
  by matrikkelenhetid descending bruksareal innarbo innarby innarba;
run;

data testm6j;
  set testm6i;
  if matrikkelenhetid ne lag(matrikkelenhetid);
run;

proc sort data=eier2;
  by matrikkelenhetid;
data eiermerge;
  merge eier2 (in=en)
        testm6j (in=to);
  by matrikkelenhetid;
  if en;
  where matrikkelenhetid ne .;
run;

*Fjerner fritidsboliger;
proc freq data=eiermerge;
  table bruksenhetstype*boligtype;
run;

data eiermerge2;
  set eiermerge;
  where person_id2 ne '00';
  where same and matrikkelenhetid ne .;
  if (bruksenhetstype ne 'F' or boligtype ne '16');
run;

data skatt.owners (compress=yes);
  set eiermerge2;
run;

data owners (drop=byggeaar_fob byggeaar_sf baartemp byggeaar baartb);
  set skatt.owners (drop=id ant_leil_: ant_hyb: antall_rom_fob antall_bad_fob antall_wc_fob tilgang_rullestol_fob vannforsyning kloakk
    har_heis rename=(byggeaar_sf=baartemp));
  if baar<1500 then baar=.;
  if baar=. & byggeaar_fob ne ('' or '0000') & byggeaar_fob>1500 & byggeaar_fob<2015 then baar=byggeaar_fob;
  byggeaar_sf=baartemp+0;
  if baar=. & byggeaar_sf>1000 then baar=byggeaar_sf;
  if baar=. & byggeaar ne ('' or '0000') then baar=byggeaar;
  baartb=substr(tattibruk_dato,1,4)+0;
  if baar=. & baartb>1000 then baar=baartb;
run;

*Export to stata;
PROC EXPORT DATA= WORK.owners
            OUTFILE= "/data/owners.dta"
            DBMS=STATA REPLACE;
RUN;
