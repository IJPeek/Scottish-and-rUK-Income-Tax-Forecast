// Import and Reshape of Global IMF Commodity Data
// Unit root testing results, use the first difference of the log for commodities


********************************************************************************
****				Import Data, Clean and Reshape Data						****

import delimited "$raw/PCPS_06-18-2022 08-16-53-22_timeSeries.csv", clear

drop v277 countryname countrycode unitname unitcode attribute

// replace date variable names m1-m12... want var name in form "jan1960"

local i =7
foreach var of varlist m1-m12 {
local i=(`i'+1)
rename `var' v`i'
}
//Note v8 is 2000M1 and v276 is 2022M5
drop commoditycode

// start from 01 2003 from when all time series are complete
drop v8-v43


reshape long v, i(commodityname) j(t)

sort commodityname
egen commod=group(commodityname)
/* to get list of commodities used: levelsof commodityname
`"APSP crude oil($/bbl)"' `"Agr. Raw Material Index "' `"Agriculture"' `"All Metals EX GOLD Index"' `"All Metals Index"' `"All index "' `"Beverages index "' `"Coal index "' `"Commodities for Index: All, excluding Gold"' `"Energy index "' `"Fertilizer"' `"Food and beverage index"' `"Food index "' `"Industrial Materials index "' `"Metal index "' `
> "Natural gas index "' `"Non-Fuel index "' `"Precious Metals Price Index"'
*/

drop commodityname
reshape wide v, i(t) j(commod)
// Make first time period 01 2003
replace t = (t-43)
generate newt = tm(2003m1) + t - 1
tsset newt, monthly /*tells Stata that the data are monthly time series*/
codebook newt

local agrp "`"APSP crude oil(bbl)"' `"Agr. Raw Material Index "' `"Agriculture"' `"All Metals EX GOLD Index"' `"All Metals Inde x"' `"All index "' `"Beverages index "' `"Coal index "' `"Commodities for Index: All, excluding Gold"' `"Energy Index"' `"Fertilizer"' `"Food and beverage index"' `"Food index "' `"Industrial Materials index "' `"Metal index "' `"Natural gas index "' `"Non-Fuel index "' `"Precious Metals Price Index"'"
local vars "v1 v1 v2 v3 v4 v5 v6 v7 v8 v9 v10 v11 v12 v13 v14 v15 v16 v17 v18"
forvalues i = 1/18 {
    local a : word `i' of `agrp'
     label variable  v`i' "`a'"
  }
  
replace t=newt
drop newt
tsset t, monthly /*tells Stata that the data are monthly time series*/
label variable t "Date given by Month and Year"


********************************************************************************
****					Generate Stationary Variables						****


//Natural Log
foreach var of varlist v1-v18{
	gen ln_`var' = ln(`var')
}

	//Label
local agrp "`"APSP crude oil(bbl)"' `"Agr. Raw Material Index "' `"Agriculture"' `"All Metals EX GOLD Index"' `"All Metals Inde x"' `"All index "' `"Beverages index "' `"Coal index "' `"Commodities for Index: All, excluding Gold"' `"Energy Index"' `"Fertilizer"' `"Food and beverage index"' `"Food index "' `"Industrial Materials index "' `"Metal index "' `"Natural gas index "' `"Non-Fuel index "' `"Precious Metals Price Index"'"
forvalues i = 1/18 {
    local a : word `i' of `agrp'
     label variable  ln_v`i' "Log of `a'"
  }
  
// First Difference
foreach var of varlist v1-v18{
	
	gen FD_`var' = D.`var'
}
	//Label
local agrp "`"APSP crude oil(bbl)"' `"Agr. Raw Material Index "' `"Agriculture"' `"All Metals EX GOLD Index"' `"All Metals Inde x"' `"All index "' `"Beverages index "' `"Coal index "' `"Commodities for Index: All, excluding Gold"' `"Energy Index"' `"Fertilizer"' `"Food and beverage index"' `"Food index "' `"Industrial Materials index "' `"Metal index "' `"Natural gas index "' `"Non-Fuel index "' `"Precious Metals Price Index"'"
forvalues i = 1/18 {
    local a : word `i' of `agrp'
     label variable  FD_v`i' "First difference of `a'"
  }
  
  
// Fist Dif of Log
foreach var of varlist ln_v1-ln_v18{
	gen FD_`var' = D.`var'
}
	//Label
local agrp "`"APSP crude oil(bbl)"' `"Agr. Raw Material Index "' `"Agriculture"' `"All Metals EX GOLD Index"' `"All Metals Inde x"' `"All index "' `"Beverages index "' `"Coal index "' `"Commodities for Index: All, excluding Gold"' `"Energy Index"' `"Fertilizer"' `"Food and beverage index"' `"Food index "' `"Industrial Materials index "' `"Metal index "' `"Natural gas index "' `"Non-Fuel index "' `"Precious Metals Price Index"'"
forvalues i = 1/18 {
    local a : word `i' of `agrp'
     label variable  FD_ln_v`i' "First difference of log of `a'"
  }


		** Unit Root Tests for each Variable
******************************************** v1: Oil (FD_v1)
tsline ln_v1 
tsline FD_v1 // looks best
tsline FD_ln_v1

// Unit root tests

** Fist var Oil
{
dfuller FD_ln_v1, lags(4)  reg //Reject the null
dfuller FD_ln_v1, lags(3)  reg	// Reject the null
dfuller FD_ln_v1, lags(2)  reg
dfuller FD_ln_v1, lags(1)  reg
dfuller FD_ln_v1, lags(0)  reg

dfsummary FD_ln_v1, lag(4) reg
* Phillips and Perron test, no trend
pperron FD_ln_v1, reg
* Elliott, Rothenberg and Stock's DF-GLS test, no trend
dfgls FD_ln_v1, maxlag(2)


dfuller ln_v1, lags(4)  reg //Fail to Reject the null
dfuller ln_v1, lags(3)  reg	//Fail to Reject the null
dfuller ln_v1, lags(2)  reg
dfuller ln_v1, lags(1)  reg
dfuller ln_v1, lags(0)  reg
dfsummary ln_v1, lag(4) reg
}

********************************************  v2: Agriculture Raw Materials FD_ln_v2
{
dfuller FD_ln_v2, lags(4)  reg 
dfuller FD_ln_v2, lags(3)  reg	
dfuller FD_ln_v2, lags(2)  reg 
dfuller FD_ln_v2, lags(1)  reg 
dfuller FD_ln_v2, lags(0)  reg // Reject the null AIC and BIC
dfsummary FD_ln_v2, lag(4) reg


dfuller ln_v2, lags(4)  reg 
dfuller ln_v2, lags(3)  reg	
dfuller ln_v2, lags(2)  reg // Fail to reject (macKinnon approx p value is 0.1167) AIC
dfuller ln_v2, lags(1)  reg // Fail to reject (macKinnon approx p value is 0.1778) BIC
dfuller ln_v2, lags(0)  reg
dfsummary ln_v2, lag(4) reg
}

********************************************  v3: Agriculture FD_ln_v3
{
dfuller FD_ln_v3, lags(4)  reg 
dfuller FD_ln_v3, lags(3)  reg	
dfuller FD_ln_v3, lags(2)  reg 
dfuller FD_ln_v3, lags(1)  reg 
dfuller FD_ln_v3, lags(0)  reg // Reject the null AIC and BIC
dfsummary FD_ln_v3, lag(4) reg


dfuller ln_v3, lags(4)  reg 
dfuller ln_v3, lags(3)  reg	
dfuller ln_v3, lags(2)  reg 
dfuller ln_v3, lags(1)  reg // Fail to reject. AIC and BIC
dfuller ln_v3, lags(0)  reg
dfsummary ln_v3, lag(4) reg
}

********************************************  v4: All metals exl gold
{
dfuller FD_ln_v4, lags(4)  reg 
dfuller FD_ln_v4, lags(3)  reg	
dfuller FD_ln_v4, lags(2)  reg 
dfuller FD_ln_v4, lags(1)  reg 
dfuller FD_ln_v4, lags(0)  reg // Reject the null AIC and BIC
dfsummary FD_ln_v4, lag(4) reg


dfuller ln_v4, lags(4)  reg 
dfuller ln_v4, lags(3)  reg	
dfuller ln_v4, lags(2)  reg 
dfuller ln_v4, lags(1)  reg // Fail to reject. AIC and BIC
dfuller ln_v4, lags(0)  reg
dfsummary ln_v4, lag(4) reg

}

********************************************  v5: All Metals Index
{
dfuller FD_ln_v5, lags(4)  reg 
dfuller FD_ln_v5, lags(3)  reg	
dfuller FD_ln_v5, lags(2)  reg 
dfuller FD_ln_v5, lags(1)  reg 
dfuller FD_ln_v5, lags(0)  reg 
dfsummary FD_ln_v5, lag(4) reg // Reject the null at all lags


dfuller ln_v5, lags(4)  reg 
dfuller ln_v5, lags(3)  reg	
dfuller ln_v5, lags(2)  reg 
dfuller ln_v5, lags(1)  reg // Fail to reject. AIC and BIC
dfuller ln_v5, lags(0)  reg
dfsummary ln_v5, lag(4) reg

}


********************************************  v6: All Index
{	
dfuller ln_v6, lags(4)  reg 
dfuller ln_v6, lags(3)  reg	
dfuller ln_v6, lags(2)  reg //Fail to Reject the null AIC lowest from DFsum
dfuller ln_v6, lags(1)  reg //Fail to Reject the null BIC lowest from DFsum
dfuller ln_v6, lags(0)  reg
dfsummary ln_v6, lag(4) reg //Fail to Reject the null


dfuller FD_ln_v6, lags(4)  reg 
dfuller FD_ln_v6, lags(3)  reg
dfuller FD_ln_v6, lags(2)  reg
dfuller FD_ln_v6, lags(1)  reg
dfuller FD_ln_v6, lags(0)  reg // Reject the Null Bigest AIC and BIc from DFsum
dfsummary FD_ln_v6, lag(4) reg // Reject the null at all lags
}

********************************************  v7: Beverages Index
{	
dfuller ln_v7, lags(4)  reg 
dfuller ln_v7, lags(3)  reg	
dfuller ln_v7, lags(2)  reg //Fail to Reject the null AIC lowest from DFsum
dfuller ln_v7, lags(1)  reg //Fail to Reject the null BIC lowest from DFsum
dfuller ln_v7, lags(0)  reg
dfsummary ln_v7, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v7, lags(4)  reg 
dfuller FD_ln_v7, lags(3)  reg
dfuller FD_ln_v7, lags(2)  reg
dfuller FD_ln_v7, lags(1)  reg
dfuller FD_ln_v7, lags(0)  reg 
dfsummary FD_ln_v7, lag(4) reg // Reject the Null at all lags
}

********************************************  v8: Coal Index
{	
dfuller ln_v8, lags(4)  reg 
dfuller ln_v8, lags(3)  reg	
dfuller ln_v8, lags(2)  reg 
dfuller ln_v8, lags(1)  reg 
dfuller ln_v8, lags(0)  reg
dfsummary ln_v8, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v8, lags(4)  reg 
dfuller FD_ln_v8, lags(3)  reg
dfuller FD_ln_v8, lags(2)  reg
dfuller FD_ln_v8, lags(1)  reg
dfuller FD_ln_v8, lags(0)  reg 
dfsummary FD_ln_v8, lag(4) reg // Reject the Null at all lags
}

********************************************  v9: Commodities for index all excl Gold
{	
dfuller ln_v9, lags(4)  reg 
dfuller ln_v9, lags(3)  reg	
dfuller ln_v9, lags(2)  reg 
dfuller ln_v9, lags(1)  reg 
dfuller ln_v9, lags(0)  reg
dfsummary ln_v9, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v9, lags(4)  reg 
dfuller FD_ln_v9, lags(3)  reg
dfuller FD_ln_v9, lags(2)  reg
dfuller FD_ln_v9, lags(1)  reg
dfuller FD_ln_v9, lags(0)  reg 
dfsummary FD_ln_v9, lag(4) reg // Reject the Null at all lags
}

********************************************  v10: Energy Index
{	
dfuller ln_v10, lags(4)  reg 
dfuller ln_v10, lags(3)  reg	
dfuller ln_v10, lags(2)  reg 
dfuller ln_v10, lags(1)  reg 
dfuller ln_v10, lags(0)  reg
dfsummary ln_v10, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v10, lags(4)  reg 
dfuller FD_ln_v10, lags(3)  reg
dfuller FD_ln_v10, lags(2)  reg
dfuller FD_ln_v10, lags(1)  reg
dfuller FD_ln_v10, lags(0)  reg 
dfsummary FD_ln_v10, lag(4) reg // Reject the Null at all lags
}

********************************************  v11: Fertilizer
{
dfuller ln_v11, lags(4)  reg 
dfuller ln_v11, lags(3)  reg	
dfuller ln_v11, lags(2)  reg 
dfuller ln_v11, lags(1)  reg 
dfuller ln_v11, lags(0)  reg
dfsummary ln_v11, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v11, lags(4)  reg 
dfuller FD_ln_v11, lags(3)  reg
dfuller FD_ln_v11, lags(2)  reg
dfuller FD_ln_v11, lags(1)  reg
dfuller FD_ln_v11, lags(0)  reg 
dfsummary FD_ln_v11, lag(4) reg // Reject the null at all lags
}

********************************************  v12: Food and Beverage index
{
dfuller ln_v12, lags(4)  reg 
dfuller ln_v12, lags(3)  reg	
dfuller ln_v12, lags(2)  reg 
dfuller ln_v12, lags(1)  reg 
dfuller ln_v12, lags(0)  reg
dfsummary ln_v12, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v12, lags(4)  reg 
dfuller FD_ln_v12, lags(3)  reg
dfuller FD_ln_v12, lags(2)  reg
dfuller FD_ln_v12, lags(1)  reg
dfuller FD_ln_v12, lags(0)  reg 
dfsummary FD_ln_v12, lag(4) reg // Reject the null at all lags
}

********************************************  v13: Food index
{
dfuller ln_v13, lags(4)  reg 
dfuller ln_v13, lags(3)  reg	
dfuller ln_v13, lags(2)  reg 
dfuller ln_v13, lags(1)  reg 
dfuller ln_v13, lags(0)  reg
dfsummary ln_v13, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v13, lags(4)  reg 
dfuller FD_ln_v13, lags(3)  reg
dfuller FD_ln_v13, lags(2)  reg
dfuller FD_ln_v13, lags(1)  reg
dfuller FD_ln_v13, lags(0)  reg 
dfsummary FD_ln_v13, lag(4) reg // Reject the null at all lags
}

********************************************  v14: Industrial Materials Index
{
dfuller ln_v14, lags(4)  reg 
dfuller ln_v14, lags(3)  reg	
dfuller ln_v14, lags(2)  reg 
dfuller ln_v14, lags(1)  reg 
dfuller ln_v14, lags(0)  reg
dfsummary ln_v14, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v14, lags(4)  reg 
dfuller FD_ln_v14, lags(3)  reg
dfuller FD_ln_v14, lags(2)  reg
dfuller FD_ln_v14, lags(1)  reg
dfuller FD_ln_v14, lags(0)  reg 
dfsummary FD_ln_v14, lag(4) reg // Reject the null at all lags
}

********************************************  v15: Metal Index
{
dfuller ln_v15, lags(4)  reg 
dfuller ln_v15, lags(3)  reg //Reject the null at 10% significance level but smaller IC than other lags anyway	
dfuller ln_v15, lags(2)  reg 
dfuller ln_v15, lags(1)  reg 
dfuller ln_v15, lags(0)  reg
dfsummary ln_v15, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v15, lags(4)  reg 
dfuller FD_ln_v15, lags(3)  reg
dfuller FD_ln_v15, lags(2)  reg
dfuller FD_ln_v15, lags(1)  reg
dfuller FD_ln_v15, lags(0)  reg 
dfsummary FD_ln_v15, lag(4) reg // Reject the null at all lags
}

********************************************  v16: Natural Gas Index
{
dfuller ln_v16, lags(4)  reg 
dfuller ln_v16, lags(3)  reg	
dfuller ln_v16, lags(2)  reg 
dfuller ln_v16, lags(1)  reg 
dfuller ln_v16, lags(0)  reg
dfsummary ln_v16, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v16, lags(4)  reg 
dfuller FD_ln_v16, lags(3)  reg
dfuller FD_ln_v16, lags(2)  reg
dfuller FD_ln_v16, lags(1)  reg
dfuller FD_ln_v16, lags(0)  reg 
dfsummary FD_ln_v16, lag(4) reg // Reject the null at all lags
}

********************************************  v17: Non-Fuel Index
{
dfuller ln_v17, lags(4)  reg 
dfuller ln_v17, lags(3)  reg	
dfuller ln_v17, lags(2)  reg 
dfuller ln_v17, lags(1)  reg 
dfuller ln_v17, lags(0)  reg
dfsummary ln_v17, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v17, lags(4)  reg 
dfuller FD_ln_v17, lags(3)  reg
dfuller FD_ln_v17, lags(2)  reg
dfuller FD_ln_v17, lags(1)  reg
dfuller FD_ln_v17, lags(0)  reg 
dfsummary FD_ln_v17, lag(4) reg // Reject the null at all lags
}

********************************************  v18: Precious Metals Price Index
{
dfuller ln_v18, lags(4)  reg 
dfuller ln_v18, lags(3)  reg	
dfuller ln_v18, lags(2)  reg 
dfuller ln_v18, lags(1)  reg 
dfuller ln_v18, lags(0)  reg
dfsummary ln_v18, lag(4) reg //Fail to Reject the null at all lags

dfuller FD_ln_v18, lags(4)  reg 
dfuller FD_ln_v18, lags(3)  reg
dfuller FD_ln_v18, lags(2)  reg
dfuller FD_ln_v18, lags(1)  reg
dfuller FD_ln_v18, lags(0)  reg 
dfsummary FD_ln_v18, lag(4) reg // Reject the null at all lags
}




// When using First difference logs for Oil and for the all commodities index series are stationary
save $temp/commodity_world.dta, replace

