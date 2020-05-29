// Demonstrate that higher betas not necessarily mean earlier peak of infection.
clear all

frame create results
frame results: generate b=.
frame results: generate d=.
frame results: generate mi=.

local gamma=0.25
local s=1000
local i=10
local days=60

forval b=0.01(0.01)0.99 {
    epi_sir, beta(`b') gamma(`gamma') ///
	         susceptible(`s') infected(`i') ///
	         days(`days') nograph clear
	local d=`r(d_maxinfect)'
	local mi=`r(maxinfect)'
	quietly {
		frame change results
			set obs `=_N+1'
			replace b=`b' in L
			replace d=`d' in L
			replace mi=`mi' in L
		frame change default
	}
}

frame change results
twoway line d b || scatter d b, msize(vsmall) scale(0.75) name(d) ///
   xtitle("{&beta}") ytitle("Day of peak infected") legend(off)
   
twoway line mi b || scatter mi b, msize(vsmall) scale(0.75) name(mi) ///
    xtitle("{&beta}") ytitle("Maximum number of infected") legend(off)
	
graph combine d mi, cols(1) xsize(6) ysize(6) ///
  title("SIR model predictions for {&gamma}=`gamma' and varying {&beta}.", ///
    size(medium)) ///
  note("Note: starting with a population of `s' susceptible and `i' infected at t0," ///
    "modeling over `days' days", color(gray))
  

// end of file