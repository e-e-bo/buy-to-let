/**************************************
Written by Erlend Eide Bø // eeb@ssb.no

Last changed 02.02.2026 

Import data on registered housing 
 transactions from Ambita, 
 for the paper "Buy to let".

Input: Csv-files obtained from Ambita.

Output: borett_2006_2007.dta;
 borett_2008_2012.dta; borett_2013_2016.dta;  
 eiendom_2003_2007.dta.; eiendom_2008_2012.dta; 
 eiendom_2013_2016.dta.
*************************************/

clear
import delim using "Omsetning_borett_2005-12-31_2008-01-01.csv", delimiters(";") varn(1)

drop embetenr rettsstiftelsestype dokumenttypekode dokumenttype borettslag_navn bygningmediomsetningen tomtestørrelseareal bygningstype etasje

compress

foreach var of var bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bebygdareal {
	replace `var' = subinstr(`var', ",", ".", .)
}
destring bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bebygdareal, replace

g selveier = 0

save borett_2006_2007, replace

clear
import delim using "Omsetning_borett_2007-12-31_2013-01-01 .csv", delimiters(";") varn(1)

drop embetenr rettsstiftelsestype dokumenttypekode dokumenttype borettslag_navn bygningmediomsetningen tomtestørrelseareal bygningstype etasje

compress

foreach var of var bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bebygdareal {
	replace `var' = subinstr(`var', ",", ".", .)
}
destring bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bebygdareal, replace

g selveier = 0

save borett_2008_2012, replace

clear
import delim using "Omsetning_borett_2012-12-31_2017-01-01 .csv", delimiters(";") varn(1)

drop embetenr rettsstiftelsestype dokumenttypekode dokumenttype borettslag_navn bygningmediomsetningen tomtestørrelseareal bygningstype etasje

compress

foreach var of var bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bebygdareal {
	replace `var' = subinstr(`var', ",", ".", .)
}
destring bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bebygdareal, replace

g selveier = 0

save borett_2013_2016, replace

clear
import delim using "Omsetning_eiendom_2002-12-31_2008-01-01 .csv", delimiters(";") varn(1)

drop embetenr rettsstiftelsestype dokumenttypekode dokumenttype eiendomadressegatenavn bygningmediomsetningen tomtestørrelseareal bygningstype etasje

compress

foreach var of var bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bruttoarealannet bebygdareal {
	replace `var' = subinstr(`var', ",", ".", .)
}
destring bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bruttoarealannet bebygdareal, replace

g selveier = 1 

save eiendom_2003_2007, replace

clear
import delim using "Omsetning_eiendom_2007-12-31_2013-01-01 .csv", delimiters(";") varn(1)

drop embetenr rettsstiftelsestype dokumenttypekode dokumenttype eiendomadressegatenavn bygningmediomsetningen tomtestørrelseareal bygningstype etasje

compress

foreach var of var bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bruttoarealannet bebygdareal {
	replace `var' = subinstr(`var', ",", ".", .)
}
destring bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bruttoarealannet bebygdareal, replace

g selveier = 1 

save eiendom_2008_2012, replace

clear
import delim using "Omsetning_eiendom_2012-12-31_2017-01-01 .csv", delimiters(";") varn(1)

drop embetenr rettsstiftelsestype dokumenttypekode dokumenttype eiendomadressegatenavn bygningmediomsetningen tomtestørrelseareal bygningstype etasje

compress

foreach var of var bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bruttoarealannet bebygdareal {
	replace `var' = subinstr(`var', ",", ".", .)
}
destring bruksarealbolig bruksarealannet bruksarealtotalt bruttoarealbolig bruttoarealtotalt bruttoarealannet bebygdareal, replace

g selveier = 1 

save eiendom_2013_2016, replace
