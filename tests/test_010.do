// TEST 010
// Test returned values
// =====================================================================================

clear all
adopath ++ "..\code\"
mata mata mlib index

epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
         days(9) nograph clear

assert r(o_maxinfect) ==  10
assert r(d_maxinfect) ==  9
assert r(t_maxinfect) ==  9
assert r(maxinfect) ==  103954.0812009651
assert r(model_params) == "{&beta}=.96, {&gamma}=.5666"
		 
epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
         days(9) nograph clear steps(10)

assert r(o_maxinfect) ==  91
assert r(d_maxinfect) ==  90
assert r(t_maxinfect) ==  9
assert r(maxinfect) ==  103956.0018622481
assert r(model_params) == "{&beta}=.96, {&gamma}=.5666"

epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
         days(9) day0(2020-01-01) nograph clear 

assert r(o_maxinfect) ==  10
assert r(d_maxinfect) ==  9
assert r(t_maxinfect) ==  21924
assert r(maxinfect) ==  103954.0812009651
assert r(model_params) == "{&beta}=.96, {&gamma}=.5666"
		 
epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
         days(9) day0(2020-01-01) nograph clear steps(10) 

assert r(o_maxinfect) ==  91
assert r(d_maxinfect) ==  90
assert r(t_maxinfect) ==  21924
assert r(maxinfect) ==  103956.0018622481
assert r(model_params) == "{&beta}=.96, {&gamma}=.5666"
		 
epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
         days(20) nograph clear steps(10)

assert r(o_maxinfect) ==  98
assert r(d_maxinfect) ==  97
assert r(t_maxinfect) ==  9.699999999999999
assert r(maxinfect) ==  105503.6013384467
assert r(model_params) == "{&beta}=.96, {&gamma}=.5666"

epi_sir, beta(0.96) gamma(0.5666) susceptible(1e6) infected(1e4) ///
         days(20) nograph clear steps(100)		 

assert r(o_maxinfect) ==  972
assert r(d_maxinfect) ==  971
assert r(t_maxinfect) ==  9.710000000000001
assert r(maxinfect) ==  105504.1195589966
assert r(model_params) == "{&beta}=.96, {&gamma}=.5666"


epi_seir, beta(0.9) gamma(0.2) sigma(0.5) susceptible(1e6) exposed(1) days(100) nograph clear
assert r(o_maxinfect) ==  47
assert r(d_maxinfect) ==  46
assert r(t_maxinfect) ==  46
assert r(maxinfect) ==  306235.2288350309
assert r(model_params) == "{&beta}=.9, {&gamma}=.2, {&sigma}=.5, {&mu}=0, {&nu}=0"
epi_seir, beta(0.9) gamma(0.2) sigma(0.5) susceptible(1e6) exposed(1) days(100) clear title("SEIR Model (`r(model_params)')")
		 
// END OF TEST FILE
