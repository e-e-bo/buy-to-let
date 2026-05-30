/**************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 31.05.2026 

Measuring the yearly number of 
 registred transactions in Oslo.
 Table A.2 in "Buy to let".

Input: ambita_oslo_full.dta created by
 /prep/Import_ambita.do; 
finndata.dta created by
 /prep/Export_finndata.sas; 
Housing_stock.xlsx from Statistcs
 Norway's Statbank;

Output: antting_ambita.dta; 
 moveshock_ambita.dta;
 trans_rate.csv; 
**************************************/


* Yearly number of registred transactions

use ambita_oslo_full, clear

drop if brukavgrunnkode!="B" & antallboenheter==0 // 24,716 obs.

* Only one observation per transaction
keep if rolle == "Kjøper"

duplicates drop dokumentnr daar, force

drop if daar == 2006

g borett = 1-selveier

collapse (sum) antbo_r=borett (sum) antselv_r=selveier (count) antting=kjøpesum, by(daar)

rename daar aar

save antting_ambita, replace


* Yearly number of transactions through finn.no
use finn2, clear

drop id festenr bta megler adresse baatplass

destring kommune gnr bnr seksjonsnr etasje, replace force
keep if kommune == 301
*drop if gnr == . 

keep if aar > 2006

drop if eieform == "Annet" // 33 obs.
drop if eieform == "Leilighet" // 1 obs.

g borett = inlist(eieform,"Andel","Obligasjon")
g aksje = eieform == "Aksje"
g selveier = borett == aksje == 0

collapse (sum) antbo_f=borett (sum) antak_f=aksje (sum) antselv_f=selveier, by(aar)

merge 1:1 aar using antting_ambita, nogen

g andfi_s = antselv_f / antselv_r
g andfi_b = antbo_f / antbo_r

save moveshock_ambita, replace


* The total number of residential housing from Statistikkbanken
clear
import excel Housing_stock.xlsx, first

keep if aar > 2006
keep if aar < 2014

merge 1:1 aar using moveshock_ambita, keep(match) nogen 

egen andfi_b2 = mean(andfi_b)

g antak2 = round(antak_f / andfi_b2)

g anttot = antting + antak2

g andmove = (antting + antak2) / sum4

mkmat aar antselv_r antbo_r antbo_f andfi_b antak_f antak2 anttot sum4 andmove, mat(MS)

mata: 
	ms = st_matrix("MS")
	ms2 = ms \ mean(ms)
	ms3 = round(ms2,.0001)
	st_matrix("MS2",ms3)
end	

outtable using matrixmsa, mat(MS2) replace nobox center norowlab caption("Housing transaction numbers") 

* Export values to matlab
clear
svmat MS2

keep in 1/8

keep MS21 MS210
expand 4
sort MS21
drop MS21

keep in 9/30

export delim ~/Matlab/trans_rate, replace novar


