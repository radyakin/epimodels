clear all

local i=0
forval b=0.3(0.1)0.8 {
	epi_sir, days(100) nograph /// 
			  beta(`b') gamma(0.13) ///
			  susceptible(60.4e+04) infected(1) 
	local bstr=string(`b',"%6.2f")
	label variable I `"Infected ({&beta}=`bstr')"'
	local i=`i'+1	
	rename I I`i'
	local v=`"`v' I`i'"'
	drop S R
	if ("`bstr'"!="0.80") drop t
}

twoway line `v' t, ///
   ylabel(,format(%10.0gc)) graphregion(fcolor(white)) ///
   title("SIR model ({&gamma}=0.13)") ///
   note("Note: Higher values of {&beta} correspond to higher peak values for number of infected.", color(gray))

// end of file		  
