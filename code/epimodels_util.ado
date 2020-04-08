program define epimodels_util
	version 16.0
	`0'
end

program define check_total_population
    version 16.0
	syntax anything
	
	if (`anything' < 1.00) {
		display ""
	    display as result "Warning! Total population size (`totpop') is less than 1.00"
		display as result "Make sure the initial conditions at t0 represent population groups counts in persons."
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