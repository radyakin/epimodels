// TEST 004
// Test estimation of parameters of the SIR model 
// =====================================================================================

clear all
mata mata mlib index
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
CreateBenchmarkData , model("SIR") beta(0.50301) gamma(0.37) ///
   `opts' days(100) suffix("TRUE")
generate noise=floor(runiform()*0.4*I)
replace R=R+noise
replace I=I-noise

epimodels fit SIR, `opts'   ///
   beta(.) gamma(.) beta0(0.75) gamma0(0.5)  ///
   vinfected(ITRUE) vrecovered(RTRUE)

return list

// Benchmark results adjusted May 02, 2020. Earlier results were incorrect
// since the initial conditions were incorrectly specified with values 
// before adding/subtracting the noise component.
assert reldif(r(gamma), 0.3864145999999999969710) < c(epsdouble) * 100
assert reldif(r(beta),  0.5237102000000000145974) < c(epsdouble) * 100

assert r(modelcmd)=="epi_sir"
assert r(modelname)=="SIR"
assert r(modelvars)=="S I R"
assert r(datavars)==" . ITRUE RTRUE"
assert r(finparamstr)==" {&beta}=.5237102; {&gamma}=.3864146;"
assert r(estimated)==" beta gamma"
assert r(finparameters)==" beta(.5237102) gamma(.3864146)"
assert r(iniconditions)==" susceptible(1000000) infected(84) recovered(16)"


// END OF TEST FILE
