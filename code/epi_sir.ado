program define _epi_sirm, rclass
	syntax , ///
	  days(real) ///
	  beta(real) ///
	  gamma(real) ///
	  ini_susceptible(real) ///
	  ini_infected(real) ///
	  ini_recovered(real)

	tempname M
	matrix `M' = J(`days',4,.)
	
	local colnames = "t S I R"
	local ordervars = subinstr("`colnames'"," ","",.)
	local vt = strpos(`"`ordervars'"',"t")
	local vs = strpos(`"`ordervars'"',"S")
	local vi = strpos(`"`ordervars'"',"I")
	local vr = strpos(`"`ordervars'"',"R")
	
	matrix `M'[1,`vt'] = 0 // day zero
	matrix `M'[1,`vs'] = `ini_susceptible'
	matrix `M'[1,`vi'] = `ini_infected'
	matrix `M'[1,`vr'] = `ini_recovered'
	
	forval iter=2(1)`days' {
	    matrix `M'[`iter',`vt']=`M'[`iter'-1,`vt'] + 1
		matrix `M'[`iter',`vs']=`M'[`iter'-1,`vs'] - `gamma'*`M'[`iter'-1,`vs']*`M'[`iter'-1,`vi']
		matrix `M'[`iter',`vi']=`M'[`iter'-1,`vi'] + (`gamma'*`M'[`iter'-1,`vs']*`M'[`iter'-1,`vi']-`beta'*`M'[`iter'-1,`vi'])
		matrix `M'[`iter',`vr']=`M'[`iter'-1,`vr'] + `beta'*`M'[`iter'-1,`vi']
	}

	matrix colnames `M' = `colnames'
	return matrix sir=`M'
end

program define epi_sir, rclass

	// k -- Average period of infectiouness=3 days (for k=1/3)
	// b -- Each infected person makes an infected contact every 2 days (for b=1/2)
	
	syntax , ///
	  days(real) [day0(string)] ///
	  beta(real) ///
	  gamma(real) ///
	  [ini_susceptible(real 0.00) ///
	  ini_infected(real 0.00) ///
	  ini_recovered(real 0.00) ///
	  nograph clear * ]
	
	assert `days'>1
	`clear'
	
	tempname M
	
	_epi_sirm, ///
	  days(`days')  ///
	  beta(`beta') ///
	  gamma(`gamma') ///
	  ini_susceptible(`ini_susceptible') ///
	  ini_infected(`ini_infected') ///
	  ini_recovered(`ini_recovered')
	
	matrix `M' = r(sir)
	
	quietly svmat `M', names(col)

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
	twoway line S I R t, legend(cols(1) ring(0) pos(2) region(lwidth(none) )) xlabel(,grid) `options'
end

// todo: check that for both models the number of simulation steps taken is identical for the same value of DAYS()

// END OF FILE
