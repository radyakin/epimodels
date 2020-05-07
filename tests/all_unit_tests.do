clear all
adopath ++ "..\code\"
cd "..\tests\"

do test_001
do test_002
do test_003
do test_004 // Test estimation of parameters of the SIR model (with noise)
do test_005 // Test estimation of parameters of the SEIR model
do test_006 // Various tests for plausibility of inputs in estimation
do test_007 // Test estimation of parameters of SEIR model in the presense of missing values
do test_008 // Verify epi_wordpos() and epi_greek() functions

// END OF ALL UNIT TESTS
