/**************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 14.01.2026 
Measuring the population inflow and 
 outflow to Oslo, for the paper 
 "Buy to let".

Input: Befoloslokvart_full_ex.xlsx from
 Statistcs Norway's Statbank. 

Output: inflow_out.dta; inflow22.csv.
***************************************/

* Import population data
clear all
import excel Befoslokvart_full_ex.xlsx, first

g inflow = Innvandring + Innflytting
g outflow = Utvandring + Utflytting
g netflow = inflow - outflow

g shinflow = inflow / Bef
g shoutflow = outflow / Bef
g shnflow = netflow / Bef

g kva = substr(A,1,4)+"."+substr(A,6,1)
g kvart = quarterly(kv,"YQ")
g kv = quarter(dofq(kvart))

* Adjusting for quarterly seasonal effects
*reg shinflow kvart	
egen msh = mean(shinflow) in 1/73
reg shinflow i.kv in 1/73
predict rsh, res
g ash = msh + rsh

egen msho = mean(shoutflow) in 1/73
reg shoutflow i.kv in 1/73
predict rsho, res
g asho = msho + rsho

egen mshn = mean(shnflow) in 1/73
reg shnflow i.kv in 1/73
predict rshn, res
g ashn = mshn + rshn

save inflow_out, replace

* T test pre versus simulation period
g pre = 1 in 1/37
replace pre = 0 in 38/67

ttest ash, by(pre)
ttest asho, by(pre)	

g pre2 = 1 in 1/37
replace pre2 = 0 in 46/67

ttest ash, by(pre2)
ttest asho, by(pre2)

********************************
* Export vector of inflow shocks
********************************
use inflow_out, clear 

keep ash 
keep in 46/67

export delim ~/Matlab/inflow22, replace novar
