program define epi_siz, rclass
    // covid-19
    version 16.0

	syntax , [lambda(real 0.00) theta(real 0.00) alpha(real 0.00) ///
	         mu1(real 0.00) mu2(real 0.00) mu3(real 0.00) mu4(real 0.00) ///
			 pi(real 0.00) psi(real 0.00) omega(real 0.00) ///
	         pops(real 0.00) popz(real 0.00) popi(real 0.00) popr(real 0.00) ///
			 poprt(real 0.00) poph(real 0.00) popc(real 0.00) popd(real 0.00) ///
			 days(real 30) day0(string) steps(real 1) percent ///
			 colormodel nograph ///
			 newframe(string) pdfreport(string) clear *]

	// checking proportions
	if (!inrange(`pi',0,1) | !inrange(`psi',0,1) | !inrange(`omega',0,1)) {
	    display as error "Error! Parameters which are proportions must be in the [0;1] range!"
		error(101)
	}
	
	local datefmt "%dCY-N-D"
	//      define default colors for           S    Z    I      H     R      RT     C      D	
	if (`"`colormodel'"'!="") local lc `"color(blue red orange cyan  green  black  maroon pink)"'
			 
	local modeltitle = "SIZ Model"
	local totpop = `pops' + `popz' + `popi' + `popr' + `poprt' + `poph' + `popc' + `popd'
	epimodels_util check_total_population `totpop'
	epimodels_util check_day0_date `day0'
	epimodels_util check_days `days'
	
	tempname M		 
	mata epimodels_siz("`M'")

	local mcolnames "t S Z I H R RT C D"
	local varlabels `""Time""'
	local varlabels `"`varlabels' "(S) Susceptible""'
	local varlabels `"`varlabels' "(Z) Asympt. inf. that will not require hospitalization""'
	local varlabels `"`varlabels' "(I) Sympt. inf. that will need hospitalization eventually""'
	local varlabels `"`varlabels' "(H) Hospitalized not in intensive care""'
	local varlabels `"`varlabels' "(R) Recovered""'
	local varlabels `"`varlabels' "(RT) Removed temporarily""'
	local varlabels `"`varlabels' "(C) Intensive care""'	
	local varlabels `"`varlabels' "(D) Dead""'   
	    
	//mata st_local("indexi", strofreal(epi_wordpos(strupper(st_local("mcolnames")),"I")))

	// todo: if {opt nodata} has been specified, do not put data to any dataset
	// todo: if frame name has been specified, put the data into that frame
	// todo: potentially calculate fully (with step 0.01), but report only the integer nodes.
	// todo: expose the step
		
	if (`"`percent'"'=="percent") {
	  tempname Z
	  matrix `Z' = `M'[1..`=rowsof(`M')',2...] * 100 / `totpop'
	  matrix `M' = `M'[1..`=rowsof(`M')',1] , `Z'
	  local ylabel="% of population"
	  local mcolnames = `"`=strlower("`mcolnames'")'"'
	  local digits=2
	  local tc=""
	}
	else {
	  local ylabel="Population"
	  local digits=0
	  local tc="c"
	  local yf = "ylabel(,format(%20.4gc))"
	}

	matrix colnames `M' = `mcolnames'
	
	`clear'
	quietly svmat double `M', names(col)
	
	label variable t "Time, days"
	forval q=2/`:word count `mcolnames'' {
	  label variable `:word `q' of `mcolnames'' "`:word `q' of `varlabels''"
	}
	
	epimodels_util makedatevar t, day0(`"`day0'"') datefmt("`datefmt'")
	
	return matrix siz=`M'
	
	tempname ivar
	if ("`percent'"=="percent") generate double `ivar'= i+z
	else generate double `ivar'=I+Z

	epimodels_util ditable t, ///
	    days(`days') day0(`"`day0'"') ///
		modeltitle(`"`modeltitle'"') ylabel(`"`ylabel'"') ///
        datefmt(`"`datefmt'"') digits(`digits') comma(`tc') ///
        mcolnames(`"`mcolnames'"') varlabels(`"`varlabels'"') ///
		ivar(`ivar') `percent'
		
	return scalar maxinfect=r(maxinfect)
	return scalar t_maxinfect=r(t_maxinfect)
	return scalar d_maxinfect=r(d_maxinfect)
    return scalar o_maxinfect=r(o_maxinfect)	
	return local model_params="{&lambda}=`lambda', {&theta}=`theta', {&alpha}=`alpha', {&mu1}=`mu1', {&mu2}=`mu2', {&mu3}=`mu3', {&mu4}=`mu4', {&pi}=`pi', {&psi}=`psi', {&omega}=`omega'"
	mata st_local("greek", epi_greek("lambda = `lambda', theta = `theta', alpha = `alpha', mu1 = `mu1', mu2 = `mu2', mu3 = `mu3', mu4 = `mu4', p = `pi', q = `psi', omega = `omega'"))
	local greek=subinstr(`"`greek'"'," = ","=",.)	
	return local umodel_params="`greek'"
	
	if (`"`graph'"'=="nograph") exit

	local t t
	if (`"`graph'"'!="nograph") {
		twoway line `: list mcolnames - t' t, ///
		   legend(cols(2) pos(6) region(lwidth(none) )) ///
		   xtitle("`:variable label t'") ytitle(`"`ylabel'"') ///
		   title(`"`modeltitle'"') `yf' `lc' xlabel(, grid) scale(0.5) `options'
		   
		if (`"`pdfreport'"'!="") {
			tempfile modelimg
			local modelimg `"`modelimg'.png"'
			quietly graph export `"`modelimg'"', as(png)
	    }
	}   
	   
	if (`"`pdfreport'"'!="") {
		capture noisily epimodels_util pdfreport `mcolnames', ///
			modelname("SIZ") modelparams("`greek'") ///
			modelgraph(`"`modelimg'"') save("`pdfreport'")
		local rc=_rc
		
		if (`"`modelimg'"'!="") capture erase `"`modelimg'"'
		error `rc'
	}   
	   
end

// END OF FILE
