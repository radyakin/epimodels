program define epimodels_util
	version 16.0
	`0'
end

program define check_total_population
    version 16.0
	syntax anything
	
	if (`anything' < 1.00+`c(epsdouble)') {
		display ""
	    display as result "Warning! Total population size (`anything') is less than 1.00"
		display as result "Make sure the initial conditions at t0 represent population groups counts in persons."
	}
end

program define check_days
	version 16.0
	syntax anything
	
	capture confirm integer number `anything'
	if (_rc) {
		display as error "Number of simulation steps (days) must an integer number."
		error 198
	}
	
	capture assert (`anything' > 0)
	if (_rc) {
	    display as error "Number of simulation steps (days) must be 1 or more."
		error 198
	}
end

program define check_day0_date
	version 16.0
	syntax [anything]
	
	if (`"`anything'"'!="") {
		if (date(`"`anything'"',"YMD")==.) {
			display as error "Option day0() is specified incorrectly."
			display as error "The date must be specified in the YYYY-MM-DD format, for example: 2020-02-29"
			error 111		  
		}
	}
end

program define makedatevar

	version 16.0
	syntax varname, [day0(string)] datefmt(string)
	
	if (`"`day0'"'!="") {
	  quietly replace t = t + date(`"`day0'"',"YMD")  // only affects the data, not the matrix
	  format t `datefmt'
	  label variable `varlist' "Date"
	}

end

program define ditable, rclass

	syntax varname, ///
	    days(real) [day0(string)] datefmt(string) ///
	    [modeltitle(string)] mcolnames(string) indexi(real) ///
		varlabels(string) ylabel(string) [digits(real 2) comma(string) percent]

	local ivar `"`:word `indexi' of `mcolnames''"'
	
	quietly maxinfect `ivar' `varlist', ///
	  day0(`"`day0'"') datefmt("`datefmt'") `percent'
	  
	local tstar=r(t_maxinfect)
	local dstar=r(d_maxinfect)
		
	local ttstar=`tstar'
	if (`"`day0'"'!="") local ttstar=string(`tstar',"`datefmt'")
	
	local title_t0 = "t0"
	local title_tX = "t`dstar'"
	local title_t1 = "t`days'"
	
	if (`"`day0'"' != "") {
	    local title_t0 = string(`varlist'[1], "`datefmt'")
		local title_tX = string(`varlist'[`=`dstar'+1'], "`datefmt'")
		local title_t1 = string(`varlist'[_N], "`datefmt'")		
	}
	
	local twid = 17
	local cwid = 14
	local lmarg = 2
	
	local twidth = `twid' + 3*(`cwid'+1)
	local titlepos = `lmarg' + floor((`twidth'-strlen(`"`modeltitle'"'))/2)
	if (`titlepos' < `lmarg') local titlepos=`lmarg'	
	local titleoffset=`"_col(`=`titlepos'+1')"'
	
	display ""
    display `titleoffset' "`modeltitle'"
    tempname tab
	.`tab' = ._tab.new, col(4) lmarg(`lmarg') commas
	.`tab'.width    `twid' | `cwid' `cwid' `cwid'
	.`tab'.titlefmt .   %`cwid's   %`cwid's %`cwid's
	.`tab'.numfmt   .   %`cwid'.`digits'f`comma'  %`cwid'.`digits'f`comma' %`cwid'.`digits'f`comma'
	.`tab'.sep, top
	.`tab'.titles `"`ylabel'"' "`title_t0'" "`title_tX'" "`title_t1'"
	.`tab'.sep, mid

	local total_t0 = 0
	local total_tX = 0
	local total_t1 = 0
	
	forvalues i = 2/`:word count `varlabels'' {
	    local vl `"`:word `i' of `varlabels''"'
		local vn `:word `i' of `mcolnames''
	    .`tab'.row `"`vl'"' `=`vn'[1]' `=`vn'[`=`dstar'+1']' `=`vn'[`=`days'+1']'
		local total_t0 = `total_t0' + `=`vn'[1]'
		local total_tX = `total_tX' + `=`vn'[`=`dstar'+1']'
		local total_t1 = `total_t1' + `=`vn'[`=`days'+1']'
	}
	.`tab'.sep, middle
	.`tab'.row `"Total"' `total_t0' `total_tX' `total_t1'
	.`tab'.sep, bottom
	
	epimodels_util maxinfect `ivar' `varlist', ///
	  day0(`"`day0'"') datefmt("`datefmt'") `percent'
	
	return scalar maxinfect=r(maxinfect)
	return scalar t_maxinfect=r(t_maxinfect)
	return scalar d_maxinfect=r(d_maxinfect)
end

program define maxinfect, rclass
	
	syntax varlist, [day0(string) datefmt(string) percent]
	
	local ivar `"`: word 1 of `varlist''"'
	local tvar `"`: word 2 of `varlist''"'
	if (`"`datefmt'"'=="") local datefmt="%td"
	
	tempname tmax max dmax
	
	summarize `ivar' if (!missing(`ivar')), meanonly
	scalar `max' = r(max)
	
	summarize `tvar' if (abs(`ivar'-`max') < c(epsdouble)), meanonly
	scalar `tmax' = r(min) // in case of multiple identical values pick the first one
	quietly count if (`tvar' < `tmax')
    scalar `dmax' = `=r(N)'
	
	if (`"`day0'"'!="") {
	  local specdate `"(`=string(`=`tvar'[`=`dmax'']',`"`datefmt'"')') "'
	}
	
	local maxtext `"`=string(`=`max'',"%20.4gc")'"'
	if (`"`percent'"'!="") local maxtext `"`maxtext'%"'
	display as text "The maximum size of the infected group {result:`maxtext'} is reached on day {result:`=`dmax'' `specdate'}of the simulation."
	
	if (`=`dmax'' + 1 == _N) {
	    display as result "Warning! The peak is detected at the end of the simulation, and may change if you extend it."
	}
	display ""
		
	return scalar t_maxinfect=`tmax'
	return scalar d_maxinfect=`dmax'
	return scalar maxinfect=`max'
end

// END OF FILE