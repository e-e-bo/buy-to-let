/*******************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 07.05.2026

This code analyses repeat sales over class
 of buyer.
 Results presented in Table 2.
 
Input: investors.dta created by
 /prep/BTL_ownership.do
 
Output: 
*******************************************/

use investors, clear

replace inv = . if aar == 2015 

sort gnr bnr seksjonsnr aar
duplicates tag gnr bnr seksjonsnr etasjenr løpenr gate_gaardsnr hus_bruksnr bokstav_festenr, g(msale)

egen msaleg = group(gnr bnr seksjonsnr etasjenr løpenr gate_gaardsnr hus_bruksnr bokstav_festenr), missing

g inv_p2 = inv[_n+1] if msale == 1 & msaleg[_n+1] == msaleg
g inv_p1 = inv[_n-1] if msale == 1 & msaleg[_n-1] == msaleg

* Take out repeat sales within 1 year
drop if msaleg == msaleg[_n+1] & sifut[_n+1] - sifut <= 365

sum inv if msale == 1 & msaleg[_n-1] == msaleg & inv[_n-1] == 1
sum inv if msale == 1 & msaleg[_n-1] == msaleg & inv[_n-1] == 0
sum inv if msale == 1 & msaleg[_n+1] == msaleg & inv[_n+1] == 0
sum inv if msale == 1 & msaleg[_n+1] == msaleg & inv[_n+1] == 1

corr inv inv_p2
