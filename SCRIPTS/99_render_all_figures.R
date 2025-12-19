#!/usr/bin/env Rscript
################################################################################
# MASTER SCRIPT: Render All Publication Figures
################################################################################
#
# Author: Claude Code
# Date: 2025-11-11
# Description: Sequential execution of all publication figure scripts
#              with error handling and timing statistics
#
# Usage: Rscript 99_render_all_figures.R
#
################################################################################

cat("\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("MASTER SCRIPT: RENDERING ALL PUBLICATION FIGURES\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Record start time
start_time <- Sys.time()

# Define all figure scripts in execution order
figure_scripts <- c(
  "01_fig1_climate_trends.R",
  "02_fig2_biomarker_metal_correlations.R",
  "04_fig3_variance_partitioning_PHASE5.5.R",  # ⭐ UPDATED: Phase 5.5 Multi-Method Convergence
  "05_fig4_scenario_projections.R",
  "06_fig6_cci_bsi_time_series.R",
  "07_fig7_mhw_delay_effects.R"
)

# Figure names for reporting
figure_names <- c(
  "Figure 1: Climate Trends + Marine Heatwaves",
  "Figure 2: Biomarker-Metal Correlations Heatmap",
  "Figure 3: Multi-Factor Variance Partitioning (Phase 5.5 Convergence)",  # ⭐ KEY RESULT
  "Figure 4: IPCC Climate Scenario Projections (2014-2100)",
  "Figure 6: CCI-BSI Time Series with Marine Heatwaves",
  "Figure 7: Marine Heatwave Delay Effects on Metals"
)

# Results tracking
results <- data.frame(
  figure = figure_names,
  script = figure_scripts,
  status = rep("pending", length(figure_scripts)),
  time_sec = rep(NA, length(figure_scripts)),
  stringsAsFactors = FALSE
)

# Execute each script
for(i in seq_along(figure_scripts)) {

  cat("\n")
  cat(paste(rep("-", 80), collapse=""), "\n")
  cat(sprintf("[%d/%d] EXECUTING: %s\n", i, length(figure_scripts), figure_names[i]))
  cat(paste(rep("-", 80), collapse=""), "\n\n")

  script_start <- Sys.time()

  # Try to execute script
  tryCatch({
    source(figure_scripts[i])
    results$status[i] <- "SUCCESS"
    script_end <- Sys.time()
    results$time_sec[i] <- as.numeric(difftime(script_end, script_start, units = "secs"))

    cat("\n")
    cat(sprintf("✓ %s completed in %.1f seconds\n",
                figure_names[i], results$time_sec[i]))

  }, error = function(e) {
    results$status[i] <- "FAILED"
    script_end <- Sys.time()
    results$time_sec[i] <- as.numeric(difftime(script_end, script_start, units = "secs"))

    cat("\n")
    cat(sprintf("✗ %s FAILED after %.1f seconds\n",
                figure_names[i], results$time_sec[i]))
    cat(sprintf("  Error message: %s\n", e$message))
  })
}

# Record end time
end_time <- Sys.time()
total_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

################################################################################
# FINAL SUMMARY
################################################################################

cat("\n\n")
cat(paste(rep("=", 80), collapse=""), "\n")
cat("FINAL SUMMARY\n")
cat(paste(rep("=", 80), collapse=""), "\n\n")

# Count successes and failures
n_success <- sum(results$status == "SUCCESS")
n_failed <- sum(results$status == "FAILED")

cat("EXECUTION RESULTS:\n\n")

# Print status for each figure
for(i in 1:nrow(results)) {
  status_symbol <- ifelse(results$status[i] == "SUCCESS", "✓", "✗")
  cat(sprintf("  %s [%s] %s (%.1fs)\n",
              status_symbol,
              results$status[i],
              results$figure[i],
              results$time_sec[i]))
}

cat("\n")
cat(sprintf("Total figures: %d\n", nrow(results)))
cat(sprintf("  - Successful: %d\n", n_success))
cat(sprintf("  - Failed: %d\n", n_failed))
cat(sprintf("\nTotal execution time: %.1f seconds (%.1f minutes)\n",
            total_time, total_time / 60))

# Output directory info
output_dir <- file.path(getwd(), "figures")
cat(sprintf("\nOutput directory: %s\n", output_dir))

if(n_success > 0) {
  cat("\nGenerated files:\n")
  pdf_files <- list.files(output_dir, pattern = "\\.pdf$", full.names = FALSE)
  png_files <- list.files(output_dir, pattern = "\\.png$", full.names = FALSE)
  txt_files <- list.files(output_dir, pattern = "caption.*\\.txt$", full.names = FALSE)

  cat(sprintf("  - %d PDF files\n", length(pdf_files)))
  cat(sprintf("  - %d PNG files\n", length(png_files)))
  cat(sprintf("  - %d caption files\n", length(txt_files)))
}

# Exit status
if(n_failed == 0) {
  cat("\n")
  cat(paste(rep("=", 80), collapse=""), "\n")
  cat("✓ ALL FIGURES RENDERED SUCCESSFULLY\n")
  cat(paste(rep("=", 80), collapse=""), "\n\n")
  quit(save = "no", status = 0)
} else {
  cat("\n")
  cat(paste(rep("=", 80), collapse=""), "\n")
  cat(sprintf("✗ %d FIGURE(S) FAILED - CHECK ERRORS ABOVE\n", n_failed))
  cat(paste(rep("=", 80), collapse=""), "\n\n")
  quit(save = "no", status = 1)
}
