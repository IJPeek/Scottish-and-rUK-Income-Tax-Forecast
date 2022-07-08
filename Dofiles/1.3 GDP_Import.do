// Import and Clean of ONS GDP data
// Unit root testing results, use the first difference or first difference of the log for all but GDP_Agri


********************************************************************************
****				Import Data, Clean and Reshape Data						****

clear
import excel "$raw/monthlygdpto4dp.xlsx", cellrange(A4:F308) sheet(Data_table) firstrow

gen newt= monthly(Month, "YM") 
format newt %tm
drop Month
rename newt t
tsset t, monthly /*tells Stata that the data are quarterly time series*/
label variable t "Date given by Month and Year"
order t

rename (MonthlyGDPAT AgricultureA ProductionBE ConstructionFnote1note2 ServicesGT) (GDP_UK GDP_Agri GDP_Prod GDP_Constr GDP_Serv)

//Keep TS from 2003 onwards
drop if t<516


********************************************************************************
****					Generate Stationary Variables						****

// Natural Log
foreach var of varlist GDP_UK GDP_Agri GDP_Prod GDP_Constr GDP_Serv {
	gen ln_`var' = ln(`var')
	label variable ln_`var' "Log of `var'"
}


// First Difference
foreach var of varlist GDP_UK GDP_Agri GDP_Prod GDP_Constr GDP_Serv {
	gen FD_`var' = D.`var'
	label variable FD_`var' "First Difference of `var'"
}


// Fist Dif of Log
foreach var of varlist GDP_UK GDP_Agri GDP_Prod GDP_Constr GDP_Serv {
	gen FD_ln_`var' = D.ln_`var'
	label variable FD_ln_`var' "First Difference of log of `var'"
}

** Unit Root Tests for each Variable


		** GDP: conclusion FD_ln_GDP_UK or FD_GDP_UK
{
dfsummary GDP_UK, lag(4) reg //Fail to reject 
dfsummary ln_GDP_UK, lag(4) reg //Fail to reject

dfsummary FD_ln_GDP_UK, lag(4) reg //Reject... better IC than FD
dfsummary FD_GDP_UK, lag(4) reg //Reject
}


		** GDP_Agri: conclusion GDP_Agri or any others
{
dfsummary GDP_Agri, lag(4) reg //Reject 
dfsummary ln_GDP_Agri, lag(4) reg //Reject

dfsummary FD_ln_GDP_Agri, lag(4) reg //Reject
dfsummary FD_GDP_Agri, lag(4) reg //Reject

}


		** GDP_Prod: conclusion FD_ln_GDP_Prod or FD_GDP_Prod
{
dfsummary GDP_Prod, lag(4) reg //Fail to reject with 4 lags (smallest AIC), reject at 2 lags 10% (BIC) 
dfsummary ln_GDP_Prod, lag(4) reg //Reject, 1 lag (smallest AIC and BIC), 5% signif level

dfsummary FD_ln_GDP_Prod, lag(4) reg //Reject at all lags
dfsummary FD_GDP_Prod, lag(4) reg //Reject at all lags
}


		** GDP_Constr FD_ln_GDP_Constr or FD_GDP_Constr
{
dfsummary GDP_Constr, lag(4) reg //Reject and fail to reject
dfsummary ln_GDP_Constr, lag(4) reg //Fail to reject (lowest AIC and BIC are more siginif)

dfsummary FD_ln_GDP_Constr, lag(4) reg //Reject all signif
dfsummary FD_GDP_Constr, lag(4) reg //Reject all signif
}


		** GDP_Serv FD_ln_GDP_Serv or FD_GDP_Serv
{
dfsummary GDP_Serv, lag(4) reg //Fail to reject 
dfsummary ln_GDP_Serv, lag(4) reg //Fail to reject

dfsummary FD_ln_GDP_Serv, lag(4) reg //Reject
dfsummary FD_GDP_Serv, lag(4) reg //Reject
}

save $temp/gdp.dta, replace
