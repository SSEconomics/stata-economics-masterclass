// -----------------------------    
// Stata Masterclass: Video 5
// Topic: Automating Tables to LaTeX & Excel/Word
// -----------------------------    
// Author: Stephen Snudden, PhD
// Website: https://stephensnudden.com/
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics/stata-economics-masterclass

// -----------------------------    
// 1. SETUP
// -----------------------------    
clear all            
capture log close    
log using "output.log", replace
set linesize 255     
set more off         

// The USER WRITTEN 'estout' package is the industry standard.
capture ssc install estout
which estout

// Import Data (Using the clean quarterly data from Video 1)
import delimited "CDataQ.csv", clear
local yy=year[1]
local qq=q[1]
generate time = tq(`yy'q`qq') + _n - 1
format %tq time
tsset time

// Create variables
gen c = c_hh + c_np         // Real Consumption

// Loop for growth rates
foreach v in y c { 
	gen d`v' = 100 * (`v'/L4.`v'-1)   // YoY Growth
}

// Labels are MANDATORY for professional tables
label variable dy "Real GDP Growth"
label variable dc "Real Consumption Growth"

// -----------------------------    
// PART 2: SUMMARY STATISTICS (Table 1a)
// -----------------------------    

// Step A: Post the summary stats to memory
// Option "listwise" ensures sample is identical, which is essential
estpost summarize dy dc, listwise			// store summary stats for dy,dc

// Step B: Export 
// Option 1: LaTeX export (for Overleaf/Papers; use \input{} to load into an existing LaTeX doc)
esttab using "Table1a_Summary.tex", replace ///
    cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///  // which statistics to print and how to format them
    noobs label booktabs fragment ///  									// drop obs numbers, use labels, nice LaTeX rules, tabular only
	nomtitles nonumbers ///												// remove unneccessary column labels - like (1)
    title("Table 1a: Descriptive Statistics")

// Option 2: Word export (.rtf keeps borders/formatting)
esttab using "Table1a_Summary.rtf", replace ///
    cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    noobs label ///								// drop obs numbers and use variable labels
	nomtitles nonumbers ///
    title("Table 1a: Descriptive Statistics")
	
// -----------------------------    
// PART 3: The Hybrid Method (putexcel)
// -----------------------------    

// Many "post" style commands expect bare variable names (not L./F. expressions).
// Workaround: run correlate, capture r(C), and export that matrix.

// Option 1) brute force the print
// Correlation matrix
pwcorr L.dc dc F.dc dy, star(.05)
matrix C = r(C)

// Write matrix with row/col names
putexcel set "Table2_corr_raw.xlsx", sheet("Corr") replace
putexcel A1 = matrix(C), names

// Option 2) the better way
// Summary statistics -> Excel (simple loop + putexcel)
putexcel set "Table2_data_formatted.xlsx", sheet("SummaryStats") modify
putexcel A1=("Variable") B1=("N") C1=("Mean") D1=("SD") E1=("Corr(GDP,X_{t-1})") F1=("Corr(GDP,X_{t})") G1=("Corr(GDP,X_{t+1})")
// Loop over each variable
local row = 2
foreach v in dy dc {
	quietly correlate L.`v' `v' F.`v' dy
	matrix C = r(C)
	matrix mrow = C[4,1..3]
    quietly summarize `v'
    putexcel A`row'=("`: variable label `v''") ///  uses label instead of dy/dc
            B`row'=(r(N)) ///
            C`row'=(r(mean)) ///
            D`row'=(r(sd)) ///
			E`row'=matrix(mrow)
    local ++row
}

// -----------------------------    
// PART 4: REGRESSION RESULTS (Table 3)
// -----------------------------    
eststo clear 

// eststo: stores each model so esttab can stack them side-by-side
eststo AR1: regress dy L.dy, vce(robust)
eststo AR4: regress dy L(1/4).dy, vce(robust)

// Screen preview: se = standard errors; ar2 = adjusted R-squared
esttab, se ar2 star(* 0.10 ** 0.05 *** 0.01) label

// Word export (.rtf opens cleanly in Word)
esttab using "Table3_Regressions.rtf", replace ///
    se ar2 label ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table 2: GDP Growth Forecasting Models") ///
    addnotes("Notes: Robust standard errors in parentheses.")
	
// -----------------------------    
// PART 5: LOOPING OVER SIMULATIONS + EXPORT TO EXCEL
// ----------------------------- 

// GLOBAL persists after the do-file finishes. We use it here to keep row count
// across blocks without restructuring the code into one long loop.
global row=1

// 1. Define the Program
capture program drop mysimprogram   
program mysimprogram, rclass        
    clear
    args vv yy bb rr
    local numobs= `yy'+`bb'  
    set obs `numobs'  
    gen t = _n
    tsset t
    scalar sdv = sqrt(`vv')
    
    // Generate AR(1)
    gen e = rnormal(0, sdv)
	
    gen x = 0
    replace x = `rr'*L.x + e if t>1 
    
    // Burn-In 
    drop if t <= `bb'
    
    // Regress - OLS
    reg x L.x, noconstant
    return scalar rho_ols = _b[L.x]
	
	// Regress - MLE
    arima x, ar(1) noconstant
    return scalar rho_mle = _b[L.ar]
end

// Loop over the simulations:
*forvalues rhome=0.99(-0.02)0.89 {   // ***Comment me in***

// 2. Define Parameters 
local var = 1       // Variance
local sims= 10      // Number of simulations
local periods= 500  // Periods
local burn= 500     // Burn
local rho = 0.99	// AR coefficent you want to loop over		// ***Comment me out***
*local rho = `rhome'	// loop over AR coefficent              // ***Comment me in***

// 3. Run the Simulation
simulate rho_ols=r(rho_ols) rho_mle=r(rho_mle), reps(`sims') seed(1369): mysimprogram `var' `periods' `burn' `rho'

// Summarize simulation outputs
qui summarize rho_ols
local m_ols  = round(r(mean), .001)
local sd_ols = round(r(sd),   .001)
local n_ols  = r(N)

qui summarize rho_mle
local m_mle  = round(r(mean), .001)
local sd_mle = round(r(sd),   .001)
local n_mle  = r(N)

// Write results to Excel
putexcel set "SimResults.xlsx", sheet("rhohat") modify

// Create header row (run once)
if $row == 1 {
    putexcel A$row = ("rho")          ///
            B$row = ("periods")       ///
            C$row = ("simulations")   ///
            E$row = ("mean rho (OLS)") ///
            F$row = ("mean rho (MLE)") ///
            H$row = ("sd rho (OLS)")  ///
            I$row = ("sd rho (MLE)")  ///
            K$row = ("N (OLS)")       ///
            L$row = ("N (MLE)")
    global row = $row + 1
}

// Print results (numeric cells stay numeric in Excel)
putexcel A$row = (`rho')      ///
         B$row = (`periods')  ///
         C$row = (`sims')     ///
         E$row = (`m_ols')    ///
         F$row = (`m_mle')    ///
         H$row = (`sd_ols')   ///
         I$row = (`sd_mle')   ///
         K$row = (`n_ols')    ///
         L$row = (`n_mle')

global row = $row + 1

// End loop over simualtions 
*}										// ***Comment me in***
	
// ---------------------------------------------------------
log close