clear all

epimodels simulate SIZ, ///
    lambda(0.3) mu1(`=1/16') mu2(`=1/5') mu3(`=1/8') ///
    mu4(`=1/5') pi(0.0172) psi(0.3386) omega(0.5) theta(0.05) ///
    pops(10000) popi(1) popz(1) steps(10) ///
    days(110) clear colormodel  ///
    xsize(16) ysize(8) legend(size(2) pos(2) cols(1)) graphregion(fc(white))

// END OF FILE