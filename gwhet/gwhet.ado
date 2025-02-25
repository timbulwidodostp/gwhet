*! Groupwise heteroschedasticity test
*! Version 1.1.0 09/10/98 by GI gimpavido@worldbank.org

program define gwhet
version 5.0

local varlist "required existing max(1)"
local options "Index(string)"
parse "`*'"

/* This creates an index variable 1....n */
if "`index'" == "" {
	di in re "You did not supply the index variable"
	exit 198
	}
unabbrev `index'
local index "$S_1"
tempvar idx
egen `idx'=group(`index'), missing
quietly summ `idx'
local max = _result(6)


/*H0*/
tempvar res2 rssn
capture {
	gen `res2' = `varlist'*`varlist'
	gen `rssn' = sum(`res2')
	}
quietly summ `rsn'
local s2n = _result(1)*ln(_result(6)/_result(1))


/*H1*/
local s2g "0"
local i "1"
while `i' <= `max' {
	tempvar rss`i' 
	capture {gen `rss`i'' = sum(`res2') if `idx' == `i'} 
	quietly sum `rss`i''
	local s2`i' = _result(1)*ln(_result(6)/_result(1))
	local s2g = `s2g' + `s2`i''
	local i = `i' + 1
	}

/* The LR statistics */
global S_E_LR = `s2n' - `s2g'

noi di in gr _n "LR test for groupwise heteroschedasticity"
noi di in gr "H0 : " in ye "`varlist'" in gr " is homoschedastic"
noi di in gr "H1 : " in ye "`varlist'" in gr " is heteroschedastic"
noi di in gr "LR = " in ye %5.3f $S_E_LR in gr /*
	*/ " Under H0 ~a Chi(" in ye `max' - 1 in gr ") = " /*
	*/ in ye %4.3f chiprob(`max'-1, $S_E_LR)

end
