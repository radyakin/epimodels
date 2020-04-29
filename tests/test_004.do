// TEST 004
// Test estimation of parameters of the SIR model 
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

// TEST SIR
local opts "susceptible(1e6) infected(1e2)"
CreateBenchmarkData , model("SIR") beta(0.50301) gamma(0.37) `opts' days(100) suffix("TRUE")
generate noise=runiform()*0.4*I
replace R=R+noise
replace I=I-noise

epimodels fit SIR, `opts' fit("IR")  ///
   beta(.) gamma(.) beta0(0.75) gamma0(0.5)  ///
   vsusceptible(STRUE) vinfected(ITRUE) vrecovered(RTRUE)

return list

assert reldif(r(gamma), 0.3757827000000000250424) < c(epsdouble) * 100
assert reldif(r(beta),  0.5099974000000000451394) < c(epsdouble) * 100

assert r(modelcmd)=="epi_sir"
assert r(modelname)=="SIR"
assert r(modelvars)=="S I R"
assert r(datavars)==" STRUE ITRUE RTRUE"
assert r(finparamstr)==" {&beta}=.5099974; {&gamma}=.3757827;"
assert r(estimated)==" beta gamma"
assert r(finparameters)==" beta(.5099974) gamma(.3757827)"
assert r(iniconditions)==" susceptible(1000000) infected(100) recovered(0)"


// END OF TEST FILE
