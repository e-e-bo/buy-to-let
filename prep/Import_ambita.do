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
 eiendom_2013_2016.dta; ambita_oslo.dta;
 ambita_bor.dta; ambita_selv1516.dta;
 ambita_oslo_full.dta.
*************************************/

******************************
* Importing from .csv to Stata
******************************
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

*********************
* Preparing data sets
*********************

* Transactions
use borett_2006_2007, clear

append using borett_2008_2012 borett_2013_2016 eiendom_2003_2007 eiendom_2008_2012 eiendom_2013_2016

keep if kommunenr == 301 // Oslo

rename dokumentår daar

drop if inlist(daar,2003,2004,2005)

keep if inlist(omsetningstypekode,1,8) // Free sales & Other
keep if inlist(brukavgrunnkode,"B","A","U") // Housing, Other & Not given

drop boligtype brukavgrunn omsetningstype eiendomadressegatenavn festenr 

save /ssb/stamme03/sparing/skatt/wk24/ambita_oslo.dta, replace


* Co-op ownership history
use borett_2006_2007, clear

append using borett_2008_2012 borett_2013_2016

rename dokumentår daar

*drop if inlist(daar,2003,2004,2005)

keep if inlist(omsetningstypekode,1,8) // Free sales & Other
keep if inlist(brukavgrunnkode,"B","A","U") // Housing, Other & Not given

drop boligtype brukavgrunn omsetningstype eiendomadressegatenavn poststed 

save /ssb/stamme03/sparing/skatt/wk24/ambita_bor.dta, replace


* Ownership exit 2015/2016
use eiendom_2013_2016

rename dokumentår daar
drop if inlist(daar,2013,2014)

keep if inlist(omsetningstypekode,1,8) // Free sales & Other
keep if inlist(brukavgrunnkode,"B","A","U") // Housing, Other & Not given

drop boligtype brukavgrunn omsetningstype poststed festenr

save /ssb/stamme03/sparing/skatt/wk24/ambita_selv1516.dta, replace

* Full set of transactions
use borett_2006_2007, clear

append using borett_2008_2012 borett_2013_2016 eiendom_2003_2007 eiendom_2008_2012 eiendom_2013_2016

keep if kommunenr == 301 // Oslo

rename dokumentår daar

drop if inlist(daar,2003,2004,2005)

*keep if inlist(omsetningstypekode,1,8) // Free sales & Other
keep if inlist(brukavgrunnkode,"B","A","U") // Housing, Other & Not given

drop boligtype brukavgrunn omsetningstype eiendomadressegatenavn festenr 

save /ssb/stamme03/sparing/skatt/wk24/ambita_oslo_full.dta, replace

