
/*******************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 09.05.2026

Creates dataset of housing owners and
 investors in Oslo for the paper "Buy to let".

Input: housingid.dta and housingid_oslo.dta, 
 created by /prep/Export_housingid.sas; 
ambita_oslo.dta, ambita_bor.dta and
 ambita_selv1516, created by
 /prep/Import_ambita.do;
finndata.dta created by 
 /prep/Export_finndata.sas;
owners.dta, created by
 /prep/Export_owners.sas;
tax.dta, tax2004.dta created by 
 /prep/Export_taxdata.sas

Output: housingid_oslo2.dta;
ambita_oslo_selv.dta; ambita_oslo2.dta;
ambita_oslo_kj.dta; housingid2.dta; 
owneryear_bor.dta; eierex_1516.dta; 
finn_ambita.dta; finn_ambita2.dta; 
imatch_ambita.dta; finn_ambita_add.dta; 
finn_ambita_add2.dta; finn_ambita3.dta; 
owners_2.dta; owneryear.dta; ownermerge.dta;
ownermerge_2.dta; owners_oslo.dta;
investors.dta; investors_2.dta;
*******************************************/

* Prepare datasets from sas
use housingid, clear

destring kommunenr gate_gaardsnr hus_bruksnr gaardsnr bruksnr seksjonsnr, replace
replace bokstav_festenr = "" if bokstav_festenr == "0000"
compress

save housingid, replace

use housingid_oslo, clear

destring gate_gaardsnr hus_bruksnr gaardsnr bruksnr seksjonsnr, replace
replace bokstav_festenr = "" if bokstav_festenr == "0000"
compress

save housingid_oslo, replace

drop leilighetsnr

sort gaardsnr bruksnr seksjonsnr gate_gaardsnr hus_bruksnr bokstav_festenr

duplicates drop gaardsnr bruksnr seksjonsnr gate_gaardsnr hus_bruksnr bokstav_festenr, force

rename gaardsnr gardsnr

save housingid_oslo2, replace

use ambita_oslo, clear

rename (eiendomadressegatenr eiendomadressehusnr eiendomadressebokstav) (gate_gaardsnr hus_bruksnr bokstav_festenr)

preserve

keep if selveier == 1
save ambita_oslo_selv, replace

restore

* Add gnr, bnr, seksjonsnr to co-ops.
keep if selveier == 0

drop bruksnr gardsnr seksjonsnr

joinby gate_gaardsnr hus_bruksnr bokstav_festenr using housingid_oslo2, unm(master) 

append using ambita_oslo_selv

drop bolignr_bruksenhet _merge

rename (gardsnr bruksnr kjøpesum) (gnr bnr pris)

save ambita_oslo2, replace

* Set of buyers
use ambita_oslo2, clear

drop dokumentnr kommunenr bruksarealbolig-bebygdareal
keep if rolle == "Kjøper"
drop rolle

rename borettsandel boand

save ambita_oslo_kj, replace


****************************
* Ownership length of co-ops
****************************

* Add gnr/bnr/leilighetsnr
use housingid, clear

drop leilighetsnr

sort kommunenr gaardsnr bruksnr seksjonsnr gate_gaardsnr hus_bruksnr bokstav_festenr

duplicates drop kommunenr gaardsnr bruksnr seksjonsnr gate_gaardsnr hus_bruksnr bokstav_festenr, force

rename gaardsnr gardsnr

save housingid2, replace

use ambita_bor, clear

rename (eiendomadressegatenr eiendomadressehusnr eiendomadressebokstav) (gate_gaardsnr hus_bruksnr bokstav_festenr)

sort kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr bolignr daar

egen bogr = group(kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr bolignr), missing
egen eigr = group(kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr bolignr dokumentdato rolle), missing

* Buyers and subsequent ownership length
preserve

keep if rolle == "Kjøper"

collapse daar bogr, by(eigr)

g uaar = daar[_n+1] - 1 if bogr == bogr[_n+1]
drop bogr daar
tempfile bor_uaar 
save `bor_uaar'

restore

* Sellers and previous ownership length
preserve

keep if rolle == "Selger"

collapse daar bogr, by(eigr)

g iaar = daar[_n-1] if bogr == bogr[_n-1]
drop bogr daar
tempfile bor_iaar 
save `bor_iaar'

restore

merge m:1 eigr using `bor_uaar', nogen
merge m:1 eigr using `bor_iaar', nogen

keep daar personid personidtype kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr uaar iaar andelteller andelnevner rolle

drop if rolle == "Selger" & iaar != . // Is duplicate of the buyer side

* Use old kommunenr for Sandefjord
replace kommunenr = 706 if kommunenr == 710

joinby kommunenr gate_gaardsnr hus_bruksnr bokstav_festenr using housingid2, unm(master) 

* Only private owners
keep if inlist(personidtype,"F","D")

g andel = andelteller / andelnevner

drop personidtype andelteller andelnevner

g antar = uaar - daar + 1 if rolle == "Kjøper"
replace antar = 2016 - daar if uaar == . | uaar == 2016 & rolle == "Kjøper"
replace antar = daar - 2006 if rolle == "Selger"

* Replace transaction year with start year for sellers
replace daar = 2006 if rolle == "Selger"

* No need for buyer transactions from 2016, as they cannot be followed for a long enough period
drop if daar == 2016 // 58,256 obs. 

* Drop duplicates (keep the obs. with highest ownership share)
gsort personid kommunenr gardsnr bruksnr seksjonsnr daar uaar -andel
duplicates drop personid kommunenr gardsnr bruksnr seksjonsnr daar uaar, force // 1,525 obs.

drop _merge gate_gaardsnr hus_bruksnr rolle

expand antar

rename (personid gardsnr bruksnr kommunenr daar uaar) (person_id gnr bnr kommune innarei utarei)

* Drop ownership periods not covering the end of a year
drop if antar < 1 // 46,583 obs.

save owneryear_bor, replace


***********************************
* Ownership exit of houses in 15/16
***********************************

use ambita_selv1516, clear

* Remove internal transactions (where same person is on both buying and sellling side)
sort dokumentnr personid rolle
g inttr = dokumentnr == dokumentnr[_n-1] & personid == personid[_n-1] & rolle != rolle[_n-1]
bysort dokumentnr: egen inttr2 = max(inttr)
drop if inttr == 1 // 19,941 obs.
drop inttr inttr2

keep if rolle == "Selger"

keep dokumentdato kjøpesum daar personid personidtype kommunenr gardsnr bruksnr seksjonsnr andelteller andelnevner

* Use old kommunenr for Sandefjord
replace kommunenr = 706 if kommunenr == 710

* Only private owners
keep if inlist(personidtype,"F","D") // 103,119 obs.

g andel2 = andelteller / andelnevner

drop personidtype andelteller andelnevner

rename (personid gardsnr bruksnr kommunenr) (person_id gnr bnr kommune)

* Drop duplicates (e.g. basement/loft units, which are sold with main floor, but registred separately)
duplicates drop daar person_id kommune gnr bnr seksjonsnr andel2, force // 140,624 obs.

* Some obs registered at two times, i.e. transaction within person: keep latest year
sort daar person_id kommune gnr bnr seksjonsnr andel2
duplicates drop person_id kommune gnr bnr seksjonsnr andel2, force // 18 obs.

bysort person_id kommune gnr bnr seksjonsnr daar: egen ants = count(kommune)

* Duplicate transactions, where price is 0, likely within household
drop if ants > 1 & kjøpesum == 0 // 272 obs.

bysort person_id kommune gnr bnr seksjonsnr daar: egen ants2 = count(kommune)
gsort person_id kommune gnr bnr seksjonsnr -dokumentdato 

* Remaining duplicates: keep latest date
duplicates drop person_id kommune gnr bnr seksjonsnr, force // 718 obs.

bysort person_id kommune gnr bnr seksjonsnr daar: egen ants3 = count(kommune)

drop kjøpesum dokumentdato ants - ants3

save eierex_1516, replace

************************
* Connect with Finn-data
************************

use finndata, clear

drop id festenr bta megler adresse baatplass

destring kommune gnr bnr seksjonsnr etasje, replace force
keep if kommune == 301
drop if gnr == . // 3398 obs.
rename postnr postnr_f

g sifin = date(datoinn, "DMY")
g sifut = date(datout, "DMY")

replace seksjonsnr = 0 if seksjonsnr == .

bysort gnr bnr seksjonsnr pris: egen ants = count(kommune)

sort ants gnr bnr seksjonsnr pris

joinby gnr bnr seksjonsnr pris using ambita_oslo_kj, unm(b)

g doksif = date(dokumentdato, "YMD")
g difsif = doksif - sifut

* Drop if registered date before sales date
drop if doksif < sifut & _merge == 3 // 44,197 obs.

bysort gnr bnr seksjonsnr pris personid: egen ants2 = count(kommune)

egen finngr = group(gnr bnr seksjonsnr pris personid)

* Drop if buyer connected to several transactions from Finn, and floor is different
g liket = etasje == etasjenr
bysort finngr: egen likeks = max(liket)
drop if liket == 0 & likeks == 1 & ants2 > 1 & _merge == 3 // 39,111 obs.

bysort gnr bnr seksjonsnr pris personid: egen ants3 = count(kommune)

* Keeping the observation with sales date closest to register date
bysort finngr: egen mindif = min(difsif)
drop if ants3 > 1 & difsif > mindif // 20,876

bysort gnr bnr seksjonsnr pris personid: egen ants4 = count(kommune)

drop if ants4 > 1 & bruksenhettypekode == "U" & _merge == 3 // 8,595 obs.

bysort gnr bnr seksjonsnr pris personid: egen ants5 = count(kommune)

* Only private buyers
drop if personidtype == "S" // 40,810 obs.

* Removing duplicates from Finn (keeping obs. with earliest in-date)
sort gnr bnr seksjonsnr pris personid sifin
drop if finngr == finngr[_n-1] & ants5 > 1 & ants > 1 & _merge == 3 // 1,009 obs.

bysort gnr bnr seksjonsnr pris personid: egen ants6 = count(kommune)

drop if ants6 > 1 & omsetningstypekode == 8 & _merge == 3 // 9 obs.

bysort gnr bnr seksjonsnr pris personid: egen ants7 = count(kommune)

* Drop basement/loft units, which are sold with main floor, but registred separately
drop if ants7 > 1 & inlist(etasjekode,"U","K","L") & _merge == 3 // 856 obs.

bysort gnr bnr seksjonsnr pris personid: egen ants8 = count(kommune)

* Keeping unit with largest area (remove smaller subunits)
bysort finngr: egen maksbo = max(bruksaereal)
drop if maksbo != bruksaereal & ants8 > 1 & _merge == 3 // 899 obs.
drop maksbo

bysort gnr bnr seksjonsnr pris personid: egen ants9 = count(kommune)

* Keep lowest floor
sort gnr bnr seksjonsnr pris personid etasjenr
drop if finngr == finngr[_n-1] & etasjenr != etasjenr[_n-1] & ants9 > 1 & _merge == 3 // 323 obs.

bysort gnr bnr seksjonsnr pris personid: egen ants10 = count(kommune)

* Removing remaining duplicates, keeping first obs. based on bolignr/bygningstypekode/tattibrukdato (though sort order not important)
sort gnr bnr seksjonsnr pris personid bolignr bygningstypekode tattibrukdato
drop if finngr == finngr[_n-1] & ants10 > 1 & _merge == 3 // 192 obs.

bysort gnr bnr seksjonsnr pris personid: egen ants11 = count(kommune)

drop ants finngr - ants11

keep if _merge == 3
drop _merge

* Registered at most a year after transaction date
keep if difsif <= 365 // 14,268 obs.

compress
save finn_ambita, replace

********************************************************************
* Make sure each transaction from Finn only matched to one ownership
********************************************************************
use finn_ambita, clear

g andel2 = andelteller / andelnevner
drop andelteller andelnevner

egen finngr = group(eiendtype - sifut), missing

bysort finngr: egen totand = total(andel2)

* Drop if Finn-obs. connected to several owners, and floor is different
g liket = etasje == etasjenr
bysort finngr: egen likeks = max(liket)
drop if liket == 0 & likeks == 1 & totand > 1 // 2,461 obs.

bysort finngr: egen totand2 = total(andel2)

* Keeping the observation with sales date closest to register date
bysort finngr: egen mindif = min(difsif)
drop if totand2 > 1 & difsif > mindif // 2,562 obs.

bysort finngr: egen totand3 = total(andel2)

drop if totand3 > 1 // 94 obs.
drop finngr - totand3

save finn_ambita2, replace

*******************************************************************
* Try to match unmatched unobservations that did not match on price
*******************************************************************
use ambita_oslo_kj, clear 

merge m:1 gnr bnr seksjonsnr pris personid using finn_ambita2, keep(master) nogen

rename pris kjsum

drop doksif - andel2

save imatch_ambita, replace

use finndata, clear

drop id festenr bta megler adresse baatplass

destring kommune gnr bnr seksjonsnr etasje, replace force
keep if kommune == 301
drop if gnr == . // 3399 obs.
rename postnr postnr_f

g sifin = date(datoinn, "DMY")
g sifut = date(datout, "DMY")

replace seksjonsnr = 0 if seksjonsnr == .

bysort gnr bnr seksjonsnr pris: egen ants = count(kommune)

sort ants gnr bnr seksjonsnr pris

merge m:m gnr bnr seksjonsnr pris using finn_ambita2, keep(master) nogen

drop daar - andel2

joinby gnr bnr seksjonsnr using imatch_ambita, unm(b)

keep if _merge == 3
drop _merge

g doksif = date(dokumentdato, "YMD")
g difsif = doksif - sifut
g difpr = pris - kjsum

drop if difsif < 0 // 209,081 obs.
drop if difsif > 365 // 1,371,017 obs.

* Drop observations with price difference larger than 5%
g pdpr = abs(difpr) / pris
drop if pdpr > .05 & pdpr != . // 42,917 obs.

* Drop observations with different floor
g liket = etasje == etasjenr
replace liket = . if etasje == . | etasjenr == .
drop if liket == 0 // 29,751 obs.

bysort gnr bnr seksjonsnr personid: egen ants2 = count(kommune)

egen finngr = group(gnr bnr seksjonsnr personid)

* Keeping the observation with sales date closest to register date if pris is missing
bysort finngr: egen mindif = min(difsif)
drop if ants2 > 1 & difsif > mindif & pris == . // 4,759 obs.

bysort gnr bnr seksjonsnr personid: egen ants3 = count(kommune)

* Only private buyers
drop if personidtype == "S" // 2,422 obs.

bysort gnr bnr seksjonsnr personid: egen ants4 = count(kommune)

bysort finngr: egen minpd = min(pdpr)
drop if ants4 > 1 & difsif > mindif & pdpr > minpd & pdpr != . // 110 obs.

bysort gnr bnr seksjonsnr personid: egen ants5 = count(kommune)

* Drop basement/loft units, which are sold with main floor, but registred separately
drop if ants5 > 1 & inlist(etasjekode,"U","K","L") // 152 obs.

bysort gnr bnr seksjonsnr personid: egen ants6 = count(kommune)

* Drop unumbered units, which are sold with main housing unit, but registred separately
drop if ants6 > 1 & bruksenhettypekode == "U" // 1,355 obs.

bysort gnr bnr seksjonsnr personid: egen ants7 = count(kommune)

g boa2 = boa
replace boa2 = p_rom if boa == .
g difbo = boa2 - bruksaereal
replace difbo = . if bruksaereal == 0

g pdbo = abs(difbo) / boa2
bysort finngr: egen mindbo = min(pdbo)

drop if mindbo > .25 & mindbo != . // 2,055

bysort gnr bnr seksjonsnr personid: egen ants8 = count(kommune)

* Drop observations with larger size difference than other obs.
drop if ants8 > 1 & pdbo > mindbo & pdbo != . // 180 obs.

bysort gnr bnr seksjonsnr personid: egen ants9 = count(kommune)

drop if ants9 > 1 & bruksaereal == 0 & mindbo != . // 4 obs.

bysort gnr bnr seksjonsnr personid: egen ants10 = count(kommune)

* If still duplicates, keep obs. with registry date closest to transaction date
drop if ants10 > 1 & difsif > mindif // 117 obs.

bysort gnr bnr seksjonsnr personid: egen ants11 = count(kommune)

* Removing duplicates from Finn (keeping obs. with earliest in-date)
sort gnr bnr seksjonsnr pris personid sifin
drop if finngr == finngr[_n-1] & ants11 > 1 & ants > 1 // 108 obs.

bysort gnr bnr seksjonsnr personid: egen ants12 = count(kommune)

drop if ants12 > 1 & bruksenhettypekode == "I" // 4 obs.
drop if ants12 > 1 & pdpr > minpd & pdpr != . // 1 obs.

bysort gnr bnr seksjonsnr personid: egen ants13 = count(kommune)

* Removing remaining duplicates, keeping first obs. based on etasjenr/bolignr/tattibrukdato (though sort order not important)
sort gnr bnr seksjonsnr personid etasjenr bolignr tattibrukdato
drop if finngr == finngr[_n-1] & ants13 > 1 // 38 obs.

bysort gnr bnr seksjonsnr personid: egen ants14 = count(kommune)

drop difpr - liket finngr - ants14

g imatch = 1

compress
save finn_ambita_add, replace

********************************************************************
* Make sure each transaction from Finn only matched to one ownership
********************************************************************
use finn_ambita_add, clear

g andel2 = andelteller / andelnevner
drop andelteller andelnevner

egen finngr = group(eiendtype - sifut), missing

bysort finngr: egen totand = total(andel2)

* Keeping the observation with sales date closest to register date
bysort finngr: egen mindif = min(difsif)
drop if totand > 1 & difsif > mindif // 4,126 obs.

bysort finngr: egen totand2 = total(andel2)

drop if totand2 > 1 // 201 obs.
drop finngr - totand2

save finn_ambita_add2, replace

*******************************
* Add together all transactions
*******************************

use finn_ambita2, clear
append using finn_ambita_add2

egen finngr = group(eiendtype - sifut), missing

bysort finngr: egen totand = total(andel2)

replace pris = kjsum if pris == .
drop kjsum

save finn_ambita3, replace

***********************
* Data from Matrikkelen
***********************
use owners, clear

* Keep owners with personal ID (removes i.e. organisational owners)
keep if inlist(person_idtype,"F","D")
destring person_id2, g(pers2)
drop if pers2 > 31
drop pers2

bysort matrikkelenhet innarei person_id andel: egen antp = count(matrikkelenhetid)

* Removing observations with multiple records of same owner in same period (some are multiple transactions in one year, other different eiendomsnivå)
drop if antp == 2 & innarei == utarei

replace eiendomsnivaa = "HE" if eiendomsnivaa == "AE" & antp == 2

sort person_id matrikkelenhetid innarei andel eiendomsnivaa 
drop if person_id == person_id[_n-1] & matrikkelenhetid == matrikkelenhetid[_n-1] & andel == andel[_n-1] & innarei == innarei[_n-1]

by person_id: egen ant = count(matrikkelenhetid)

sum ant,d

drop person_idtype-eiertype person_type_dsp-person_id2 perstar adresseid-leilighetsnr bruksareal_gdato-undernr utarba-tidskode_sf godkjent_dato igangsatt_dato ant_klosett_agr-bebygd_areal

drop if innarei == 2015

rename (gaardsnr bruksnr kommunenr) (gnr bnr kommune)

destring gnr bnr seksjonsnr kommune, replace

merge m:1 person_id kommune gnr bnr seksjonsnr using eierex_1516, keep(match master) nogen

replace utarei = daar if utarei == .

* Want last year with ownership at end of year
replace utarei = utarei - 1 

* Adding a seperate observation for each owner-year
g antar = utarei - max(2004,innarei) + 1
replace antar = 2016 - max(2004,innarei) if utarei == . | utarei == 2016

drop if antar < 1

expand antar

* Add co-ops
append using owneryear_bor

sort matrikkelenhetid kommune gnr bnr seksjonsnr person_id innarei utarei andel

by matrikkelenhetid kommune gnr bnr seksjonsnr person_id innarei utarei andel: egen arnr = seq()

g aar = max(2004,innarei) + arnr - 1
drop antar arnr

compress
save owners_2, replace

use owners_2, clear

drop person_id_gdato bruksareal_totalt bruksareal_bolig_gdato kode_paabygg_tilbygg_gdato oppdateringsdato_bygg bta
drop festenr

drop if inlist(aar,2004,2005)

* Gathering area in one variable
replace p_rom = p_romse if p_rom == .
replace p_rom = boa if p_rom == .
replace p_rom = bra if p_rom == .
drop boa bra
rename p_rom p_rom2

bysort person_id kommune gnr bnr seksjonsnr aar: egen antobs = count(aar)

* Removing observations with multiple records of same owner in same period (some are multiple transactions in one year, other different eiendomsnivå)
replace eiendomsnivaa = "HE" if eiendomsnivaa == "AE" & antobs > 1

* Drop different matrikkelnumbers if other identifying information similar
sort person_id kommune gnr bnr seksjonsnr aar innarei andel eiendomsnivaa 
drop if person_id == person_id[_n-1] & gnr == gnr[_n-1] & seksjonsnr == seksjonsnr[_n-1] & aar == aar[_n-1] & andel == andel[_n-1] & innarei == innarei[_n-1] // 143,422 obs.

bysort person_id kommune gnr bnr seksjonsnr aar: egen antobs2 = count(aar)

* Dropping duplicate observations without information on ownership share
drop if antobs2 > 1 & andel == . // 8,263 obs.

bysort person_id kommune gnr bnr seksjonsnr aar: egen antobs3 = count(aar)

* Keeping duplicates with largest living area (most likely main house)
bysort person_id kommune gnr bnr seksjonsnr aar: egen mp_rom = max(p_rom2)
drop if antobs3 > 1 & p_rom2 != mp_rom // 14,135 obs.
drop mp_rom

bysort person_id kommune gnr bnr seksjonsnr aar: egen antobs4 = count(aar)

* Keeping duplicates with largest living area (most likely main house)
bysort person_id kommune gnr bnr seksjonsnr aar: egen mbo = max(bruksareal_bolig)
drop if antobs4 > 1 & bruksareal_bolig != mbo // 26,345 obs.
drop mbo

bysort person_id kommune gnr bnr seksjonsnr aar: egen antobs5 = count(aar)

* Remaining duplicates: keep earliest matrikkelenhetid
sort person_id kommune gnr bnr seksjonsnr aar matrikkelenhetid 
duplicates drop person_id kommune gnr bnr seksjonsnr aar, force // 44,128 obs.

drop antobs - antobs5

save owneryear, replace

*********************************************************
* Add transactions from Finn and Ambita to Matrikkel data
*********************************************************
use finn_ambita3, clear

drop grflate leilighetsnr boligtype modernisert tomt_eid fellesvask peis hage heis gara_pplass dokumentdato bruksenhettype rettsstiftelsesnr omsetningstypekode bolignr

bysort personid kommune gnr bnr seksjonsnr: egen antfiam = count(kommune)
bysort personid kommune gnr bnr seksjonsnr daar: egen antfiam2 = count(kommune)

* Where two transactions within year, keep latest to reflect end of year status
gsort personid kommune gnr bnr seksjonsnr daar -sifut
duplicates drop personid kommune gnr bnr seksjonsnr daar, force // 29 obs.

drop antfiam antfiam2 

rename (personid aar daar) (person_id faar aar)

merge 1:1 person_id kommune gnr bnr seksjonsnr aar using owneryear, keep(match using) nogen

save ownermerge, replace

* Add hushnr to look at households
use tax, clear
append using tax2004

keep fnr hushnr aar bokomnr

rename fnr person_id

merge 1:m person_id aar using ownermerge, keep(match using) nogen

save ownermerge_2, replace


***********************************
* Use household as unit of interest
***********************************
use ownermerge_2, clear

*sort person_id aar matrikkelenhetid
sort person_id aar kommune gnr bnr seksjonsnr

* Replacing missing obs of hushnr with last year's value
replace hushnr = hushnr[_n-1] if hushnr == . & person_id == person_id[_n-1]

* Otherwise, hushnr given as fnr
replace hushnr = person_id if hushnr == .

sort hushnr aar kommune gnr bnr seksjonsnr matrikkelenhetid person_id

bysort hushnr aar kommune gnr bnr seksjonsnr matrikkelenhetid: egen totandel = total(andel)

* Drop persons without ownership in Oslo
egen oslo = anymatch(kommune), v(301)
bysort hushnr: egen osloei2 = max(oslo)
drop if osloei2 == 0
drop oslo osloei2

drop eieform

save owners_oslo, replace

use owners_oslo, clear

* Only counting houses hold more than half by a household
drop if totandel <= .5 // 940,130 obs.

* Keep one obs. per household-unit-year
sort hushnr aar gnr bnr seksjonsnr matrikkelenhetid pris
duplicates drop hushnr aar gnr bnr seksjonsnr matrikkelenhetid, force // 1,066,221 obs.

drop person_id 
bysort hushnr aar: egen anthus = count(matrikkelenhetid)

preserve

collapse anthus, by(hushnr aar)
g anthus1 = anthus[_n+1] if hushnr == hushnr[_n+1] & aar == aar[_n+1] - 1
g anthus2 = anthus[_n+2] if hushnr == hushnr[_n+2] & aar == aar[_n+2] - 2

tempfile anthus
save `anthus'

restore

merge m:1 hushnr aar using `anthus', keep(match) nogen

replace p_rom2 = p_rom if p_rom2 == .
bysort hushnr aar: egen max_p = max(p_rom2)
bysort hushnr aar: egen ant_p = count(p_rom2)

keep if pris != .

* Making dummy inv for investors, those with multiple houses one years after buying
g inv = anthus > 1 & anthus1 > 1 & anthus1 != .

* inv2 for investors with multiple houses one and two years after buying
g inv2 = anthus > 1 & anthus1 > 1 & anthus1 != . & anthus2 > 1 & anthus2 != .

* New houses which are bigger than other owned houses not classified as investments
g inv3 = inv
recode inv3 (1 = 0) if p_rom2 == max_p & ant_p > 1 // 1,797 changes

* Same as above, but only if all owned houses have information on area
g inv4 = inv
recode inv4 (1 = 0) if p_rom2 == max_p & ant_p > 1 & ant_p == anthus // 962 changes
drop max_p ant_p 

g month = mofd(sifut)

save investors, replace

* Replacing missing housing size
replace p_rom = boa if p_rom == . // 12,178 obs.
replace p_rom = boa if p_rom < 10 & boa != .
drop if p_rom < 10 // 3 obs.
sum p_rom, d
drop if p_rom > r(p99)

* Import housing prices from nefind.dta
clear all
use nefind

keep ialt Oslo 

g month = mofd(ialt)
drop ialt

g pvekst = (Oslo - Oslo[_n-1])/Oslo[_n-1]
g pvekstq = (Oslo - Oslo[_n-3])/Oslo[_n-3]
g pveksty = (Oslo - Oslo[_n-12])/Oslo[_n-12]
g pvekst2 = (Oslo[_n-1] - Oslo[_n-2])/Oslo[_n-2]
g pvekstq2 = (Oslo[_n-1] - Oslo[_n-4])/Oslo[_n-4]
g pveksty2 = (Oslo[_n-1] - Oslo[_n-13])/Oslo[_n-13]

merge 1:m month using investors, keep(match) nogen

g loslo = log(Oslo)

compress

save investors_2, replace

