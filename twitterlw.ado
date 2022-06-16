program define twitterlw

/*This program uses the python file premiumapi to interface with twitter's API*/

syntax anything(name=scope), KEY(string) SECRET(string) DEVenvironment(string) QUERY(string) FILENAME(string) [PAID TIME MAXresults(integer 5) STARTdate(string) ENDdate(string) SAVE]

clear

**Make sure dates are in the right format and give dates if not specified**
if "`startdate'" == "" {
	if "`time'" == "" {
		local startdate = td(`c(current_date)') - 30
		local startdate = string(`startdate', "%tdDD_Month_CCYY")
	}
	else {
		local subtract = tc(31 jan 1960 00:00)
		local fulldate = "`c(current_date)'" + " " + "`c(current_time)'"
		local startdate = tc(`fulldate')
		local startdate = `fulldate' - `subtract'
		local startdate = string(`startdate', "%tcDD_Month_CCYY_HH:MM")
	}
}
if "`enddate'" == "" {
	if "`time'" == "" {
		local enddate = td(`c(current_date)')
		local enddate = string(`enddate', "%tdDD_Month_CCYY")
	}
	else {
		local fulldate = "`c(current_date)'" + " " + "`c(current_time)'"
		local enddate = tc(`fulldate') - 11*60*60*1000
		local enddate = string(`enddate', "%tcDD_Month_CCYY_HH:MM")
	}
}

**Check if dates have been given with times and in the correct format**
if "`time'" != "" {
	capture local test1 = tc(`startdate')
	if _rc != 0 {
		display as error "Dates and times must be given in 'Day Month Year hours minutes' format, e.g. 1 Jan 2020 09:34. Please specify your dates and times accordingly."
		exit _rc
	}
	capture local test2 = tc(`enddate')
	if _rc != 0 {
		display as error "Dates and times must be given in 'Day Month Year hours minutes' format, e.g. 1 Jan 2020 09:34. Please specify your dates and times accordingly."
		exit _rc
	}
	**Convert dates with times to format appropriate for premiumapi.py**
	local start = tc(`startdate')
	local end = tc(`enddate')
	local startdate = string(`start', "%tcCCYY-NN-DD_HH:MM")
	local enddate = string(`end', "%tcCCYY-NN-DD_HH:MM")
}
*Check if dates have been given in the correct format**
else {
	capture local test1 = td(`startdate')
	if _rc != 0 {
		display as error "Dates must be given in 'Day Month Year' format, e.g. 1 Jan 2020. Please specify your dates accordingly. If you are including time, don't forget to indicate you are giving time with the TIME option."
		exit _rc
	}
	capture local test2 = td(`enddate')
	if _rc != 0 {
		display as error "Dates must be given in 'Day Month Year' format, e.g. 1 Jan 2020. Please specify your dates accordingly. If you are including time, don't forget to indicate you are giving time with the TIME option."
		exit _rc
	}
	*convert dates to the appropriate format for premiumapi.py**
	local start = td(`startdate')
	local end = td(`enddate')
	local startdate = string(`start', "%tdCCYY-NN-DD")
	local enddate = string(`end', "%tdCCYY-NN-DD")
}

*set results per call
if "`paid'" != "" {
	local results = 500
}
else {
	local results = 100
}

*make sure scope has been set successfully as either 'fullarchive' or 30day'**
if "`scope'" != "30day" & "`scope'" != "fullarchive" {
	display as error "SCOPE incorrectly specified. Please specify either '30day' or 'fullarchive'."
	exit 198
}

if "`startdate'" == "`enddate'" {
	display as error "Your end date is the same as your start date. The end date must be at least one day after the start date."
	exit 198
}

*Download twitter data into specified jsonl file**
python script "/Users/davidwhite/Documents/Stata/ado/personal/premiumapi.py", args(`scope' `key' `secret' "`devenvironment'" "`query'" "`filename'" `maxresults' "`startdate'" "`enddate'" `results') global userpaths(/Users/davidwhite/Documents/Stata/NZAE, prepend)

*This is what each of the Stata options are as python arguments positionally**
*scope=argv[1] key=argv[2] secret=argv[3] devenvironment=argv[4] query=argv[5] filename=argv[6] maxresults=argv[7] startdate=argv[8] enddate=argv[9] resultspercall=argv[10]

**Once data has been downloaded, load the jsonl file into Stata**
python script "/Users/davidwhite/Documents/Stata/ado/personal/twitter_test.py", args("`filename'") global userpaths(/Users/davidwhite/Documents/Stata/NZAE, prepend)

**---------DATA MANAGEMENT SECTION---------**
drop user
generate double created_at_rev = clock(created_at,"#MDhms#Y")
format created_at_rev %tcDay_Mon_DD_HH:MM:SS_CCYY
drop created_at
rename created_at_rev created_at
order created_at
quietly destring id, replace
encode truncated, generate(truncated2) label(truncatedlbl)
order truncated2, after(truncated)
drop truncated
rename truncated2 truncated
quietly replace in_reply_to_status_id = "0" if in_reply_to_status_id == "None"
quietly destring in_reply_to_status_id, replace
quietly replace in_reply_to_user_id = "0" if in_reply_to_user_id == "None"
quietly destring in_reply_to_user_id, replace
quietly count if geo == "None"
local geo = `r(N)'
quietly describe
if `geo' == `r(N)' {
	drop geo
}

quietly count if coordinates == "None"
local coord = `r(N)'
quietly describe
if `coord' == `r(N)' {
	drop coordinates
}

quietly count if contributors == "None"
local cont = `r(N)'
quietly describe
if `cont' == `r(N)' {
	drop contributors
}

encode is_quote_status, generate(quote) label(quotelbl)
order quote, after(is_quote_status)
drop is_quote_status
rename quote is_quote_status

quietly destring quote_count, replace
quietly destring reply_count, replace
quietly destring retweet_count, replace
quietly destring favorite_count, replace
rename favorite_count favourite_count

encode favorited, generate(favourited) label(favouritedlbl)
order favourited, after(favorited)
drop favorited

encode retweeted, generate(retweeted2) label(retweetedlbl)
order retweeted2, after(retweeted)
drop retweeted
rename retweeted2 retweeted

quietly replace possibly_sensitive = "N/A" if possibly_sensitive == "None"
encode possibly_sensitive, generate(sensitive) label(sensitivelbl)
order sensitive, after(possibly_sensitive)
drop possibly_sensitive
rename sensitive possibly_sensitive

encode filter_level, generate(filter) label(filterlbl)
order filter, after(filter_level)
drop filter_level
rename filter filter_level

quietly count if lang == "en"
local lang = `r(N)'
quietly describe
if `lang' == `r(N)' {
	drop lang
}
else {
	encode lang, generate(language) label(langlbl)
	order language, after(lang)
	drop lang
	rename language lang
}

capture quietly replace quoted_status_id = "0" if quoted_status_id == "None"
capture quietly destring quoted_status_id, replace

quietly destring user_id, replace

encode user_translator_type, generate(u_translate) label(user_translator_typelbl)
order u_translate, after(user_translator_type)
drop user_translator_type
rename u_translate user_translator_type

encode user_protected, generate(u_protect) label(user_protectedlbl)
order u_protect, after(user_protected)
drop user_protected
rename u_protect user_protected

encode user_verified, generate(u_verify) label(user_verifiedlbl)
order u_verify, after(user_verified)
drop user_verified
rename u_verify user_verified

quietly destring user_followers_count, replace
quietly destring user_friends_count, replace
quietly destring user_listed_count, replace
quietly destring user_favourites_count, replace
quietly destring user_statuses_count, replace

generate double created_at_rev = clock(user_created_at,"#MDhms#Y")
format created_at_rev %tcDay_Mon_DD_HH:MM:SS_CCYY
order created_at_rev, after(user_created_at)
drop user_created_at
rename created_at_rev user_created_at

encode user_geo_enabled, generate(u_geo) label(user_geo_enabledlbl)
order u_geo, after(user_geo_enabled)
drop user_geo_enabled
rename u_geo user_geo_enabled

quietly count if user_lang == "None"
local ulang = `r(N)'
quietly describe
if `ulang' == `r(N)' {
	drop user_lang
}

encode user_contributors_enabled, generate(u_cont) label(user_contributors_enabledlbl)
order u_cont, after(user_contributors_enabled)
drop user_contributors_enabled
rename u_cont user_contributors_enabled

encode user_is_translator, generate(u_translate) label(user_is_translatorlbl)
order u_translate, after(user_is_translator)
drop user_is_translator
rename u_translate user_is_translator

encode user_prof_back_tile, generate(u_back) label(user_prof_back_tilelbl)
order u_back, after(user_prof_back_tile)
drop user_prof_back_tile
rename u_back user_prof_back_tile

encode user_prof_use_back_imag, generate(u_img) label(user_prof_use_back_imaglbl)
order u_img, after(user_prof_use_back_imag)
drop user_prof_use_back_imag
rename u_img user_prof_use_back_imag

encode user_default_profile, generate(u_def) label(user_default_profilelbl)
order u_def, after(user_default_profile)
drop user_default_profile
rename u_def user_default_profile

encode user_defa_prof_imag, generate(u_prof) label(user_defa_prof_imaglbl)
order u_prof, after(user_defa_prof_imag)
drop user_defa_prof_imag
rename u_prof user_defa_prof_imag

quietly count if user_following == "None"
local fol = `r(N)'
quietly describe
if `fol' == `r(N)' {
	drop user_following
}

quietly count if user_follow_request_sent == "None"
local fol = `r(N)'
quietly describe
if `fol' == `r(N)' {
	drop user_follow_request_sent
}

quietly count if user_notifications == "None"
local user = `r(N)'
quietly describe
if `user' == `r(N)' {
	drop user_notifications
}
**------------END---------------**
if "`save'" != "" {
local pos = strpos("`filename'",".jsonl") - 1
local savefile = substr("`filename'",1,`pos')
local savefile = "`savefile'" + ".dta"
capture quietly save "`savefile'", replace
}
end
