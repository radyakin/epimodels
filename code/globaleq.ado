program define globaleq
    syntax , modelname(string)
	local c=0
	tempname fr fw

	tempfile tmp

	file open `fw' using `"`tmp'"', write text replace

	file open `fr' using "make_epimodels.do", read text
	file read `fr' line
	while !r(eof) {
	  if strpos(`"`line'"',"### ---")>0 local c=0
	  if strpos(`"`line'"',"### `modelname' MODEL EQUATIONS")>0 {
		local c=1
		file write `fw' (`"global MODELEQ`modelname' = "" ///"') _n
	  }
	  if strpos(`"`line'"',"###")==0 & (`c'==1) {
		 local fline =strtrim(subinstr(`"`line'"',"`=char(09)'"," ",.))
		 local zline "`=char(96)'=char(10)`=char(39)'`=char(96)'=char(13)`=char(39)'"
		 local zline "{break}"
		 // display _asis `"`macval(zline)'"'
		 // file write `fw' (`" + `"`fline' `macval(zline)'"' ///"') _n
		 file write `fw' (`" + `"`fline' `zline'"' ///"') _n
	  }
	  file read `fr' line
	}

	file close `fr'

	file write `fw' (`" + "" "')
	file close `fw'

	//view `"`tmp'"'
	do `"`tmp'"'
end



/* TEST 
putpdf begin
  putpdf paragraph
  putpdf text (`"`=subinstr(`"$MODELEQ"',"{break}","`=char(10)'",.)'"')
putpdf save "C:\temp\ddd.pdf"
*/
// end