
clear all
local vers "16.0"
version `vers'

cd "..\code"

mata 

real matrix epimodels_rk4(pointer(real matrix function) scalar f, real matrix param, real stp, real matrix initc, real iters) {
    version `vers'
	res = initc
	for(tt=1; tt<=iters; tt++) {
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
	  res = res \ (stp*tt, adjFactor)
	}
	return(res)
}

real matrix epimodels_sir_eq(real matrix x, real matrix parm) {
    version `vers'
    N=x[1]+x[2]+x[3]
    r1= -parm[1]*x[1]*x[2]/N
    r2= parm[1]*x[1]*x[2]/N - parm[2]*x[2]
    r3= parm[2]*x[2]
    return(r1,r2,r3)
}

void function epimodels_sir(string scalar matname) {
    version `vers'
	par_beta  = strtoreal(st_local("beta"))
	par_gamma = strtoreal(st_local("gamma"))
	ini_S = strtoreal(st_local("susceptible"))
	ini_I = strtoreal(st_local("infected"))
	ini_R = strtoreal(st_local("recovered"))
	iters = strtoreal(st_local("iterations"))
	// step=0.01 // step is disabled in this version
	step=1

	par=par_beta,par_gamma
	ini=0,ini_S,ini_I,ini_R

	valu = epimodels_rk4(&epimodels_sir_eq(),par,step,ini,iters)

	st_matrix(matname, valu)
}

real matrix epimodels_seir_eq(real matrix x, real matrix parm) {
    version `vers'
    r1 = parm[4]*(x[2]+x[3]+x[4]) - parm[1]*x[3]*x[1]/(x[1]+x[2]+x[3]+x[4]) - parm[5]*x[1]
    r2 = parm[1]*x[3]*x[1]/(x[1]+x[2]+x[3]+x[4]) - (parm[4] + parm[3])*x[2]
    r3 = parm[3]*x[2] - (parm[4]+parm[2])*x[3]
    r4 = parm[2]*x[3] - parm[4]*x[4]+parm[5]*x[1]
    return(r1,r2,r3,r4)
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
	iters = strtoreal(st_local("iterations"))
	// step=0.01 // step is disabled in this version
	step=1

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
	
	printf("{error: unknown letter: %s}{break}", name)
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
	stata(`"window menu append item "Epimodels" "Estimate" `"window stopbox note "Dialog for this command is not implemented yet""'"')
	stata(`"window menu append submenu "Epimodels" "Simulate""')
	stata(`"window menu append item "Simulate" "SIR model" "db epi_sir""')
	stata(`"window menu append item "Simulate" "SEIR model" "db epi_seir""')
	stata(`"window menu append item "Epimodels" "About" `"window stopbox note "Stata package Epimodels" "by Sergiy Radyakin and Paolo Verme" "The World Bank, 2020""'"')
	stata(`"window menu refresh"')
}


mata mlib create lepimodels, replace
mata mlib add lepimodels epimodels_rk4()
mata mlib add lepimodels epimodels_sir_eq()
mata mlib add lepimodels epimodels_sir()
mata mlib add lepimodels epimodels_seir()
mata mlib add lepimodels epimodels_seir_eq()

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

mata mlib index

end

// END OF FILE
