// TEST 006
// Test estimation check for zero population, and
//        check for at least one population variable to fit, and
//        check for when all parameters are already known and nothing to estimate.
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
   format(%10.6f) `opts'
   
assert (_rc==112)   // at least one population variable 
   
capture noisily epimodels fit SIR, `opts'   ///
   beta(0.987654321) gamma(0.123456789) ///
   vinfected(ITRUE) vrecovered(RTRUE)

return list
assert r(gamma)==.123456789
assert r(beta)==0.987654321
assert r(modelcmd)=="epi_sir"
assert r(modelname)=="SIR"
assert r(modelvars)=="S I R"
assert r(datavars)==" . ITRUE RTRUE"
assert r(finparamstr)==" {&beta}=.9876543209999999; {&gamma}=.123456789;"
assert r(iniconditions)==" susceptible(1000000) infected(10000) recovered(0)"
// all parameters are known, nothing to estimate, should not be a problem   

replace STRUE=0 in 1
replace ETRUE=0 in 1
replace ITRUE=0 in 1
replace RTRUE=0 in 1

capture noisily epimodels fit SEIR, ///
   beta(.) gamma(.) sigma(.) mu(0) nu(0) ///
   beta0(0.5) gamma0(0.3) sigma0(0.2) ///
   format(%10.6f)   ///
   vsusceptible(STRUE) vexposed(ETRUE) ///
   vinfected(ITRUE) vrecovered(RTRUE) 

assert (_rc==112)   // total population size may not be zero

   
// END OF TEST FILE
