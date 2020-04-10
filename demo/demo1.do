clear all

epi_sir, beta(0.50) gamma(0.33333) susceptible(1) infected(1.27e-06) days(100) clear name(SIR1demo)

epi_sir, beta(0.5) gamma(0.33333) susceptible(60.4e+06) infected(1)  days(100) clear name(SIR2demo) lpattern(.--  .- __####__####) lwidth(thick vvthick vthick )

epi_sir , days(150) beta(0.9) gamma(0.3) susceptible(10) infected(1) recovered(2) clear day0(2020-02-29) xlabel(, labsize(tiny)) name(SIR3demo)

epi_seir, beta(0.9) gamma(0.2) sigma(0.5) susceptible(10) exposed(1) infected(0) recovered(0) days(15) clear name(SEIR1demo)

epi_seir, beta(0.9) gamma(0.2) sigma(0.5) mu(0.003) susceptible(10) exposed(1) days(560) clear name(SEIR2demo)

// END OF FILE
