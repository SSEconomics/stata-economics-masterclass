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
// It contains the 5 most common errors students make.
// Your goal: Run the code, find the error, fix it, and run again.

// ***************************
// 1. Setup
// ***************************
clear all
capture log close
set more off
log using "output_02.log", replace

// ***************************
// PART 1: THE PATH ERROR (r601)
// ERROR: "not found"
// ***************************

// ERROR #1a: Did you unzip the file?

// ERROR #1b: Did you double click the file to open Stata (correct working directory)? 
pwd // print working directory

// ERROR #1c: Are you using an incorrect path?
import delimited "Data/CDataM.csv", clear  // FIX: Remove "Data/" to locate the current folder.

// Other common path failure examples
// graph export "Figures/growth_graph.png", replace  
// log using "Output/output_02.log", replace

// ERROR #1d: Use "\" only works on Windows; "/" works on Mac and Linux  
// BAD: import delimited "Data\CDataM.csv", clear
// GOOD: import delimited "Data/CDataM.csv", clear

// ***************************
// PART 2: THE RED TEXT ERROR (r4)
// ERROR: "no; data in memory would be lost"
// ***************************

// ERROR #2: Uploading data when some already exists
import delimited "CDataM_broken.csv"   // FIX: use the ", clear" option

// ***************************
// PART 3: THE RED TEXT ERROR (r109)
// ERROR: "type mismatch"
// ERROR: "string variable ... not allowed" 
// ***************************

// Import the "Broken" Monthly Data
import delimited "CDataM_broken.csv", clear
// Set time
generate month = tm(1961m1) + _n - 1 
format %tm month
tsset month

// FIX: Handle the "N/A" text by cleaning up the CSV
// Better Fix: Ignore specific non-numeric characters
*destring unemp, replace ignore("N/A")

// ERROR #3a: Look at the Data Browser. 'unemp' is RED (String).
describe unemp emp
gen laborforce=unemp+emp

// Collapse to quarterly
gen time = qofd(dofm(month))
format time %tq
// ERROR #3b: If 'unemp' is still a string (red) because you didn't fix it above
ds month time year m, not
collapse (mean) `r(varlist)', by(time)
save "DataM.dta", replace

// ***************************
// PART 4: THE GHOST VARIABLE (r111)
// ERROR: "variable ... not found"
// ERROR: "time variable not set"
// ***************************

// ERROR #4a: Here we call it 'EMP' instead of 'emp'. 
// Stata is case-sensitive and spelling-sensitive.
gen lemp = ln(EMP) 

// We collapse to quarterly, but Stata forgot 'time' is the date variable.
*tsset time
gen lag_cpi=L.cpi

// ***************************
// PART 5: THE SILENT KILLER (Logic)
// ***************************

// ERROR #5: The data starts in 1961. The code below says 1971.
// Stata won't give an error (Red Text), but your graph will be wrong.
import delimited "CDataQ.csv", clear

generate time = tq(1971q1) + _n - 1 // FIX: Check the Source! Change 1971 to 1961.
format %tq time
tsset time

// VALIDATION: Look at Output! If something doesn't seem right - "it's your mistake".
tsline y, title("The Wrong Timeline") 

// ***************************
// PART 6: THE INVALID SYNTAX (r198)
// ERROR: "invalid syntax"
// ***************************

// ERROR #6: Locals must be run in the SAME execution block as the command using them.

// INSTRUCTION TO BREAK IT: 
// 1. Highlight and run just the "import" and "local" lines below.
// 2. Then, highlight and run just the "generate" line. 
// 3. Observe the "invalid syntax" error.
import delimited "CDataQ.csv", clear
local yy = year[1]
local qq = q[1]

// WHY IT FAILS: 
// Locals are temporary. If you run them separately, they die before this line sees them.
// The "Ghost Typist" tries to type `yy' but finds nothing, so it types: tq(q) -> Error!

// FIX: Run everything from "local" to "generate" in ONE GO.
generate time = tq(`yy'q`qq') + _n - 1 
format %tq time
tsset time

// ***************************
// End
// ***************************
log close