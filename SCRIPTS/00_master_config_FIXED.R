#!/usr/bin/env Rscript
################################################################################
# MASTER CONFIGURATION FOR PUBLICATION FIGURES
################################################################################
#
# This file sets up paths, styling, and common functions for all figure scripts
#
# IMPORTANT: This version uses RELATIVE PATHS for portability across systems
#
################################################################################

cat("========================================\n")
cat("MASTER CONFIGURATION\n")
cat("========================================\n\n")

################################################################################
# 1. LOAD REQUIRED PACKAGES
################################################################################

cat("[1/5] Loading R packages...\n")

required_packages <- c(
  "ggplot2", "tidyr", "dplyr", "readr", "patchwork",
  "scales", "RColorBrewer", "viridis", "zoo"
)

# Check and install missing packages
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(missing_packages)) {
  cat(sprintf("  ⚠ Installing missing packages: %s\n", paste(missing_packages, collapse=", ")))
  install.packages(missing_packages, repos="https://cloud.r-project.org/")
}

# Load all packages
suppressPackageStartupMessages({
  lapply(required_packages, library, character.only = TRUE)
})

cat(sprintf("  ✓ %d packages loaded\n", length(required_packages)))

################################################################################
# 2. SETUP DIRECTORY PATHS (RELATIVE)
################################################################################

cat("\n[2/5] Setting up directory paths...\n")

# Get script directory
SCRIPT_DIR <- dirname(sys.frame(1)$ofile)
if(length(SCRIPT_DIR) == 0 || SCRIPT_DIR == "") {
  # Fallback if running interactively
  SCRIPT_DIR <- getwd()
}

# Repository root (1 level up from SCRIPTS/)
REPO_ROOT <- normalizePath(file.path(SCRIPT_DIR, ".."))

# Data directories
DATA_DIR <- file.path(REPO_ROOT, "DATA")
PROCESSED_DATA_DIR <- file.path(REPO_ROOT, "PROCESSED_DATA")
RESULTS_DIR <- file.path(REPO_ROOT, "RESULTS")

# Output directories
OUTPUT_DIR <- file.path(RESULTS_DIR, "figures")
TABLES_DIR <- file.path(RESULTS_DIR, "tables")

# Create output directories if they don't exist
dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TABLES_DIR, showWarnings = FALSE, recursive = TRUE)

cat(sprintf("  ✓ Repository root: %s\n", REPO_ROOT))
cat(sprintf("  ✓ Raw data: %s\n", DATA_DIR))
cat(sprintf("  ✓ Processed data: %s\n", PROCESSED_DATA_DIR))
cat(sprintf("  ✓ Output figures: %s\n", OUTPUT_DIR))

################################################################################
# 3. DATA FILE PATHS
################################################################################

cat("\n[3/5] Configuring data file paths...\n")

DATA_PATHS <- list(
  # Raw data (DATA/)
  biomarkers = file.path(DATA_DIR, "biomarkers.csv"),
  heavy_metals = file.path(DATA_DIR, "heavy_metals.csv"),
  ctd = file.path(DATA_DIR, "ctd_oceanographic.csv"),
  copernicus_models = file.path(DATA_DIR, "copernicus_models.csv"),
  copernicus_daily = file.path(DATA_DIR, "copernicus_models_daily.csv"),
  copernicus_co2_daily = file.path(DATA_DIR, "copernicus_co2_daily.csv"),
  copernicus_satellite = file.path(DATA_DIR, "copernicus_satellite.csv"),
  mhw_events = file.path(DATA_DIR, "marine_heatwaves/heatwave_events.csv"),
  mhw_daily = file.path(DATA_DIR, "marine_heatwaves/daily_temperature_heatwaves.csv"),
  mhw_thresholds = file.path(DATA_DIR, "marine_heatwaves/climatology_p90_thresholds.csv"),

  # Processed data (PROCESSED_DATA/)
  # Phase 1: Climate trends
  phase1_trends = file.path(PROCESSED_DATA_DIR, "phase1_climate_trends/trend_analysis_results.csv"),

  # Phase 4: Climate-metal linkage
  phase4_mlr = file.path(PROCESSED_DATA_DIR, "phase4_climate_metals/mlr_models_summary.csv"),
  phase4_mhw_comp = file.path(PROCESSED_DATA_DIR, "phase4_climate_metals/mhw_comparison.csv"),

  # Phase 5.5: Multi-method variance partitioning
  phase5.5_variance_biomarker = file.path(PROCESSED_DATA_DIR, "../RESULTS/tables/variance_partitioning_by_biomarker_phase5.5.csv"),
  phase5.5_variance_convergence = file.path(PROCESSED_DATA_DIR, "../RESULTS/tables/variance_partitioning_5methods_convergence.csv"),

  # Phase 6: Composite indices & scenarios
  phase6_cci = file.path(PROCESSED_DATA_DIR, "phase6_indices/cci_time_series.csv"),
  phase6_bsi = file.path(PROCESSED_DATA_DIR, "phase6_indices/bsi_dataset.csv"),
  phase6_mci = file.path(PROCESSED_DATA_DIR, "phase6_indices/mci_dataset.csv"),
  phase6_scenarios = file.path(PROCESSED_DATA_DIR, "phase6_indices/scenario_projections.csv"),
  phase6_baseline = file.path(PROCESSED_DATA_DIR, "phase6_indices/baseline_statistics.csv")
)

# Verify critical files exist
critical_files <- c("biomarkers", "heavy_metals", "copernicus_daily", "mhw_events")
missing_files <- c()
for(f in critical_files) {
  if(!file.exists(DATA_PATHS[[f]])) {
    missing_files <- c(missing_files, f)
  }
}

if(length(missing_files) > 0) {
  cat(sprintf("  ⚠ WARNING: Missing critical files: %s\n", paste(missing_files, collapse=", ")))
} else {
  cat("  ✓ All critical data files found\n")
}

################################################################################
# 4. VISUALIZATION SETTINGS
################################################################################

cat("\n[4/5] Configuring visualization settings...\n")

# Figure dimensions (inches)
WIDTH_SINGLE <- 7
WIDTH_DOUBLE <- 10
HEIGHT_STANDARD <- 10
HEIGHT_DOUBLE <- 12

# Resolution
DPI <- 300

# Okabe-Ito colorblind-safe palette
COLOR_PALETTE <- c(
  orange = "#E69F00",
  skyblue = "#56B4E9",
  green = "#009E73",
  yellow = "#F0E442",
  blue = "#0072B2",
  vermillion = "#D55E00",
  purple = "#CC79A7",
  gray = "#999999"
)

# Factor-specific colors (for variance partitioning)
FACTOR_COLORS <- c(
  Climate = "#E74C3C",    # Red/orange
  Metals = "#3498DB",     # Blue
  Terminal = "#F39C12",   # Orange
  Season = "#2ECC71",     # Green
  Unknown = "#95A5A6"     # Gray
)

# ggplot2 theme
THEME_PUBLICATION <- theme_minimal(base_size = 10, base_family = "Arial") +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    axis.title = element_text(size = 10, face = "bold"),
    axis.text = element_text(size = 9),
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
    strip.background = element_rect(fill = "gray90", color = "black"),
    strip.text = element_text(face = "bold")
  )

# Set as default theme
theme_set(THEME_PUBLICATION)

cat("  ✓ Figure dimensions set\n")
cat("  ✓ Color palette configured (Okabe-Ito, colorblind-safe)\n")
cat("  ✓ Publication theme applied\n")

################################################################################
# 5. HELPER FUNCTIONS
################################################################################

cat("\n[5/5] Loading helper functions...\n")

#' Save plot in multiple formats
#'
#' @param plot ggplot2 object
#' @param filename Base filename (without extension)
#' @param width Figure width in inches
#' @param height Figure height in inches
#' @param dpi Resolution (default: 300)
save_plot <- function(plot, filename, width, height, dpi = DPI) {
  # PDF (vector)
  ggsave(
    file.path(OUTPUT_DIR, paste0(filename, ".pdf")),
    plot = plot,
    width = width,
    height = height,
    device = "pdf"
  )

  # PNG (raster)
  ggsave(
    file.path(OUTPUT_DIR, paste0(filename, ".png")),
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    device = "png"
  )

  cat(sprintf("  ✓ Saved: %s (PDF + PNG)\n", filename))
}

#' Format p-values for display
#'
#' @param p_value Numeric p-value
#' @return Formatted string
format_pvalue <- function(p_value) {
  if (p_value < 0.001) {
    return("p < 0.001")
  } else if (p_value < 0.01) {
    return(sprintf("p = %.3f", p_value))
  } else {
    return(sprintf("p = %.2f", p_value))
  }
}

#' Add significance stars
#'
#' @param p_value Numeric p-value
#' @return Stars string
add_stars <- function(p_value) {
  if (p_value < 0.001) {
    return("***")
  } else if (p_value < 0.01) {
    return("**")
  } else if (p_value < 0.05) {
    return("*")
  } else {
    return("")
  }
}

cat("  ✓ Helper functions loaded\n")

################################################################################
# CONFIGURATION COMPLETE
################################################################################

cat("\n========================================\n")
cat("✓ MASTER CONFIGURATION LOADED\n")
cat("========================================\n\n")
