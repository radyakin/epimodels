mata 

real matrix rk4(pointer(real matrix function) scalar f, real matrix param, real stp, real matrix initc, real iters) {
	res = initc
	for(tt=1; tt<=iters; tt++) {
	  prevVals = res[rows(res),2..cols(res)] 
	  nextVals = (*f)( prevVals, param )
	  k1 = stp :* nextVals
	  k2 = stp :* (*f)(prevVals :+ (.5*k1),param)
	  k3 = stp :* (*f)(prevVals :+ (.5*k2),param)
	  k4 = stp :* (*f)(prevVals :+     k3, param)
	  adjFactor = prevVals  :+ (1/6)*k1
	  adjFactor = adjFactor :+ (1/3)*k2
	  adjFactor = adjFactor :+ (1/3)*k3
	  adjFactor = adjFactor :+ (1/6)*k4
	  res = res \ (stp*tt, adjFactor)
	}
	return(res)
}

real matrix seir(real matrix x, real matrix parm) {
  r1 = parm[4]*(x[2]+x[3]+x[4]) - parm[1]*x[3]*x[1]/(x[1]+x[2]+x[3]+x[4]) - parm[5]*x[1]
  r2 = parm[1]*x[3]*x[1]/(x[1]+x[2]+x[3]+x[4]) - (parm[4] + parm[3])*x[2]
  r3 = parm[3]*x[2] - (parm[4]+parm[2])*x[3]
  r4 = parm[2]*x[3] - parm[4]*x[4]+parm[5]*x[1]
  return(r1,r2,r3,r4)
}


void function epi_seir(string scalar matname) {
	par_beta  = strtoreal(st_local("beta"))
	par_gamma = strtoreal(st_local("gamma"))
	par_sigma = strtoreal(st_local("sigma"))
	par_mu = strtoreal(st_local("mu"))
	par_nu = strtoreal(st_local("nu"))
	ini_S = strtoreal(st_local("susceptible"))
	ini_E = strtoreal(st_local("exposed"))
	ini_I = strtoreal(st_local("infected"))
	ini_R = strtoreal(st_local("recovered"))
	iters = strtoreal(st_local("iterations"))
	// step=0.01 // step is disabled in this version
	step=1

	par=par_beta,par_gamma,par_sigma,par_mu,par_nu
	ini=0,ini_S,ini_E,ini_I,ini_R

	valu = rk4(&seir(),par,step,ini,iters)

	st_matrix(matname, valu)
}

end

program define epi_seir, rclass

	syntax , beta(real) gamma(real) sigma(real) mu(real) nu(real) ///
	         susceptible(real) exposed(real) infected(real) recovered(real) ///
			 days(real) [day0(string) nograph clear newframe(string) *]

	local iterations= /*100* */ `days'
	tempname M		 
	mata epi_seir("`M'")

	matrix colnames `M' = t S E I R

	// todo: if {opt nodata} has been specified, do not put data to any dataset
	// todo: if frame name has been specified, put the data into that frame
	// todo: potentially separate the simulation part from the graphing part
	// todo: potentially calculate fully (with step 0.01), but report only the integer nodes.
	// todo: graph by date, not day
	// todo: expose the step
	`clear'
	quietly svmat double `M', names(col)
	
	label variable t "Time, days"
	label variable S "Susceptible"
	label variable E "Exposed"
	label variable I "Infected"
	label variable R "Recovered"

	if (`"`day0'"'!="") {
	  replace t=t+date(`"`day0'"',"YMD")
	  format t %dCY-N-D
	  label variable t "Date"
	}
	
	return matrix seir=`M'
	
	if (`"`graph'"'=="nograph") exit
	
	twoway line S E I R t, ///
	   legend(cols(1) ring(0) pos(2) region(lwidth(none) )) ///
	   xtitle("`:variable label t'") ytitle("Population") title("SEIR Model") ///
	   color(orange blue red green) ///
	   xlabel(, grid) scale(0.85) `options'
end
