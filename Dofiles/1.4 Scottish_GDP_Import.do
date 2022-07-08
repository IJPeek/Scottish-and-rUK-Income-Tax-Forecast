// Import and Reshape of Global IMF Commodity Data
// Unit root testing results, use the first difference or first difference of the log for all but GDP_Agri


********************************************************************************
****	
clear
import excel "$raw/mGDP+-+March+2022+-+Publication+Tables.xlsx", cellrange(A4:z294) sheet(Table_1) firstrow
drop if _n==1
drop if _n==1
keep if DataCategory=="Chainlinked Volume Measure (Index, 2018 = 100)"
drop DataCategory
gen t = Month + Year

gen newt= monthly(t, "MY") 

format newt %tm

// Convert String to Date
drop t
rename newt t
drop Year Month
order t
tsset t, monthly


rename TotalGrossDomesticProduct GDP_Scot
rename Agricultureforestryandfishin GDP_Scot_Agri
rename Construction GDP_Scot_Constr 
rename TotalServicesSector GDP_Scot_Serv
rename TotalProductionSector GDP_Scot_Prod

rename (MiningandQuarryingIndustries Manufacturing ElectricityGasSupply WaterSupplyWasteManagement WholesaleRetailMotorTrades TransportStorage Accommodationfoodservices InformationCommunication FinancialInsuranceActivities RealEstateActivities ProfessionalScientificTechn AdministrativeSupportService PublicAdministrationandDefen Education HealthandSocialWork ArtsCultureRecreation OtherServices HouseholdsasEmployersofDomes) (GDP_Scot_Mining GDP_Scot_Manu GDP_Scot_Electr GDP_Scot_Water GDP_Scot_Motor_WS GDP_Scot_Transp GDP_Scot_Accom GDP_Scot_IC GDP_Scot_Fin GDP_Scot_RealEst GDP_Scot_Scient GDP_Scot_Admin GDP_Scot_Public GDP_Scot_Educ GDP_Scot_Health GDP_Scot_Arts GDP_Scot_Other GDP_Scot_HH)


********************************************************************************
****					Generate Stationary Variables						****

// Natural Log
foreach var of varlist GDP_Scot GDP_Scot_Agri GDP_Scot_Prod GDP_Scot_Mining GDP_Scot_Manu GDP_Scot_Electr GDP_Scot_Water GDP_Scot_Constr GDP_Scot_Serv GDP_Scot_Motor_WS GDP_Scot_Transp GDP_Scot_Accom GDP_Scot_IC GDP_Scot_Fin GDP_Scot_RealEst GDP_Scot_Scient GDP_Scot_Admin GDP_Scot_Public GDP_Scot_Educ GDP_Scot_Health GDP_Scot_Arts GDP_Scot_Other GDP_Scot_HH {
	destring `var', replace
	gen ln_`var' = ln(`var')
	label variable ln_`var' "Log of `var'"
}

// First Difference
foreach var of varlist GDP_Scot GDP_Scot_Agri GDP_Scot_Prod GDP_Scot_Mining GDP_Scot_Manu GDP_Scot_Electr GDP_Scot_Water GDP_Scot_Constr GDP_Scot_Serv GDP_Scot_Motor_WS GDP_Scot_Transp GDP_Scot_Accom GDP_Scot_IC GDP_Scot_Fin GDP_Scot_RealEst GDP_Scot_Scient GDP_Scot_Admin GDP_Scot_Public GDP_Scot_Educ GDP_Scot_Health GDP_Scot_Arts GDP_Scot_Other GDP_Scot_HH {
	gen FD_`var' = D.`var'
	label variable FD_`var' "First Difference of `var'"
}


// Fist Dif of Log
foreach var of varlist GDP_Scot GDP_Scot_Agri GDP_Scot_Prod GDP_Scot_Mining GDP_Scot_Manu GDP_Scot_Electr GDP_Scot_Water GDP_Scot_Constr GDP_Scot_Serv GDP_Scot_Motor_WS GDP_Scot_Transp GDP_Scot_Accom GDP_Scot_IC GDP_Scot_Fin GDP_Scot_RealEst GDP_Scot_Scient GDP_Scot_Admin GDP_Scot_Public GDP_Scot_Educ GDP_Scot_Health GDP_Scot_Arts GDP_Scot_Other GDP_Scot_HH {
	gen FD_ln_`var' = D.ln_`var'
	label variable FD_ln_`var' "First Difference of log of `var'"
}


******** Unit Root Tests

// Fist Dif of Log
foreach var of varlist GDP_Scot GDP_Scot_Agri GDP_Scot_Prod GDP_Scot_Mining GDP_Scot_Manu GDP_Scot_Electr GDP_Scot_Water GDP_Scot_Constr GDP_Scot_Serv GDP_Scot_Motor_WS GDP_Scot_Transp GDP_Scot_Accom GDP_Scot_IC GDP_Scot_Fin GDP_Scot_RealEst GDP_Scot_Scient GDP_Scot_Admin GDP_Scot_Public GDP_Scot_Educ GDP_Scot_Health GDP_Scot_Arts GDP_Scot_Other GDP_Scot_HH {
	dfsummary FD_ln_`var', lag(4) reg
}
*** all stationary ^^

// ln
foreach var of varlist GDP_Scot GDP_Scot_Agri GDP_Scot_Prod GDP_Scot_Mining GDP_Scot_Manu GDP_Scot_Electr GDP_Scot_Water GDP_Scot_Constr GDP_Scot_Serv GDP_Scot_Motor_WS GDP_Scot_Transp GDP_Scot_Accom GDP_Scot_IC GDP_Scot_Fin GDP_Scot_RealEst GDP_Scot_Scient GDP_Scot_Admin GDP_Scot_Public GDP_Scot_Educ GDP_Scot_Health GDP_Scot_Arts GDP_Scot_Other GDP_Scot_HH {
	dfsummary ln_`var', lag(4) reg
}
** Stationary: ln_GDP_Scot_Prod , ln_GDP_Scot_Manu,  ln_GDP_Scot_Constr,  ln_GDP_Scot_Serv,  ln_GDP_Scot_Motor_WS, ln_GDP_Scot_RealEst,  ln_GDP_Scot_Educ

		** Check

foreach var of varlist ln_GDP_Scot_Prod ln_GDP_Scot_Manu  ln_GDP_Scot_Constr  ln_GDP_Scot_Serv  ln_GDP_Scot_Motor_WS ln_GDP_Scot_RealEst ln_GDP_Scot_Educ  
{
	dfsummary `var', lag(4) reg
}
 
 //Levels
foreach var of varlist GDP_Scot GDP_Scot_Agri GDP_Scot_Prod GDP_Scot_Mining GDP_Scot_Manu GDP_Scot_Electr GDP_Scot_Water GDP_Scot_Constr GDP_Scot_Serv GDP_Scot_Motor_WS GDP_Scot_Transp GDP_Scot_Accom GDP_Scot_IC GDP_Scot_Fin GDP_Scot_RealEst GDP_Scot_Scient GDP_Scot_Admin GDP_Scot_Public GDP_Scot_Educ GDP_Scot_Health GDP_Scot_Arts GDP_Scot_Other GDP_Scot_HH {
	dfsummary `var', lag(4) reg
}


foreach var of varlist  GDP_Scot_Prod GDP_Scot_Manu GDP_Scot_Constr GDP_Scot_Serv GDP_Scot_Motor_WS GDP_Scot_RealEst GDP_Scot_Educ GDP_Scot_Other {
	dfsummary `var', lag(4) reg
}

** Stationary: GDP_Scot_Manu,  GDP_Scot_RealEst,  GDP_Scot_Educ


save $temp/gdp_scot.dta, replace












