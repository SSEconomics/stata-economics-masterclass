// -----------------------------    
// Stata Masterclass: Video 5
// Topic: The Output Factory - Automating Tables to LaTeX & Excel/Word
// -----------------------------    
// Author: Stephen Snudden, PhD
// -----------------------------    
// YouTube: https://youtube.com/@ssnudden
// Website: https://stephensnudden.com/
// GitHub:  https://github.com/SSEconomics/stata-economics-masterclass
// -----------------------------    

// -----------------------------    
// 1. SETUP
// -----------------------------    
clear all            
capture log close    
log using "output.log", replace
set linesize 255     
set more off         

// [PRO RULE]: The 'estout' package is the industry standard.
capture ssc install estout

// Import Data (Using the clean quarterly data from Video 3)
import delimited "CDataQ.csv", clear
generate time = tq(1961q1) + _n - 1
format %tq time
tsset time

// Create variables
gen c = c_hh + c_np         // Real Consumption
gen dy = 100 * (y/L4.y-1)   // Annualized GDP Growth
gen dc = 100 * (c/L4.c-1)   // Annualized Consumption Growth

// Labels are MANDATORY for professional tables
label variable dy "Real GDP Growth"
label variable dc "Real Consumption Growth"

// -----------------------------    
// PART 2: SUMMARY STATISTICS (Table 1a)
// -----------------------------    

// Step A: Post the summary stats to memory
estpost summarize dy dc, listwise

// Step B: Export 
// Option 1: LaTeX (for Overleaf/Papers)
esttab using "Table1a_Summary.tex", replace ///
    cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    noobs label booktabs fragment ///
    title("Table 1a: Descriptive Statistics")

// Option 2: Word/Excel (.rtf) - (Replace .rtf with .csv to export to excel)
esttab using "Table1a_Summary.rtf", replace ///
    cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
    noobs label ///
    title("Table 1a: Descriptive Statistics")

// -----------------------------    
// PART 3: CORRELATIONS (The Matrix Method)
// -----------------------------    
// Problem: 'estpost' produces an error with time-series operators (L./F.).
// Solution: Run standard 'correlate', save matrix C, export matrix C.

// 1. Run standard correlation 
quietly correlate L.dc dc F.dc dy

// 2. Capture the hidden correlation matrix
matrix C = r(C)

// 3. Export the matrix directly
// [PRO TIP]: Use 'coeflabels' so rows don't say "L.dc"
esttab matrix(C) using "Table1b_Correlations.rtf", replace ///
    nomtitles nonumbers noobs ///
    coeflabels(L.dc "Cons (t-1)" F.dc "Cons (t+1)" dy "GDP Growth" dc "Cons Growth") ///
    title("Table 1b: Cross-Correlations")

// -----------------------------    
// PART 4: REGRESSION RESULTS (Table 2)
// -----------------------------    
eststo clear 

// Model 1: Simple AR(1)
eststo: regress dy L.dy, vce(robust)

// Model 2: AR(4) 
eststo: regress dy L(1/4).dy, vce(robust)
  
// EXPORT (The "Magic" Button)

// A. Screen Preview
esttab, se ar2 star(* 0.10 ** 0.05 *** 0.01) label

// B. Word Export (.rtf)
// [PRO TIP]: This file opens in Word with Borders and Formatting intact.
esttab using "Table2_Regressions.rtf", replace ///
    se ar2 label ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table 2: GDP Growth Forecasting Models") ///
    addnotes("Notes: Robust standard errors in parentheses.")

// -----------------------------    
// PART 5: SIMULATION RESULTS (Table 3)
// ----------------------------- 

eststo clear 

// 1. Define Parameters 
local var = 1       // Variance
local sims= 500     // Number of simulations
local periods= 100  // Periods
local burn= 500     // Burn

// 2. Define the Program
capture program drop mysimprogram   
program mysimprogram, rclass        
    clear
    args vv yy bb 
    local numobs= `yy'+`bb'  
    set obs `numobs'  
    gen t = _n
    tsset t
    scalar sdv = sqrt(`vv')
    
    // Generate AR(1) with rho = 0.99 (Near Unit Root)
    gen e = rnormal(0, sdv)
    gen x = 0
    replace x = 0.99*L.x + e if t>1 
    
    // Burn-In 
    drop if t <= `bb'
    
    // Regress
    reg x L.x
    return scalar rho = _b[L.x]
end

// 3. Run the Simulation
simulate rho_hat=r(rho), reps(`sims') seed(1369): mysimprogram `var' `periods' `burn'

// 4. Summarize and Export
estpost summarize rho_hat, listwise

esttab using "Table3_Sims.rtf", replace ///
    cells("count mean(fmt(4)) sd(fmt(4)) min(fmt(4)) max(fmt(4))") ///
    noobs label ///
    title("Table 3: Monte Carlo Simulation Results (True Rho = 0.99)")

// ---------------------------------------------------------
log close