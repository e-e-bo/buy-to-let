/**********************************************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 21.05.2026 

Calculates the moments used in the MSM estimation in "Buy to let".

Input: investors_2.dta created by /prep/BTL_ownership.do; leieoslo.dta 
 created by prep/Rent_and_price_indices.do; cpimall.xslx from /data; 
oslobygg.dta created by prep/Export_owners.sas; 

Output: investors_3.dta; investors_4.dta; osloprisnorm.dta; 
 moments_MSM.csv.
**********************************************************************/

* Adding inflation
clear all
import excel cpimall.xlsx, first
g m2 = string(month)+"."+string(year)
drop month year
g month = monthly(m2,"MY")
drop m2

merge 1:m month using investors_2, keep(match) nogen

drop if faar < 2007

g kvart = qofd(sifut)
g kv = quarter(sifut)

drop bydel boligverdi - baar
save investors_3, replace

* Adding bydel
use oslobygg, clear

compress

destring bygningsnr - inngangsnr etasjenr leilighetsnr byggeaar, replace

save oslobygg, replace

keep gaardsnr bruksnr bydel 
rename (gaardsnr bruksnr) (gnr bnr)
destring gnr bnr, replace
sort gnr bnr 
drop if gnr == gnr[_n-1] & bnr == bnr[_n-1]

merge 1:m gnr bnr using investors_3, keep(match using) nogen

destring bydel, replace

save investors_4, replace


*****************************************
* Adjusting housing prices for compostion
*****************************************
set more off
clear all 
use investors_4

* Replace missing/unreasonable values of p_rom
replace p_rom = boa if p_rom == . // 12,178 obs.
replace p_rom = boa if p_rom < 10 & boa != .
drop if p_rom < 10 // 3 obs.

drop boligtype ant_et boa bra 
destring etasje, replace

g leilpris = pris if substr(eiendtype,1,1) == "3"

* Adjust for inflation
replace pris = pris * (100 / cpi)
replace leilpris = leilpris * (100 / cpi)

g ald = aar - byggeaar
replace ald = . if ald > 1000 // One obs. of ald 1802

g aldg = ald < 6
replace aldg = 2 if inrange(ald,6,10) 
replace aldg = 3 if inrange(ald,11,20) 
replace aldg = 4 if inrange(ald,21,30) 
replace aldg = 5 if inrange(ald,31,40) 
replace aldg = 6 if inrange(ald,41,50) 
replace aldg = 7 if inrange(ald,51,100) 
replace aldg = 8 if inrange(ald,101,400) 

replace aldg = . if ald == .

g btype = substr(eiendtype,1,1)
destring btype, replace

rename felleesformue fellesf
recode fellesf (. = 0)
recode fellesgj (. = 0)

g nfgj = fellesgj - fellesf
replace nfgj = nfgj * (100 / cpi)

replace etasje = . if etasje > 19 // 2 obs.
replace etasje = 10 if etasje > 10 & etasje < . // 84 obs.
replace etasje = 1 if btype != 3
replace etasje = 1 if etasje == 0 // 117 obs.

* Housing price index
reg pris p_rom nfgj i.etasje i.btype i.aldg i.bydel i.month
qui reg pris p_rom nfgj i.etasje i.btype i.aldg i.bydel ibn.month, noconst

mat res = e(b)
mat res2 = res[.,1..40]
mat res3 = res[.,41..130]

keep if e(sample)

qui tab btype, g(dbt)
qui tab etasje, g(det)
qui tab aldg, g(dal)
qui tab bydel, g(dby)

mata: 
	X = st_data(.,("p_rom", "nfgj", "det*", "dbt*", "dal*", "dby*"))
	beta = st_matrix("res2")
	beta2 = st_matrix("res3")

	M = mean(X)

	est = beta*M'
	est2 = est*J(1,cols(beta2),1)+beta2

	st_matrix("E",est)
	st_matrix("E2",est2')

end


collapse kv inv* pris leilpris mndsol kvart faar cpi p_rom (median) medpris=pris (median) medlpris=leilpris (count) np=pris, by(month) 

svmat double E2

save osloprisnorm, replace

use osloprisnorm,clear

* Quarterly values
collapse kv inv inv2 pris leilpris E21 cpi medpris medlpris (sum) np2=np, by(kvart) 

* Adding rental data
merge 1:1 kvart using leieoslo, keep(match) nogen 

* Inflation adjustments
replace leiea = leiea * (100 / cpi)

*Adjusting for quarterly seasonal effects
foreach var of varlist inv inv2 pris leilpris medpris medlpris np2 leiea E21 {	
	egen m`var' = mean(`var')
	reg `var' i.kv
	predict r`var', res
	g a`var' = m`var' + r`var'
}


* Quarterly rent
g aqleie = aleiea*3

* Median quarterly rent to housing price
g rentprice = aqleie / E21

keep ainv rentprice E21 aqleie anp2
order aqleie anp2, last
order ainv

replace E21 = round(E21) / 100000
replace aqleie = round(aqleie) / 1000

* Simulation over 22 quarters.
keep in 9/30

export delim /data/moments_MSM, replace novar
