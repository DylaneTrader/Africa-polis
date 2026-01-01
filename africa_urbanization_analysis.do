/*==============================================================================
    AFRICA URBANIZATION ANALYSIS - STATA 16 DO-FILE
    
    Description: 
    This script analyzes African urbanization patterns using the Africa-polis
    dataset. It produces tabulations and graphs for:
    1. Urban vs. rural population shares (continent, region, country)
    2. Population size class distributions in urban areas
    3. Dynamics analysis (growth rates and absolute changes)
    
    Data: Stata_workbook.xlsx
    Years analyzed: 2000, 2025, 2050
    
    Author: Generated for Africa-polis project
    Date: 2026-01-01
==============================================================================*/

clear all
set more off
cap log close

* Set working directory (modify as needed)
* cd "path/to/your/working/directory"

* Create log file
log using "africa_urbanization_analysis.log", replace

* Set graph scheme
set scheme s2color

/*------------------------------------------------------------------------------
    SECTION 1: DATA IMPORT AND PREPARATION
------------------------------------------------------------------------------*/

* Import data from Excel
* Note: Stata will automatically rename variables with spaces/special characters
import excel using "Stata_workbook.xlsx", firstrow clear

* Display basic information
describe
summarize

* Rename key variables for easier handling
* After import, variable names may be truncated or modified by Stata
rename pays country
rename AU_Regions region
rename Agglomeration_ID agglo_id

* Rename population class variables (Stata converts spaces to underscores, removes special chars)
* Original: CPopulation_2000_10 to 500 -> CPopulation_2000_10to500 (or similar)
* We need to identify the actual variable names after import
* Use capture to handle potential name variations

* Display variable names to identify CPopulation columns
ds CPopulation*

* Rename the population class variables to simpler names
* Stata may rename "10 to 500" to "10to500" or similar
* Check actual names and rename accordingly

cap rename CPopulation_2000_10to500 cp2000_10_500
cap rename CPopulation_2000_500to1M cp2000_500_1M
cap rename CPopulation_2000_1Mto3M cp2000_1M_3M
cap rename CPopulation_2000_3Mto5M cp2000_3M_5M
cap rename CPopulation_2000_5Mto10M cp2000_5M_10M
cap rename CPopulation_2000_10M cp2000_10M

cap rename CPopulation_2025_10to500 cp2025_10_500
cap rename CPopulation_2025_500to1M cp2025_500_1M
cap rename CPopulation_2025_1Mto3M cp2025_1M_3M
cap rename CPopulation_2025_3Mto5M cp2025_3M_5M
cap rename CPopulation_2025_5Mto10M cp2025_5M_10M
cap rename CPopulation_2025_10M cp2025_10M

cap rename CPopulation_2050_10to500 cp2050_10_500
cap rename CPopulation_2050_500to1M cp2050_500_1M
cap rename CPopulation_2050_1Mto3M cp2050_1M_3M
cap rename CPopulation_2050_3Mto5M cp2050_3M_5M
cap rename CPopulation_2050_5Mto10M cp2050_5M_10M
cap rename CPopulation_2050_10M cp2050_10M

* Alternative rename patterns (Stata may use different patterns)
* Handle case where spaces become underscores
cap rename CPopulation_2000_10_to_500 cp2000_10_500
cap rename CPopulation_2000_500_to_1M cp2000_500_1M
cap rename CPopulation_2000_1M_to_3M cp2000_1M_3M
cap rename CPopulation_2000_3M_to_5M cp2000_3M_5M
cap rename CPopulation_2000_5M_to_10M cp2000_5M_10M
cap rename CPopulation_2000__10M cp2000_10M

cap rename CPopulation_2025_10_to_500 cp2025_10_500
cap rename CPopulation_2025_500_to_1M cp2025_500_1M
cap rename CPopulation_2025_1M_to_3M cp2025_1M_3M
cap rename CPopulation_2025_3M_to_5M cp2025_3M_5M
cap rename CPopulation_2025_5M_to_10M cp2025_5M_10M
cap rename CPopulation_2025__10M cp2025_10M

cap rename CPopulation_2050_10_to_500 cp2050_10_500
cap rename CPopulation_2050_500_to_1M cp2050_500_1M
cap rename CPopulation_2050_1M_to_3M cp2050_1M_3M
cap rename CPopulation_2050_3M_to_5M cp2050_3M_5M
cap rename CPopulation_2050_5M_to_10M cp2050_5M_10M
cap rename CPopulation_2050__10M cp2050_10M

* Create numeric region variable for graphing
encode region, gen(region_num)
label var region_num "Region (numeric)"

* Create numeric country variable
encode country, gen(country_num)
label var country_num "Country (numeric)"

* Create population class categories as numeric variables
* Use the renamed variables or fall back to pattern matching
gen pop_class_2000 = .
cap replace pop_class_2000 = 1 if cp2000_10_500 == 1
cap replace pop_class_2000 = 2 if cp2000_500_1M == 1
cap replace pop_class_2000 = 3 if cp2000_1M_3M == 1
cap replace pop_class_2000 = 4 if cp2000_3M_5M == 1
cap replace pop_class_2000 = 5 if cp2000_5M_10M == 1
cap replace pop_class_2000 = 6 if cp2000_10M == 1
label var pop_class_2000 "Population size class 2000"

gen pop_class_2025 = .
cap replace pop_class_2025 = 1 if cp2025_10_500 == 1
cap replace pop_class_2025 = 2 if cp2025_500_1M == 1
cap replace pop_class_2025 = 3 if cp2025_1M_3M == 1
cap replace pop_class_2025 = 4 if cp2025_3M_5M == 1
cap replace pop_class_2025 = 5 if cp2025_5M_10M == 1
cap replace pop_class_2025 = 6 if cp2025_10M == 1
label var pop_class_2025 "Population size class 2025"

gen pop_class_2050 = .
cap replace pop_class_2050 = 1 if cp2050_10_500 == 1
cap replace pop_class_2050 = 2 if cp2050_500_1M == 1
cap replace pop_class_2050 = 3 if cp2050_1M_3M == 1
cap replace pop_class_2050 = 4 if cp2050_3M_5M == 1
cap replace pop_class_2050 = 5 if cp2050_5M_10M == 1
cap replace pop_class_2050 = 6 if cp2050_10M == 1
label var pop_class_2050 "Population size class 2050"

* Define value labels for population classes
label define pop_class_lbl 1 "10K-500K" 2 "500K-1M" 3 "1M-3M" 4 "3M-5M" 5 "5M-10M" 6 "10M+"
label values pop_class_2000 pop_class_2025 pop_class_2050 pop_class_lbl

* Save prepared dataset
save "africa_polis_prepared.dta", replace

/*------------------------------------------------------------------------------
    SECTION 2: URBAN VS RURAL POPULATION ANALYSIS
------------------------------------------------------------------------------*/

di _n(3) "=" * 80
di "SECTION 2: URBAN VS RURAL POPULATION ANALYSIS"
di "=" * 80

*-------------------------------------------------------------------------------
* 2.1 Continental Level Analysis
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "2.1 CONTINENTAL LEVEL - URBAN VS RURAL SHARES"
di "-" * 60

* Collapse to get continental totals
preserve
    collapse (sum) Upop2000 Upop2025 Upop2050 TPOP2000 TPOP2025 TPOP2050, fast
    
    * Calculate urban shares
    gen urban_share_2000 = (Upop2000 / TPOP2000) * 100
    gen urban_share_2025 = (Upop2025 / TPOP2025) * 100
    gen urban_share_2050 = (Upop2050 / TPOP2050) * 100
    
    * Calculate rural shares
    gen rural_share_2000 = 100 - urban_share_2000
    gen rural_share_2025 = 100 - urban_share_2025
    gen rural_share_2050 = 100 - urban_share_2050
    
    * Display results
    di _n "AFRICA TOTAL - Urban Population Shares:"
    list urban_share_2000 urban_share_2025 urban_share_2050, noobs
    
    di _n "AFRICA TOTAL - Rural Population Shares:"
    list rural_share_2000 rural_share_2025 rural_share_2050, noobs
    
    * Create data for graph
    gen geo = "Africa"
    reshape long urban_share_ rural_share_, i(geo) j(year)
    rename urban_share_ urban_share
    rename rural_share_ rural_share
    
    * Graph: Continental Urban/Rural shares over time
    graph bar urban_share rural_share, over(year) ///
        title("Africa: Urban vs Rural Population Share") ///
        subtitle("2000, 2025, 2050") ///
        ytitle("Percentage (%)") ///
        legend(label(1 "Urban") label(2 "Rural")) ///
        bar(1, color(navy)) bar(2, color(forest_green)) ///
        name(continent_urban_rural, replace)
    graph export "continent_urban_rural.png", replace width(1200) height(800)
restore

*-------------------------------------------------------------------------------
* 2.2 Regional Level Analysis
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "2.2 REGIONAL LEVEL - URBAN VS RURAL SHARES"
di "-" * 60

preserve
    collapse (sum) Upop2000 Upop2025 Upop2050 TPOP2000 TPOP2025 TPOP2050, by(region)
    
    * Calculate urban shares
    gen urban_share_2000 = (Upop2000 / TPOP2000) * 100
    gen urban_share_2025 = (Upop2025 / TPOP2025) * 100
    gen urban_share_2050 = (Upop2050 / TPOP2050) * 100
    
    * Calculate rural shares
    gen rural_share_2000 = 100 - urban_share_2000
    gen rural_share_2025 = 100 - urban_share_2025
    gen rural_share_2050 = 100 - urban_share_2050
    
    * Display results
    di _n "BY REGION - Urban Population Shares:"
    list region urban_share_2000 urban_share_2025 urban_share_2050, sep(0)
    
    di _n "BY REGION - Rural Population Shares:"
    list region rural_share_2000 rural_share_2025 rural_share_2050, sep(0)
    
    * Graph: Urban shares by region for each year
    graph bar urban_share_2000 urban_share_2025 urban_share_2050, over(region, label(angle(45))) ///
        title("Urban Population Share by Region") ///
        subtitle("Comparison: 2000, 2025, 2050") ///
        ytitle("Urban Share (%)") ///
        legend(label(1 "2000") label(2 "2025") label(3 "2050")) ///
        bar(1, color(navy*0.5)) bar(2, color(navy*0.75)) bar(3, color(navy)) ///
        name(region_urban_share, replace)
    graph export "region_urban_share.png", replace width(1200) height(800)
    
    * Save regional data for dynamics analysis
    save "regional_urban_rural.dta", replace
restore

*-------------------------------------------------------------------------------
* 2.3 Country Level Analysis
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "2.3 COUNTRY LEVEL - URBAN VS RURAL SHARES"
di "-" * 60

preserve
    collapse (sum) Upop2000 Upop2025 Upop2050 TPOP2000 TPOP2025 TPOP2050, by(country region)
    
    * Calculate urban shares
    gen urban_share_2000 = (Upop2000 / TPOP2000) * 100
    gen urban_share_2025 = (Upop2025 / TPOP2025) * 100
    gen urban_share_2050 = (Upop2050 / TPOP2050) * 100
    
    * Calculate rural shares
    gen rural_share_2000 = 100 - urban_share_2000
    gen rural_share_2025 = 100 - urban_share_2025
    gen rural_share_2050 = 100 - urban_share_2050
    
    * Display results by country sorted by region
    sort region country
    di _n "BY COUNTRY - Urban Population Shares (sorted by region):"
    list region country urban_share_2000 urban_share_2025 urban_share_2050, sep(0)
    
    * Export country-level data
    export excel using "country_urban_rural.xlsx", firstrow(variables) replace
    
    * Graph: Top 10 most urbanized countries in 2050
    gsort -urban_share_2050
    gen rank = _n
    
    graph bar urban_share_2050 if rank <= 10, over(country, sort(1) descending label(angle(45))) ///
        title("Top 10 Most Urbanized Countries in 2050") ///
        ytitle("Urban Share (%)") ///
        bar(1, color(navy)) ///
        name(top10_urban_2050, replace)
    graph export "top10_urban_2050.png", replace width(1200) height(800)
    
    * Graph: Top 10 least urbanized countries in 2050
    gsort urban_share_2050
    replace rank = _n
    
    graph bar urban_share_2050 if rank <= 10, over(country, sort(1) label(angle(45))) ///
        title("Top 10 Least Urbanized Countries in 2050") ///
        ytitle("Urban Share (%)") ///
        bar(1, color(maroon)) ///
        name(bottom10_urban_2050, replace)
    graph export "bottom10_urban_2050.png", replace width(1200) height(800)
    
    * Save country-level data
    save "country_urban_rural.dta", replace
restore

/*------------------------------------------------------------------------------
    SECTION 3: POPULATION SIZE CLASS DISTRIBUTION
------------------------------------------------------------------------------*/

di _n(3) "=" * 80
di "SECTION 3: POPULATION SIZE CLASS DISTRIBUTION IN URBAN AREAS"
di "=" * 80

*-------------------------------------------------------------------------------
* 3.1 Continental Level - Population Class Distribution
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "3.1 CONTINENTAL LEVEL - POPULATION SIZE CLASSES"
di "-" * 60

* Tabulate population classes for each year
di _n "Population Class Distribution - 2000:"
tab pop_class_2000

di _n "Population Class Distribution - 2025:"
tab pop_class_2025

di _n "Population Class Distribution - 2050:"
tab pop_class_2050

* Calculate urban population by size class
preserve
    * Create totals for each class and year
    * Using renamed variables cp20XX_... 
    collapse (sum) ///
        cp2000_10_500 cp2000_500_1M cp2000_1M_3M ///
        cp2000_3M_5M cp2000_5M_10M cp2000_10M ///
        cp2025_10_500 cp2025_500_1M cp2025_1M_3M ///
        cp2025_3M_5M cp2025_5M_10M cp2025_10M ///
        cp2050_10_500 cp2050_500_1M cp2050_1M_3M ///
        cp2050_3M_5M cp2050_5M_10M cp2050_10M ///
        Upop2000 Upop2025 Upop2050

    * Count agglomerations by class
    di _n "Number of Agglomerations by Size Class - Continental:"
    di "Year 2000:"
    list cp2000_10_500 cp2000_500_1M cp2000_1M_3M ///
         cp2000_3M_5M cp2000_5M_10M cp2000_10M, noobs
    di "Year 2025:"
    list cp2025_10_500 cp2025_500_1M cp2025_1M_3M ///
         cp2025_3M_5M cp2025_5M_10M cp2025_10M, noobs
    di "Year 2050:"
    list cp2050_10_500 cp2050_500_1M cp2050_1M_3M ///
         cp2050_3M_5M cp2050_5M_10M cp2050_10M, noobs
restore

* Graph: Number of agglomerations by size class over time
preserve
    gen n_2000_1 = (pop_class_2000 == 1)
    gen n_2000_2 = (pop_class_2000 == 2)
    gen n_2000_3 = (pop_class_2000 == 3)
    gen n_2000_4 = (pop_class_2000 == 4)
    gen n_2000_5 = (pop_class_2000 == 5)
    gen n_2000_6 = (pop_class_2000 == 6)
    
    gen n_2025_1 = (pop_class_2025 == 1)
    gen n_2025_2 = (pop_class_2025 == 2)
    gen n_2025_3 = (pop_class_2025 == 3)
    gen n_2025_4 = (pop_class_2025 == 4)
    gen n_2025_5 = (pop_class_2025 == 5)
    gen n_2025_6 = (pop_class_2025 == 6)
    
    gen n_2050_1 = (pop_class_2050 == 1)
    gen n_2050_2 = (pop_class_2050 == 2)
    gen n_2050_3 = (pop_class_2050 == 3)
    gen n_2050_4 = (pop_class_2050 == 4)
    gen n_2050_5 = (pop_class_2050 == 5)
    gen n_2050_6 = (pop_class_2050 == 6)
    
    collapse (sum) n_2000_* n_2025_* n_2050_*
    
    gen id = 1
    reshape long n_2000_ n_2025_ n_2050_, i(id) j(class)
    rename n_2000_ count_2000
    rename n_2025_ count_2025
    rename n_2050_ count_2050
    
    label define class_lbl 1 "10K-500K" 2 "500K-1M" 3 "1M-3M" 4 "3M-5M" 5 "5M-10M" 6 "10M+"
    label values class class_lbl
    
    graph bar count_2000 count_2025 count_2050, over(class) ///
        title("Number of Urban Agglomerations by Size Class") ///
        subtitle("Africa: 2000, 2025, 2050") ///
        ytitle("Number of Agglomerations") ///
        legend(label(1 "2000") label(2 "2025") label(3 "2050")) ///
        bar(1, color(navy*0.5)) bar(2, color(navy*0.75)) bar(3, color(navy)) ///
        name(continent_size_class, replace)
    graph export "continent_size_class.png", replace width(1200) height(800)
    
    save "continent_size_class_data.dta", replace
restore

*-------------------------------------------------------------------------------
* 3.2 Regional Level - Population Class Distribution
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "3.2 REGIONAL LEVEL - POPULATION SIZE CLASSES"
di "-" * 60

* Tabulate by region for each year
di _n "Population Class by Region - 2000:"
tab region pop_class_2000, row

di _n "Population Class by Region - 2025:"
tab region pop_class_2025, row

di _n "Population Class by Region - 2050:"
tab region pop_class_2050, row

* Graph: Size class distribution by region in 2050
preserve
    gen n_class_1 = (pop_class_2050 == 1)
    gen n_class_2 = (pop_class_2050 == 2)
    gen n_class_3 = (pop_class_2050 == 3)
    gen n_class_4 = (pop_class_2050 == 4)
    gen n_class_5 = (pop_class_2050 == 5)
    gen n_class_6 = (pop_class_2050 == 6)
    
    collapse (sum) n_class_*, by(region)
    
    graph bar n_class_1 n_class_2 n_class_3 n_class_4 n_class_5 n_class_6, ///
        over(region, label(angle(45))) stack ///
        title("Urban Agglomeration Size Distribution by Region - 2050") ///
        ytitle("Number of Agglomerations") ///
        legend(label(1 "10K-500K") label(2 "500K-1M") label(3 "1M-3M") ///
               label(4 "3M-5M") label(5 "5M-10M") label(6 "10M+") rows(2)) ///
        bar(1, color(navy*0.3)) bar(2, color(navy*0.5)) bar(3, color(navy*0.7)) ///
        bar(4, color(dkorange*0.7)) bar(5, color(dkorange)) bar(6, color(cranberry)) ///
        name(region_size_class_2050, replace)
    graph export "region_size_class_2050.png", replace width(1200) height(800)
    
    save "region_size_class_data.dta", replace
restore

*-------------------------------------------------------------------------------
* 3.3 Country Level - Population Class Distribution
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "3.3 COUNTRY LEVEL - POPULATION SIZE CLASSES"
di "-" * 60

preserve
    gen n_class_1 = (pop_class_2050 == 1)
    gen n_class_2 = (pop_class_2050 == 2)
    gen n_class_3 = (pop_class_2050 == 3)
    gen n_class_4 = (pop_class_2050 == 4)
    gen n_class_5 = (pop_class_2050 == 5)
    gen n_class_6 = (pop_class_2050 == 6)
    
    collapse (sum) n_class_* Upop2050, by(country region)
    gen total_agglos = n_class_1 + n_class_2 + n_class_3 + n_class_4 + n_class_5 + n_class_6
    
    * Top 10 countries by number of agglomerations
    gsort -total_agglos
    gen rank = _n
    
    di _n "Top 15 Countries by Number of Urban Agglomerations (2050):"
    list country region total_agglos n_class_1 n_class_2 n_class_3 n_class_4 n_class_5 n_class_6 if rank <= 15, sep(0)
    
    * Countries with mega-cities (10M+)
    di _n "Countries with Mega-cities (10M+) in 2050:"
    list country n_class_6 if n_class_6 > 0, noobs
    
    export excel using "country_size_class.xlsx", firstrow(variables) replace
    save "country_size_class_data.dta", replace
restore

/*------------------------------------------------------------------------------
    SECTION 4: DYNAMICS ANALYSIS - GROWTH PATTERNS
------------------------------------------------------------------------------*/

di _n(3) "=" * 80
di "SECTION 4: DYNAMICS ANALYSIS - GROWTH AND CHANGES"
di "=" * 80

*-------------------------------------------------------------------------------
* 4.1 Urban Share Growth Analysis
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "4.1 URBAN SHARE GROWTH - ABSOLUTE AND PERCENTAGE CHANGES"
di "-" * 60

* Regional dynamics
use "regional_urban_rural.dta", clear

* Calculate absolute changes
gen urban_change_2000_2025 = urban_share_2025 - urban_share_2000
gen urban_change_2025_2050 = urban_share_2050 - urban_share_2025
gen urban_change_2000_2050 = urban_share_2050 - urban_share_2000

* Calculate percentage growth rates
gen urban_growth_pct_2000_2025 = ((urban_share_2025 - urban_share_2000) / urban_share_2000) * 100
gen urban_growth_pct_2025_2050 = ((urban_share_2050 - urban_share_2025) / urban_share_2025) * 100
gen urban_growth_pct_2000_2050 = ((urban_share_2050 - urban_share_2000) / urban_share_2000) * 100

di _n "REGIONAL URBAN SHARE DYNAMICS:"
di "Absolute Change in Urban Share (percentage points):"
list region urban_change_2000_2025 urban_change_2025_2050 urban_change_2000_2050, sep(0)

di _n "Percentage Growth in Urban Share:"
list region urban_growth_pct_2000_2025 urban_growth_pct_2025_2050 urban_growth_pct_2000_2050, sep(0)

* Identify regions with acceleration/deceleration
gen acceleration = urban_change_2025_2050 - urban_change_2000_2025
di _n "Change in Rate of Urbanization (positive = accelerating):"
list region urban_change_2000_2025 urban_change_2025_2050 acceleration, sep(0)

* Graph: Regional dynamics
graph bar urban_change_2000_2025 urban_change_2025_2050, over(region, label(angle(45))) ///
    title("Rate of Urbanization by Region") ///
    subtitle("Change in Urban Share (percentage points)") ///
    ytitle("Change in Urban Share (pp)") ///
    legend(label(1 "2000-2025") label(2 "2025-2050")) ///
    bar(1, color(navy)) bar(2, color(dkorange)) ///
    name(region_urban_dynamics, replace)
graph export "region_urban_dynamics.png", replace width(1200) height(800)

save "regional_dynamics.dta", replace

* Country-level dynamics
use "country_urban_rural.dta", clear

* Calculate changes
gen urban_change_2000_2025 = urban_share_2025 - urban_share_2000
gen urban_change_2025_2050 = urban_share_2050 - urban_share_2025
gen urban_change_2000_2050 = urban_share_2050 - urban_share_2000

* Calculate percentage growth
gen urban_growth_pct_2000_2050 = ((urban_share_2050 - urban_share_2000) / urban_share_2000) * 100

* Top 10 countries by absolute urbanization increase
gsort -urban_change_2000_2050
gen rank_abs = _n

di _n "TOP 10 COUNTRIES - Largest Absolute Increase in Urban Share (2000-2050):"
list country region urban_share_2000 urban_share_2050 urban_change_2000_2050 if rank_abs <= 10, sep(0)

* Top 10 countries by percentage urbanization growth
gsort -urban_growth_pct_2000_2050
gen rank_pct = _n

di _n "TOP 10 COUNTRIES - Highest Percentage Growth in Urban Share (2000-2050):"
list country region urban_share_2000 urban_share_2050 urban_growth_pct_2000_2050 if rank_pct <= 10, sep(0)

* Identify acceleration/deceleration patterns
gen acceleration = urban_change_2025_2050 - urban_change_2000_2025
gen accel_type = "Accelerating" if acceleration > 0.5
replace accel_type = "Decelerating" if acceleration < -0.5
replace accel_type = "Stable" if accel_type == ""

tab region accel_type

di _n "COUNTRIES WITH ACCELERATING URBANIZATION (sorted by acceleration):"
gsort -acceleration
list country region urban_change_2000_2025 urban_change_2025_2050 acceleration if acceleration > 1, sep(0)

di _n "COUNTRIES WITH DECELERATING URBANIZATION (sorted by deceleration):"
gsort acceleration
list country region urban_change_2000_2025 urban_change_2025_2050 acceleration if acceleration < -1, sep(0)

* Graph: Top 15 fastest urbanizing countries
gsort -urban_change_2000_2050
graph bar urban_change_2000_2050 if rank_abs <= 15, over(country, sort(1) descending label(angle(45))) ///
    title("Top 15 Fastest Urbanizing Countries") ///
    subtitle("Change in Urban Share 2000-2050 (percentage points)") ///
    ytitle("Change in Urban Share (pp)") ///
    bar(1, color(navy)) ///
    name(top15_urbanizing, replace)
graph export "top15_urbanizing.png", replace width(1200) height(800)

save "country_dynamics.dta", replace

*-------------------------------------------------------------------------------
* 4.2 Population Size Class Dynamics
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "4.2 POPULATION SIZE CLASS GROWTH DYNAMICS"
di "-" * 60

use "continent_size_class_data.dta", clear

* Calculate changes
gen change_2000_2025 = count_2025 - count_2000
gen change_2025_2050 = count_2050 - count_2025
gen change_2000_2050 = count_2050 - count_2000

* Calculate percentage growth
gen growth_pct_2000_2050 = ((count_2050 - count_2000) / count_2000) * 100 if count_2000 > 0

di _n "POPULATION SIZE CLASS DYNAMICS - CONTINENTAL:"
di "Number of Agglomerations and Changes:"
list class count_2000 count_2025 count_2050 change_2000_2050, noobs

di _n "Percentage Growth by Size Class (2000-2050):"
list class count_2000 count_2050 growth_pct_2000_2050, noobs

* Graph: Growth by size class
graph bar change_2000_2050, over(class) ///
    title("Growth in Number of Urban Agglomerations") ///
    subtitle("Absolute Change 2000-2050") ///
    ytitle("Change in Number of Agglomerations") ///
    bar(1, color(navy)) ///
    name(size_class_growth_abs, replace)
graph export "size_class_growth_abs.png", replace width(1200) height(800)

graph bar growth_pct_2000_2050 if growth_pct_2000_2050 != ., over(class) ///
    title("Growth Rate of Urban Agglomerations by Size Class") ///
    subtitle("Percentage Growth 2000-2050") ///
    ytitle("Percentage Growth (%)") ///
    bar(1, color(dkorange)) ///
    name(size_class_growth_pct, replace)
graph export "size_class_growth_pct.png", replace width(1200) height(800)

save "size_class_dynamics.dta", replace

*-------------------------------------------------------------------------------
* 4.3 Regional Comparison of Size Class Dynamics
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "4.3 REGIONAL COMPARISON - SIZE CLASS DYNAMICS"
di "-" * 60

use "africa_polis_prepared.dta", clear

* Create count variables by region and class
preserve
    gen n_2000_1 = (pop_class_2000 == 1)
    gen n_2000_2 = (pop_class_2000 == 2)
    gen n_2000_3 = (pop_class_2000 == 3)
    gen n_2000_4 = (pop_class_2000 == 4)
    gen n_2000_5 = (pop_class_2000 == 5)
    gen n_2000_6 = (pop_class_2000 == 6)
    
    gen n_2050_1 = (pop_class_2050 == 1)
    gen n_2050_2 = (pop_class_2050 == 2)
    gen n_2050_3 = (pop_class_2050 == 3)
    gen n_2050_4 = (pop_class_2050 == 4)
    gen n_2050_5 = (pop_class_2050 == 5)
    gen n_2050_6 = (pop_class_2050 == 6)
    
    collapse (sum) n_2000_* n_2050_*, by(region)
    
    * Calculate changes for each class
    forvalues i = 1/6 {
        gen change_class_`i' = n_2050_`i' - n_2000_`i'
        gen growth_pct_class_`i' = ((n_2050_`i' - n_2000_`i') / n_2000_`i') * 100 if n_2000_`i' > 0
    }
    
    di _n "REGIONAL SIZE CLASS CHANGES 2000-2050:"
    di "Absolute Changes in Number of Agglomerations:"
    list region change_class_1 change_class_2 change_class_3 change_class_4 change_class_5 change_class_6, sep(0)
    
    * Identify which region has most growth in each class
    foreach i in 1 2 3 4 5 6 {
        qui sum change_class_`i'
        local max_change = r(max)
        di _n "Class `i' - Maximum growth: `max_change'"
        list region change_class_`i' if change_class_`i' == `max_change', noobs
    }
    
    save "regional_class_dynamics.dta", replace
restore

/*------------------------------------------------------------------------------
    SECTION 5: COMPARATIVE ANALYSIS AND INSIGHTS
------------------------------------------------------------------------------*/

di _n(3) "=" * 80
di "SECTION 5: COMPARATIVE ANALYSIS AND KEY INSIGHTS"
di "=" * 80

*-------------------------------------------------------------------------------
* 5.1 Regional Disparities Analysis
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "5.1 REGIONAL DISPARITIES"
di "-" * 60

use "regional_urban_rural.dta", clear

* Summary statistics
summarize urban_share_2000 urban_share_2025 urban_share_2050

* Range and coefficient of variation
foreach year in 2000 2025 2050 {
    qui sum urban_share_`year'
    local min = r(min)
    local max = r(max)
    local mean = r(mean)
    local sd = r(sd)
    local cv = (`sd' / `mean') * 100
    local range = `max' - `min'
    
    di _n "Year `year':"
    di "  Min urban share: `min'"
    di "  Max urban share: `max'"
    di "  Range: `range'"
    di "  Coefficient of Variation: `cv'%"
}

* Compare most and least urbanized regions
gsort -urban_share_2050
di _n "REGIONS RANKED BY URBANIZATION (2050):"
list region urban_share_2000 urban_share_2025 urban_share_2050, noobs

*-------------------------------------------------------------------------------
* 5.2 Within-Region Country Disparities
*-------------------------------------------------------------------------------

di _n(2) "-" * 60
di "5.2 WITHIN-REGION COUNTRY DISPARITIES"
di "-" * 60

use "country_dynamics.dta", clear

* Calculate disparity metrics by region
bysort region: egen min_urban_2050 = min(urban_share_2050)
bysort region: egen max_urban_2050 = max(urban_share_2050)
bysort region: egen sd_urban_2050 = sd(urban_share_2050)
bysort region: egen mean_urban_2050 = mean(urban_share_2050)

gen within_region_range = max_urban_2050 - min_urban_2050
gen cv_within_region = (sd_urban_2050 / mean_urban_2050) * 100

preserve
    collapse (first) min_urban_2050 max_urban_2050 within_region_range cv_within_region, by(region)
    
    di _n "WITHIN-REGION DISPARITIES (Urban Share 2050):"
    list region min_urban_2050 max_urban_2050 within_region_range cv_within_region, sep(0)
    
    * Region with highest internal disparity
    gsort -within_region_range
    di _n "REGION WITH HIGHEST INTERNAL DISPARITY:"
    list region within_region_range if _n == 1, noobs
restore

* Show extremes within each region
di _n "MOST AND LEAST URBANIZED COUNTRY IN EACH REGION (2050):"
* Use levelsof to get actual region values dynamically
levelsof region, local(regions)
foreach reg of local regions {
    di _n "Region: `reg'"
    
    preserve
        keep if region == "`reg'"
        gsort -urban_share_2050
        di "  Most urbanized: " country[1] " (" urban_share_2050[1] "%)"
        gsort urban_share_2050
        di "  Least urbanized: " country[1] " (" urban_share_2050[1] "%)"
    restore
}

/*------------------------------------------------------------------------------
    SECTION 6: SUMMARY TABLES AND EXPORT
------------------------------------------------------------------------------*/

di _n(3) "=" * 80
di "SECTION 6: SUMMARY TABLES"
di "=" * 80

* Create summary table for continental trends
preserve
    clear
    input str20 indicator float(val_2000 val_2025 val_2050 change_abs change_pct)
    end
    
    * Get continental data
    use "africa_polis_prepared.dta", clear
    collapse (sum) Upop2000 Upop2025 Upop2050 TPOP2000 TPOP2025 TPOP2050
    
    local urban2000 = Upop2000[1]
    local urban2025 = Upop2025[1]
    local urban2050 = Upop2050[1]
    local total2000 = TPOP2000[1]
    local total2025 = TPOP2025[1]
    local total2050 = TPOP2050[1]
    
    local share2000 = (`urban2000' / `total2000') * 100
    local share2025 = (`urban2025' / `total2025') * 100
    local share2050 = (`urban2050' / `total2050') * 100
    
    clear
    set obs 3
    gen indicator = ""
    gen val_2000 = .
    gen val_2025 = .
    gen val_2050 = .
    gen change_abs_2000_2050 = .
    gen change_pct_2000_2050 = .
    
    replace indicator = "Urban Population (millions)" in 1
    replace val_2000 = `urban2000' / 1000000 in 1
    replace val_2025 = `urban2025' / 1000000 in 1
    replace val_2050 = `urban2050' / 1000000 in 1
    replace change_abs_2000_2050 = (`urban2050' - `urban2000') / 1000000 in 1
    replace change_pct_2000_2050 = ((`urban2050' - `urban2000') / `urban2000') * 100 in 1
    
    replace indicator = "Total Population (millions)" in 2
    replace val_2000 = `total2000' / 1000000 in 2
    replace val_2025 = `total2025' / 1000000 in 2
    replace val_2050 = `total2050' / 1000000 in 2
    replace change_abs_2000_2050 = (`total2050' - `total2000') / 1000000 in 2
    replace change_pct_2000_2050 = ((`total2050' - `total2000') / `total2000') * 100 in 2
    
    replace indicator = "Urban Share (%)" in 3
    replace val_2000 = `share2000' in 3
    replace val_2025 = `share2025' in 3
    replace val_2050 = `share2050' in 3
    replace change_abs_2000_2050 = `share2050' - `share2000' in 3
    replace change_pct_2000_2050 = ((`share2050' - `share2000') / `share2000') * 100 in 3
    
    di _n "AFRICA CONTINENTAL SUMMARY:"
    list, noobs sep(0)
    
    export excel using "continental_summary.xlsx", firstrow(variables) replace
restore

* Export all datasets to Excel for further analysis
di _n "Exporting final datasets..."

* Combine all key results
export delimited using "analysis_results.csv", replace

di _n(3) "=" * 80
di "ANALYSIS COMPLETE"
di "=" * 80
di _n "Output files created:"
di "  - africa_polis_prepared.dta (prepared dataset)"
di "  - regional_urban_rural.dta (regional urban/rural data)"
di "  - country_urban_rural.dta (country urban/rural data)"
di "  - continent_size_class_data.dta (size class data)"
di "  - regional_dynamics.dta (regional growth dynamics)"
di "  - country_dynamics.dta (country growth dynamics)"
di "  - size_class_dynamics.dta (size class growth)"
di "  - regional_class_dynamics.dta (regional class dynamics)"
di ""
di "Graphs exported:"
di "  - continent_urban_rural.png"
di "  - region_urban_share.png"
di "  - top10_urban_2050.png"
di "  - bottom10_urban_2050.png"
di "  - continent_size_class.png"
di "  - region_size_class_2050.png"
di "  - region_urban_dynamics.png"
di "  - top15_urbanizing.png"
di "  - size_class_growth_abs.png"
di "  - size_class_growth_pct.png"

log close

/*------------------------------------------------------------------------------
    END OF SCRIPT
------------------------------------------------------------------------------*/
