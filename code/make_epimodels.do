
clear all
local vers "16.0"
version `vers'
local compdate "`c(current_date)'"

cd "..\code"

globaleq, modelname("SIZ")
display `"$MODELEQSIZ"'

globaleq, modelname("SIR")
display `"$MODELEQSIR"'

globaleq, modelname("SEIR")
display `"$MODELEQSEIR"'

mata 

real matrix epimodels_about() {
    st_local("compile_date", "`compdate'")
	st_local("compile_version", "`vers'")
	st_local("epimodels_version", "2.1.1")
}

real matrix epimodels_rk4(pointer(real matrix function) scalar f, real matrix param, real mlt, real matrix initc, real iters) {
    version `vers'
	res = initc
	
	mltstr=strtrim(strofreal(mlt,"%20.4gc"))
	if (mlt>10000) {
	    printf("{break}Error! Too fine-grain simulation. Specified number of steps per day (%s) is too large.{break}",mltstr)
	    exit(error(3300))
	}
	
	stp=1/mlt
	
	for(t=0;t<iters;t++) {
		for(j=1;j<=mlt;j++) {
		  tt=t+stp*j
		  prevVals = res[rows(res),2..cols(res)] 
		  nextVals = (*f)( prevVals, param )
		  k1 = stp :* nextVals
		  k2 = stp :* (*f)(prevVals :+ (.5*k1),param)
		  k3 = stp :* (*f)(prevVals :+ (.5*k2),param)
		  k4 = stp :* (*f)(prevVals :+     k3, param)
		  adjFactor = prevVals  :+ (1/6)*k1
		  adjFactor = adjFactor :+ (1/3)*k2
		  adjFactor = adjFactor :+ (1/3)*k3
		  adjFactor = adjFactor :+ (1/6)*k4
		  res = res \ (tt, adjFactor)
		}
	}
	return(res)
}

real matrix epimodels_sir_eq(real matrix x, real matrix parm) {
    version `vers'
	// ### SIR MODEL EQUATIONS ----------------------------------
    N=x[1]+x[2]+x[3]
    r1= -parm[1]*x[1]*x[2]/N
    r2= parm[1]*x[1]*x[2]/N - parm[2]*x[2]
    r3= parm[2]*x[2]
    return(r1,r2,r3)
	// ### ------------------------------------------------------
}

void function epimodels_sir(string scalar matname) {
    version `vers'
	par_beta  = strtoreal(st_local("beta"))
	par_gamma = strtoreal(st_local("gamma"))
	ini_S = strtoreal(st_local("susceptible"))
	ini_I = strtoreal(st_local("infected"))
	ini_R = strtoreal(st_local("recovered"))
	iters = strtoreal(st_local("days"))
	step= strtoreal(st_local("steps"))

	par=par_beta,par_gamma
	ini=0,ini_S,ini_I,ini_R

	valu = epimodels_rk4(&epimodels_sir_eq(),par,step,ini,iters)

	st_matrix(matname, valu)
}

real matrix epimodels_seir_eq(real matrix x, real matrix parm) {
    version `vers'
	// ### SEIR MODEL EQUATIONS ----------------------------------
    r1 = parm[4]*(x[2]+x[3]+x[4]) - parm[1]*x[3]*x[1]/(x[1]+x[2]+x[3]+x[4]) - parm[5]*x[1]
    r2 = parm[1]*x[3]*x[1]/(x[1]+x[2]+x[3]+x[4]) - (parm[4] + parm[3])*x[2]
    r3 = parm[3]*x[2] - (parm[4]+parm[2])*x[3]
    r4 = parm[2]*x[3] - parm[4]*x[4]+parm[5]*x[1]
    return(r1,r2,r3,r4)
	// ### -------------------------------------------------------
}

void function epimodels_seir(string scalar matname) {
    version `vers'
	par_beta  = strtoreal(st_local("beta"))
	par_gamma = strtoreal(st_local("gamma"))
	par_sigma = strtoreal(st_local("sigma"))
	par_mu = strtoreal(st_local("mu"))
	par_nu = strtoreal(st_local("nu"))
	ini_S = strtoreal(st_local("susceptible"))
	ini_E = strtoreal(st_local("exposed"))
	ini_I = strtoreal(st_local("infected"))
	ini_R = strtoreal(st_local("recovered"))
	iters = strtoreal(st_local("days"))
	step= strtoreal(st_local("steps"))

	par=par_beta,par_gamma,par_sigma,par_mu,par_nu
	ini=0,ini_S,ini_E,ini_I,ini_R

	valu = epimodels_rk4(&epimodels_seir_eq(),par,step,ini,iters)

	st_matrix(matname, valu)
}


real epi_wordpos(string s1, string s2) {
	version `vers'
	T=tokens(s1)
	for(w=1;w<=cols(T);w++) {
	  if (T[w]==s2) return(w)
	}
	return(0)
}


real epi_sum2diff(string v1, string v2) {
    version `vers'
	// calculate sum of squared differences 
	// between variables v1 and v2
	V1=J(0,0,.)
	V2=J(0,0,.)
	st_view(V1,.,v1)
	st_view(V2,.,v2)
	D=V1-V2
	for(i=1;i<=rows(D);i++) {
	    if (D[i,1]==.) D[i,1]=0
	}
	sum=colsum(D:*D)
	return(sum)
}

real epi_getpenalty(string fit) {
    version `vers'	
	result=0

	for(i=1;i<=strlen(fit);i++) {
	  l = strupper(substr(fit,i,1))
	  v0index = strpos(subinstr(st_local("model_vars")," ","",.),l)
	  v0name = tokens(st_local("model_stocks"))[v0index]
	  vnamedata = st_local("v"+v0name)
	  vnamemodel = l
	  result=result-epi_sum2diff(vnamedata,vnamemodel)
	}

	return(result)
}

string epi_makeparamstr(real rowvector p, string allparams) {
    version `vers'
	t=tokens(allparams)
	result=""
	idx=1
	for(i=1;i<=cols(t);i++) {
	  pname=t[i]
	  pv=strtoreal(st_local(pname))
	  if (missing(pv)) {
	    pv=p[idx]
	    idx=idx+1
	  }
	  result=result+" "+pname+"("+strofreal(pv)+")"
	}
	return(result)
}

void epi_searcheval(todo, p, v, g, H) {
    version `vers'
	i=strtoreal(st_local("iterations"))
	i=i+1
	st_local("iterations", strofreal(i))

	cmd = sprintf("quietly %s , %s %s days(%g) nograph", ///
	  st_local("modelname"), ///
	  epi_makeparamstr(p,st_local("model_params")), ///
	  st_local("initial_conditions"), ///
	  st_nobs()-1 ///	  
	)
	stata(cmd)
	
	v = epi_getpenalty(st_local("fit"))
	// todo: all models always produce variable 't',
	// which is unsafe as this variable may already exist
	stata("quietly drop t " + st_local("model_vars"))
	
	if (st_global("epi_search_verbose")=="1") {
		outstr = "{text:%10.0g} {text:%14.10g} {result:%14.10g} {result:%14.10g} {break}"
		printf(outstr,i,v,p[1],p[2])
	}

}

real rowvector epi_getstartparams(string allparams) {
    version `vers'
	t=tokens(allparams)
	p0=J(1,0,.)
	for(i=1;i<=cols(t);i++) {
	  pname=t[i]
	  if (st_local(pname)==".") {
	    p0=p0, strtoreal(st_local(pname+"0"))
	  }
	}
	return(p0)
}

void epi_postendparams(real rowvector x, string allparams) {
    version `vers'
	t=tokens(allparams)
	idx=1
	for(i=1;i<=cols(t);i++) {
	  pname=t[i]
	  if (st_local(pname)==".") {
	    st_local(pname+"1", strofreal(x[idx]))
		idx=idx+1
	  }
	}
	st_local("finalparams", epi_makeparamstr(x, allparams))
}

void epi_searchparams() {
    version `vers'
	model_params = st_local("model_params")
	p0=epi_getstartparams(model_params)
	
	if (st_local("allparamsknown")=="0") {
		S = optimize_init()
		optimize_init_evaluator(S, &epi_searcheval())
		optimize_init_params(S, p0)
		optimize_init_technique(S, "nr 5 dfp 5 bfgs 5")
		optimize_init_conv_ignorenrtol(S, "on" )
		x = optimize(S)
	}
	else {
		x=p0
	}
	epi_postendparams(x, model_params)
}

string epi_greek(string line) {
    version `vers'
	if (line=="") return("")
	T=tokens(line)
	R=""
	Z=""
	for(i=1;i<=cols(T);i++) {
	  R=R+Z+epi_greek1(T[i])
	  Z=" "
	}
	return(R)
}

string epi_greek1(string name) {
    version `vers'

	if (name=="") return("")
	
	if (regexm(name,"[0-9]")>0) {
		if (regexm(name,"^[a-z]+[0-9]+$")==0) {
		    return(name)
			printf("{error}Invalid greek: {%s}{break}", name)
			exit(error(112))
		}
	}
	
	english=regexr(name,"[0-9]+$","")
	num=substr(name,strlen(english)+1,strlen(name)-strlen(english))

	L = tokens("alpha beta gamma delta epsilon zeta eta theta iota kappa " + ///
	 "lambda mu nu xi omicron pi rho ssigma sigma tau upsilon phi chi psi omega")
	
	for(i=1;i<=cols(L);i++) {
	    if (L[i]==english) {
		  return(uchar(944+i)+num)
		}
	}
	
	// printf("{error: unknown letter: %s}{break}", name)
	return(name)
}

void epi_getmodelmeta(string model) {
    version `vers'	
	// When defining new models:
	// - model_vars MUST CORRESPOND TO model_stocks!
	// - model_default_fit MUST BE ONE OR SOME OF the model_vars!
	
	if (model=="") {
	    st_local("models_known", "SIR SEIR")
		exit()
	}
	
	if (strupper(model)=="SIR" | model=="epi_sir") {
		st_local("model_params", "beta gamma")
		st_local("model_stocks", "susceptible infected recovered")
		st_local("model_vars", "S I R")
		st_local("model_default_fit", "I")
		exit()
	}
	
	if (strupper(model)=="SEIR" | model=="epi_seir") {
		st_local("model_params", "beta gamma sigma mu nu")
		st_local("model_stocks", "susceptible exposed infected recovered")
		st_local("model_vars", "S E I R")
		st_local("model_default_fit", "I")
		exit()
	}
	
	printf("{error:Error! Unknown model: %s.}", model)
	exit(error(111))
}

void epi_menu() {
	stata(`"window menu clear"')
	
	stata(`"window menu append submenu "stUserStatistics" "Epimodels""')
	
	stata(`"window menu append submenu "Epimodels" "Estimate""')
	stata(`"window menu append item "Simulate" "SIR model" "db epi_fit_sir""')
	stata(`"window menu append item "Simulate" "SEIR model" "db epi_fit_seir""')
	stata(`"window menu append item "Simulate" "SIZ model" `"window stopbox note "Dialog for this command is not implemented yet""'"')	
	
	stata(`"window menu append submenu "Epimodels" "Simulate""')
	stata(`"window menu append item "Simulate" "SIR model" "db epi_sir""')
	stata(`"window menu append item "Simulate" "SEIR model" "db epi_seir""')
	stata(`"window menu append item "Simulate" "SIZ model" "db epi_siz""')
	stata(`"window menu append item "Epimodels" "About" `"window stopbox note "Stata package Epimodels" "by Carlos M Hernandez-Suarez, Sergiy Radyakin and Paolo Verme" "The World Bank, 2020""'"')
	stata(`"window menu refresh"')
}

void epi_applylabels() {
    st_varlabel("t","Time, days")
	vars=tokens(st_local("mcolnames"))
	labs=tokens(st_local("varlabels"))
	for(v=2;v<=cols(vars);v++) {
	  st_varlabel(vars[v],labs[v])
	}
}

string epimodels_sir_eqtext() {
	printf("========================================================={break}")
	printf(" SIR model specification{break}")
	printf("========================================================={break}")
	printf(`"$MODELEQSIR"')
	printf("========================================================={break}")
	return(`"$MODELEQSIR"')
}

string epimodels_seir_eqtext() {
	printf("========================================================={break}")
	printf(" SEIR model specification{break}")
	printf("========================================================={break}")
	printf(`"$MODELEQSEIR"')
	printf("========================================================={break}")
	return(`"$MODELEQSEIR"')
}

string epimodels_siz_eqtext() {
	printf("========================================================={break}")
	printf(" SIZ model as per the specification from May 26, 2020{break}")
	printf("========================================================={break}")
	printf(`"$MODELEQSIZ"')
	printf("========================================================={break}")
	return(`"$MODELEQSIZ"')
}

real matrix epimodels_siz_eq(real matrix x, real matrix parm) {
    version `vers'
	
	lambda=parm[1]
	mu1=parm[2]
	mu2=parm[3]
	mu3=parm[4]
	mu4=parm[5]
	pi=parm[6]
	psi=parm[7]
	omega=parm[8]
	theta=parm[9]
	alpha=parm[10]
	
	S=x[1]
	Z=x[2]
	I=x[3]
	H=x[4]
	R=x[5]
	RT=x[6]
	C=x[7]	
	D=x[8]
	// ### SIZ MODEL EQUATIONS ----------------------------------
    N = S + Z + I + H + R + RT + C + D
	rS = -lambda*S*(I+Z)/N
	rZ = lambda*(1-pi)*S*(Z+I)/N - mu1*(1+theta)*Z 
	rI = lambda*pi*S*(Z+I)/N - mu2*(1+alpha)*(1+theta)*I
	rR = (1-psi)*mu3*H + (1-omega)*mu4*C + mu1*(1+theta)*Z
	rRT = mu2*(alpha+theta*(2+alpha))*I - mu2*RT 
	rH = mu2*RT + mu2*(1-theta)*I - mu3*H
	rC = psi*mu3*H - mu4*C
	rD = omega*mu4*C 
	// ### --------------------------------------------------	
    return(rS,rZ,rI,rH,rR,rRT,rC,rD)
}

void function epimodels_siz(string scalar matname) {
    version `vers'
	par_lambda = strtoreal(st_local("lambda"))
	par_mu1 = strtoreal(st_local("mu1"))
	par_mu2 = strtoreal(st_local("mu2"))
	par_mu3 = strtoreal(st_local("mu3"))
	par_mu4 = strtoreal(st_local("mu4"))
	par_pi = strtoreal(st_local("pi"))
	par_psi = strtoreal(st_local("psi"))
	par_omega = strtoreal(st_local("omega"))
	par_theta = strtoreal(st_local("theta"))
	par_alpha = strtoreal(st_local("alpha"))
	par=par_lambda,par_mu1,par_mu2,par_mu3,par_mu4,par_pi,par_psi,par_omega,par_theta, par_alpha
	
	ini_S = strtoreal(st_local("pops"))
	ini_Z = strtoreal(st_local("popz"))
	ini_I = strtoreal(st_local("popi"))
	ini_H = strtoreal(st_local("poph"))
	ini_R = strtoreal(st_local("popr"))
	ini_RT = strtoreal(st_local("poprt"))
	ini_C = strtoreal(st_local("popc"))
	ini_D = strtoreal(st_local("popd"))
	ini=0,ini_S,ini_Z,ini_I,ini_H,ini_R,ini_RT,ini_C,ini_D
	
	iters = strtoreal(st_local("days"))
	step=strtoreal(st_local("steps"))

	valu = epimodels_rk4(&epimodels_siz_eq(),par,step,ini,iters)

	st_matrix(matname, valu)
}

string function epi_mergerowlabs(string mname, string rows) {

       // MNAME is a stata matrix name
	   // ROWS is a sequence of old rows that are forming the blocks
	   // For example: 1 2 7 will be blocks with rows [1-1], [2-6], and [7-7]
	   // Correspondingly: the first value must always be 1, 
	   //                  
	   // Each label should be in format: ###-###
	   
	   merge=strtoreal(tokens(rows))
	   if (cols(merge)==0) {
	       printf("{error}Must have rows defined!{break}")
	       exit(error(3001))
	   }
	   if (merge[1]!=1) {
	       printf("{error}Rows must start with row 1!{break}")
	       exit(error(3001))
	   }

	   rownames=st_matrixrowstripe(mname)
	   result=""
	   nj=1
	   for(i=1; i<=cols(merge); i++) {
	      t=merge[i]
		  if (i<cols(merge)) nextt=merge[i+1]-1
		  else nextt=9999999
		  mx=min((rows(rownames),nextt))
		  first=tokens(rownames[nj,2],"-")
		  last=tokens(rownames[mx,2],"-")
		  result=result+`" ""'+first[1]+"-"+last[3]+`"""'
		  nj=mx+1
	   }
	   return(strtrim(result))
}

real function epi_obsmin(string v) {
	n=st_nobs()
	if (n==0) return(.)
	result=1
	for(i=2;i<=n;i++) if (st_data(i,v)<st_data(result,v)) result=i
	return(result)
}

real function epi_obsmax(string v) {
	n=st_nobs()
	if (n==0) return(.)
	result=1
	for(i=2;i<=n;i++) if (st_data(i,v)>st_data(result,v)) result=i
	return(result)
}

real rowvector epi_multinomial(real N, real rowvector P) {

      if (N!=floor(N)) {
	    printf("{error}Error! First parameter N must be integer, received: %g{break}",N)
		exit(error(3001))
	  }
	  
	  s=sum(P)
	  if (round(s,0.000001)!=1.00) {
	    printf("{error}Error! Probabilities must sum to 1.0: but they sum to %10.6g{break}",s)
		exit(error(3001))
	  }	  
	  
	  result=J(1, cols(P), 0)
	  
	  for(i=1;i<=N;i++) {
	    Z=rdiscrete(1,1,P)
		result[1,Z]=result[1,Z]+1
	  }
	  result
	  return(result)  
}

void function epi_sim_siz(string fmatname, real N, real R0, real theta, ///
                    real C1, real C2, real C3, real tmax, string agpop) {

    // Clears the data
    // Relies on fixed names as produced by SIZ
					
    // --------------------------------STABLE PARAMETERS------------------------
   
	AR=st_matrix(st_local("AR")) 
	// Results aggregation
	AR2=AR[1,.] \ colsum(AR[2..6,.]) \ AR[7,.] // reduce to ages 0-9, 10-59, 60+
	// AR2=AR // for no aggregation
	
	st_local("burdenrownames",`""0-9" "10-59" "60-129" "Total""')
	st_local("burdencolnames",`""Deaths" "Hosp." "ICU" "')

	mu1   = st_numscalar("mu1")
	mu2   = st_numscalar("mu2")
	mu3   = st_numscalar("mu3")
	mu4   = st_numscalar("mu4")
	q     = st_numscalar("q")
	w     = st_numscalar("w")
	alpha = st_numscalar("alpha")
   
    // -------------------------------------------------------------------------

	F=st_matrix(fmatname)
	TH=AR:*F
	pmod=sum(TH) // .00042468 == 0.00042468 (Matlab) = OK
	p=pmod/(q*w) // .002535403 == 0.002535402985075 (Matlab) = OK
	LAMBDA=R0/(p/mu2 + (1-p)/mu1)
	LAMBDA=LAMBDA*(1-C1)*(1-C2) // .2731049624 == 0.273104962438366 (Matlab) = OK
	p=p*C3
	
	stata(sprintf(`"epimodels simulate siz , "' ///
      + `"lambda(%g) mu1(%g) mu2(%g) mu3(%g) mu4(%g) pi(%g) psi(%g) omega(%g) theta(%g) alpha(%g) "' ///
      + `"pops(%g) popi(%g) steps(1) days(%g) clear nograph "' ///
      + `"xsize(16) ysize(8) legend(size(2) pos(2) cols(1)) graphregion(fc(white)) "', ///
	  LAMBDA, mu1, mu2, mu3, mu4, p, q, w, theta, alpha, N-1, 1, tmax ///
	  ))
	  
	dead=st_data(st_nobs(), "D") // 33.50166 vs 33.3344 (Matlab) ~ OK
	AR2=AR2:/sum(AR2)
    Burden1=round(dead*AR2)
    Burden1=rowsum(Burden1\colsum(Burden1))
	Burden3=Burden1/w
	Burden2=Burden1/(q*w)
	Burden=round((Burden1,Burden2,Burden3)) // (vs Matlab) ~ OK
	
	Total_num_of_infections=round(N-st_data(st_nobs(),"S")) // 78484 vs 78496 (Matlab) ~ OK
	
	pos=epi_obsmax("H")
	Max_num_of_hospitalized_in_a_day=st_data(pos,"H")
	tmaxH=st_data(pos,"t") // 68 vs 67 (Matlab)
	
	pos=epi_obsmax("C")
	Max_num_of_ICU_in_a_day=st_data(pos,"C")
	tmaxC=st_data(pos,"t") // 74 vs 72 (Matlab)
	
	stata("summarize t if H>=1, meanonly")
	Time_to_first_hosp=st_numscalar("r(min)") // ...... (Matlab)
	
	stata("summarize t if D>=1, meanonly")
	Time_to_first_death=st_numscalar("r(min)") // 53 vs 52 (Matlab)

	infe=st_tempname()
	stata(sprintf("generate double %s = (%g-S)/%g",infe,N,Total_num_of_infections))
	
	stata(sprintf("summarize t if %s>0.25, meanonly",infe))
	t25=st_numscalar("r(min)")
	
	stata(sprintf("summarize t if %s>0.50, meanonly",infe))
	t50=st_numscalar("r(min)")
	
	stata(sprintf("summarize t if %s>0.75, meanonly",infe))
	t75=st_numscalar("r(min)")
	
	st_matrix("B",Burden)
	st_matrix("T",(t25,t50,t75))
	st_numscalar("tni",Total_num_of_infections)
	st_numscalar("mhosp",Max_num_of_hospitalized_in_a_day)
	st_numscalar("tmaxH",tmaxH)
	st_numscalar("micu",Max_num_of_ICU_in_a_day)
	st_numscalar("tmaxC",tmaxC)
	st_numscalar("thosp1",Time_to_first_hosp)
	st_numscalar("tdeath1",Time_to_first_death)
}

string function epi_siz_compname(string c) {
	if (strupper(c)=="T") return(`"Time"')
	if (strupper(c)=="S") return(`"(S) Susceptible"')
	if (strupper(c)=="Z") return(`"(Z) Asympt. inf. that will not require hospitalization"')
	if (strupper(c)=="I") return(`"(I) Sympt. inf. that will need hospitalization eventually"')
	if (strupper(c)=="H") return(`"(H) Hospitalized not in intensive care"')
	if (strupper(c)=="R") return(`"(R) Recovered"')
	if (strupper(c)=="RT") return(`"(RT) Removed temporarily"')
	if (strupper(c)=="C") return(`"(C) Intensive care"')
	if (strupper(c)=="D") return(`"(D) Dead"')
	
	return("UNKNOWN COMPARTMENT")
}






mata mlib create lepimodels, replace

mata mlib add lepimodels epimodels_about()
mata mlib add lepimodels epi_applylabels()

mata mlib add lepimodels epimodels_rk4()
mata mlib add lepimodels epimodels_sir_eq()
mata mlib add lepimodels epimodels_sir()
mata mlib add lepimodels epimodels_seir()
mata mlib add lepimodels epimodels_seir_eq()
mata mlib add lepimodels epimodels_sir_eqtext()
mata mlib add lepimodels epimodels_seir_eqtext()

mata mlib add lepimodels epi_sum2diff()
mata mlib add lepimodels epi_getpenalty()
mata mlib add lepimodels epi_makeparamstr()
mata mlib add lepimodels epi_searcheval()
mata mlib add lepimodels epi_getstartparams()
mata mlib add lepimodels epi_postendparams()
mata mlib add lepimodels epi_searchparams()
mata mlib add lepimodels epi_greek()
mata mlib add lepimodels epi_greek1()
mata mlib add lepimodels epi_getmodelmeta()

mata mlib add lepimodels epi_menu()
mata mlib add lepimodels epi_wordpos()

mata mlib add lepimodels epimodels_siz()
mata mlib add lepimodels epimodels_siz_eq()
mata mlib add lepimodels epimodels_siz_eqtext()
mata mlib add lepimodels epi_mergerowlabs()
mata mlib add lepimodels epi_obsmin()
mata mlib add lepimodels epi_obsmax()
mata mlib add lepimodels epi_multinomial()
mata mlib add lepimodels epi_sim_siz()
mata mlib add lepimodels epi_siz_compname()

mata mlib index

end

// END OF FILE
