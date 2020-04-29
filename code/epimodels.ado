program define epimodels
	version 16.0
	`0'
end

program define simulate
	version 16.0
	gettoken model 0 : 0
	display `"`model'"'
	local cmd = "epi_"+strlower(`"`model'"')
	`cmd' `0'
end

program define fit, rclass

	version 16.0
	
	syntax anything, [*]
	
	local anything=strupper(`"`anything'"')
	mata epi_getmodelmeta("")
	assert(strpos(" `models_known' "," `anything' ")>0)
	local modelname=strlower("epi_`anything'")
	mata epi_getmodelmeta("`modelname'")
	
	local syntax_params ""
	foreach p in `model_params' {
	    local syntax_params `"`syntax_params' `p'(numlist max=1 missingok) `p'0(real 0.50)"'
	}
	
	local syntax_stocks ""
	foreach s in `model_stocks' {
	    local syntax_stocks `"`syntax_stocks' `s'(real 0.0000) v`s'(varname numeric)"'
	}
	
	syntax anything, [ `syntax_params' `syntax_stocks' fit(string) format(string)]		
	// Not all variables specified in v*() must be mentioned in fit(), 
	// but ALL that is mentioned in fit() must be specified	in v*()!
	// ToDo: add check for the above!
	
	// ToDo: add check that no search is necessary if all the parameters are known
	
	if (`"`format'"'=="") local format "%10.5f"
	
	if (`"`fit'"'=="") local fit="`model_default_fit'"
	local fit=subinstr(strupper(`"`fit'"')," ","",.)
	
	foreach p in `model_params' {
	  if (`"``p''"'=="") local `p'="."	  
	  local `p'1=``p''
	}
	
	local stockvarlist=""
	foreach s in `model_stocks' {
	  local initial_conditions = `"`initial_conditions' `s'(``s'')"'
	  local vname=`"`v`s''"'
	  if (`"`vname'"'=="") local vname="."
	  local stockvarlist `"`stockvarlist' `vname'"'
	}
	
	local iterations=0
	
	mata epi_searchparams()
	
	local modeltitle `"`anything' model estimation"'
	local twid = 17
	local cwid = 10
	local lmarg = 2
	
	local twidth = `twid' + (`cwid'+1) + (17+1)
	local titlepos = `lmarg' + floor((`twidth'-strlen(`"`modeltitle'"'))/2)
	if (`titlepos' < `lmarg') local titlepos=`lmarg'	
	local titleoffset=`"_col(`=`titlepos'+1')"'
	
	display ""
    display `titleoffset' "`modeltitle'"
    tempname tab
	.`tab' = ._tab.new, col(3) lmarg(`lmarg') commas
	.`tab'.width    `twid' | `cwid'  17
	.`tab'.titlefmt . %`cwid's %17s
	.`tab'.numfmt   . `format' .
	.`tab'.sep, top
	.`tab'.titles "Parameter" "Value " "Source   "
	.`tab'.sep, mid
	
	local greekstr=""
	foreach p in `model_params' {
	  return scalar `p' = ``p'1'
	  local greekstr `"`greekstr' {&`p'}=``p'1';"'
	  mata st_local("g", epi_greek("`p'"))
	  local src=cond(missing(``p''),"Estimated","Supplied")
	  .`tab'.row `"`p' (`g')"' ``p'1' `"`src'"'
	  if (missing(``p'')) local estimated `"`estimated' `p'"'
	}
	.`tab'.sep, bottom

	return local iniconditions `"`initial_conditions'"'
	return local finparameters `"`finalparams'"'	
	return local estimated `"`estimated'"'
    return local finparamstr `"`greekstr'"'
	return local datavars `"`stockvarlist'"'
	return local modelvars `"`model_vars'"'
	return local modelname `"`anything'"'
	return local modelcmd `"`modelname'"'
	
end	

// END OF FILE
