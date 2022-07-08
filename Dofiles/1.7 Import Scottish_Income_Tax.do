
// Import and Reshape of Scottish Income Tax Outturn Statistics released 7th July 2022
// No unit root tests have been conducted unlike in the import dofiles of the other time series
//  Indicative In-Year Income Tax taken from HMRC's Real Time Information system


// Import all data, reshape Scottish Income Tax Data first, then restore the dataset for UK data reshape. Then the two are merged together into one dataset and an rUKIT created from UKIT-SIT

clear
import excel "$raw/Scottish_Income_Tax_Outturn_Statistics_2021-22__rounded_.xls", cellrange(A10:o31) sheet(Table_4) firstrow 
//Scottish_Income_Tax_Outturn_Statistics_2020-21__rounded_.ods

preserve
keep if IncomeTax=="Scottish"
drop IncomeTax AnnualTotal
//is from 2016m4-2022m3 previous release was 2021m3
 order April May June July August September October November December January February March 
 
local i =0
ds
foreach var of varlist `r(varlist)' {
	local i=(`i'+1)
rename `var' mon`i'	
}
rename mon13 Taxyear



reshape long mon , i(Taxyear)  j(Month)
rename mon SIT
label variable SIT "Scottish Income Tax (SIT) (NSND excl. self employed)"
generate t = tm(2016m4) + _n -1
tsset t, monthly /*tells Stata that the data are monthlytime series*/
drop Taxyear Month
order t SIT



tempfile scottish_tax
save scottish_tax, replace
	
restore


*********************************************************
** Having restored the imported Dataset, Reshape for UK data and generate rUK data

keep if IncomeTax=="All UK"
drop IncomeTax AnnualTotal

order April May June July August September October November December January February March 
 
local i =0
ds
foreach var of varlist `r(varlist)' {
	local i=(`i'+1)
rename `var' mon`i'	
}
rename mon13 Taxyear

//i is definitely taxyear
//a is the months
reshape long mon , i(Taxyear)  j(Month)
rename mon UKIT
label variable UKIT "UK Income Tax  (NSND excl. self employed)"
generate t = tm(2016m4) + _n -1
tsset t, monthly /*tells Stata that the data are monthlytime series*/
drop Taxyear Month
order t UKIT

merge 1:1 t using "scottish_tax"
drop _merge
gen rUKIT = (UKIT-SIT)
label variable rUKIT "Rest of the UK (rUK) Income Tax (NSND excl. self employed)"

save "$temp/tax.dta", replace








