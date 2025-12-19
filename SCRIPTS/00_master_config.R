#!/usr/bin/env Rscript
# ==============================================================================
# MASTER CONFIGURATION FOR ALL PUBLICATION FIGURES
# ==============================================================================
# Project: Climate Change Ecotoxicology - Mediterranean Mussel Study
# Purpose: Unified configuration for R publication-quality figures
# Date: 2025-11-11
#
# Load this script FIRST in all figure scripts:
#   source("00_master_config.R")
# ==============================================================================

cat("\n")
cat("================================================================================\n")
cat("LOADING MASTER CONFIGURATION FOR PUBLICATION FIGURES\n")
cat("================================================================================\n\n")

# ==============================================================================
# 1. PACKAGE MANAGEMENT
# ==============================================================================

required_packages <- c(
  # Core tidyverse
  "tidyverse",      # ggplot2, dplyr, tidyr, readr, purrr, tibble
  "scales",         # Formatting (percent, scientific notation)

  # Multi-panel layouts
  "patchwork",      # Combine ggplot2 plots
  "cowplot",        # Publication themes

  # Color palettes
  "viridis",        # Perceptually uniform colors
  "RColorBrewer",   # Color palettes

  # Time series
  "zoo",            # Rolling means
  "lubridate"       # Date handling
)

cat("[1/5] Checking required packages...\n")

# Check and install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages) > 0) {
  cat(sprintf("  Installing missing packages: %s\n", paste(new_packages, collapse=", ")))
  install.packages(new_packages, repos = "https://cran.r-project.org", quiet = TRUE)
} else {
  cat("  ✓ All required packages already installed\n")
}

# Load all packages (suppress messages)
invisible(suppressPackageStartupMessages(
  lapply(required_packages, library, character.only = TRUE)
))

cat("  ✓ Core packages loaded successfully\n\n")

# ==============================================================================
# 2. SPECIALIZED PACKAGES (optional, with error handling)
# ==============================================================================

cat("[2/5] Loading specialized packages...\n")

# ComplexHeatmap (Bioconductor) - for Figure 2
if (!requireNamespace("ComplexHeatmap", quietly = TRUE)) {
  cat("  ! ComplexHeatmap not installed (needed for Figure 2)\n")
  cat("    Install with: BiocManager::install('ComplexHeatmap')\n")
} else {
  suppressPackageStartupMessages(library(ComplexHeatmap))
  suppressPackageStartupMessages(library(circlize))  # Color ramps for heatmaps
  cat("  ✓ ComplexHeatmap loaded (heatmap support)\n")
}

# visualizeR (climate4R) - for Figure 4 IPCC projections
if (!requireNamespace("visualizeR", quietly = TRUE)) {
  cat("  ! visualizeR not installed (optional for Figure 4)\n")
  cat("    Will use ggplot2 fallback\n")
} else {
  suppressPackageStartupMessages(library(visualizeR))
  cat("  ✓ visualizeR loaded (IPCC-style projections)\n")
}

# ggpubr + ggsignif - for statistical annotations (optional)
if (!requireNamespace("ggpubr", quietly = TRUE)) {
  cat("  ! ggpubr not installed (optional for stats annotations)\n")
} else {
  suppressPackageStartupMessages(library(ggpubr))
  cat("  ✓ ggpubr loaded (statistical annotations)\n")
}

if (!requireNamespace("ggsignif", quietly = TRUE)) {
  cat("  ! ggsignif not installed (optional for significance bars)\n")
} else {
  suppressPackageStartupMessages(library(ggsignif))
  cat("  ✓ ggsignif loaded (significance bars)\n")
}

cat("\n")

# ==============================================================================
# 3. GLOBAL GGPLOT2 THEME (Publication Quality)
# ==============================================================================

cat("[3/5] Setting publication theme...\n")

# Base theme: minimal + Arial font + 300 DPI
theme_set(
  theme_minimal(base_size = 12, base_family = "Arial") +
  theme(
    # Titles
    plot.title = element_text(size = 14, face = "bold", hjust = 0, margin = margin(b = 10)),
    plot.subtitle = element_text(size = 11, hjust = 0, margin = margin(b = 10)),

    # Axes
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10, color = "black"),
    axis.line = element_line(color = "black", linewidth = 0.5),
    axis.ticks = element_line(color = "black", linewidth = 0.5),

    # Legend
    legend.title = element_text(size = 11, face = "bold"),
    legend.text = element_text(size = 10),
    legend.position = "bottom",
    legend.box = "horizontal",
    legend.margin = margin(t = 10),

    # Grid (minimal, Tufte style)
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray90", linewidth = 0.3),

    # Background
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA),

    # Margins
    plot.margin = margin(15, 15, 15, 15),

    # Facets
    strip.text = element_text(size = 11, face = "bold"),
    strip.background = element_rect(fill = "gray95", color = "black", linewidth = 0.5)
  )
)

cat("  ✓ Publication theme applied (Arial, 300 DPI, minimal grid)\n\n")

# ==============================================================================
# 4. COLOR PALETTES (Colorblind-Safe)
# ==============================================================================

cat("[4/5] Defining color palettes...\n")

# Okabe-Ito palette (colorblind-safe, 8 colors)
okabe_ito <- c(
  orange     = "#E69F00",
  sky_blue   = "#56B4E9",
  green      = "#009E73",
  yellow     = "#F0E442",
  blue       = "#0072B2",
  vermillion = "#D55E00",
  purple     = "#CC79A7",
  gray       = "#999999"
)

# Factor colors (for variance partitioning, Figure 3)
factor_colors <- c(
  Climate  = "#E74C3C",  # Red
  Metals   = "#3498DB",  # Blue
  Terminal = "#F39C12",  # Orange
  Season   = "#2ECC71",  # Green
  Unknown  = "#95A5A6"   # Gray
)

# Scenario colors (IPCC-style, for Figure 4)
scenario_colors <- c(
  Baseline  = "#666666",  # Dark gray
  "SSP2-3.4" = "#3498DB",  # Blue (strong mitigation)
  "RCP4.5"   = "#F39C12",  # Orange (moderate emissions)
  "RCP8.5"   = "#E74C3C"   # Red (business-as-usual)
)

# Marine Heatwave colors (Hobday et al. 2018, Figure 1 & 6)
mhw_colors <- c(
  Moderate = "#FEE090",  # Yellow
  Strong   = "#FC8D59",  # Orange
  Severe   = "#E34A33",  # Red-orange
  Extreme  = "#B30000"   # Dark red/maroon
)

mhw_alpha <- c(
  Moderate = 0.3,
  Strong   = 0.4,
  Severe   = 0.5,
  Extreme  = 0.6
)

cat("  ✓ Color palettes defined:\n")
cat("    - Okabe-Ito (8 colors, colorblind-safe)\n")
cat("    - Factor colors (Climate, Metals, Terminal, Season, Unknown)\n")
cat("    - Scenario colors (IPCC-style: SSP2-3.4, RCP4.5, RCP8.5)\n")
cat("    - MHW colors (Hobday 2018: Moderate→Extreme)\n\n")

# ==============================================================================
# 5. FILE PATHS & OUTPUT SETTINGS
# ==============================================================================

cat("[5/5] Setting file paths and output parameters...\n")

# Base directory (relative to ANALYSIS/)
BASE_DIR <- "/home/guido/SRC/climate-change-ecotoxicology/ANALYSIS"

# Data paths (all relative to BASE_DIR)
DATA_PATHS <- list(
  # Phase 1: Climate trends + MHW
  phase1_trends = file.path(BASE_DIR, "PHASE_1_CLIMATE_CHANGE/STEP_1.1_TRENDS_QUANTIFICATION/results/trend_analysis_results.csv"),
  phase1_mhw_events = file.path(BASE_DIR, "PHASE_1_CLIMATE_CHANGE/STEP_1.2_MARINE_HEATWAVES/results/marine_heatwave_events.csv"),
  phase1_mhw_daily = file.path(BASE_DIR, "PHASE_1_CLIMATE_CHANGE/STEP_1.2_MARINE_HEATWAVES/results/daily_temperature_with_mhw_flags.csv"),

  # Phase 4: Climate-metal linkage
  phase4_mlr = file.path(BASE_DIR, "PHASE_4_CLIMATE_BIOACCUMULATION/STEP_4.2_CLIMATE_INTERFERENCE/results/mlr_models_summary.csv"),
  phase4_mhw_comp = file.path(BASE_DIR, "PHASE_4_CLIMATE_BIOACCUMULATION/STEP_4.2_CLIMATE_INTERFERENCE/results/mhw_comparison.csv"),

  # Phase 5: Variance partitioning
  phase5_variance = file.path(BASE_DIR, "PHASE_5_MULTIFACTOR_STRESS_W_SEASON/STEP_5.1_CONTRIBUTION_CALCULATION/results/variance_partitioning_5factors_FULL_CLIMATE.csv"),

  # Phase 6: Composite indices & scenarios
  phase6_cci = file.path(BASE_DIR, "PHASE_6_COMPOSITE_INDICES/STEP_6.1_CLIMATE_CHANGE_INDEX/results/cci_time_series.csv"),
  phase6_bsi = file.path(BASE_DIR, "PHASE_6_COMPOSITE_INDICES/STEP_6.2_BIOLOGICAL_STRESS_INDEX/results/bsi_dataset.csv"),
  phase6_scenarios = file.path(BASE_DIR, "PHASE_6_COMPOSITE_INDICES/STEP_6.5_CLIMATE_SCENARIOS/results/scenario_projections.csv"),
  phase6_baseline = file.path(BASE_DIR, "PHASE_6_COMPOSITE_INDICES/STEP_6.5_CLIMATE_SCENARIOS/results/baseline_statistics.csv"),

  # Raw data (for Figure 1 if needed)
  copernicus_daily = file.path(BASE_DIR, "../CLEAN_DATA_PACKAGE/RAW_DATA/copernicus_models_daily.csv"),
  copernicus_co2_daily = file.path(BASE_DIR, "../CLEAN_DATA_PACKAGE/RAW_DATA/copernicus_co2_daily.csv")
)

# Output directory
OUTPUT_DIR <- file.path(BASE_DIR, "RESULTS/figures")
dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)

# Output settings
DPI <- 300
WIDTH_SINGLE <- 7    # inches (single column, Nature/Science)
WIDTH_DOUBLE <- 10   # inches (double column)
HEIGHT_STANDARD <- 6
HEIGHT_TALL <- 10
HEIGHT_DOUBLE <- 12  # inches (double-height for complex multi-panel figures)

cat(sprintf("  ✓ Output directory: %s\n", OUTPUT_DIR))
cat(sprintf("  ✓ Resolution: %d DPI\n", DPI))
cat(sprintf("  ✓ Widths: Single=%g\", Double=%g\"\n", WIDTH_SINGLE, WIDTH_DOUBLE))
cat("\n")

# ==============================================================================
# 6. HELPER FUNCTIONS
# ==============================================================================

# Save function (PDF + PNG)
save_figure <- function(plot_object, filename, width = WIDTH_DOUBLE, height = HEIGHT_STANDARD) {
  # PDF (vector, editable)
  ggsave(
    filename = file.path(OUTPUT_DIR, paste0(filename, ".pdf")),
    plot = plot_object,
    width = width,
    height = height,
    dpi = DPI,
    device = cairo_pdf  # Better font rendering
  )

  # PNG (raster, high-res)
  ggsave(
    filename = file.path(OUTPUT_DIR, paste0(filename, ".png")),
    plot = plot_object,
    width = width,
    height = height,
    dpi = DPI
  )

  cat(sprintf("\n✓ Saved: %s.pdf + %s.png\n", filename, filename))
  cat(sprintf("  Location: %s/\n", OUTPUT_DIR))
}

# Get MHW color with transparency
get_mhw_color <- function(category, with_alpha = TRUE) {
  cat <- tolower(category)
  cat <- tools::toTitleCase(cat)  # Capitalize first letter

  color <- mhw_colors[cat]
  if (is.na(color)) color <- "#CCCCCC"  # Default gray

  if (with_alpha) {
    alpha <- mhw_alpha[cat]
    if (is.na(alpha)) alpha <- 0.3
    return(list(color = color, alpha = alpha))
  } else {
    return(color)
  }
}

# Format chemical notation for plot labels
format_chemical <- function(formula) {
  # Convert to expression with subscripts
  # Usage: ylab(format_chemical("O2")) → O₂

  replacements <- list(
    "O2" = expression(O[2]),
    "CO2" = expression(CO[2]),
    "NO3" = expression(NO[3]^"-"),
    "PO4" = expression(PO[4]^"3-"),
    "pCO2" = expression(italic(p)*CO[2]),
    "fCO2" = expression(italic(f)*CO[2])
  )

  if (formula %in% names(replacements)) {
    return(replacements[[formula]])
  } else {
    return(formula)
  }
}

cat("================================================================================\n")
cat("✓ MASTER CONFIGURATION LOADED SUCCESSFULLY\n")
cat("================================================================================\n")
cat(sprintf("  Ready to create publication-quality figures\n"))
cat(sprintf("  Output: %s/\n", OUTPUT_DIR))
cat(sprintf("  Resolution: %d DPI | Font: Arial | Theme: Publication Minimal\n", DPI))
cat("================================================================================\n\n")

# Make all objects available globally
list2env(
  list(
    okabe_ito = okabe_ito,
    factor_colors = factor_colors,
    scenario_colors = scenario_colors,
    mhw_colors = mhw_colors,
    mhw_alpha = mhw_alpha,
    DATA_PATHS = DATA_PATHS,
    OUTPUT_DIR = OUTPUT_DIR,
    DPI = DPI,
    WIDTH_SINGLE = WIDTH_SINGLE,
    WIDTH_DOUBLE = WIDTH_DOUBLE,
    HEIGHT_STANDARD = HEIGHT_STANDARD,
    HEIGHT_TALL = HEIGHT_TALL,
    HEIGHT_DOUBLE = HEIGHT_DOUBLE,
    save_figure = save_figure,
    get_mhw_color = get_mhw_color,
    format_chemical = format_chemical
  ),
  envir = .GlobalEnv
)
