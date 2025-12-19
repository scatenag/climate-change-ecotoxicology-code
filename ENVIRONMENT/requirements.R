# R Package Requirements for Climate Change Ecotoxicology Analysis
# Project: Climate Change Exceeds Metal Contamination as Primary Driver of Biological Stress
# Study Period: 2014-2023, Ligurian Sea, Mediterranean

# Installation script - Run this first:
# install.packages(c("ggplot2", "tidyr", "dplyr", "readr", "patchwork",
#                    "ComplexHeatmap", "corrplot", "relaimpo", "zoo",
#                    "lavaan", "bnlearn", "mgcv", "nlme"))

# ============================================================================
# CORE VISUALIZATION & DATA MANIPULATION
# ============================================================================

# ggplot2 >= 3.4.0 - Grammar of graphics visualization (publication figures)
# tidyr >= 1.3.0 - Data reshaping and tidying
# dplyr >= 1.1.0 - Data manipulation and transformation
# readr >= 2.1.0 - Fast CSV reading
# patchwork >= 1.1.0 - Combining multiple ggplot2 plots into layouts

# ============================================================================
# SPECIALIZED PLOTTING
# ============================================================================

# ComplexHeatmap >= 2.14.0 - Advanced heatmap visualization (Figure 2)
# corrplot >= 0.92 - Correlation matrix visualization
# zoo >= 1.8.0 - Time series manipulation (rolling means for Figure 6)

# ============================================================================
# STATISTICAL ANALYSIS
# ============================================================================

# relaimpo >= 2.2 - Relative importance (LMG method, Phase 5.5)
# lavaan >= 0.6-12 - Structural Equation Modeling (SEM mediation, Phase 5.5.3)
# bnlearn >= 4.8 - Bayesian Network structure learning (Phase 5.5.6-8)
# mgcv >= 1.8-40 - Generalized Additive Models (GAM, Phase 4 HGAM)
# nlme >= 3.1-160 - Linear and Nonlinear Mixed Effects Models

# ============================================================================
# ADDITIONAL UTILITIES
# ============================================================================

# scales - Scale functions for visualization
# RColorBrewer - ColorBrewer palettes
# viridis - Viridis color palettes (colorblind-safe)

# ============================================================================
# R VERSION
# ============================================================================

# Minimum R version: 4.3.0
# Recommended: R >= 4.3.1

# ============================================================================
# PACKAGE INSTALLATION COMMAND
# ============================================================================

required_packages <- c(
  "ggplot2", "tidyr", "dplyr", "readr", "patchwork",
  "ComplexHeatmap", "corrplot", "relaimpo", "zoo",
  "lavaan", "bnlearn", "mgcv", "nlme",
  "scales", "RColorBrewer", "viridis"
)

# Check and install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Load all packages
lapply(required_packages, library, character.only = TRUE)

cat("✓ All R packages installed and loaded successfully\n")
cat("R version:", R.version.string, "\n")
