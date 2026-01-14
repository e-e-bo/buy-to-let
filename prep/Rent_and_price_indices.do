/*******************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 14.01.2026

This code imports rental prices for Oslo
 from Boligbygg and housing prices from 
 NEF, for the paper "Buy to let". 
 It adjusts these price indices with
 inflation.
 
Input: cpimall.xlsx from Statistcs Norway's 
 Statbank;
 Leieoslo.xlsx from Boligbygg; 
 NEFindex.xlsx from NEF 
 
 
Output: leieoslo.dta; nefind.dta; plind.dta;
nefrind.dta.
*******************************************/

* Import rental prices from Boligbygg
clear all
import excel Leieoslo.xlsx, first

egen leiea = rowmean(byd_*)

g a = substr(A,2,1) + "." + substr(A,3,.)
g kvart = quarterly(a,"QY")

drop A a

save leieoslo, replace

*Boligprisindeks fra Eiendom Norge
clear all
import excel NEFindex.xlsx, first

set more off
g sifmnd = mofd(ialt)

g mnd = .
forv i = 1/12 {
	forv j = 0/10 { 
		replace mnd = `i' if sifmnd == 515 + `i' + (12 * `j')
	}
}

save nefind, replace

* Making quarterly indices
keep ialt Oslo

g kvart = qofd(ialt)

collapse Oslo, by(kvart)

merge 1:1 kvart using leieoslo, keep(match) nogen
	
g indleie = (leiea * 100) / leiea[1]
g indpris = (Oslo * 100) / Oslo[1]

drop byd_*

save plind, replace 

* Adjusted for inflation
clear all
import excel cpimall.xlsx, first
g m2 = string(month)+"."+string(year)
drop month year
g sifmnd = monthly(m2,"MY")
drop m2

merge 1:m sifmnd using nefind, keep(match) nogen

keep cpi sifmnd ialt Oslo

g rOslo = Oslo * (100 / cpi)

g kvart = qofd(ialt)

save nefrind, replace
