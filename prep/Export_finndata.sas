/*******************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 18.02.2026

Creating .sas files with code lists and 
 formats from .txt files.
 Exporting to .dta format.
 
Input: .txt files from Finn.no via Statistics 
 Norway.

Output: finn.dta;
*******************************************/

libname skatt '/data';

PROC FORMAT LIBRARY = library;
RUN;

*Definerer en makro for å importere finndata for flere år;
%macro finndata(begaar,sluttaar);
  %local ar;
  %do ar=&begaar %to &sluttaar;
    %let m0=m0;
    %let m=m;
    %local mnd;
    %do mnd=1 %to 9;
    DATA skatt.finn&ar&m&mnd;
      INFILE "/finn_data/g&ar&m0&mnd/grunnlag.txt" MISSOVER PAD LRECL=407;
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
    %end;
    %do mnd=10 %to 12;
    DATA skatt.finn&ar&m&mnd;
      INFILE "/finn_data/g&ar&m&mnd/grunnlag.txt" MISSOVER PAD LRECL=407;
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
        @404 heis $CHAR4. ;
    %end;
  %end;
%mend;

%finndata(2005,2013);

********
*År 2005
********;

data skatt.finn2005 (compress=yes);
  set skatt.finn2005m1
      skatt.finn2005m2
      skatt.finn2005m3
      skatt.finn2005m4
      skatt.finn2005m5
      skatt.finn2005m6
      skatt.finn2005m7
      skatt.finn2005m8
      skatt.finn2005m9
      skatt.finn2005m10
      skatt.finn2005m11
      skatt.finn2005m12;
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
proc sort data=skatt.finn2005;
  by postnr gnr bnr festenr seksjonsnr mndsol;
data skatt.finn2005;
  set skatt.finn2005;
  retain ants;
  by postnr gnr bnr festenr seksjonsnr mndsol;
  if first.seksjonsnr then antsalg=0;
  ants=ants+1;
run;

********
*År 2006
********;

data skatt.finn2006 (compress=yes);
  set skatt.finn2006m1
      skatt.finn2006m2
      skatt.finn2006m3
      skatt.finn2006m4
      skatt.finn2006m5
      skatt.finn2006m6
      skatt.finn2006m7
      skatt.finn2006m8
      skatt.finn2006m9
      skatt.finn2006m10
      skatt.finn2006m11
      skatt.finn2006m12;
  aar=2006;

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

********
*År 2007
********;

data skatt.finn2007 (compress=yes);
  set skatt.finn2007m1
      skatt.finn2007m2
      skatt.finn2007m3
      skatt.finn2007m4
      skatt.finn2007m5
      skatt.finn2007m6
      skatt.finn2007m7
      skatt.finn2007m8
      skatt.finn2007m9
      skatt.finn2007m10
      skatt.finn2007m11
      skatt.finn2007m12;
  aar=2007;

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

********
*År 2008
********;

data skatt.finn2008 (compress=yes);
  set skatt.finn2008m1
      skatt.finn2008m2
      skatt.finn2008m3
      skatt.finn2008m4
      skatt.finn2008m5
      skatt.finn2008m6
      skatt.finn2008m7
      skatt.finn2008m8
      skatt.finn2008m9
      skatt.finn2008m10
      skatt.finn2008m11
      skatt.finn2008m12;
  aar=2008;

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

********
*År 2009
********;

*2009-årgangen er organisert litt annerledes, så må endres for å ha like formater;
data skatt.finn2009 (drop=kommune2 gnr2 bnr2 festenr2 seksjonsnr2 kommunem gnrm bnrm festenrm seksjonsnrm i compress=yes);
  set skatt.finn2009m1 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m2 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m3 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m4 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m5 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m6 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m7 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m8 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m9 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m10 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m11 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2009m12 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2));
  array nr2 (*) $ kommune2 gnr2 bnr2 festenr2 seksjonsnr2;
  array nrmidl (*) kommunem gnrm bnrm festenrm seksjonsnrm;
  do i=1 to dim(nr2);
    if nr2(i)='.' then nr2(i)='';
    nrmidl(i)=nr2(i)+0;
  end;
  kommune=put(kommunem,z4.);
  if kommune='   .' then kommune='    ';
  gnr=put(gnrm,z5.);
  if gnr='    .' then gnr='     ';
  bnr=put(bnrm,z4.);
  if bnr='   .' then bnr='    ';
  festenr=put(festenrm,z4.);
  if festenr='   .' then festenr='    ';
  if seksjonsnrm>999 then seksjonsnrm=.;
  seksjonsnr=put(seksjonsnrm,z3.);
  if seksjonsnr='  .' then seksjonsnr='   ';
  aar=2009;

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


********
*År 2010
********;

*2010-årgangen, mnd 6,9 og 10 er organisert litt annerledes, så må endres for å ha like formater;
data skatt.finn2010 (drop=kommune2 gnr2 bnr2 festenr2 seksjonsnr2 kommunem gnrm bnrm festenrm seksjonsnrm i compress=yes);
  set skatt.finn2010m1 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m2 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m3 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m4 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m5 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m6 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m7 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m8 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m9 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m10 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m11 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2))
      skatt.finn2010m12 (rename=(kommune=kommune2 gnr=gnr2 bnr=bnr2 festenr=festenr2 seksjonsnr=seksjonsnr2));
  array nr2 (*) $ kommune2 gnr2 bnr2 festenr2 seksjonsnr2;
  array nrmidl (*) kommunem gnrm bnrm festenrm seksjonsnrm;
  do i=1 to dim(nr2);
    if nr2(i)='.' then nr2(i)='';
    nrmidl(i)=nr2(i)+0;
  end;
  kommune=put(kommunem,z4.);
  if kommune='   .' then kommune='    ';
  gnr=put(gnrm,z5.);
  if gnr='    .' then gnr='     ';
  bnr=put(bnrm,z4.);
  if bnr='   .' then bnr='    ';
  festenr=put(festenrm,z4.);
  if festenr='   .' then festenr='    ';
  if seksjonsnrm>999 then seksjonsnrm=.;
  seksjonsnr=put(seksjonsnrm,z3.);
  if seksjonsnr='  .' then seksjonsnr='   ';
  aar=2010;

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

********
*År 2011
********;

data skatt.finn2011 (compress=yes);
  set skatt.finn2011m1
      skatt.finn2011m2
      skatt.finn2011m3
      skatt.finn2011m4
      skatt.finn2011m5
      skatt.finn2011m6
      skatt.finn2011m7
      skatt.finn2011m8
      skatt.finn2011m9
      skatt.finn2011m10
      skatt.finn2011m11
      skatt.finn2011m12;
  aar=2011;

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

********
*År 2012
********;

data skatt.finn2012 (compress=yes);
  set skatt.finn2012m1
      skatt.finn2012m2
      skatt.finn2012m3
      skatt.finn2012m4
      skatt.finn2012m5
      skatt.finn2012m6
      skatt.finn2012m7
      skatt.finn2012m8
      skatt.finn2012m9
      skatt.finn2012m10
      skatt.finn2012m11
      skatt.finn2012m12;
  aar=2012;

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

********
*År 2013
********;

data skatt.finn2013 (compress=yes);
  set skatt.finn2013m1
      skatt.finn2013m2
      skatt.finn2013m3
      skatt.finn2013m4
      skatt.finn2013m5
      skatt.finn2013m6
      skatt.finn2013m7
      skatt.finn2013m8
      skatt.finn2013m9
      skatt.finn2013m10
      skatt.finn2013m11
      skatt.finn2013m12;
  aar=2013;

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

**************************************
*Data for the first six months of 2014
**************************************;

DATA skatt.finn2014m1 (compress=yes);
      INFILE "/finn_data/g2014m01/grunnlag.txt" MISSOVER PAD LRECL=407;
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
run;

DATA skatt.finn2014m2 (compress=yes);
      INFILE "/finn_data/g2014m02/grunnlag.txt" MISSOVER PAD LRECL=407;
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
run;

DATA skatt.finn2014m3 (compress=yes);
      INFILE "/finn_data/g2014m03/grunnlag.txt" MISSOVER PAD LRECL=407;
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
run;

DATA skatt.finn2014m4 (compress=yes);
      INFILE "/finn_data/g2014m04/grunnlag.txt" MISSOVER PAD LRECL=407;
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
run;

DATA skatt.finn2014m5 (compress=yes);
      INFILE "/finn_data/g2014m05/grunnlag.txt" MISSOVER PAD LRECL=407;
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
run;

DATA skatt.finn2014m6 (compress=yes);
      INFILE "/finn_data/g2014m06/grunnlag.txt" MISSOVER PAD LRECL=407;
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
run;

data skatt.finn2014h1 (compress=yes);
  set skatt.finn2014m1
      skatt.finn2014m2
      skatt.finn2014m3
      skatt.finn2014m4
      skatt.finn2014m5
      skatt.finn2014m6;
  aar=2014;
run;

*****************
*All years export
*****************;
data skatt.finn2 (compress=yes);
  set skatt.finn2005
      skatt.finn2006
      skatt.finn2007
      skatt.finn2008
      skatt.finn2009
      skatt.finn2010
      skatt.finn2011
      skatt.finn2012
      skatt.finn2013
      skatt.finn2014h1;
run;

*Export to stata;
PROC EXPORT DATA= skatt.finn2
            OUTFILE= "/data/finndata.dta"
            DBMS=STATA REPLACE;
RUN;
