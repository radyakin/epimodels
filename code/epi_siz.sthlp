{smcl}
{* *! version 1.0.0  02sept2020}{...}
{cmd:help epimodels}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: epi_siz} {hline 2} Implementation of SIZ epidemiological model and simulations.}
{p_end}
{p2colreset}{...}



{title:Syntax}

{p 8 12 2}
{cmd: epi_siz ,}
{it:options}


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model parameters (optional, assumed to be zero if not specified)}

{synopt :{opt lambda(#)}} λ, the contact rate, that is, the average number of contacts per unit of time{p_end}
{synopt :{opt mu1(#)}} µ1, inverse of the average time in the compartment Z.{p_end}
{synopt :{opt mu2(#)}} µ2, inverse of the average time in the compartment I.{p_end}
{synopt :{opt mu3(#)}} µ3, inverse of the average time in hospitalization (not in intensive care).{p_end}
{synopt :{opt mu4(#)}} µ4, inverse of the average time in the intensive care unit.{p_end}
{synopt :{opt pi(#)}} p, the probability that an infected individual becomes a symptomatic.{p_end}
{synopt :{opt psi(#)}} q, the proportion of hospitalized individuals that will require intensive care.{p_end}
{synopt :{opt omega(#)}} w, the proportion of individuals in intensive care that die from the infection.{p_end}
{synopt :{opt theta(#)}} θ, the fraction of infected contacts that are removed due to testing. {p_end}
{synopt :{opt alpha(#)}} α, is the effect on the exit rate from compartment I by symptom awareness and self isolation. {p_end}

{syntab :Initial conditions (optional, assumed to be zero if not specified)}

{synopt :{opt pops(#)}}(S) Number of susceptible individuals at t0{p_end}
{synopt :{opt popz(#)}}(Z) Number of individuals who are asymptomatic infected that will not require hospitalization at t0{p_end}
{synopt :{opt popi(#)}}(I) Number of individuals who are symptomatic infected that will need hospitalization eventually at t0{p_end}
{synopt :{opt poph(#)}}(H) Number of individuals that are hospitalized not in intensive care at t0{p_end}
{synopt :{opt popr(#)}}(R) Number of individuals recovered at t0{p_end}
{synopt :{opt poprt(#)}}(RT) Number of individuals removed temporarily at t0{p_end}
{synopt :{opt popc(#)}}(C) Number of individuals in intensive care at t0{p_end}
{synopt :{opt popd(#)}}(D) Number of individuals who are dead at t0{p_end}


INCLUDE help epimodels_common_options

{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd: epi_siz} calculates the deterministic SIZ model 
as applicable for modelling SARS-CoV-2 outbreak and transmission, 
which is a theoretical model of the number of 
infected individuals in a closed population over time.{p_end}

{pstd}
The following source presents the paper with detailed 
explanation of the model structure, parameters and their estimation.
{it: "COVID-19 Outbreaks in Refugee Camps. A simulation study." {browse "https://www.medrxiv.org/content/10.1101/2020.10.02.20204818v1":full text online}}{p_end}

{pstd}
When properly parametrized, the model is suitable for modeling the transmission 
of SARS-CoV-2 in closed populations, making explicit division to symptomatic
and asymptomatic infected, as well as hospitalized patients and patients in ICUs.{p_end}

{pstd}
The initial conditions must be specified in absolute numbers, 
(not as shares, or percentages).{p_end}

{pstd}
The output can be produced in absolute numbers, or in percentages.{p_end}

INCLUDE help epimodels_common_output

{pstd}Note, when a graph is built, Stata's current active scheme colors are used to 
colorize the curves. With option {opt colormodel} one can use fixed model colors, 
in which case they are: {p_end}

  compartment | color
  ----------------------
      S       | blue
      Z       | red
      I       | orange
      H       | cyan
      R       | green
      RT      | black
      C       | maroon
      D       | pink
  ----------------------

{title:Examples}

    {hline}
{pstd}Simulation{p_end}

{phang2}{cmd:. epimodels simulate SIZ}, /// {p_end}
               lambda(0.3) mu1(`=1/16') mu2(`=1/5') mu3(`=1/8') ///
               mu4(`=1/5') pi(0.0172) psi(0.3386) omega(0.5) theta(0.05) ///
               pops(10000) popi(1) popz(1) ///
               days(110) ///
               xsize(16) ysize(8) legend(size(2) pos(2) cols(1)) graphregion(fc(white))

{pstd}Perform SIZ model simulation for a population of 10000 susceptible and 1 
infected symptomatic and 1 infected asymptomatic individuals over 110 
days, and display graph{p_end}

{phang2}{cmd:. epimodels simulate SIZ}, /// {p_end}
               lambda(0.3) mu1(`=1/16') mu2(`=1/5') mu3(`=1/8') ///
               mu4(`=1/5') pi(0.0172) psi(0.3386) omega(0.5) theta(0.05) ///
               pops(10000) popi(1) popz(1) ///
               days(110) steps(100) clear ///
               xsize(16) ysize(8) legend(size(2) pos(2) cols(1)) graphregion(fc(white))

{pstd}Same as above, but clearing the data first for the storage of the results, and simulating with 100 steps per day.{p_end}

{phang2}{cmd:. epimodels simulate SIZ}, /// {p_end}
               lambda(0.3) mu1(`=1/16') mu2(`=1/5') mu3(`=1/8') ///
               mu4(`=1/5') pi(0.0172) psi(0.3386) omega(0.5) theta(0.05) ///
               pops(10000) popi(1) popz(1) ///
               days(110) steps(100) clear ///
               nograph

{pstd}Same as above, but without plotting any graph.{p_end}

{title:References}

{pstd}
CARLOS M Hernandez-Suarez, Paolo Verme, Sergiy Radyakin, Efren Murillo-Zamora (2020). 
COVID-19 Outbreaks in Refugee Camps. A simulation study.
{browse "https://www.medrxiv.org/content/10.1101/2020.10.02.20204818v1":online}{p_end}

INCLUDE help epimodels_footer
