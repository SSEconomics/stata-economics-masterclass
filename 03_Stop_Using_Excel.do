// -----------------------------    
// Stata Masterclass: Video 3 
// Topic: Stop Using Excel - Essential Stata Skills
// -----------------------------    
// Author: Stephen Snudden, PhD
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics/stata-economics-masterclass
// -----------------------------    

// Edit this file freely - its yours now (understand every line of code)

// ---------------------------------------------------------
// 1. FORMALITIES
// ---------------------------------------------------------
clear all            // Clear memory
capture log close    // Close any open logs
log using "output.log", replace

// "The Setup" - Standard settings for every project
set linesize 255     // Prevents line wrapping in the log
set more off         // Prevents Stata from pausing
*set scheme s2mono    // Set default graph scheme to black & white if needed for journals

// ---------------------------------------------------------
// 2. DATA IMPORT & MERGE (The "Data Prep" Phase)
// ---------------------------------------------------------
// [PRO RULE]: Never use the menus or command window. If I can't replicate your data cleaning 
// by running this do-file, the work is invalid.

// TIP: Near instand automation of the frequency conversion  (Monthly -> Quarterly)
// This takes hours in Excel. In Stata, it's 5 lines.

// Step A: Process Monthly Data
import delimited "CDataM.csv", clear
generate month = tm(1961m1) + _n - 1 
format %tm month
tsset month

// Step B: Collapse to Quarterly (Advanced Skill)
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

// Merge the collapsed monthly data into the quarterly file
merge 1:1 time using "DataM.dta", nogenerate

// ---------------------------------------------------------
// 3. VARIABLE CREATION (The "Time Series Engineer")
// ---------------------------------------------------------
// [TRAP]: Never calculate growth rates in Excel and import them.
// Hard-coding hides mistakes. We use operators (L. D. S.) so the math is visible here.
// L4. = Lag of 4 quarters (1 year ago)

// A. Aggregates
gen c = c_hh + c_np              // Real Consumption
gen c_nom = c_hh_n + c_np_n      // Nominal Consumption

// B. Growth Rates (The "Stop Using Excel" Method)
// Formula: (Current - YearAgo) / YearAgo
gen gy4 = 100 * (y / L4.y - 1)   // Real GDP Growth (Y-o-Y)
gen gp4 = 100 * (cpi / L4.cpi - 1) // Inflation (Y-o-Y)

// C. Ratios (Shares of GDP in Percent)
gen c_share = 100 * (c_nom / y_n)

// Labels (Crucial for clean graphs later)
// [PRO RULE]: Label variables immediately. 
// "gy4" means nothing to a reader. "Real GDP Growth" stands alone.
label variable gy4 "Real GDP Growth"
label variable gp4 "Headline CPI Inflation"
label variable c_share "Consumption (% of GDP)"

// ---------------------------------------------------------
// 4. FIGURES (The "Data Artist")
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
    title("Consumption Share of GDP") ///
    ytitle("Percent") ///
    xtitle("Quarters") ///
    tlabel(1990q1(20)2015q1) ///
    yline(60, lstyle(grid)) ///   Add a reference line
    graphregion(color(white)) /// Clean white background (Publication Standard)
    note("Notes: Authors calculations using Statistics Canada Table 36-10-0104-01.")
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
    legend(label(1 "Real GDP") label(2 "CPI (Right Axis)") region(lstyle(none))) ///
    graphregion(color(white)) ///
	note("Notes: Year-over-year growth rate in percent. Authors calculations using Statistics Canada Table 36-10-0104-01.")
graph export "fig_growth_inf.png", replace width(2000)

// ---------------------------------------------------------
// 5. SUMMARY STATS (The "Analyst")
// ---------------------------------------------------------

// A. Summary Statistics 
// [TRAP]: 
// 1. Only summarize STATIONARY data (Growth rates = Yes, Nominal Levels = No).
// 2. Do not copy 6 decimal places. Use 2 (e.g., 0.75). Precision implies false confidence.

summarize gy4 gp4 if time >= tq(1991q1) 

// B. Relative Volatility 
// Question: "Is CPI more or less volatile than GDP?"
// [PRO RULE]: Don't use a calculator. Stata stores the SD in 'r(sd)'.
// If the data updates next month, this code updates the ratio automatically.

quietly summarize gy4 if time >= tq(1991q1)
scalar sd_gdp = r(sd)  // Save GDP volatility

quietly summarize gp4 if time >= tq(1991q1)
scalar sd_cpi = r(sd)  // Save CPI volatility

display "Relative Volatility (CPI / GDP): " sd_cpi / sd_gdp

// C. Correlations (Contemporanous, Leads & Lags)
// Question: "Does CPI Lead or Lag GDP?"
// [PRO TIP]: Learn to read pwcorr with lags. 
// Row 'gy4', Column 'l.gp4' = Correlation of GDP with PAST Inflation.
// Row 'gy4', Column 'f.gp4' = Correlation of GDP with FUTURE Inflation.

display "Correlations with Lags of CPI"
pwcorr l.gp4 gp4 f.gp4 gy4 if tin(1991q1, 2010q1)
pwcorr l.gp4 gp4 f.gp4 gy4 if time>=tq(1991q1)

// ---------------------------------------------------------
// Close Log
log close

// -----------------
// End of file
// -----------------