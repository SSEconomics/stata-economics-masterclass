// -----------------------------    
// Stata Masterclass: Video 4
// Topic: Monte Carlo Simulations & The Spurious Regression Trap
// -----------------------------    
// Author: Stephen Snudden, PhD
// -----------------------------    
// YouTube: https://youtube.com/@ssnudden
// Wesite:  https://stephensnudden.com/
// GitHub:  https://github.com/SSEconomics/stata-economics-masterclass
// -----------------------------    

// -----------------------------    
// PART 1: PRE-TESTING (The Single Draw)
// -----------------------------    
// [PRO TIP]: Always write and debug your code for ONE iteration
// before you wrap it in a program. You cannot debug inside a loop.

// 1. SETUP
clear all
set seed 369        // Set a 'seed' to ensure exact replicability
set obs 100          // Start small for visualization

// 2. Generate Data (Random Walks)
gen time = _n
tsset time

// Create two independent Random Walks (drunkards walking unrelated paths)
// We use cumulative sum (sum) of random shocks to create a trend
// 
gen e1 = rnormal()
gen e2 = rnormal()
gen y1 = sum(e1)     
gen y2 = sum(e2)

// 3. Visual Inspection
// [PRO RULE]: Always graph your data. 
// They look correlated (both trending away from 0), but they are independent.
twoway (tsline y1) (tsline y2, yaxis(2)), ///
    graphregion(color(white)) legend(region(lstyle(none))) ///
    title("The Visual Trap: Spurious Correlation") ///
    note("These variables are completely unrelated.") ///
    name(visual_check, replace)

// 4. The "Lie" (Regression in Levels)
reg y1 y2
// Look at the t-statistic > 1.96. The model says "Significant". It is lying.

// -----------------------------    
//  Note on Saving Outputs  
// -----------------------------    

// Here are two ways to save p-values/ output in simulations
reg y1 y2

// Option 1: Manual Calculation
// Prone to typos. Don't do this.
display _b[y2]                      // coefficient
display _se[y2]                     // s.d of coefficient
scalar tstat =_b[y2]/_se[y2]        // t-stat
scalar pval = 2*ttail(e(df_r),abs(_b[y2]/_se[y2]))  // pvalue
display "Manual Extraction: " pval 

// Option 2: Steal from "The Hidden Matrix" 
// Stata stores results in a hidden matrix called r(table).
// Col 1 = First variable, Last Col = constant
// 
matrix M=r(table)                   // save matrix
matrix list M                       // display the matrix
scalar tstat =M[3,1]                // t-stat
scalar pval = M[4,1]                // pvalue
display "Automated Extraction: " pval

// ----------------------------- 
// 3. THE SIMULATION LOOP (The "Proof")
// ----------------------------- 
// We need to do this 500 times to prove the "Lie" happens systematically.

// 1. Define Parameters (Use locals for easy changing)
local var = 1       // Variance
local sims= 500     // Number of simulations
local periods= 100  // Periods
local burn= 500     // Burn

// 2. Define the Program
capture program drop mysimprogram   // drop program if already exists
program mysimprogram, rclass        // create a program 

    // clear data from last sim but not saved results
    clear
    
    // We pass arguments so we can change N later without rewriting code
    args vv yy bb 
    
    // Set total obs "desired+burn"
    local numobs= `yy'+`bb'  
    set obs `numobs'  
    gen t = _n
    tsset t
    
    // S.D of Random Walks
    scalar sdv = sqrt(`vv')
    // Generate Random Walks
    gen y1 = sum(rnormal(0, sdv))
    gen y2 = sum(rnormal(0, sdv))
     
    // The "Burn-In" 
    // Best practice to drop the first 500 obs to remove starting point effects
    // The regression should ONLY run on the final 100 obs.
    drop if t <= `bb'

    // A. Regress Levels (The Mistake)
    reg y1 y2
    matrix M = r(table)
    return scalar t_stat_level = M[3,1] 
    return scalar reject_level = (M[4,1] < 0.05) // 1 if Significant, 0 if not
     
    // B. Regress Differences (The Fix)
    // [PRO TIP]: Difference to make data stationary / results valid
    reg D.y1 D.y2
    matrix M2 = r(table)
    return scalar t_stat_diff = M2[3,1] // Row 3 is t-stat
    return scalar reject_diff = (M2[4,1] < 0.05)
    
end

// 3. Run the Simulation
// Note: We can use the 'seed' option here to ensure replicability
simulate t_stat_lvl=r(t_stat_level) reject_lvl=r(reject_level)  ///
t_stat_diff=r(t_stat_diff) reject_diff=r(reject_diff) ///
, reps(`sims') seed(369): mysimprogram `var' `periods' `burn'

// ----------------------------- 
// 4. THE RESULTS (The "Histogram of Lies")
// -----------------------------

// Calculate share of spurious rejections (The "Error Rate")
summarize reject_lvl
local error_rate_lvl = round(r(mean) * 100, 1)

summarize reject_diff
local error_rate_dif = round(r(mean) * 100, 1)

// Graph 1: The Spurious Regressions (Levels)
// 
hist t_stat_lvl, percent xline(-1.96 1.96) ///
    color(red%30) ///
    title("Levels (The Trap)") ///
    subtitle("Rejection Rate: `error_rate_lvl'% (Target: 5%)") ///
    xtitle("t-statistic") graphregion(color(white)) name(g1, replace)

// Graph 2: The Corrected Regressions (Differences)
hist t_stat_diff, percent xline(-1.96 1.96) ///
    color(green%30) ///
    title("Differences (The Fix)") ///
    subtitle("Rejection Rate: `error_rate_dif'% (Target: 5%)") ///
    xtitle("t-statistic") graphregion(color(white)) name(g2, replace)

// Combine for the "Mic Drop" moment
graph combine g1 g2, ///
    title("Why You Must Test for Unit Roots") ///
    note("Left: Spurious Regression. Right: Stationary Regression.") ///
    graphregion(color(white))
    
// -----------------
// End of file
// -----------------