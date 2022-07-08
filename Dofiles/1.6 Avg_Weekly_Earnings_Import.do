// Import and Reshape of BoE Base Rate Data
// Conclusion of unit root test for Dataset: FD_ln_earnings_UK,
********************************************************************************
****				Import Data, Clean and Reshape Data						****


clear
import excel "$raw/earn01jun2022.xls", cellrange(a6:b277) sheet(1. AWE Total Pay) firstrow 
//allstring 
drop if _n<=3


gen t=mofd(A)
format t %tm
destring WeeklyEarnings, replace
drop A

rename WeeklyEarnings earnings_UK
label variable earnings_UK "Average Weekly Earnings per month (total pay, Great Britain (seasonally adjusted)"
order t

tsset t



********************************************************************************
****					Generate Stationary Variables						****

//Natural Log
gen ln_earnings_UK = ln(earnings_UK)
label variable ln_earnings_UK "Log of earnings_UK"

// First Difference
gen FD_earnings_UK = D.earnings_UK
label variable FD_earnings_UK "First Difference of earnings_UK"

// Fist Dif of Log
gen FD_ln_earnings_UK = D.ln_earnings_UK
label variable FD_ln_earnings_UK "First Difference of log of earnings_UK"


**			Unit Root Tests to determine which transformation should be used

		//Graphical analysis
tsline earnings_UK
tsline ln_earnings_UK
tsline FD_earnings_UK // 
tsline FD_ln_earnings_UK // 

//Conclusion: ln_earnings_UK is stationary at 5% siginicance level
dfsummary ln_earnings_UK lag(4) reg


//Conclusion: FD_earnings_UK is stationary at 5% siginicance level
dfsummary FD_earnings_UK, lag(4) reg

//Comclusion: FD_ln_earnings_UK stationary at 5% siginifcance level
dfsummary FD_ln_earnings_UK, lag(4) reg

//Conclusion: earnings_UK is non-stationary 
dfsummary earnings_UK, lag(4) reg

save $temp/earnings_UK.dta, replace





