// Import and Reshape of BoE Base Rate Data
// Conclusion of unit root test for Dataset: 
********************************************************************************
****				Import Data, Clean and Reshape Data						****



import delimited "$raw/Bank Rate history and data  Bank of England Database.csv", clear
drop if _n>33
split datechanged
destring datechanged3, replace
replace datechanged3= datechanged3 + 2000
tostring datechanged3, replace 

gen t=datechanged2 + datechanged3
collapse rate, by(t)

gen newt= monthly(t, "MY") 
format newt %tm
gsort -newt
rename t basechange
rename newt t

tempfile baserate
save baserate, replace


clear
set obs 234
gen t=_n +515
tsset t, monthly /*tells Stata that the data are quarterly time series*/
format t %tm
merge 1:1 t using baserate

gsort t
replace rate = rate[_n-1] if missing(rate) 
drop if _merge==2
drop _merge
drop basechange

tsset t
tsline rate

// Not too sure how to put in the base rate here

rename rate baserate
label variable baserate "Bank of England Base Rate"

save $temp/baserate.dta, replace
