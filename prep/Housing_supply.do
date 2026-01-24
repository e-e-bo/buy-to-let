/**************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 24.01.2026 

Data on housing supply in Oslo,
 for the paper "Buy to let".

Input: Antbolig_full_ex.xlsx; 
 Boligbygg_ex.xlsx from Statistcs
 Norway's Statbank; 
 inflow_out.dta from Pop_oslo.do.

Output: antbolig.dta; antbolig_y.dta;  
 boligbygg.dta.
*************************************/

* Import data on housing numbers

* Stock at the beginnging of the year (01.01)
clear all
import excel Antbolig_full_ex.xlsx, first

destring aar, replace
drop if aar == .

keep aar sum2

save antbolig_y, replace

* Constructed during year
clear all
import excel Boligbygg_ex.xlsx, first

g aar = substr(kva,1,4)
destring aar, replace
drop if aar == .

g kv = substr(kva,1,4)+"."+substr(kva,6,1)
g  kvart = quarterly(kv,"YQ")

save boligbygg, replace

