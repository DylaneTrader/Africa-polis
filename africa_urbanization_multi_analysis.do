/*==============================================================================
    AFRICA URBANIZATION MULTI-ANALYSIS - STATA 16 DO-FILE
    
    Description: 
    This script performs urbanization analysis on multiple Africa-polis datasets.
    It can process multiple Excel files and generate comparative analyses across
    different datasets.
    
    Features:
    1. Automated processing of multiple input files
    2. Handles files with different header configurations
    3. Generates separate analysis for each dataset
    4. Creates comparative summaries across datasets
    
    Data: Multiple Stata_workbook*.xlsx files
    Years analyzed: 2000, 2025, 2050
    
    Author: Generated for Africa-polis project
    Date: 2026-01-07
==============================================================================*/

clear all
set more off
cap log close

* Set working directory (modify as needed)
* cd "path/to/your/working/directory"

* Create log file
log using "africa_urbanization_multi_analysis.log", replace

* Set graph scheme
set scheme s2color

/*------------------------------------------------------------------------------
    DEFINE FILE LIST FOR ANALYSIS
------------------------------------------------------------------------------*/

* Define the list of input files to analyze
* Add or modify this list to process different files
local files "Stata_workbook.xlsx Stata_workbook_1.xlsx"

* Counter for file processing
local file_counter = 1

* Create empty frame for combined continental summaries
frame create combined_summary str30 dataset str50 indicator float(val_2000 val_2025 val_2050 change_abs change_pct)

/*------------------------------------------------------------------------------
    PROCESS EACH FILE
------------------------------------------------------------------------------*/

foreach input_file of local files {
    
    di _n(3) "=" * 80
    di "PROCESSING FILE `file_counter': `input_file'"
    di "=" * 80
    
    * Clear memory for new file
    clear
    
    * Extract base filename for output naming
    local base_name = substr("`input_file'", 1, strlen("`input_file'") - 5)
    
    /*--------------------------------------------------------------------------
        SECTION 1: DATA IMPORT AND PREPARATION
    --------------------------------------------------------------------------*/
    
    di _n(2) "-" * 60
    di "SECTION 1: DATA IMPORT AND PREPARATION"
    di "-" * 60
    
    * Import data from Excel
    * Note: Some files may have headers in different rows or formats
    * Always try importing with firstrow option
    cap import excel using "`input_file'", firstrow clear
    
    if _rc != 0 {
        di as error "Failed to import `input_file' with firstrow option"
        di "Trying without firstrow..."
        import excel using "`input_file'", clear
    }
    
    * Check if we got proper column names
    qui ds
    local varlist = r(varlist)
    local first_var : word 1 of `varlist'
    
    * Check if first variable is unnamed (starts with A-Z for default Excel naming)
    * or contains the actual header text
    if "`first_var'" == "A" | "`first_var'" == "Agglomeration_ID" {
        di "Variable names look correct: `first_var'"
    }
    else {
        * Variables might have generic names like A, B, C
        * Check if first data row contains headers
        local test_val = `first_var'[1]
        if "`test_val'" == "Agglomeration_ID" {
            di "Found headers in first data row, fixing variable names..."
            * Manually set proper variable names from first row
            local col_num = 0
            foreach var of varlist _all {
                local col_num = `col_num' + 1
                local newname = `var'[1]
                * Skip if empty
                if "`newname'" != "" & "`newname'" != "." {
                    * Clean the variable name
                    local newname = subinstr("`newname'", " ", "_", .)
                    local newname = subinstr("`newname'", "+", "plus", .)
                    local newname = subinstr("`newname'", "-", "_", .)
                    cap rename `var' `newname'
                }
            }
            * Drop the header row
            drop in 1
        }
    }
    
    di "Data import completed"
    
    * Display basic information
    describe, short
    
    * Check if required variables exist
    cap confirm variable pays
    if _rc != 0 {
        di as error "Error: Required variable 'pays' not found in `input_file'"
        continue
    }
    
    cap confirm variable AU_Regions
    if _rc != 0 {
        di as error "Error: Required variable 'AU_Regions' not found in `input_file'"
        continue
    }
    
    * Rename key variables for easier handling
    cap rename pays country
    cap rename AU_Regions region
    cap rename Agglomeration_ID agglo_id
    
    * Check for required population variables
    cap confirm variable Upop2000 Upop2025 Upop2050 TPOP2000 TPOP2025 TPOP2050
    if _rc != 0 {
        di as error "Error: Required population variables not found in `input_file'"
        continue
    }
    
    * Display variable names to identify CPopulation columns
    qui ds CPopulation*
    local cpop_vars = r(varlist)
    if "`cpop_vars'" != "" {
        di "Found CPopulation variables: `cpop_vars'"
    }
    
    * Rename the population class variables to simpler names
    * Handle multiple possible naming patterns from Excel import
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
    
    * Alternative pattern: spaces become "to" with spaces
    cap rename CPopulation_2000_10to500K cp2000_10_500
    cap rename CPopulation_2000_500to1M cp2000_500_1M
    cap rename CPopulation_2000_1Mto3M cp2000_1M_3M
    cap rename CPopulation_2000_3Mto5M cp2000_3M_5M
    cap rename CPopulation_2000_5Mto10M cp2000_5M_10M
    cap rename CPopulation_2000__10M cp2000_10M
    
    cap rename CPopulation_2025_10to500K cp2025_10_500
    cap rename CPopulation_2025_500to1M cp2025_500_1M
    cap rename CPopulation_2025_1Mto3M cp2025_1M_3M
    cap rename CPopulation_2025_3Mto5M cp2025_3M_5M
    cap rename CPopulation_2025_5Mto10M cp2025_5M_10M
    cap rename CPopulation_2025__10M cp2025_10M
    
    cap rename CPopulation_2050_10to500K cp2050_10_500
    cap rename CPopulation_2050_500to1M cp2050_500_1M
    cap rename CPopulation_2050_1Mto3M cp2050_1M_3M
    cap rename CPopulation_2050_3Mto5M cp2050_3M_5M
    cap rename CPopulation_2050_5Mto10M cp2050_5M_10M
    cap rename CPopulation_2050__10M cp2050_10M
    
    * Create numeric region variable for graphing
    encode region, gen(region_num)
    label var region_num "Region (numeric)"
    
    * Create numeric country variable
    encode country, gen(country_num)
    label var country_num "Country (numeric)"
    
    * Create population class categories as numeric variables
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
    
    * Save prepared dataset with file-specific name
    save "`base_name'_prepared.dta", replace
    
    /*--------------------------------------------------------------------------
        SECTION 2: CONTINENTAL SUMMARY FOR THIS FILE
    --------------------------------------------------------------------------*/
    
    di _n(2) "-" * 60
    di "SECTION 2: CONTINENTAL LEVEL ANALYSIS"
    di "-" * 60
    
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
        di _n "AFRICA TOTAL - Urban Population Shares (`input_file'):"
        list urban_share_2000 urban_share_2025 urban_share_2050, noobs
        
        di _n "AFRICA TOTAL - Rural Population Shares (`input_file'):"
        list rural_share_2000 rural_share_2025 rural_share_2050, noobs
        
        * Store continental values for combined summary
        local urban2000 = Upop2000[1]
        local urban2025 = Upop2025[1]
        local urban2050 = Upop2050[1]
        local total2000 = TPOP2000[1]
        local total2025 = TPOP2025[1]
        local total2050 = TPOP2050[1]
        local share2000 = urban_share_2000[1]
        local share2025 = urban_share_2025[1]
        local share2050 = urban_share_2050[1]
        
        * Graph: Continental Urban/Rural shares over time
        gen geo = "Africa"
        reshape long urban_share_ rural_share_, i(geo) j(year)
        rename urban_share_ urban_share
        rename rural_share_ rural_share
        
        graph bar urban_share rural_share, over(year) ///
            title("Africa: Urban vs Rural Population Share") ///
            subtitle("`input_file': 2000, 2025, 2050") ///
            ytitle("Percentage (%)") ///
            legend(label(1 "Urban") label(2 "Rural")) ///
            bar(1, color(navy)) bar(2, color(forest_green)) ///
            name(continent_urban_rural_`file_counter', replace)
        graph export "`base_name'_continent_urban_rural.png", replace width(1200) height(800)
    restore
    
    * Add to combined summary frame
    frame combined_summary {
        * Add urban population row
        local new_obs = _N + 1
        set obs `new_obs'
        replace dataset = "`base_name'" in `new_obs'
        replace indicator = "Urban Population (millions)" in `new_obs'
        replace val_2000 = `urban2000' / 1000000 in `new_obs'
        replace val_2025 = `urban2025' / 1000000 in `new_obs'
        replace val_2050 = `urban2050' / 1000000 in `new_obs'
        replace change_abs = (`urban2050' - `urban2000') / 1000000 in `new_obs'
        replace change_pct = ((`urban2050' - `urban2000') / `urban2000') * 100 in `new_obs'
        
        * Add total population row
        local new_obs = _N + 1
        set obs `new_obs'
        replace dataset = "`base_name'" in `new_obs'
        replace indicator = "Total Population (millions)" in `new_obs'
        replace val_2000 = `total2000' / 1000000 in `new_obs'
        replace val_2025 = `total2025' / 1000000 in `new_obs'
        replace val_2050 = `total2050' / 1000000 in `new_obs'
        replace change_abs = (`total2050' - `total2000') / 1000000 in `new_obs'
        replace change_pct = ((`total2050' - `total2000') / `total2000') * 100 in `new_obs'
        
        * Add urban share row
        local new_obs = _N + 1
        set obs `new_obs'
        replace dataset = "`base_name'" in `new_obs'
        replace indicator = "Urban Share (%)" in `new_obs'
        replace val_2000 = `share2000' in `new_obs'
        replace val_2025 = `share2025' in `new_obs'
        replace val_2050 = `share2050' in `new_obs'
        replace change_abs = `share2050' - `share2000' in `new_obs'
        replace change_pct = ((`share2050' - `share2000') / `share2000') * 100 in `new_obs'
    }
    
    /*--------------------------------------------------------------------------
        SECTION 3: REGIONAL ANALYSIS
    --------------------------------------------------------------------------*/
    
    di _n(2) "-" * 60
    di "SECTION 3: REGIONAL LEVEL ANALYSIS"
    di "-" * 60
    
    preserve
        collapse (sum) Upop2000 Upop2025 Upop2050 TPOP2000 TPOP2025 TPOP2050, by(region)
        
        * Calculate urban shares
        gen urban_share_2000 = (Upop2000 / TPOP2000) * 100
        gen urban_share_2025 = (Upop2025 / TPOP2025) * 100
        gen urban_share_2050 = (Upop2050 / TPOP2050) * 100
        
        * Display results
        di _n "BY REGION - Urban Population Shares (`input_file'):"
        list region urban_share_2000 urban_share_2025 urban_share_2050, sep(0)
        
        * Graph: Urban shares by region for each year
        graph bar urban_share_2000 urban_share_2025 urban_share_2050, over(region, label(angle(45))) ///
            title("Urban Population Share by Region") ///
            subtitle("`input_file': 2000, 2025, 2050") ///
            ytitle("Urban Share (%)") ///
            legend(label(1 "2000") label(2 "2025") label(3 "2050")) ///
            bar(1, color(navy*0.5)) bar(2, color(navy*0.75)) bar(3, color(navy)) ///
            name(region_urban_share_`file_counter', replace)
        graph export "`base_name'_region_urban_share.png", replace width(1200) height(800)
        
        * Save regional data
        save "`base_name'_regional_urban_rural.dta", replace
    restore
    
    /*--------------------------------------------------------------------------
        SECTION 4: COUNTRY LEVEL ANALYSIS
    --------------------------------------------------------------------------*/
    
    di _n(2) "-" * 60
    di "SECTION 4: COUNTRY LEVEL ANALYSIS"
    di "-" * 60
    
    preserve
        collapse (sum) Upop2000 Upop2025 Upop2050 TPOP2000 TPOP2025 TPOP2050, by(country region)
        
        * Calculate urban shares
        gen urban_share_2000 = (Upop2000 / TPOP2000) * 100
        gen urban_share_2025 = (Upop2025 / TPOP2025) * 100
        gen urban_share_2050 = (Upop2050 / TPOP2050) * 100
        
        * Display top 10 most urbanized countries in 2050
        gsort -urban_share_2050
        di _n "TOP 10 MOST URBANIZED COUNTRIES IN 2050 (`input_file'):"
        list country region urban_share_2050 if _n <= 10, noobs
        
        * Export country-level data
        export excel using "`base_name'_country_urban_rural.xlsx", firstrow(variables) replace
        save "`base_name'_country_urban_rural.dta", replace
    restore
    
    /*--------------------------------------------------------------------------
        SECTION 5: POPULATION SIZE CLASS ANALYSIS
    --------------------------------------------------------------------------*/
    
    di _n(2) "-" * 60
    di "SECTION 5: POPULATION SIZE CLASS DISTRIBUTION"
    di "-" * 60
    
    * Tabulate population classes for 2050
    di _n "Population Class Distribution - 2050 (`input_file'):"
    tab pop_class_2050
    
    * Graph: Number of agglomerations by size class
    preserve
        gen n_2050_1 = (pop_class_2050 == 1)
        gen n_2050_2 = (pop_class_2050 == 2)
        gen n_2050_3 = (pop_class_2050 == 3)
        gen n_2050_4 = (pop_class_2050 == 4)
        gen n_2050_5 = (pop_class_2050 == 5)
        gen n_2050_6 = (pop_class_2050 == 6)
        
        collapse (sum) n_2050_*
        
        gen id = 1
        reshape long n_2050_, i(id) j(class)
        rename n_2050_ count_2050
        
        label define class_lbl 1 "10K-500K" 2 "500K-1M" 3 "1M-3M" 4 "3M-5M" 5 "5M-10M" 6 "10M+"
        label values class class_lbl
        
        di _n "Number of Agglomerations by Size Class - 2050 (`input_file'):"
        list class count_2050, noobs
        
        graph bar count_2050, over(class) ///
            title("Urban Agglomerations by Size Class - 2050") ///
            subtitle("`input_file'") ///
            ytitle("Number of Agglomerations") ///
            bar(1, color(navy)) ///
            name(size_class_2050_`file_counter', replace)
        graph export "`base_name'_size_class_2050.png", replace width(1200) height(800)
        
        save "`base_name'_size_class_2050.dta", replace
    restore
    
    * Increment file counter
    local file_counter = `file_counter' + 1
    
    di _n(3) "=" * 80
    di "COMPLETED ANALYSIS FOR: `input_file'"
    di "=" * 80
}

/*------------------------------------------------------------------------------
    COMPARATIVE SUMMARY ACROSS ALL FILES
------------------------------------------------------------------------------*/

di _n(3) "=" * 80
di "COMPARATIVE SUMMARY ACROSS ALL DATASETS"
di "=" * 80

* Display combined summary
frame combined_summary {
    if _N > 0 {
        di _n "COMBINED CONTINENTAL SUMMARY - ALL DATASETS:"
        list, sep(3)
        
        * Export combined summary
        export excel using "multi_analysis_combined_summary.xlsx", firstrow(variables) replace
        save "multi_analysis_combined_summary.dta", replace
        
        * Create comparison graph for urban share
        preserve
            keep if indicator == "Urban Share (%)"
            
            if _N > 1 {
                graph bar val_2000 val_2025 val_2050, over(dataset, label(angle(45))) ///
                    title("Comparison of Urban Share Across Datasets") ///
                    subtitle("Africa Continental Level") ///
                    ytitle("Urban Share (%)") ///
                    legend(label(1 "2000") label(2 "2025") label(3 "2050")) ///
                    bar(1, color(navy*0.5)) bar(2, color(navy*0.75)) bar(3, color(navy)) ///
                    name(comparison_urban_share, replace)
                graph export "multi_analysis_comparison_urban_share.png", replace width(1200) height(800)
            }
        restore
    }
    else {
        di as error "No data was successfully processed"
    }
}

/*------------------------------------------------------------------------------
    FINAL SUMMARY
------------------------------------------------------------------------------*/

di _n(3) "=" * 80
di "MULTI-ANALYSIS COMPLETE"
di "=" * 80
di _n "Files processed: `files'"
di _n "Output files created:"
di "  - [filename]_prepared.dta (prepared datasets)"
di "  - [filename]_regional_urban_rural.dta (regional data)"
di "  - [filename]_country_urban_rural.dta (country data)"
di "  - [filename]_size_class_2050.dta (size class data)"
di "  - multi_analysis_combined_summary.xlsx (comparative summary)"
di ""
di "Graphs exported:"
di "  - [filename]_continent_urban_rural.png"
di "  - [filename]_region_urban_share.png"
di "  - [filename]_size_class_2050.png"
di "  - multi_analysis_comparison_urban_share.png"

log close

/*------------------------------------------------------------------------------
    END OF SCRIPT
------------------------------------------------------------------------------*/
