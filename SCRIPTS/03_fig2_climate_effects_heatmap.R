#!/usr/bin/env Rscript
################################################################################
# FIGURE 2: Climate Effects on Metal Bioaccumulation (HGAM Heatmap)
################################################################################
#
# Author: Claude Code
# Date: 2025-11-11
# Description: Heatmap showing MLR coefficients for climate effects on 12 metals
#
# Data: PHASE_4_CLIMATE_BIOACCUMULATION/STEP_4.2_CLIMATE_INTERFERENCE
# Method: Multiple Linear Regression (partial effects)
# Layout: 12 metals × 3 climate variables (Temperature, pH, O₂)
#
################################################################################

# Load configuration
source("00_master_config.R")

# Additional libraries
suppressPackageStartupMessages({
  library(ComplexHeatmap)
  library(circlize)
  library(grid)
})

cat(paste(rep("=", 70), collapse=""), "\n")
cat("FIGURE 2: CLIMATE EFFECTS ON METAL BIOACCUMULATION (HGAM HEATMAP)\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

################################################################################
# 1. LOAD DATA
################################################################################

cat("[1/5] Loading MLR model summary data...\n")

# MLR coefficients
mlr_file <- file.path(
  BASE_DIR,
  "PHASE_4_CLIMATE_BIOACCUMULATION",
  "STEP_4.2_CLIMATE_INTERFERENCE",
  "results",
  "mlr_models_summary.csv"
)

mlr_data <- read_csv(mlr_file, show_col_types = FALSE)
cat(sprintf("  ✓ Loaded MLR coefficients: %d metals\n", nrow(mlr_data)))

################################################################################
# 2. EXTRACT COEFFICIENTS & P-VALUES (3 climate variables only)
################################################################################

cat("\n[2/5] Extracting coefficients and p-values...\n")

# Extract only Temperature, pH, Oxygen (NOT pCO2, pH_co2)
coef_data <- mlr_data %>%
  select(
    metal,
    coef_temperature, pval_temperature,
    coef_ph, pval_ph,
    coef_oxygen, pval_oxygen
  )

# Reshape coefficients to matrix (12 metals × 3 climate vars)
coef_matrix <- coef_data %>%
  select(metal, coef_temperature, coef_ph, coef_oxygen) %>%
  column_to_rownames("metal") %>%
  as.matrix()

# Column names for display
colnames(coef_matrix) <- c("Temperature", "pH", "Oxygen")

# Reshape p-values to matrix
pval_matrix <- coef_data %>%
  select(metal, pval_temperature, pval_ph, pval_oxygen) %>%
  column_to_rownames("metal") %>%
  as.matrix()

colnames(pval_matrix) <- c("Temperature", "pH", "Oxygen")

cat(sprintf("  ✓ Coefficient matrix: %d metals × %d climate variables\n",
            nrow(coef_matrix), ncol(coef_matrix)))

################################################################################
# 3. CREATE SIGNIFICANCE MATRIX (asterisks)
################################################################################

cat("\n[3/5] Creating significance annotations...\n")

# Function to convert p-value to asterisk notation
pval_to_asterisk <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.001) return("***")
  if (p < 0.01) return("**")
  if (p < 0.05) return("*")
  return("")
}

# Apply to all p-values
sig_matrix <- apply(pval_matrix, c(1, 2), pval_to_asterisk)

# Count significant effects per climate variable
sig_counts <- colSums(pval_matrix < 0.05, na.rm = TRUE)
sig_pct <- round(sig_counts / nrow(coef_matrix) * 100, 0)

cat("  Significant effects per climate variable:\n")
cat(sprintf("    - Temperature: %d/12 metals (%d%%)\n",
            sig_counts[1], sig_pct[1]))
cat(sprintf("    - pH: %d/12 metals (%d%%)\n",
            sig_counts[2], sig_pct[2]))
cat(sprintf("    - Oxygen: %d/12 metals (%d%%)\n",
            sig_counts[3], sig_pct[3]))

# Identify most sensitive metal (most significant effects)
sig_per_metal <- rowSums(pval_matrix < 0.05, na.rm = TRUE)
most_sensitive <- names(which.max(sig_per_metal))
cat(sprintf("\n  ✓ Most climate-sensitive metal: %s (%d/3 climate vars significant)\n",
            most_sensitive, max(sig_per_metal)))

################################################################################
# 4. CREATE COMPLEXHEATMAP
################################################################################

cat("\n[4/5] Creating ComplexHeatmap...\n")

# Determine color scale limits (symmetric around 0)
max_abs_coef <- max(abs(coef_matrix), na.rm = TRUE)
max_abs_coef <- ceiling(max_abs_coef * 10) / 10  # Round up to 1 decimal

# Color function (RdBu_r diverging: red = positive, blue = negative)
col_fun <- colorRamp2(
  breaks = seq(-max_abs_coef, max_abs_coef, length.out = 100),
  colors = colorRampPalette(rev(RColorBrewer::brewer.pal(11, "RdBu")))(100)
)

# Cell annotation function (value + significance)
cell_fun <- function(j, i, x, y, width, height, fill) {
  coef_val <- coef_matrix[i, j]
  sig_mark <- sig_matrix[i, j]

  # Text color (white for dark cells, black for light cells)
  text_col <- ifelse(abs(coef_val) > (max_abs_coef * 0.4), "white", "black")

  # Format: coefficient value + asterisks
  label_text <- sprintf("%.2f%s", coef_val, sig_mark)

  grid.text(
    label_text,
    x, y,
    gp = gpar(fontsize = 9, col = text_col, fontface = ifelse(sig_mark != "", "bold", "plain"))
  )
}

# Column labels with proper chemical notation
# Note: ComplexHeatmap doesn't support expression() in column_labels directly
# We'll use plain text and add note about O2 subscript
column_labels <- c(
  "Temperature (°C)",
  "pH",
  "O₂ (mmol/m³)"  # Unicode subscript
)

# Create heatmap
ht <- Heatmap(
  coef_matrix,
  name = "MLR Coefficient (β)",
  col = col_fun,

  # Clustering
  cluster_rows = TRUE,
  cluster_columns = FALSE,  # Keep fixed order: Temp, pH, O2
  clustering_distance_rows = "euclidean",
  clustering_method_rows = "complete",
  show_row_dend = TRUE,
  row_dend_width = unit(2.5, "cm"),  # Increased from 1.5 to 2.5 cm to separate lines

  # Labels
  row_names_side = "left",
  column_names_side = "top",
  column_labels = column_labels,
  row_title = NULL,
  column_title = NULL,

  # Cell annotations
  cell_fun = cell_fun,
  rect_gp = gpar(col = "gray30", lwd = 0.5),

  # Styling
  row_names_gp = gpar(fontsize = 10, fontfamily = "Arial"),
  column_names_gp = gpar(fontsize = 11, fontface = "bold", fontfamily = "Arial"),
  heatmap_legend_param = list(
    title = "MLR Coefficient (β)",
    title_gp = gpar(fontsize = 10, fontface = "bold", fontfamily = "Arial"),
    labels_gp = gpar(fontsize = 9, fontfamily = "Arial"),
    legend_height = unit(4, "cm"),
    grid_width = unit(0.5, "cm")
  ),

  # Size
  width = unit(5, "cm"),
  height = unit(10, "cm")
)

cat("  ✓ ComplexHeatmap created\n")

################################################################################
# 5. SAVE FIGURE
################################################################################

cat("\n[5/5] Saving figure...\n")

# Create title and subtitle
plot_title <- "Climate Effects on Metal Bioaccumulation"
plot_subtitle <- "(Multiple Linear Regression Coefficients: Partial Effects)"

# Save PDF (use cairo_pdf for TrueType font support)
pdf_file <- file.path(OUTPUT_DIR, "fig2_climate_effects_heatmap.pdf")
cairo_pdf(pdf_file, width = WIDTH_DOUBLE, height = HEIGHT_STANDARD * 1.2)

# Draw heatmap with title (NO legend at bottom)
grid.newpage()
pushViewport(viewport(layout = grid.layout(nrow = 2, ncol = 1,
                                           heights = unit(c(1.2, 10), c("cm", "cm")))))

# Title
pushViewport(viewport(layout.pos.row = 1, layout.pos.col = 1))
grid.text(plot_title,
          y = 0.6,
          gp = gpar(fontsize = 14, fontface = "bold", fontfamily = "Arial"))
popViewport()

# Heatmap only
pushViewport(viewport(layout.pos.row = 2, layout.pos.col = 1))
draw(ht, newpage = FALSE)
popViewport()

dev.off()
cat(sprintf("  ✓ Saved PDF: %s\n", pdf_file))

# Save PNG
png_file <- file.path(OUTPUT_DIR, "fig2_climate_effects_heatmap.png")
png(png_file, width = WIDTH_DOUBLE * DPI, height = HEIGHT_STANDARD * 1.2 * DPI, res = DPI)

# Redraw (same layout - NO legend)
grid.newpage()
pushViewport(viewport(layout = grid.layout(nrow = 2, ncol = 1,
                                           heights = unit(c(1.2, 10), c("cm", "cm")))))
pushViewport(viewport(layout.pos.row = 1, layout.pos.col = 1))
grid.text(plot_title, y = 0.6,
          gp = gpar(fontsize = 14, fontface = "bold", fontfamily = "Arial"))
popViewport()
pushViewport(viewport(layout.pos.row = 2, layout.pos.col = 1))
draw(ht, newpage = FALSE)
popViewport()

dev.off()
cat(sprintf("  ✓ Saved PNG: %s\n", png_file))

################################################################################
# COMPLETION SUMMARY
################################################################################

# Save summary statistics to separate file (removed from figure caption)
summary_stats_file <- file.path(OUTPUT_DIR, "fig2_caption_statistics.txt")
caption_text <- sprintf(
  "FIGURE 2 CAPTION (for manuscript)
================================================================================

Climate Effects on Metal Bioaccumulation (MLR Heatmap)

Heatmap showing Multiple Linear Regression coefficients (β) for climate effects
on 12 metals bioaccumulation. Hierarchical clustering (left dendrogram) groups
metals by similarity of climate response patterns.

SIGNIFICANCE LEGEND (to include in figure caption):
* p<0.05, ** p<0.01, *** p<0.001 (FDR-corrected)

KEY STATISTICS:

Significant effects per climate variable:
- Temperature: %d/12 metals (%d%%)
- pH: %d/12 metals (%d%%)
- Oxygen: %d/12 metals (%d%%)

Most climate-sensitive metal: %s (%d/3 climate variables significant)

Hierarchical clustering reveals functional metal groups:
- Group 1 (top): Cr - strong positive pH effect
- Group 2 (middle): Hg, Ni, Fe, Cd, Cu, V, Mn, Zn - oxygen-dominated effects
- Group 3 (bottom): As, Pb, Ba - negative temperature/pH effects

INTERPRETATION:
- Oxygen dominates (50%% metals affected) as primary climate stressor
- pH affects 25%% metals (ocean acidification concern)
- Temperature affects 33%% metals (warming effects)
- MLR coefficients represent PARTIAL effects (controlling for covariates)
- All coefficients are standardized for comparability across variables

================================================================================
",
  sig_counts[1], sig_pct[1],
  sig_counts[2], sig_pct[2],
  sig_counts[3], sig_pct[3],
  most_sensitive, max(sig_per_metal)
)
writeLines(caption_text, summary_stats_file)
cat(sprintf("  ✓ Saved caption statistics: %s\n", summary_stats_file))

cat("\n", paste(rep("=", 70), collapse=""), "\n")
cat("FIGURE 2 COMPLETED SUCCESSFULLY\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

cat("Files saved:\n")
cat(sprintf("  - %s\n", pdf_file))
cat(sprintf("  - %s\n", png_file))
cat(sprintf("  - %s (caption statistics)\n", summary_stats_file))

cat("\nKey findings:\n")
cat(sprintf("  - Temperature: %d/12 metals affected (%d%%)\n", sig_counts[1], sig_pct[1]))
cat(sprintf("  - pH: %d/12 metals affected (%d%%)\n", sig_counts[2], sig_pct[2]))
cat(sprintf("  - Oxygen: %d/12 metals affected (%d%%)\n", sig_counts[3], sig_pct[3]))
cat(sprintf("  - Most climate-sensitive metal: %s (%d/3 significant)\n",
            most_sensitive, max(sig_per_metal)))
cat("  - Hierarchical clustering reveals functional metal groups\n")
cat("  - MLR coefficients show partial effects (controlling for covariates)\n")
cat("  - Caption statistics saved for manuscript writing\n")

cat("\n")
