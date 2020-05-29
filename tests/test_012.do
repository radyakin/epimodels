// TEST 012
// Run PDF reporting for SIR and SEIR models.
// =====================================================================================

clear all
//local sirpdf "C:\temp\epimodels_sir_test.pdf"
tempfile sirpdf
local sirpdf `"`sirpdf'.pdf"'
epi_sir, days(50) beta(0.50) gamma(0.33333) susceptible(1000) infected(1) ///
		 pdfreport(`"`sirpdf'"') 
confirm file `"`sirpdf'"'

clear all
// local seirpdf "C:\temp\epimodels_seir_test.pdf"
tempfile seirpdf
local seirpdf `"`seirpdf'.pdf"'
epi_seir, days(50) day0("2020-02-01") beta(0.50) gamma(0.33333) sigma(0.2) ///
         susceptible(1000) infected(1) ///
		 pdfreport(`"`seirpdf'"')
confirm file `"`seirpdf'"'
		
// END OF TEST 012