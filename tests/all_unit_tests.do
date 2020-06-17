clear all
adopath ++ "..\code\"
cd "..\tests\"
mata mata mlib index

do "test_001.do"
do "test_002.do"
do "test_003.do"
do "test_004.do" // Test estimation of parameters of the SIR model (with noise)
do "test_005.do" // Test estimation of parameters of the SEIR model
do "test_006.do" // Various tests for plausibility of inputs in estimation
do "test_007.do" // Test estimation of parameters of SEIR model in the presense of missing values
do "test_008.do" // Verify epi_wordpos() and epi_greek() functions
do "test_009.do" // Test steps
do "test_010.do" // Test returned values
do "test_012.do" // Test PDF reports production

// END OF ALL UNIT TESTS
