// Epidemics profile

clear

epi_sir, beta(0.90) gamma(0.1) ///
         susceptible(10000) infected(100) recovered(0.00) ///
		 days(50) clear 
		 
local d=r(d_maxinfect)
local d1=`d'+1

generate double s1=S
label variable s1 "`:variable label S'"
generate double s2=S+I
label variable s2 "`:variable label I'"
generate double s3=S+I+R
label variable s3 "`:variable label R'"

twoway area s3 s2 s1 t , title("SIR model ({&beta}=0.90, {&gamma}=0.1)") ///
    || scatteri `=s1[`d1']' `d' `=s2[`d1']' `d', ///
	recast(line) lcolor(red) lwidth(medthick) ///
	|| scatteri `=s1[`d1']' `d' `=s2[`d1']' `d', mcolor(red) ///
	legend( ///
	  order(3 2 1 4) pos(bottom) rows(1) ///
	  region(fcolor(none)) label(4 "Peak infected") ///
	)
	
// end of file
