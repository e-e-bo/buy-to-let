/*******************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 06.05.2026

This code checks the share of investors with 
 residential address in Oslo or nearby. 
 Results referenced on p. 662.
 
Input: investors.dta created by
 /prep/BTL_ownership.do
 
Output: 
*******************************************/

use investors, clear

replace inv = . if aar == 2015 
drop if faar < 2007 // Coops only from 2007

g inv_o = inv == 1 & bokomnr == "0301" // Oslo
g inv_oo = inv == 1 & inlist(bokomnr,"0213","0217","0219","0220","0230","0231","0233","0301") // Oslo, Ski, Oppegård, Bærum, Asker, Lørenskog, Skedsmo and Nittedal

sum inv if bokomnr!=""
sum inv_o if bokomnr!=""
sum inv_oo if bokomnr!=""

di .121/.204
di .148/.204


* Time-dimension of the share (added 03.07.2023)
collapse inv*, by(month)
g invsh_o = inv_o / inv
g invsh_oo = inv_oo / inv

format month %tm
line invsh_o month || line invsh_oo month || if month < 645, graphregion(fcolor(white)) scheme(s2mono) // (data on bokomnr limited at the end of 2013, and not existing afterwards)
line invsh_o month || line invsh_oo month || if month < 636, graphregion(fcolor(white)) scheme(s2mono) // (data on bokomnr last covers 31.12.2012)

g year = year(dofm(month))

table year if year < 2013, stat(mean invsh_o) 
table year if year < 2013, stat(mean invsh_oo)
