// TEST 003
// Verify sum of squared differences function
// =====================================================================================

clear all

input double x double y
	1 2
	3 5
	7 12
	-4 -7
	0 -5
	-2 9
	0 0
	2 2
	100.31 20.31
	-3.14159265 3.14159265
end

mata sprintf("%25.19f",epi_sum2diff("x","y"))
mata assert(reldif(epi_sum2diff("x","y"), 6624.4784175141357991379) < st_numscalar("c(epsdouble)") * 100)

// END OF TEST FILE
