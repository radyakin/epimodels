// TEST 006
// Test estimation check for zero population 
// =====================================================================================

clear all
set seed 12345678

program define CreateBenchmarkData
    version 16.0
    syntax , model(string) suffix(string) [*]
	 
	epimodels simulate `model', `options' nograph
	capture rename S S`suffix'
	capture rename I I`suffix'	
	capture rename E E`suffix'
	capture rename R R`suffix'
	drop t
end

local opts "susceptible(1e6) infected(1e4)"
CreateBenchmarkData , model("SEIR") ///
    beta(0.90301) gamma(0.2) sigma(0.102) `opts' days(100) suffix("TRUE")

capture noisily epimodels fit SEIR, ///
   beta(.) gamma(.) sigma(.) mu(0) nu(0) ///
   beta0(0.5) gamma0(0.3) sigma0(0.2) ///
   fit("EI") format(%10.6f)   ///
   vsusceptible(STRUE) vexposed(ETRUE) ///
   vinfected(ITRUE) vrecovered(RTRUE) 

assert (_rc==112)   // total population size may not be zero

// END OF TEST FILE
