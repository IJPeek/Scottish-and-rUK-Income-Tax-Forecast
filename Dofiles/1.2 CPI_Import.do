// Import and Reshape of ONS CPI Data
// Conclusion of unit root test for Dataset use the FD_CPI_UK

********************************************************************************
****				Import Data, Clean and Reshape Data						****

import delimited "$raw/series-170622.csv", clear

//Get rid of non-monthly data and preamble
drop if _n<=174

//Get rid of before 2003
drop if _n<=168

rename v1 t
rename v2 CPI_UK
gen newt= monthly(t, "YM") 

format newt %tm

// Convert String to Date
drop t
rename newt t
order t CPI_UK
destring CPI_UK, replace 
tsset t, monthly
label variable t "Date given by Month and Year"
label variable CPI_UK "CPI (ONS) for the UK (Relative to last year)"


********************************************************************************
****					Generate Stationary Variables					******

tsline CPI_UK

//Natural Log
gen ln_CPI_UK = ln(CPI_UK)
label variable ln_CPI_UK "Log of CPI_UK"

// First Difference
gen FD_CPI_UK = D.CPI_UK
label variable FD_CPI_UK "First Difference of CPI_UK"

// Fist Dif of Log
gen FD_ln_CPI_UK = D.ln_CPI_UK
label variable FD_ln_CPI_UK "First Difference of log of CPI_UK"


**			Unit Root Tests to determine which transformation should be used
// v1
tsline ln_CPI_UK
tsline FD_CPI_UK // looks ok but clear structural break for current inflation
tsline FD_ln_CPI_UK // 

//Conclusion: FD_CPI_UK is stationary 
dfuller FD_CPI_UK, lags(4)  reg 
dfuller FD_CPI_UK, lags(3)  reg	
dfuller FD_CPI_UK, lags(2)  reg
dfuller FD_CPI_UK, lags(1)  reg //Reject the null AIC and BIC smallest
dfuller FD_CPI_UK, lags(0)  reg
dfsummary FD_CPI_UK, lag(4) reg

//Comclusion: FD_ln_CPI_UK stationary 
dfuller FD_ln_CPI_UK, lags(4)  reg 
dfuller FD_ln_CPI_UK, lags(3)  reg	
dfuller FD_ln_CPI_UK, lags(2)  reg //Reject the null. AIC smallest lag here
dfuller FD_ln_CPI_UK, lags(1)  reg 
dfuller FD_ln_CPI_UK, lags(0)  reg //Reject the null. BIC smallest lag here
dfsummary FD_ln_CPI_UK, lag(4) reg



//Conclusion: CPI_UK is non-stationary 
dfuller CPI_UK, lags(4)  reg 
dfuller CPI_UK, lags(3)  reg	
dfuller CPI_UK, lags(2)  reg
dfuller CPI_UK, lags(1)  reg //Reject the null AIC and BIC smallest
dfuller CPI_UK, lags(0)  reg
dfsummary CPI_UK, lag(4) reg

//unit root test for CPI with strucural break in the intercept.
// fail to reject unit root and
zandrews CPI_UK, lagmethod(AIC) break(intercept)

save "$temp/cpi_uk.dta", replace


