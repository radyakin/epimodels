// TEST 007
// Test estimation of parameters of the SEIR model under presence of missing values
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

replace ETRUE=. in 10
replace ITRUE=. in 20	
	
epimodels fit SEIR, ///
   beta(.) gamma(.) sigma(.) mu(0) nu(0) ///
   beta0(0.5) gamma0(0.3) sigma0(0.2) ///
   `opts' format(%10.6f)   ///
   vexposed(ETRUE) vinfected(ITRUE) 

return list

assert reldif(r(gamma), 0.1999999000000000082267) < c(epsdouble) * 100
assert reldif(r(beta),  0.9030087999999999448519) < c(epsdouble) * 100
assert reldif(r(sigma), 0.1020001999999999992008) < c(epsdouble) * 100
assert r(mu)==0.0000
assert r(nu)==0.0000

assert r(modelcmd)=="epi_seir"
assert r(modelname)=="SEIR"
assert r(modelvars)=="S E I R"
assert r(datavars)==" . ETRUE ITRUE ."
assert r(finparamstr)==" {&beta}=.9030088; {&gamma}=.1999999; {&sigma}=.1020002; {&mu}=0; {&nu}=0;"
assert r(estimated)==" beta gamma sigma"
assert r(finparameters)==" beta(.9030088) gamma(.1999999) sigma(.1020002) mu(0) nu(0)"
assert r(iniconditions)==" susceptible(1000000) exposed(0) infected(10000) recovered(0)"


// END OF TEST FILE
