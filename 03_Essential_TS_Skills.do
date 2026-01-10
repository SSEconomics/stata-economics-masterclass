// -----------------------------    
// Stata Masterclass: Video 3 
// Topic: Essential Stata Skills
// -----------------------------    
// Author: Stephen Snudden, PhD
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics/stata-economics-masterclass
// -----------------------------    

// Edit this file freely - its yours now (understand every line of code)

// ---------------------------------------------------------
// FORMALITIES
// ---------------------------------------------------------
clear all            // Clear memory
capture log close    // Close any open logs
log using "output.log", replace

// "The Setup" - Standard settings for every project
set linesize 255     // Prevents line wrapping in the log
set more off         // Prevents Stata from pausing
*set scheme s2mono    // Set default graph scheme to black & white if needed for journals

// ---------------------------------------------------------
// 1. DATA IMPORT & MERGE (Reproducible Automation)
// ---------------------------------------------------------
// [PRO RULE]: Never use the menus or command window. If I can't replicate your data cleaning 
// by running this do-file, the work is invalid.

// TIP: Near-instant automation of the frequency conversion  (Monthly -> Quarterly)
// This takes hours in Excel. In Stata, it's 5 lines.

// Step A: Process Monthly Data
import delimited "CDataM.csv", clear
generate month = tm(1961m1) + _n - 1 
format %tm month
tsset month

// Step B: Collapse to Quarterly (
// [PRO RULE]: Don't list every variable manually. 
// Use 'ds, not' to find everything except the keys. This scales to 1000s of variables.
gen time = qofd(dofm(month))    // Create quarterly date from monthly
format time %tq
ds month time year m, not       // Find all variables that are NOT date keys
collapse `r(varlist)', by(time) // Collapse them automatically
save "DataM.dta", replace

// Step C: Import Quarterly Data & Merge
import delimited "CDataQ.csv", clear
generate time = tq(1961q1) + _n - 1
format %tq time
tsset time
isid time
// Merge the collapsed monthly data into the quarterly file
merge 1:1 time using "DataM.dta", nogenerate

// ---------------------------------------------------------
// 2. VARIABLE CREATION (The Time Series Engineer)
// ---------------------------------------------------------
// [TRAP]: Never calculate growth rates in Excel and import them.
// Hard-coding hides mistakes. We use operators (L. D. S.) so the math is visible here.
// L4. = Lag of 4 quarters (1 year ago)

// A. Aggregates
gen c = c_hh + c_np              // Real Consumption
gen c_nom = c_hh_n + c_np_n      // Nominal Consumption

// B. Growth Rates (Year-over-year)
// Formula: (Current - YearAgo) / YearAgo
gen gy4 = 100 * (y / L4.y - 1)   // Real GDP Growth 
gen gp4 = 100 * (cpi / L4.cpi - 1) // Inflation 

// C. Ratios (Shares of GDP in Percent)
gen c_share = 100 * (c_nom / y_n)

// Labels (Crucial for clean graphs later)
// [PRO TIP]: Label variables here instead of in the figure legends. 
// "gy4" means nothing to a reader. "Real GDP Growth" stands alone.
label variable gy4 "Real GDP Growth"
label variable gp4 "Headline CPI Inflation"
label variable c_share "Consumption (% of GDP)"

// ---------------------------------------------------------
// 3. FIGURES (The Data Artist)
// ---------------------------------------------------------
// [THE STAND-ALONE PRINCIPLE]: 
// If I drop your graph on the floor, can a stranger understand it 
// without reading your paper? If no, you lose marks.

// Figure 1: Basic Time Series (The GDP Share)
// [CHECKLIST]:
// 1. Title describes the figure generally? Yes.
// 2. Axes are for UNITS (Percent/Quarters), not variable names? Yes.
// 3. Notes describe Source, Date Range, and Transformations? Yes.
// 4. No blue background? Yes.

tsline c_share if time >= tq(1990q1), ///
    title("Consumption as a Percent of GDP") ///
    ytitle("Percent") ///
    xtitle("Quarters") ///
    tlabel(1990q1(20)2015q1) ///
    yline(56, lstyle(grid)) ///   Add a reference line
    graphregion(color(white)) /// Clean white background (Publication Standard)
    note("Notes: Author's calculations using Statistics Canada Table 36-10-0104-01.")
graph export "fig_ratios.png", replace width(2000)

// Figure 2: Advanced Two-Axis Plot (Growth vs Inflation)
// [TRAP]: Plotting Percent Change (GDP) and Percent Level (Interest Rates)
// on the same axis flattens the growth data. You MUST use yaxis(2).

twoway ///
    (tsline gy4 if time >= tq(1995q1)) ///
    (tsline gp4 if time >= tq(1995q1), yaxis(2) lp(dash)), ///
    ytitle("Percent Change") ///
    ytitle("Percent Change", axis(2)) ///
    xtitle("Quarters") ///
    legend(position(6) col(2) label(1 "Real GDP") label(2 "CPI (Right Axis)") region(lstyle(none))) ///
    graphregion(color(white)) ///
	note("Notes: Year-over-year growth rate in percent. Authors calculations using Statistics Canada Table 36-10-0104-01.")
graph export "fig_growth_inf.png", replace width(2000)

// Figure 3: Scatter Plot (Growth vs Inflation)

twoway ///
    (scatter gy4 gp4 if time >= tq(1990q1)) ///
    (lfit    gy4 gp4 if time >= tq(1990q1)), ///
    title("GDP Growth and Inflation") ///
    ytitle("GDP Growth (percent)") ///
    xtitle("CPI Inflation (percent)") ///
    yline(0, lpattern(dash) lcolor(gs10)) ///
    legend(off) ///
    graphregion(color(white)) ///
    note("Notes: Year-over-year growth rates. Authors calculations using Statistics Canada Table 36-10-0104-01.")
graph export "scatter_GDP_CPI.png", replace width(2000)

// Closes graph window before moving on 
graph close _all

// ---------------------------------------------------------
// 4. SUMMARY STATS (The Analyst)
// ---------------------------------------------------------

// A. Summary Statistics 
// [TRAP]: 
// 1. Only summarize STATIONARY data (Growth rates = Yes, Nominal Levels = No).
// 2. Do not copy 6 decimal places. Use max 3 (e.g., 0.752). Precision implies false confidence.

summarize gy4 gp4 if time >= tq(1994q1) 

// B. Relative Volatility 
// Question: "Is CPI more or less volatile than GDP?"
// [PRO RULE]: Don't use a calculator. Stata stores the SD in 'r(sd)'.
// If the data updates next month, this code updates the ratio automatically.

quietly summarize gy4 if time >= tq(1994q1)
scalar sd_gdp = r(sd)  // Save GDP volatility

quietly summarize gp4 if time >= tq(1994q1)
scalar sd_cpi = r(sd)  // Save CPI volatility

display "Relative Volatility (CPI / GDP): " sd_cpi / sd_gdp

// C. Correlations (Contemporaneous, Leads & Lags)
// Question: "Does CPI Lead or Lag GDP?"
// [PRO TIP]: Learn to read pwcorr with lags. 
// Row 'gy4', Column 'l.gp4' = Correlation of GDP with PAST Inflation.
// Row 'gy4', Column 'f.gp4' = Correlation of GDP with FUTURE Inflation.

display "Correlations with Lags of CPI"
pwcorr l.gp4 gp4 f.gp4 gy4 if tin(1994q1, 2010q1)
pwcorr l.gp4 gp4 f.gp4 gy4 if time>=tq(1994q1)

// ---------------------------------------------------------
// 5. The Modeller 
// ---------------------------------------------------------

// Regressions (autoregressive distributed lag - ARDL)
reg gp4 l.gp4 l.gy4 if tin(1994q1, 2009q4)
// Check for serial correlation in errors (underspecification)
estat bgodfrey
// Check residuals for autocorrelation
predict e_gp4 if tin(1994q1, 2009q4), resid
varsoc e_gp4, maxlag(12)

// Check for maximum number of recommended lags in bi-variate VAR 
varsoc gp4 gy4, maxlag(12)

regress gp4 l(1/9).gp4 l(1).gy4 if tin(1994q1, 2009q4)
// Check for serial correlation in errors (underspecification)
estat bgodfrey
// Check residuals for autocorrelation
predict e2_gp4 if tin(1994q1, 2009q4), resid
varsoc e2_gp4, maxlag(12)

// Hypothesis Testing (Wald/ F Tests) 
// H_0: beta=0
test L1.gy4
// H_0: rho_8=rho_9=0
test L8.gp4 L9.gp4

// One-step ahead prediction
predict f_gp4 if time>=tq(2010q1), xb
label variable f_gp4 "Out-of-Sample Forecast"

// Visualize 
tsline gp4 f_gp4 if time>=tq(2005q1), ///
    title("One-Quarter Ahead CPI Inflation Forecasts") ///
    ytitle("Percent") ///
    xtitle("Quarters") ///
    tlabel(2005q1(8)2016q1) ///
    yline(60, lstyle(grid)) ///   Add a reference line
    graphregion(color(white)) 
graph export "CPIforecast.png", replace width(2000)

// ---------------------------------------------------------
// Close Log
log close

// -----------------
// End of file
// -----------------