// Demonstrates the plotting of the peak value/label

	clear all
	version 16.0

	local params beta(0.50) gamma(0.33333) 
	local init susceptible(60.4e+06) infected(1000) recovered(0.00)
	local opts days(100) clear day0("2020-02-01") percent 
	local model epi_sir, `params' `init' `opts' 

	quietly `model' nograph
	local maxi=r(maxinfect)
	local maxt=r(t_maxinfect)

	quietly summarize t, meanonly
	local lastday=r(max)

	local col "red"
	local maxdate = string(`maxt', "%dCY-N-D")
	local maxf=string(`maxi',"%6.2f")
	local atext="peak value: `maxf'% on `maxdate'"
	
	`model' ///
	   lcolor(blue red green) lwidth(medthick medthick medthick) ///
	   yline(`maxi', lcolor(`col') lpattern(-..-)) ///
	   text(`maxi' `lastday' "`atext'" , color(`col') size(vsmall) ///
	   placement(10) justification(right)  margin(0 0 1 0)) 

// end of file
