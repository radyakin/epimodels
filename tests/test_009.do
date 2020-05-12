// TEST 009
// Verify stoppage for invalid number of steps
// Verify equivalence of modelling with step 1 and smaller steps
// =====================================================================================

clear all
adopath ++ "..\code\"
mata mata mlib index

// Verify stoppage for invalid number of steps
capture noisily epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
                 days(9) nograph clear steps(10.2)
display _rc
assert _rc==198

capture noisily epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
                 days(9) nograph clear steps(0)
assert _rc==198

capture noisily epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
                 days(9) nograph clear steps(10001)
assert _rc==198

// Verify equivalence of modelling with step 1 and smaller steps
generate t=_n-1
format t %6.3f
generate double S=.
generate double I=.
generate double R=.

mata: 
    // benchmark
    par=0.9, 0.1
	ini=0,10000,20,0
	mlt=25  // typical 1,2,5,10,20,50,100,200,500,1000
	iters=20
	valu = epimodels_rk4(&epimodels_sir_eq(),par,mlt,ini,iters)
	if (st_nobs()<rows(valu)) {
	  st_addobs(rows(valu)-st_nobs())
	}
	st_store((1..rows(valu))',.,valu)
end

generate I_crude=I if (t==round(t))
rename I I_fine
twoway line I_crude I_fine t

// END OF TEST FILE
