// TEST 005
// Test estimation of parameters of the SEIR model 
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

epimodels fit SEIR, ///
   beta(.) gamma(.) sigma(.) mu(0) nu(0) ///
   beta0(0.5) gamma0(0.3) sigma0(0.2) ///
   `opts' fit("EI") format(%10.6f)   ///
   vsusceptible(STRUE) vexposed(ETRUE) ///
   vinfected(ITRUE) vrecovered(RTRUE) 

return list

assert reldif(r(gamma), 0.1999999000000000082267) < c(epsdouble) * 100
assert reldif(r(beta),  0.9030089999999999506031) < c(epsdouble) * 100
assert reldif(r(sigma), 0.1020000999999999963253) < c(epsdouble) * 100
assert r(mu)==0.0000
assert r(nu)==0.0000

assert r(modelcmd)=="epi_seir"
assert r(modelname)=="SEIR"
assert r(modelvars)=="S E I R"
assert r(datavars)==" STRUE ETRUE ITRUE RTRUE"
assert r(finparamstr)==" {&beta}=.903009; {&gamma}=.1999999; {&sigma}=.1020001; {&mu}=0; {&nu}=0;"
assert r(estimated)==" beta gamma sigma"
assert r(finparameters)==" beta(.903009) gamma(.1999999) sigma(.1020001) mu(0) nu(0)"
assert r(iniconditions)==" susceptible(1000000) exposed(0) infected(10000) recovered(0)"


// END OF TEST FILE
