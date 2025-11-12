# =============================================================================
# COVID-19 Data Analysis Project
# Author: Youssef Khabir
# Dataset: owid-covid-data.csv
# =============================================================================

# Load required libraries with conflict resolution
library(tidyverse)
library(lubridate)
library(ggplot2)
library(readr)
library(stringr)

# Resolve namespace conflicts by using explicit packages
# Use dplyr functions explicitly to avoid conflicts with stats
# Example: dplyr::filter() instead of filter()
# Example: dplyr::lag() instead of lag()

# Set global options for better output
options(scipen = 999, stringsAsFactors = FALSE)

# =============================================================================
# 1. DATA IMPORT & INITIAL EXPLORATION
# =============================================================================

cat("Starting COVID-19 Data Analysis...\n")
cat("=====================================\n\n")

# Import the dataset
covid_data <- read_csv("data/raw/owid-covid-data.csv",
                      show_col_types = FALSE)

# Display basic information about the dataset
cat("Dataset Dimensions:", nrow(covid_data), "rows,", ncol(covid_data), "columns\n\n")

# Show column names
cat("Column Names:\n")
print(names(covid_data))

# Display first few rows
cat("\nFirst 6 rows of the dataset:\n")
print(head(covid_data))

# Check data structure
cat("\nData Structure:\n")
str(covid_data)

# Summary statistics
cat("\nSummary Statistics:\n")
summary(covid_data)

# Check missing values
cat("\nMissing Values Analysis:\n")
missing_values <- colSums(is.na(covid_data))
missing_percent <- (missing_values / nrow(covid_data)) * 100
missing_summary <- data.frame(
  Column = names(covid_data),
  Missing_Count = missing_values,
  Missing_Percentage = round(missing_percent, 2)
)
print(missing_summary[missing_summary$Missing_Count > 0, ])

# =============================================================================
# 2. DATA PREPARATION AND CLEANING
# =============================================================================

cat("\n\n2. DATA PREPARATION AND CLEANING\n")
cat("=================================\n")

# Convert date column to proper date format
covid_data <- covid_data %>%
  mutate(date = as.Date(date))

# Check date range
cat("Date Range:", min(covid_data$date, na.rm = TRUE), "to", max(covid_data$date, na.rm = TRUE), "\n")

# Filter out rows with essential missing data
covid_clean <- covid_data %>%
  dplyr::filter(!is.na(location), !is.na(date)) %>%
  dplyr::filter(location != "International" & location != "World")

# Handle missing values in key columns
covid_clean <- covid_clean %>%
  mutate(
    total_cases = ifelse(is.na(total_cases), 0, total_cases),
    new_cases = ifelse(is.na(new_cases), 0, new_cases),
    total_deaths = ifelse(is.na(total_deaths), 0, total_deaths),
    new_deaths = ifelse(is.na(new_deaths), 0, new_deaths)
  )

# Create regions for better analysis
covid_clean <- covid_clean %>%
  mutate(
    region = case_when(
      continent %in% c("Europe", "North America", "South America", "Asia", "Africa", "Oceania") ~ continent,
      TRUE ~ "Other"
    )
  )

cat("After cleaning:", nrow(covid_clean), "rows remaining\n")

# =============================================================================
# 3. FEATURE ENGINEERING
# =============================================================================

cat("\n\n3. FEATURE ENGINEERING\n")
cat("=====================\n")

# Create derived variables
covid_analysis <- covid_clean %>%
  mutate(
    # Case fatality rate
    case_fatality_rate = ifelse(total_cases > 0, (total_deaths / total_cases) * 100, 0),

    # Testing positivity rate
    positivity_rate_derived = ifelse(total_tests > 0, (total_cases / total_tests) * 100, 0),

    # Vaccination coverage
    vaccination_coverage = ifelse(population > 0, (people_fully_vaccinated / population) * 100, 0),

    # Month and year for time series analysis
    month = format(date, "%Y-%m"),
    year = year(date),

    # Days since first case (for each location)
    days_since_first_case = ifelse(total_cases > 0,
                                 as.numeric(date - min(date[total_cases > 0]), units = "days"), 0),

    # Outbreak stage classification
    outbreak_stage = case_when(
      total_cases == 0 ~ "No Cases",
      total_cases < 100 ~ "Early Stage",
      total_cases < 1000 ~ "Growing Stage",
      total_cases < 10000 ~ "Established Stage",
      total_cases >= 10000 ~ "Widespread Stage"
    ),

    # High impact country indicator (based on total cases)
    high_impact_country = ifelse(total_cases > quantile(total_cases, 0.9, na.rm = TRUE), 1, 0)
  )

cat("Feature engineering completed. New variables created:\n")
print(names(covid_analysis)[(ncol(covid_clean)+1):ncol(covid_analysis)])

# =============================================================================
# 4. DESCRIPTIVE ANALYSIS
# =============================================================================

cat("\n\n4. DESCRIPTIVE ANALYSIS\n")
cat("======================\n")

# Global statistics
global_stats <- covid_analysis %>%
  group_by(location) %>%
  summarise(
    total_cases = max(total_cases, na.rm = TRUE),
    total_deaths = max(total_deaths, na.rm = TRUE),
    case_fatality_rate = max(case_fatality_rate, na.rm = TRUE),
    population = max(population, na.rm = TRUE),
    cases_per_million = max(total_cases_per_million, na.rm = TRUE),
    deaths_per_million = max(total_deaths_per_million, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(total_cases))

# Top 10 countries by cases
cat("\nTop 10 Countries by Total Cases:\n")
print(head(global_stats, 10))

# Continent-level analysis
continent_stats <- covid_analysis %>%
  dplyr::filter(!is.na(continent)) %>%
  group_by(continent) %>%
  summarise(
    total_countries = n_distinct(location),
    total_cases = sum(total_cases, na.rm = TRUE),
    total_deaths = sum(total_deaths, na.rm = TRUE),
    avg_case_fatality_rate = mean(case_fatality_rate, na.rm = TRUE),
    total_population = sum(population, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(total_cases))

cat("\nStatistics by Continent:\n")
print(continent_stats)

# =============================================================================
# 5. CONDITIONAL ANALYSIS & LOOPS
# =============================================================================

cat("\n\n5. CONDITIONAL ANALYSIS & LOOPS\n")
cat("==============================\n")

# Analyze countries by different case thresholds
case_thresholds <- c(100, 1000, 10000, 100000, 1000000)

cat("Countries reaching case milestones:\n")
for(threshold in case_thresholds) {
  countries_reached <- covid_analysis %>%
    dplyr::filter(total_cases >= threshold) %>%
    pull(location) %>%
    unique()

  cat(paste("Countries with", threshold, "+ cases:", length(countries_reached), "\n"))
}

# Custom function for outbreak analysis
analyze_outbreak <- function(data, country_name) {
  country_data <- data %>% dplyr::filter(location == country_name)

  if(nrow(country_data) == 0) {
    return(paste("No data found for", country_name))
  }

  first_case_date <- min(country_data$date[country_data$total_cases > 0], na.rm = TRUE)
  peak_daily_cases <- max(country_data$new_cases, na.rm = TRUE)
  peak_date <- country_data$date[country_data$new_cases == peak_daily_cases][1]

  result <- list(
    country = country_name,
    first_case_date = first_case_date,
    peak_daily_cases = peak_daily_cases,
    peak_date = peak_date,
    total_cases = max(country_data$total_cases, na.rm = TRUE),
    total_deaths = max(country_data$total_deaths, na.rm = TRUE)
  )

  return(result)
}

# Analyze a few key countries
key_countries <- c("United States", "India", "Brazil", "France", "United Kingdom")
outbreak_results <- lapply(key_countries, function(country) {
  analyze_outbreak(covid_analysis, country)
})

cat("\nOutbreak Analysis for Key Countries:\n")
for(result in outbreak_results) {
  if(is.list(result)) {
    cat(paste(result$country, ":\n"))
    cat(paste("  First case:", result$first_case_date, "\n"))
    cat(paste("  Peak daily cases:", result$peak_daily_cases, "on", result$peak_date, "\n"))
    cat(paste("  Total cases:", result$total_cases, "\n"))
    cat(paste("  Total deaths:", result$total_deaths, "\n\n"))
  }
}

# =============================================================================
# 6. DATA VISUALIZATION
# =============================================================================

cat("\n\n6. DATA VISUALIZATION\n")
cat("=====================\n")

# Create directories if they don't exist
if(!dir.exists("plots")) {
  dir.create("plots")
}
if(!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# 1. Global cases over time
global_timeline <- covid_analysis %>%
  group_by(date) %>%
  summarise(
    total_cases = sum(total_cases, na.rm = TRUE),
    total_deaths = sum(total_deaths, na.rm = TRUE),
    new_cases = sum(new_cases, na.rm = TRUE),
    .groups = 'drop'
 )

p1 <- ggplot(global_timeline, aes(x = date)) +
  geom_line(aes(y = new_cases/1000, color = "New Cases"), size = 1) +
  geom_smooth(aes(y = new_cases/1000), method = "loess", se = FALSE) +
  labs(
    title = "Global Daily New COVID-19 Cases",
    subtitle = "Thousand cases per day",
    x = "Date",
    y = "New Cases (thousands)",
    color = "Metric"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("plots/global_daily_cases.png", p1, width = 12, height = 6, dpi = 300)

# 2. Top countries comparison
top_countries <- global_stats$location[1:10]
top_data <- covid_analysis %>%
  dplyr::filter(location %in% top_countries) %>%
  group_by(location) %>%
  summarise(
    total_cases = max(total_cases, na.rm = TRUE),
    total_deaths = max(total_deaths, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  arrange(desc(total_cases))

p2 <- ggplot(top_data, aes(x = reorder(location, total_cases), y = total_cases/1000000)) +
  geom_col(fill = "steelblue", alpha = 0.7) +
  coord_flip() +
  labs(
    title = "Top 10 Countries by Total COVID-19 Cases",
    subtitle = "As of latest data",
    x = "Country",
    y = "Total Cases (millions)"
  ) +
  theme_minimal()

ggsave("plots/top_countries_cases.png", p2, width = 10, height = 6, dpi = 300)

# 3. Case fatality rate by continent
continent_cfr <- covid_analysis %>%
  dplyr::filter(!is.na(continent), total_cases > 1000) %>%
  group_by(continent) %>%
  summarise(
    avg_cfr = mean(case_fatality_rate, na.rm = TRUE),
    median_cfr = median(case_fatality_rate, na.rm = TRUE),
    .groups = 'drop'
  )

p3 <- ggplot(continent_cfr, aes(x = reorder(continent, avg_cfr), y = avg_cfr)) +
  geom_col(fill = "coral", alpha = 0.7) +
  labs(
    title = "Average Case Fatality Rate by Continent",
    subtitle = "For countries with 1000+ cases",
    x = "Continent",
    y = "Average CFR (%)"
  ) +
  theme_minimal() +
  coord_flip()

ggsave("plots/cfr_by_continent.png", p3, width = 10, height = 6, dpi = 300)

# 4. Cases vs Population Density
density_analysis <- covid_analysis %>%
  dplyr::filter(!is.na(population_density), total_cases_per_million > 0, population_density < 1000) %>%
  group_by(location) %>%
  summarise(
    cases_per_million = max(total_cases_per_million, na.rm = TRUE),
    population_density = max(population_density, na.rm = TRUE),
    .groups = 'drop'
  )

p4 <- ggplot(density_analysis, aes(x = population_density, y = cases_per_million)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  scale_x_log10() +
  scale_y_log10() +
  labs(
    title = "COVID-19 Cases vs Population Density",
    subtitle = "Log-log scale",
    x = "Population Density (people per km², log scale)",
    y = "Cases per Million (log scale)"
  ) +
  theme_minimal()

ggsave("plots/cases_vs_density.png", p4, width = 10, height = 6, dpi = 300)

# 5. Vaccination progress over time
vaccination_timeline <- covid_analysis %>%
  dplyr::filter(date >= "2021-01-01") %>%
  group_by(date) %>%
  summarise(
    avg_vaccination_coverage = mean(vaccination_coverage, na.rm = TRUE),
    .groups = 'drop'
  )

p5 <- ggplot(vaccination_timeline, aes(x = date, y = avg_vaccination_coverage)) +
  geom_line(color = "green", size = 1) +
  geom_area(fill = "green", alpha = 0.3) +
  labs(
    title = "Global COVID-19 Vaccination Progress",
    subtitle = "Average vaccination coverage over time",
    x = "Date",
    y = "Vaccination Coverage (%)"
  ) +
  theme_minimal()

ggsave("plots/vaccination_progress.png", p5, width = 12, height = 6, dpi = 300)

cat("Visualizations saved to 'plots' directory\n")

# =============================================================================
# 7. SUMMARY STATISTICS
# =============================================================================

cat("\n\n7. SUMMARY STATISTICS\n")
cat("====================\n")

# Calculate global statistics as of latest date
latest_date <- max(covid_analysis$date)
latest_data <- covid_analysis %>% dplyr::filter(date == latest_date)

cat("Global COVID-19 Statistics as of", latest_date, ":\n")
cat("Total countries/territories:", length(unique(latest_data$location)), "\n")
cat("Total cases:", format(sum(latest_data$total_cases, na.rm = TRUE), big.mark = ","), "\n")
cat("Total deaths:", format(sum(latest_data$total_deaths, na.rm = TRUE), big.mark = ","), "\n")
cat("Global average case fatality rate:",
    round(mean(latest_data$case_fatality_rate[latest_data$total_cases > 0], na.rm = TRUE), 2), "%\n")

# Save the cleaned dataset for further analysis
write_csv(covid_analysis, "data/processed/covid_data_processed.csv")
cat("\nProcessed dataset saved to data/processed/covid_data_processed.csv\n")

cat("\nAnalysis completed successfully!\n")
cat("================================\n")