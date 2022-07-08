
//Stationarity 
	// How to choose appropriate lags for ADF test

use "$temp/tax.dta", clear


tsline SIT //Looks non-stationary
ac SIT //1st lag significant, 3rd lag significant. 12 lags significant
//some decay
pac SIT // 1st lag significant, 3rd lag significant, 9th lag, 11th lag, 12th lag,
//looks like there is no slow decay


dfsummary SIT, lag(20) trend reg //definitely non-stationary... need ARIMA
dfuller SIT, lag(19) trend reg // fail to reject unit root
dfuller SIT, lag(4) trend reg // reject unit root
// trend and constant are significant

// Dont need ARIMA just ARMA
pperron SIT,trend reg //reject unit root, newey-west lags==3
pperron SIT,trend lag(20) reg //reject unit root
// trend and constant significant

pperron SIT,trend reg //reject unit root, newey-west lags==3
pperron SIT,trend lag(20) reg //reject unit root


tsline d.SIT
dfuller d.SIT, reg
pperron d.SIT, reg //stationary


ac d.SIT //1,3,12 significant
pac d.SIT // 1,3,8, 10, 11, 12, 13, 14, 15,... significant

// Candidate models? 
/*
ARIMA(1,1,1)
ARIMA(2,1,1)
ARIMA(3,1,1) 

ARIMA(1,1,2) 
ARIMA(1,1,3) 

ARIMA(2,1,2)
ARIMA(2,1,3)

ARIMA(3,1,3) 

(1,1,1)
(0,1,1)
(0,1,1)
(1,0,1)
(0,0,1)
(1,0,0)

*/


//		
arima SIT if tin(2016m4, 2021m3), arima(1,1,1) sarima(1,1,1,12) 
predict error, resid
sum error //near ish zero
tsline error, yline(`r(mean)')
wntestq error // is white noise
estat aroots //AR not on unit circle most MA are... bad sign?
 predict fitted
 estimates store SAR111
//One step ahead fit 
 gen SIT_fitted = SIT + fitted[_n+1] if _n>1
 gen v1= SIT if _n==60
 replace v1= (v1[_n-1] + fitted) if _n>60
replace SIT_fitted=. if _n>60
label variable v1 "Forecast of SIT using an SARIMA(1,1,1)(1,1,1)12"
 tsline SIT SIT_fitted v1
 //Doesn't Look Great
 
 
 
 
 
 /* Adds the fitted FD value from the model from the starting observation
 gen model1SIT =.
 replace model1SIT=SIT if _n==13
 drop if _n<=12
 gen fit= model1SIT+ fitted[_n+1] if _n==1
 replace fit = fit[_n-1]+fitted if _n>1
 tsline SIT fit
*/ 




arima SIT, arima(1,1,1) sarima(1,0,1,12)

drop fitted
 predictnl  fitted
 tsline fitted SIT

 
 arima SIT, arima(1,1,1)
 predict fitted2
  tsline fitted2 SIT
 
 
 arima SIT, arima(3,1,3) sarima(0,0,1,12)
 predict fitted
  tsline fitted d.SIT
 
 
 
 
 
 
 
 
 