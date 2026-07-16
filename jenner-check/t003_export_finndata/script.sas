/*******************************************
Adapted from prep/Export_finndata.sas
Written by Erlend Eide Bø // eeb@ssb.no

Creating .sas files with code lists and
 formats from .txt files.
 Exporting to .dta format.

Original input: fixed-width extracts from
 Finn.no listings via Statistics Norway,
 read with `INFILE "/finn_data/g&ar&m0&mnd/
 grunnlag.txt" MISSOVER PAD LRECL=407;` for
 each year/month combination (the upstream
 script macro-loops this over 2005-2014).

Jenner-check adaptation: one month's worth of
 the fixed-width layout is reproduced verbatim
 (same @col informats, same LRECL=407) against
 three inline listings instead of the external
 file; the LABEL block, the duplicate-listing
 sort/retain logic (`if first.seksjonsnr then
 antsalg=0; ants=ants+1;`), and the PROC EXPORT
 to Stata are all unchanged from upstream.

output: finndata_sample.dta
*******************************************/

DATA finn2005m2 (compress=yes);
  INFILE DATALINES MISSOVER PAD LRECL=407;
  INPUT
    @1 id $CHAR10.
    @11 eiendtype $CHAR2.
    @13 boa 4.
    @17 p_rom 4.
    @21 bta 4.
    @25 bra 4.
    @29 grflate 4.
    @33 kommune $CHAR4.
    @37 pris 8.
    @45 fellesgj 8.
    @53 felleesformue 8.
    @61 postnr $CHAR4.
    @65 datoinn $char10.
    @75 datout $char10.
    @85 totalsum 8.
    @93 mndsol 2.
    @95 byggeaar 4.
    @99 gnr $CHAR5.
    @104 bnr $CHAR4.
    @108 festenr $CHAR4.
    @112 seksjonsnr $CHAR3.
    @115 leilighetsnr $CHAR8.
    @123 megler $CHAR100.
    @223 adresse $CHAR60.
    @283 boligtype $CHAR30.
    @313 eieform $CHAR25.
    @338 ant_soverom 2.
    @340 ant_rom $CHAR2.
    @342 etasje $CHAR2.
    @344 ant_et $CHAR2.
    @346 tomt_eid $CHAR4.
    @350 tomteareal 10.
    @360 verditakst 8.
    @368 laanetakst 8.
    @376 modernisert $CHAR4.
    @380 balkong $CHAR4.
    @384 baatplass $CHAR4.
    @388 gara_pplass $CHAR4.
    @392 peis $CHAR4.
    @396 fellesvask $CHAR4.
    @400 hage $CHAR4.
    @404 heis $CHAR4.;
  DATALINES;
FN0000000120  65  60  70  65   00301 2100000       0       0017001.02.200515.02.2005 2100000 21965001020004    001        Oslo Eiendomsmegling AS                                                                             Storgata 5                                                  Leilighet                     Selveier                  2 3 2 4             0 2000000 1900000    J               J       N
FN0000000220  88  82  95  88   00301 3200000  150000       0025003.02.200520.02.2005 3350000 21998002100011               Vestkant Megler AS                                                                                  Bygdoy Alle 12                                              Leilighet                     Selveier                  3 4 3 5             0 3100000 3000000    J       J   J           J
FN0000000310 140 130 160 145 4501103 4500000       0       0430010.02.200528.02.2005 4500000 21978000440002               Sandnes Eiendom AS                                                                                  Haugveien 3                                                 Enebolig                      Selveier                  4 6 2 2J          450 4300000 41000002001        J   J       J   N
;
RUN;

data finn2005 (compress=yes);
  set finn2005m2;
  aar=2005;

   LABEL
      id = 'ident fra Finn'
      eiendtype = ' diverse eiendomstyper: 10, 20, 30, 32, 33'
      boa = 'boligens boligareal'
      p_rom = 'boligens primærrom'
      bta = 'boligens bruttoareal'
      bra = 'boligens bruksareal'
      grflate = 'boligens grunnflate'
      kommune = 'kommune boligen ligger i'
      pris = 'pris boligen er solgt for'
      fellesgj = 'fellesgjeld'
      felleesformue = 'fellesformue'
      postnr = 'postnummer boligen tilhører'
      datoinn = 'dato oppdraget ble bestilt'
      datout = 'dato oppdraget var utført'
      totalsum = 'sum er pris boligen er solt for + fellesgjeld'
      mndsol = 'måned boligen solgt'
      byggeaar = 'boligens byggeår'
      gnr = 'gårdsnummer'
      bnr = 'bruksnummer'
      festenr = 'festenummer'
      seksjonsnr = 'seksjonsnummer'
      leilighetsnr = 'leilighetsnummer'
      megler = 'navn på meglerfirma'
      adresse = 'boligens gate/vei adresse'
      boligtype = 'boligtype: enebolig, rekkehus, tomannsbolig, leilighet'
      eieform = 'eieform: eier selveier,aksje, andel'
      ant_soverom = 'antall soverom'
      ant_rom = 'antall rom'
      etasje = 'hvilken etasje er boligen i'
      ant_et = 'antall etasjer i boligen'
      tomt_eid = 'er det eid tomt'
      tomteareal = 'tomtearealets størrelse'
      verditakst = 'boligens verditakst'
      laanetakst = 'boligens lånetakst'
      modernisert = 'år boligen var modernisertm'
      balkong = 'balkong/terasse som tilhører boligen'
      baatplass = 'båtplass som tilhører boligen'
      gara_pplass = 'garasjeplass / pplass som tilhører boligen'
      peis = 'peis i boligen'
      fellesvask = 'fellesvask som tihører boligenl'
      hage = 'hage som tilhører boligen'
      heis = 'heis i bygget/boligen'
   ;
RUN;

*Introducing a variabel if two or more observations have the same housing code;
proc sort data=finn2005;
  by postnr gnr bnr festenr seksjonsnr mndsol;
data finn2005;
  set finn2005;
  retain ants;
  by postnr gnr bnr festenr seksjonsnr mndsol;
  if first.seksjonsnr then antsalg=0;
  ants=ants+1;
run;

*Export to stata;
PROC EXPORT DATA= finn2005
            OUTFILE= "./finndata_sample.dta"
            DBMS=STATA REPLACE;
RUN;

proc print data=finn2005 (obs=10);
  var id kommune pris boligtype ants;
run;
