program define epi_sir, rclass

    version 16.0

	syntax , [beta(real 0.00) gamma(real 0.00) ///
	         susceptible(real 0.00) infected(real 0.00) recovered(real 0.00) ///
			 days(real 30) day0(string) nograph clear newframe(string) *]

	local iterations= /*100* */ `days'
	tempname M		 
	mata epimodels_sir("`M'")

	matrix colnames `M' = t S I R

	// todo: if {opt nodata} has been specified, do not put data to any dataset
	// todo: if frame name has been specified, put the data into that frame
	// todo: potentially calculate fully (with step 0.01), but report only the integer nodes.
	// todo: expose the step
	`clear'
	quietly svmat double `M', names(col)
	
	label variable t "Time, days"
	label variable S "Susceptible"
	label variable I "Infected"
	label variable R "Recovered"

	if (`"`day0'"'!="") {
	  replace t=t+date(`"`day0'"',"YMD")
	  format t %dCY-N-D
	  label variable t "Date"
	}
	
	return matrix sir=`M'
	
	if (`"`graph'"'=="nograph") exit
	
	twoway line S I R t, ///
	   legend(cols(1) ring(0) pos(2) region(lwidth(none) )) ///
	   xtitle("`:variable label t'") ytitle("Population") title("SIR Model") ///
	   color(blue red green) ///
	   xlabel(, grid) scale(0.85) `options'
end

// END OF FILE
