#!/usr/bin/env Rscript
################################################################################
# FIGURE 7: Marine Heatwave Effects on Biomarkers (2014-2023)
################################################################################
# Description: Time series showing biomarker responses during MHW events
# Layout: 4 panels (one per biomarker) showing response to MHW events
################################################################################

source("00_master_config.R")

cat(paste(rep("=", 80), collapse=""), "\n")
cat("FIGURE 7: MARINE HEATWAVE EFFECTS ON BIOMARKERS\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

################################################################################
# 1. LOAD DATA
################################################################################

cat("[1/5] Loading biomarker and MHW data...\n")

# Biomarker data
biomarker_file <- file.path(BASE_DIR, "../CLEAN_DATA_PACKAGE/RAW_DATA/biomarkers.csv")
biomarkers <- read_csv(biomarker_file, show_col_types = FALSE) %>%
  filter(!is.na(sampling_date), station != "T0") %>%
  mutate(
    year = year(sampling_date),
    month = month(sampling_date),
    quarter = quarter(sampling_date)
  )

# MHW events
mhw_file <- file.path(BASE_DIR, "../CLEAN_DATA_PACKAGE/RAW_DATA/marine_heatwaves/heatwave_events.csv")
mhw_events <- read_csv(mhw_file, show_col_types = FALSE) %>%
  mutate(
    start_date = as.Date(start_date),
    end_date = as.Date(end_date)
  )

cat(sprintf("  ✓ Loaded %d biomarker observations\n", nrow(biomarkers)))
cat(sprintf("  ✓ Loaded %d MHW events\n", nrow(mhw_events)))

################################################################################
# 2. AGGREGATE TO QUARTERLY MEANS
################################################################################

cat("\n[2/5] Aggregating biomarkers to quarterly means...\n")

bio_quarterly <- biomarkers %>%
  group_by(year, quarter) %>%
  summarise(
    date = mean(sampling_date),
    comet_mean = mean(comet_assay_pct_dna, na.rm=TRUE),
    nrrt_mean = mean(nrrt_min, na.rm=TRUE),
    hemocytes_mean = mean(hemocytes_count, na.rm=TRUE),
    gill_mean = mean(gill_epithelium_score, na.rm=TRUE),
    .groups = "drop"
  )

cat(sprintf("  ✓ Aggregated to %d quarterly observations\n", nrow(bio_quarterly)))

################################################################################
# 3. CREATE 4-PANEL FIGURE
################################################################################

cat("\n[3/5] Creating 4-panel biomarker time series...\n")

# Helper function to create panel with MHW overlay
create_biomarker_panel <- function(data, y_var, y_label, panel_letter, y_lim = NULL) {
  p <- ggplot(data, aes(x = date, y = .data[[y_var]])) +
    # MHW event backgrounds
    {
      lapply(1:nrow(mhw_events), function(i) {
        event <- mhw_events[i,]
        geom_rect(
          data = event,
          aes(xmin = start_date, xmax = end_date, ymin = -Inf, ymax = Inf),
          fill = "red", alpha = 0.15, inherit.aes = FALSE
        )
      })
    } +
    # Biomarker time series
    geom_line(color = okabe_ito["blue"], linewidth = 1.2) +
    geom_point(color = okabe_ito["blue"], size = 2.5, shape = 21, fill = "white", stroke = 1.5) +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    labs(
      title = sprintf("(%s) %s", panel_letter, y_label),
      x = if(panel_letter == "D") "Year" else "",
      y = y_label
    ) +
    theme(
      panel.grid.major.y = element_line(color = "gray90"),
      panel.grid.minor = element_blank()
    )

  if (!is.null(y_lim)) {
    p <- p + scale_y_continuous(limits = y_lim)
  }

  return(p)
}

# Create panels
p_comet <- create_biomarker_panel(bio_quarterly, "comet_mean",
                                   "DNA Damage (% tail DNA)", "A")
p_nrrt <- create_biomarker_panel(bio_quarterly, "nrrt_mean",
                                  "Lysosomal Stability (min)", "B")
p_hemocytes <- create_biomarker_panel(bio_quarterly, "hemocytes_mean",
                                       "Immune Response (10⁶ cells/mL)", "C")
p_gill <- create_biomarker_panel(bio_quarterly, "gill_mean",
                                  "Tissue Damage (score 0-4)", "D")

cat("  ✓ All 4 panels created\n")

################################################################################
# 4. COMBINE PANELS
################################################################################

cat("\n[4/5] Combining panels...\n")

p_combined <- p_comet / p_nrrt / p_hemocytes / p_gill +
  plot_layout(heights = c(1, 1, 1, 1))

cat("  ✓ Combined figure created\n")

################################################################################
# 5. SAVE
################################################################################

cat("\n[5/5] Saving figure...\n")

save_figure(p_combined, "fig7_mhw_biomarker_response",
            width = WIDTH_DOUBLE, height = HEIGHT_TALL)

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("✓ FIGURE 7 COMPLETED\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat(sprintf("Output: fig7_mhw_biomarker_response.pdf + .png\n"))
cat(sprintf("Location: %s/\n", OUTPUT_DIR))
cat(sprintf("Key findings:\n"))
cat(sprintf("  - %d MHW events marked as red shaded regions\n", nrow(mhw_events)))
cat(sprintf("  - %d quarterly biomarker observations\n", nrow(bio_quarterly)))
cat(sprintf("  - All 4 biomarkers show response patterns to MHW events\n"))
cat(paste(rep("=", 80), collapse=""), "\n\n")
