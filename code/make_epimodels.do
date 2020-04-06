clear all
version 16.0

mata 

real matrix epimodels_rk4(pointer(real matrix function) scalar f, real matrix param, real stp, real matrix initc, real iters) {
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
  N=x[1]+x[2]+x[3]
  r1= -parm[1]*x[1]*x[2]/N
  r2= parm[1]*x[1]*x[2]/N - parm[2]*x[2]
  r3= parm[2]*x[2]
  return(r1,r2,r3)
}

void function epimodels_sir(string scalar matname) {
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
  r1 = parm[4]*(x[2]+x[3]+x[4]) - parm[1]*x[3]*x[1]/(x[1]+x[2]+x[3]+x[4]) - parm[5]*x[1]
  r2 = parm[1]*x[3]*x[1]/(x[1]+x[2]+x[3]+x[4]) - (parm[4] + parm[3])*x[2]
  r3 = parm[3]*x[2] - (parm[4]+parm[2])*x[3]
  r4 = parm[2]*x[3] - parm[4]*x[4]+parm[5]*x[1]
  return(r1,r2,r3,r4)
}


void function epimodels_seir(string scalar matname) {
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



mata mlib create lepimodels, replace
mata mlib add lepimodels epimodels_rk4()
mata mlib add lepimodels epimodels_sir_eq()
mata mlib add lepimodels epimodels_sir()
mata mlib add lepimodels epimodels_seir()
mata mlib add lepimodels epimodels_seir_eq()
mata mlib index

end

// END OF FILE
