# COVID-19 Data Analysis Project

**Author**: Youssef Khabir
**Dataset**: owid-covid-data.csv (Our World in Data)
**Last Updated**: November 2025

## Project Overview

This comprehensive COVID-19 data analysis project performs statistical analysis and visualization of global COVID-19 data to extract meaningful insights about the pandemic's progression, impact across different regions, and relationships between various epidemiological and socio-economic factors.

## Files Structure

```
├── Projet_R_YoussefKhabir.R          # Main analysis script (FIXED - namespace conflicts resolved)
├── COVID-19_Analysis_Report.md       # Comprehensive analysis report with step-by-step explanations
├── COVID-19_Visualizations.Rmd       # R Markdown file for generating visualizations
├── README.md                         # This file - project documentation
├── data/
│   └── raw/
│       └── owid-covid-data.csv       # Raw COVID-19 dataset
│   └── processed/                    # Will be created during analysis
└── plots/                            # Will be created for visualization outputs
```

## Fixed Issues

✅ **Namespace Conflicts Resolved**:
- Fixed dplyr::filter() vs stats::filter() conflict
- Fixed dplyr::lag() vs stats::lag() conflict
- All filter() calls now use explicit dplyr::filter() syntax
- Code now runs without namespace warnings

## Prerequisites

### Required Software
1. **R (version 4.0+)**: Download from https://www.r-project.org/
2. **RStudio (recommended)**: Download from https://www.rstudio.com/

### Required R Packages
Install the following packages in R:
```r
install.packages(c("tidyverse", "lubridate", "ggplot2", "readr", "stringr"))
```

## How to Run This Analysis

### Method 1: Using the Main R Script

1. **Open R or RStudio**
2. **Set working directory** to the project folder:
   ```r
   setwd("D:/DEV-TOOLS/R covid-19 By joseph")
   ```
3. **Run the analysis**:
   ```r
   source("Projet_R_YoussefKhabir.R")
   ```

### Method 2: Using R Markdown (for visualizations)

1. **Open RStudio**
2. **Set working directory** to the project folder:
   ```r
   setwd("D:/DEV-TOOLS/R covid-19 By joseph")
   ```
3. **Open and knit** the R Markdown file:
   ```r
   rmarkdown::render("COVID-19_Visualizations.Rmd")
   ```

## Expected Outputs

### Console Output
- Dataset dimensions and structure information
- Missing values analysis
- Global and continental statistics
- Country-specific outbreak analysis
- Progress indicators throughout the analysis

### Generated Files
- **`plots/global_daily_cases.png`**: Global daily new cases timeline
- **`plots/top_countries_cases.png`**: Top 10 countries by total cases
- **`plots/cfr_by_continent.png`**: Case fatality rates by continent
- **`plots/cases_vs_density.png`**: Cases vs population density relationship
- **`plots/vaccination_progress.png`**: Vaccination coverage over time
- **`data/processed/covid_data_processed.csv`**: Cleaned and processed dataset

### HTML Report (Method 2 only)
- **`COVID-19_Visualizations.html`**: Interactive HTML report with all visualizations

## Key Analysis Features

### Data Processing
- **Data Import**: CSV file loading with proper type conversion
- **Cleaning**: Missing value handling and outlier treatment
- **Feature Engineering**: Creation of derived variables for analysis
- **Namespace Conflict Resolution**: Explicit package prefixes to avoid conflicts

### Statistical Analyses
- **Descriptive Statistics**: Global and regional summaries
- **Time Series Analysis**: Pandemic wave identification
- **Comparative Analysis**: Country and continent comparisons
- **Correlation Analysis**: Relationships between variables

### Visualizations
- **Professional Quality**: ggplot2-based visualizations with consistent styling
- **High Resolution**: 300 DPI images suitable for reports and presentations
- **Comprehensive Coverage**: Five key visualization types for complete analysis

## Troubleshooting

### Common Issues

1. **"Rscript: command not found"**
   - **Solution**: R is not installed or not in your system PATH
   - **Fix**: Install R or use RStudio instead

2. **"Error: package not found"**
   - **Solution**: Required packages not installed
   - **Fix**: Run the install.packages() command listed in prerequisites

3. **"File not found" errors**
   - **Solution**: Working directory not set correctly
   - **Fix**: Use `setwd()` to navigate to the project folder

4. **"Cannot open file for writing: data/processed/covid_data_processed.csv"**
   - **Solution**: The data/processed directory doesn't exist
   - **Fix**: This has been fixed in the updated code. The script now automatically creates the directory.

5. **Memory issues with large dataset**
   - **Solution**: Dataset may be too large for available memory
   - **Fix**: Close other applications or use a machine with more RAM

### Verification Steps

To verify the analysis is working correctly:

1. **Check console output**: You should see progress messages throughout the analysis
2. **Verify plot generation**: All 5 plot files should be created in the `plots/` directory
3. **Check processed data**: `covid_data_processed.csv` should be created in `data/processed/`
4. **No conflict warnings**: No namespace conflict messages should appear

## Data Source

- **Dataset**: owid-covid-data.csv
- **Source**: Our World in Data (https://ourworldindata.org/coronavirus)
- **License**: Creative Commons BY license
- **Update Frequency**: Regularly updated with latest global COVID-19 data

## Technical Details

### Data Structure
- **Rows**: 429,436 observations
- **Columns**: 67 variables including cases, deaths, vaccinations, testing, and demographic data
- **Time Period**: January 2020 to November 2025
- **Geographic Coverage**: 200+ countries and territories

### Key Variables
- Epidemiological metrics (cases, deaths, testing)
- Healthcare system indicators
- Vaccination data
- Socio-economic indicators
- Population demographics

### Analysis Methods
- Tidyverse framework for data manipulation
- ggplot2 for professional visualizations
- Statistical analysis using R base functions
- Time series analysis and trend identification

## Support

For questions or issues with this analysis:
1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Ensure proper working directory setup
4. Review the detailed code explanations in COVID-19_Analysis_Report.md

---

*This project demonstrates comprehensive COVID-19 data analysis using R, with resolved namespace conflicts and detailed documentation for reproducibility.*