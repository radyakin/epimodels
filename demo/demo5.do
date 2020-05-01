// Social distancing policy simulation

clear all
version 16.0

local interventiondate=7
local modelwindow=60
local betaA=0.90
local betaB=0.30

local notetxt = "Note: social distancing policy reducing intensity of " ///
              + "spread of the disease from {&beta}=`betaA' to " ///
			  + "{&beta}=`betaB' after `interventiondate' days."

local inicond0 "susceptible(10000) " ///
             + "infected(50) " ///
	         + "recovered(0)"

epi_sir, beta(`betaA') gamma(0.1) `inicond0' ///
		 days(`modelwindow') clear day0(2020-02-01) nograph
		 
local mA `r(maxinfect)'
local d1=t[`interventiondate']
local inicond1 = "susceptible(`=S[`interventiondate']') " ///
               + "infected(`=I[`interventiondate']') " ///
	           + "recovered(`=R[`interventiondate']')"
			 
label variable I "Infected, no intervention ({&beta}=0.9)"
sort t
tempfile tmp
save `"`tmp'"'
clear

local day1=string(`d1',"%tdCY-N-D")

epi_sir, beta(`betaB') gamma(0.1) `inicond1' ///
		 days(`=`modelwindow'-`interventiondate'+1') ///
		 clear day0(`day1') nograph
		 
local mB `r(maxinfect)'

label variable I "Infected, with intervention ({&beta}=0.3)"

rename S SB
rename I IB
rename R RB

sort t
merge t using `"`tmp'"'
sort t
local z=t[`interventiondate']
local effect "`mB' `z' `mA' `z'"
twoway line I IB t, xlabel(`=t[1]'(15)`=t[`=_N']') ///
  lcolor(maroon navy) lwidth(medthick medthick) ///
  xline(`z', lpattern("-") lcolor(green)) ///
  || scatteri `effect', recast(line) color(green) lwidth(medthick) ///
  || scatteri `effect', msize(large) msymbol(plus) color(green) ///
  legend(order(1 2 3) label(3 "reduction in peak due to intervention") ///
  position(bottom) rows(2) region(fcolor(none))) ///
  title("Effect of intervention (social distancing) in SIR model") ///
  note("`notetxt'", color(gray) size(vsmall))

// end of file
