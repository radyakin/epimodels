// TEST 002
// Run each model with realistic parameters
// Verify the results are returned:
// -- simulations matrix, 
// -- peak infected rate
// -- day of peak infected rate,
// -- date of peak infected rate
// The test does not verify the numerical accuracy, 
// but confirms the corresponding results are 
// saved and returned in r().
// =====================================================================================

clear all
epi_sir, beta(0.50) gamma(0.33333) susceptible(1.00) infected(1.27e-06) days(150) day0("2020-01-14") nograph 
return list
matrix A = r(sir)
assert rowsof(A) == 151 // 1 + days 
assert colsof(A) == 4   // "t S I R"

assert r(d_maxinfect) == 74
assert r(t_maxinfect) == 22002
assert reldif(r(maxinfect), .0629794564725003) < c(epsdouble) * 100

clear all
epi_seir, beta(0.9) gamma(0.2) sigma(0.5) susceptible(10) exposed(1) days(150) day0("2020-01-14") nograph
return list
matrix A = r(seir)
assert rowsof(A) == 151 // 1 + days 
assert colsof(A) == 5   // "t S E I R"

assert r(d_maxinfect) == 12
assert r(t_maxinfect) == 21940
assert reldif(r(maxinfect), 3.51460615814378) < c(epsdouble) * 100

// END OF TEST FILE
