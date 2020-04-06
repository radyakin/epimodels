{smcl}
{* *! version 1.0.0  02apr2020}{...}
{cmd:help epimodels}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: epimodels} {hline 2} Set of calculation routines for epidemiological modeling and simulations.}
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 12 2}
{cmd: epi_sir ,}
{it:options}


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Model parameters}
{synopt :{opt beta(#)}}The model parameter controlling how often a susceptible-infected contact results in a new infection{p_end}
{synopt :{opt gamma(#)}}The model parameter controlling how often an infected individual recovers{p_end}

{syntab :Initial conditions}
{synopt :{opt ini_susceptible(#)}}Number of susceptible individuals at t0{p_end}
{synopt :{opt ini_infected(#)}}Number of infected individuals at t0{p_end}
{synopt :{opt ini_recovered(#)}}Number of recovered individuals at t0{p_end}

{syntab :Other options}
{synopt :{opt days(#)}}Number of days for advancing the simulations{p_end}
{synopt :{opt day0(string)}}Optional date for beginning of the simulations{p_end}
{synopt :{opt nograph}}suppress graph{p_end}
{synopt :{opt clear}}permits the data in memory to be cleared{p_end}

{syntab :Y axis, X axis, Titles, Legend, Overall, By}
{synopt :{it:twoway_options}}any of the options documented in 
     {manhelpi twoway_options G-3}{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd: epi_sir} calculates the deterministic SIR model (susceptible-infected-recovered), which is a theoretical model of the number of infected individuals in a closed population over time. The model is commonly used for modeling the development of directly transmitted infectious disease (spread through contacts between individuals). See Kermack-McKendrick (1927) for the model description and assumptions.

{pstd}
The initial conditions may be specified in absolute numbers, as shares, or expressed in percent.


{title:Examples}

    {hline}
{pstd}Simulation{p_end}
{phang2}{cmd:. epi_sir , days(150) beta(0.9) gamma(0.3) ini_susceptible(10) ini_infected(1) }{p_end}

{pstd}Perform SIR model simulation for a population of 10 susceptible and 1 infected individuals, with infection rate 0.3 and recovery rate 0.9 over 150 days, and 
display graph{p_end}

{phang2}{cmd:. epi_sir , days(150) beta(0.9) gamma(0.3) ini_susceptible(10) ini_infected(1) ini_recovered(2) clear}{p_end}

{pstd}Same as above, but start also with 2 recovered individuals, and clear the data in memory (if any).{p_end}

{phang2}{cmd:. epi_sir , days(150) beta(0.9) gamma(0.3) ini_susceptible(10) ini_infected(1) ini_recovered(2) clear nograph}{p_end}
{pstd}Same as above, but without plotting any graph.{p_end}

{title:References}

{pstd}
Kermack, W. O. and McKendrick, A. G. (1927). Contributions to the mathematical theory of epidemics, part i. Proceedings of the Royal Society of Edinburgh. Section A. Mathematics. 115 700-721
{browse "https://royalsocietypublishing.org/doi/10.1098/rspa.1927.0118":online}


{title:Also see}

{psee}
Online: {browse "http://www.radyakin.org/stata/epimodels/": epimodels homepage}

