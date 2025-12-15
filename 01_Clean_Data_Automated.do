// -----------------------------	
// Stata Masterclass: Video 01
// Topic: Importing, Frequency Conversion, and Merging
// -----------------------------	
// Author: Stephen Snudden, PhD
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics/stata-economics-masterclass
// -----------------------------

// ***************************
// 1. Setup & Environment
// ***************************
// Tips: 
// 1. Keep this .do file and your .csv files in the SAME folder.
// 2. Do not set a working directory (cd); Stata finds the files automatically if you double-click the .do file.
// 3. Highlight lines and press Ctrl+D (Windows) or Cmd+Shift+D (Mac) to run.

clear all               // Clears memory to start fresh
capture log close       // Closes any open log files to prevent errors
set more off            // Prevents Stata from pausing for "--more--" messages
set linesize 255        // Widens the output window

// Start a log to record your results
log using "output_01.log", replace

// ***************************
// 2. Process Monthly Data (Labor & Prices)
// ***************************

// Import the raw Comma Separated Values (CSV) file
import delimited "CDataM.csv", clear

// Create Time Variable
// logic: Start at Jan 1961 + (Row Number - 1)
generate month = tm(1961m1) + _n - 1 
format %tm month        // Make the date human-readable (e.g., 1961m1)
tsset month             // Tell Stata this is time-series data

// Label Variables (Good hygiene!)
label variable cpi "Consumer Price Index"
label variable emp "Employment"
label variable unemp "Unemployment"

// ***************************
// 3. Frequency Conversion (Monthly -> Quarterly)
// ***************************

// Step A: Create the new Quarterly time variable
gen time = qofd(dofm(month)) // Date-of-monthly -> Date-of-quarterly
format time %tq

// Step B: Identify variables to collapse
// We want to keep everything EXCEPT the date variables
ds month time year m, not
local vars_to_collapse `r(varlist)'  // Store the list safely

// Step C: Collapse (The Aggregation Strategy)
// ---------------------------------------------------------
// IMPORTANT: Choose the correct method for your data type.
// ---------------------------------------------------------

// Option (a): End-of-quarter values (Best for Asset Prices/Stocks)
// collapse (last) `vars_to_collapse', by(time)

// Option (b): Quarterly Averages (Best for Rates, CPI, Employment)
// We use this because we want the "average level" of employment during the quarter.
collapse (mean) `vars_to_collapse', by(time)

// Option (c): Quarterly Sums (Best for Flows like Sales or GDP)
// collapse (sum) `vars_to_collapse', by(time)
// Save the clean temporary dataset
save "DataM.dta", replace

// ***************************
// 4. Process Quarterly Data (National Accounts)
// ***************************

import delimited "CDataQ.csv", clear

// Create Time Variable (Quarterly)
generate time = tq(1961q1) + _n - 1
format %tq time
tsset time

// Save the clean quarterly dataset
save "DataQ.dta", replace

// ***************************
// 5. Merge and Final Polish
// ***************************

merge 1:1 time using "DataM.dta", nogenerate
tsset time // Re-declare time series after merge

// ***************************
// 6. Transformations & Cleanup
// ***************************

// Calculate Textbook Real Consumption
// Note: Variable names must match your CSV headers exactly
gen c = c_hh + c_np

// Sample Restriction
// Note: tq() requires a quarter, e.g., 1971q1, not 1971m1
drop if time < tq(1971q1)

// Clean up unnecessary variables
drop c_hh c_np 

// Final Labelling
label variable y "Real GDP"
label variable c "Real Consumption"

// Verify the result
describe
summarize

// ***************************
// End Program
// ***************************
log close

