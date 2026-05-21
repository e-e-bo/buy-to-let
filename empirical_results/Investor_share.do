/**********************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 21.05.2026

Regressions of investor share on housing 
 price growth. Table 1 and Table D1 in
 "Buy to Let".

Input: investors_2.dta created by
 /prep/BTL_ownership.do;
tax.dta created by /prep/Export_taxdata.sas.
 
Output: investors_inc.dta; tab1a.tex; 
 tabd1b.tex; tabd1c.tex; tab1b.tex; tabd1a.tex.
**********************************************/

****************
* Investor share
****************
use investors_2, clear

replace inv = . if aar == 2015 
replace inv2 = . if aar == 2014 
replace inv2 = . if aar == 2015 

drop if faar < 2007 // Coops only from 2007

sum inv*

* Share of investment transactions and other transactions that are apartments
g leil = substr(eiendtype,1,1) == "3"
sum leil if inv == 1
sum leil if inv == 0

sum inv* if selveier == 1
sum inv* if selveier == 0

collapse pv* inv* Oslo loslo mnd faar hposlo* (count) antinv=inv, by(month) 
	
* Table 1, Panel A
reg inv pvekstq, robust
outreg2 using tab1a, tex(frag) replace nocons 2aster 
reg inv pvekstq i.mnd, robust
outreg2 using tab1a, tex(frag) nocons 2aster 
reg inv pvekstq i.mnd faar, robust
outreg2 using tab1a, tex(frag) nocons 2aster 

* Table D1, Panel B
reg inv pvekstq2, robust
outreg2 using tabd1b, tex(frag) replace nocons 2aster 
reg inv pvekstq2 i.mnd, robust
outreg2 using tabd1b, tex(frag) nocons 2aster 
reg inv pvekstq2 i.mnd faar, robust
outreg2 using tabd1b, tex(frag) nocons 2aster


* Log number of investor transactions as outcome
g lantinv = log(antinv)

* Table D1, Panel C
reg lantinv pvekstq, robust
outreg2 using tabd1c, tex(frag) replace nocons 2aster 
reg lantinv pvekstq i.mnd, robust 
outreg2 using tabd1c, tex(frag) nocons 2aster 
reg lantinv pvekstq i.mnd faar, robust
outreg2 using tabd1c, tex(frag) nocons 2aster 
	

*******************
* Robustness, flats
*******************
clear all
use investors_2

replace inv = . if aar == 2015 
replace inv2 = . if aar == 2014 
replace inv2 = . if aar == 2015 

drop if faar < 2007

keep if substr(eiendtype,1,1) == "3"

collapse pv* inv* Oslo loslo mnd faar, by(month) 

*Table 1, Panel B
reg inv pvekstq, robust
outreg2 using tab1b, tex(frag) replace nocons 2aster 
reg inv pvekstq i.mnd, robust
outreg2 using tab1b, tex(frag) nocons 2aster 
reg inv pvekstq i.mnd faar, robust
outreg2 using tab1b, tex(frag) nocons 2aster 


***************************
* Robustness, rental income
***************************
clear all
use tax

keep fnr hushnr aar bel43_1 bel43_2 bel28_2 
rename fnr person_id

replace aar = aar - 2 

recode bel28_2 (. = 0)

sort person_id aar

* Replacing missing obs of hushnr with last year's value
replace hushnr = hushnr[_n-1] if hushnr == . & person_id == person_id[_n-1]

* Otherwise, hushnr given as fnr
replace hushnr = person_id if hushnr == .

* Aggregate income on household level
sort hushnr aar
foreach v of var bel43_1 bel43_2 bel28_2 {
	by hushnr aar: egen h`v' = total(`v')
}

* Keep one obs. per household-year
sort hushnr aar person_id
duplicates drop hushnr aar, force // 20,601,760 obs.

drop bel28_2 - person_id  

rename aar faar // Merging on transaction year, not registry year.

merge 1:m hushnr faar using investors_2, keep(match using) 

save investors_inc, replace

use investors_inc, clear

drop if month > 623  // No tax data after 2012

* Variables from tax.dta is from the tax year consistent with inv
tabulate inv, s(hbel28_2)

g invr = inv == 1 & hbel28_2 > 0 & hbel28_2 != .

drop if faar < 2007
drop if hbel28_2 == .
collapse pv* inv* Oslo mnd aar faar, by(month) 

* Table D1, Panel A
reg invr pvekstq, robust
outreg2 using tabd1a, tex(frag) replace nocons 2aster 
reg invr pvekstq i.mnd, robust
outreg2 using tabd1a, tex(frag) nocons 2aster 
reg invr pvekstq i.mnd faar, robust
outreg2 using tabd1a, tex(frag) nocons 2aster 

