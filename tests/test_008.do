// TEST 008
// Verify epi_wordpos() and epi_greek() functions
// =====================================================================================

clear all

mata 

H="aaaa      aaa  aa  a    bbbb bb bb bb b aa a bb abba abab"

assert(epi_wordpos(H,"a")==4)
assert(epi_wordpos(H,"aa")==3)
assert(epi_wordpos(H,"aaa")==2)
assert(epi_wordpos(H,"aaaa")==1)
assert(epi_wordpos(H,"bbbb")==5)
assert(epi_wordpos(H,"z")==0)
assert(epi_wordpos("","a")==0)
assert(epi_wordpos(H,"")==0)

assert(epi_greek("")=="")
assert(epi_greek("beta")=="β")
assert(epi_greek("beta2")=="β2")
assert(epi_greek("rho32")=="ρ32")
assert(epi_greek("beta2   rho32 delta0")=="β2 ρ32 δ0")

assert(epi_greek("2")=="2")
assert(epi_greek("23")=="23")
assert(epi_greek("2delta3")=="2delta3")

end


/*

// These test are no longer valid. 
// The new behavior is: for non-convertible items, return the item itself.

capture mata epi_greek("2")
assert _rc==112

capture mata epi_greek("23")
assert _rc==112

capture mata epi_greek("2delta3")
assert _rc==112
*/

// END OF TEST FILE
