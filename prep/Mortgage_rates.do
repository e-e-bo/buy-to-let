/**************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 06.01.2026 

Data on mortgage rates in Norway,
 2007-2014, for the paper "Buy to 
 let".

Input: Mortgage rates_ex.xlsx from 
 Excel. 

Output: mort_rates.dta;
**************************************/

* Import mortgage data
clear all
import excel "Mortgage rates_ex.xlsx", first

g kva = string(year)+"."+string(quart)
g  kvart = quarterly(kva,"YQ")
drop kva
format kvart %tq

save mort_rates, replace
