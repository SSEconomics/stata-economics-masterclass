// -----------------------------    
// Stata Masterclass: Video 02
// Topic: Debugging, Common Errors, and Data Validation
// -----------------------------    
// Author: Stephen Snudden, PhD
// YouTube: https://youtube.com/@ssnudden
// GitHub:  https://github.com/SSEconomics/stata-economics-masterclass
// -----------------------------    

// INSTRUCTIONS:
// This code is PURPOSELY BROKEN. 
// It contains the 6 most common errors students make.
// Your goal: Run the code, find the error, fix it, and run again.

// ***************************
// 1. Setup
// ***************************
clear all
capture log close
set more off
log using "output_02.log", replace

// ***************************
// SLIDE 1: THE RED TEXT ERROR (r109)
// ***************************

// Import the "Broken" Monthly Data
// ERROR: Look at the Data Browser. 'unemp' is RED (String).
import delimited "CDataM_broken.csv", clear

// FIX: Handle the "N/A" text
// Alternative (The Hammer): Force all non-numeric text to missing automatically
// (Uncomment the line below to fix the r109 error later)
destring unemp, replace force

// Generate Dates
generate month = tm(1961m1) + _n - 1 
format %tm month
tsset month

// We need to collapse to quarterly.
gen time = qofd(dofm(month))
format time %tq

// ERROR #1: If 'unemp' is still a string (red) because you didn't fix it above,
// the command below will crash with r(109) Type Mismatch.
ds month time year m, not
collapse (mean) `r(varlist)', by(time)

save "DataM.dta", replace

// ***************************
// SLIDE 2: THE SILENT TIME SHIFTER (Logic)
// ***************************

// Import Quarterly Data
clear
import delimited "CDataQ.csv"
drop year

// ERROR #2: Check the Source! 
// The data starts in 1961. The code below says 1971.
// This shifts all GDP data by 10 years. Stata won't give an error.
// FIX: Change 1971 to 1961.
generate time = tq(1971q1) + _n - 1 
format %tq time

save "DataQ.dta", replace
merge 1:1 time using "DataM.dta", nogenerate

// VALIDATION STEP: 
// Look at the Output window. If dates are wrong, you see many "not matched".

// ***************************
// SLIDE 3: THE TIME TRAVEL ERROR (r198)
// ***************************

// ERROR #3: "Time-series operators not allowed"
// We merged the data, but Stata forgot 'time' is the date variable.
// FIX: Uncomment the line below.
*tsset time
gen gy4 = 100 * (y / L4.y - 1)
label variable gy4 "Real GDP Growth"

// VALIDATION STEP (Visual): 
// This graph proves Error #2 (The Time Shifter). 
// The recession should be in 1982, not 1992.
tsline gy4, title("The Wrong Timeline") name(bad_graph, replace)

// ***************************
// SLIDE 4: THE GHOST VARIABLE (r111)
// ***************************

// Textbook Real GDP
gen c = c_hh + c_np

// ERROR #4: "Variable not found"
// We called it 'emp' in the CSV. Here we call it 'empo'. 
// Stata is case-sensitive and spelling-sensitive.
gen lemp = ln(empo) 

// ***************************
// SLIDE 5: THE SILENT KILLER (Destruction)
// ***************************

// ERROR #5: The Silent Wipe
// This line runs successfully (no red text).
// But look at your data browser. 'gy4' is now entirely empty dots (.).
// FIX: Delete this line!
replace gy4 = . 

// ***************************
// SLIDE 6: THE PATH ERROR (r601)
// ***************************

// ERROR #6: "Directory not found"
// Stata cannot save into a folder that doesn't exist.
// FIX: Remove "Figures\" to save in the current folder.
graph export "Figures\growth_graph.png", replace 

// ***************************
// End
// ***************************
log close