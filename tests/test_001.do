// TEST 001
// Run each model with realistic parameters
// Verify the variables are named:
// -- in upper case for counts, 
// -- in lower case for proportions (percent)
// =====================================================================================

clear all
epi_sir, beta(0.50) gamma(0.33333) susceptible(1.00) infected(1.27e-06) days(5) nograph 
confirm numeric variable t
confirm numeric variable S
confirm numeric variable I
confirm numeric variable R

clear all
epi_sir, beta(0.50) gamma(0.33333) susceptible(1.00) infected(1.27e-06) days(5) nograph percent
confirm numeric variable t
confirm numeric variable s
confirm numeric variable i
confirm numeric variable r

clear all
epi_seir, beta(0.9) gamma(0.2) sigma(0.5) susceptible(10) exposed(1) days(5) nograph
confirm numeric variable t
confirm numeric variable S
confirm numeric variable E
confirm numeric variable I
confirm numeric variable R

clear all
epi_seir, beta(0.9) gamma(0.2) sigma(0.5) susceptible(10) exposed(1) days(5) nograph percent
confirm numeric variable t
confirm numeric variable s
confirm numeric variable e
confirm numeric variable i
confirm numeric variable r

// END OF TEST FILE
