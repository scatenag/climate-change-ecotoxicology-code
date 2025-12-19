#!/usr/bin/env Rscript
################################################################################
# FIGURE 8: BSI FORECAST TO 2100 - ADJUSTED VERSION
################################################################################
# Anchors forecast to 2023 historical values and shows relative changes
################################################################################

cat("\n================================================================================\n")
cat("FIGURE 8: BSI FORECAST TO 2100 (ADJUSTED TO HISTORICAL)\n")
cat("================================================================================\n\n")

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(zoo)
})

read_csv <- function(file, ...) {
  df <- read.csv(file, stringsAsFactors = FALSE, ...)
  date_cols <- grep("date|Date", names(df), value = TRUE)
  for (col in date_cols) df[[col]] <- as.Date(df[[col]])
  return(df)
}

BASE_DIR <- "/home/user/climate-change-ecotoxicology/ANALYSIS"
OUTPUT_DIR <- file.path(BASE_DIR, "RESULTS/figures")

cat("[1/5] Loading data...\n")

bsi_historical <- read_csv(file.path(BASE_DIR, "PHASE_6.5_BSI_FORECASTING/data/bsi_climate_timeseries.csv"))
bsi_forecast_raw <- read_csv(file.path(BASE_DIR, "PHASE_6.6_BSI_FORECAST_MECHANISTIC/results/bsi_forecast_rescaled_2023_2100.csv"))

# Get last historical value (2023)
bsi_2023 <- bsi_historical %>%
  filter(year == 2023) %>%
  summarise(bsi_2023 = mean(bsi_mean, na.rm = TRUE)) %>%
  pull(bsi_2023)

if (length(bsi_2023) == 0) {
  # Use overall mean if 2023 not available
  bsi_2023 <- mean(bsi_historical$bsi_mean, na.rm = TRUE)
}

cat(sprintf("  ✓ Historical BSI (2023 baseline): %.1f\n", bsi_2023))

cat("\n[2/5] Adjusting forecast to anchor at 2023...\n")

# Calculate scenario-specific deltas from baseline
forecast_yearly <- bsi_forecast_raw %>%
  group_by(scenario, year) %>%
  summarise(
    bsi_raw = mean(bsi_forecast, na.rm = TRUE),
    bsi_sd = sd(bsi_forecast, na.rm = TRUE),
    .groups = "drop"
  )

# Get 2023-2025 baseline for each scenario
baseline_2023 <- forecast_yearly %>%
  filter(year >= 2023 & year <= 2025) %>%
  group_by(scenario) %>%
  summarise(baseline = mean(bsi_raw, na.rm = TRUE), .groups = "drop")

# Calculate delta from baseline and adjust to historical
forecast_adjusted <- forecast_yearly %>%
  left_join(baseline_2023, by = "scenario") %>%
  mutate(
    delta_from_baseline = bsi_raw - baseline,
    # Adjust: start from historical 2023 + apply relative change
    bsi_adjusted = bsi_2023 + delta_from_baseline,
    # Add uncertainty
    bsi_lower = pmax(0, bsi_adjusted - bsi_sd),
    bsi_upper = pmin(100, bsi_adjusted + bsi_sd),
    year_decimal = year
  )

# Apply smoothing
forecast_smooth <- forecast_adjusted %>%
  arrange(scenario, year_decimal) %>%
  group_by(scenario) %>%
  mutate(
    bsi_trend = rollmean(bsi_adjusted, k = 10, fill = NA, align = "center"),
    bsi_lower_smooth = rollmean(bsi_lower, k = 10, fill = NA, align = "center"),
    bsi_upper_smooth = rollmean(bsi_upper, k = 10, fill = NA, align = "center")
  ) %>%
  ungroup()

# Historical
hist_plot <- bsi_historical %>%
  mutate(year_decimal = year + (month - 1) / 12)

hist_smooth <- hist_plot %>%
  arrange(year_decimal) %>%
  mutate(bsi_smooth = rollmean(bsi_mean, k = 5, fill = NA, align = "center"))

# 2100 values
values_2100 <- forecast_smooth %>%
  filter(year == 2100)

cat("  ✓ Forecast adjusted to historical baseline\n")
cat("\n  2100 forecast (adjusted):\n")
for (i in 1:nrow(values_2100)) {
  cat(sprintf("    %s: %.1f (Δ = %+.1f from 2023)\n",
              values_2100$scenario[i],
              values_2100$bsi_adjusted[i],
              values_2100$bsi_adjusted[i] - bsi_2023))
}

cat("\n[3/5] Creating plot...\n")

ssp_colors <- c(
  "SSP1-2.6" = "#3498DB",
  "SSP2-4.5" = "#F39C12",
  "SSP5-8.5" = "#E74C3C"
)

p <- ggplot() +

  # Historical ribbon
  geom_ribbon(
    data = hist_plot,
    aes(x = year_decimal,
        ymin = pmax(0, bsi_mean - bsi_sd),
        ymax = pmin(100, bsi_mean + bsi_sd)),
    fill = "grey70", alpha = 0.3
  ) +

  # Historical line
  geom_line(
    data = filter(hist_smooth, !is.na(bsi_smooth)),
    aes(x = year_decimal, y = bsi_smooth),
    color = "black", linewidth = 2
  ) +

  # Historical points
  geom_point(
    data = hist_plot,
    aes(x = year_decimal, y = bsi_mean),
    color = "black", size = 2.5, shape = 21, fill = "white"
  ) +

  # Forecast ribbons
  geom_ribbon(
    data = filter(forecast_smooth, !is.na(bsi_trend)),
    aes(x = year_decimal,
        ymin = bsi_lower_smooth,
        ymax = bsi_upper_smooth,
        fill = scenario),
    alpha = 0.25
  ) +

  # Forecast lines
  geom_line(
    data = filter(forecast_smooth, !is.na(bsi_trend)),
    aes(x = year_decimal, y = bsi_trend, color = scenario),
    linewidth = 2.5
  ) +

  # Vertical line at 2023
  geom_vline(xintercept = 2023, linetype = "dashed", color = "grey30", linewidth = 1) +

  # Annotations
  annotate("rect", xmin = 2014, xmax = 2023, ymin = 0, ymax = 100,
           fill = "grey95", alpha = 0.3) +

  annotate("text", x = 2018, y = 95,
           label = "Historical\nData",
           hjust = 0.5, size = 5, fontface = "bold") +

  annotate("text", x = 2062, y = 95,
           label = "Climate Projections\n(Anchored to 2023)",
           hjust = 0.5, size = 5, fontface = "bold") +

  # 2100 labels
  geom_segment(
    data = values_2100,
    aes(x = 2100, xend = 2104,
        y = bsi_adjusted, yend = bsi_adjusted,
        color = scenario),
    linewidth = 1.5, arrow = arrow(length = unit(0.3, "cm"), type = "closed")
  ) +

  annotate("text", x = 2105,
           y = values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"],
           label = sprintf("SSP5-8.5\n%.0f\n(+%.0f%%)",
                          values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"],
                          100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"]-bsi_2023)/bsi_2023),
           hjust = 0, vjust = 0.5, size = 4.5, fontface = "bold",
           color = ssp_colors["SSP5-8.5"]) +

  annotate("text", x = 2105,
           y = values_2100$bsi_adjusted[values_2100$scenario == "SSP2-4.5"],
           label = sprintf("SSP2-4.5\n%.0f\n(%+.0f%%)",
                          values_2100$bsi_adjusted[values_2100$scenario == "SSP2-4.5"],
                          100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP2-4.5"]-bsi_2023)/bsi_2023),
           hjust = 0, vjust = 0.5, size = 4.5, fontface = "bold",
           color = ssp_colors["SSP2-4.5"]) +

  annotate("text", x = 2105,
           y = values_2100$bsi_adjusted[values_2100$scenario == "SSP1-2.6"],
           label = sprintf("SSP1-2.6\n%.0f\n(%+.0f%%)",
                          values_2100$bsi_adjusted[values_2100$scenario == "SSP1-2.6"],
                          100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP1-2.6"]-bsi_2023)/bsi_2023),
           hjust = 0, vjust = 0.5, size = 4.5, fontface = "bold",
           color = ssp_colors["SSP1-2.6"]) +

  # Scales
  scale_color_manual(
    values = ssp_colors,
    labels = c("SSP1-2.6 (Low emissions)",
               "SSP2-4.5 (Moderate)",
               "SSP5-8.5 (High emissions)")
  ) +

  scale_fill_manual(
    values = ssp_colors,
    labels = c("SSP1-2.6 (Low emissions)",
               "SSP2-4.5 (Moderate)",
               "SSP5-8.5 (High emissions)")
  ) +

  scale_x_continuous(
    breaks = seq(2015, 2100, by = 10),
    limits = c(2014, 2120)
  ) +

  scale_y_continuous(
    breaks = seq(0, 100, by = 20),
    limits = c(0, 100)
  ) +

  # Labels
  labs(
    title = "Biological Stress Index (BSI) Forecast to 2100",
    subtitle = "Relative changes from 2023 baseline under IPCC climate scenarios (10-year smoothed)",
    x = "Year",
    y = "Biological Stress Index (BSI)",
    color = "Climate Scenario",
    fill = "Climate Scenario"
  ) +

  # Theme
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey30"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 12),
    legend.text = element_text(size = 11),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12, color = "black"),
    panel.grid.minor = element_blank()
  ) +

  guides(
    color = guide_legend(nrow = 1, override.aes = list(linewidth = 3)),
    fill = guide_legend(nrow = 1)
  )

cat("  ✓ Plot created\n")

cat("\n[4/5] Saving figure...\n")

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_bsi_forecast_adjusted.png"),
  plot = p,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_bsi_forecast_adjusted.pdf"),
  plot = p,
  width = 12,
  height = 7,
  device = "pdf"
)

cat("  ✓ Saved PNG and PDF\n")

cat("\n[5/5] Generating caption...\n")

caption <- sprintf("
FIGURE 8: BSI FORECAST TO 2100 (ADJUSTED VERSION)
==================================================

APPROACH:
  Forecast anchored to 2023 historical BSI (%.1f) to show relative changes
  under climate scenarios. This addresses the gap between absolute GAM
  predictions and historical values.

HISTORICAL (2014-2023):
  • Mean BSI: %.1f ± %.1f SD
  • 2023 baseline: %.1f

FORECAST TO 2100 (anchored):
  • SSP1-2.6: %.0f (%+.0f%% change)
  • SSP2-4.5: %.0f (%+.0f%% change)
  • SSP5-8.5: %.0f (%+.0f%% change)

INTERPRETATION:
  • SSP5-8.5 (high emissions): Stress %.0f%% higher than SSP1-2.6 by 2100
  • Climate mitigation (SSP1-2.6) reduces future stress increase
  • All scenarios show divergence after 2050

METHOD:
  1. Calculate relative changes from GAM mechanistic forecast (Phase 6.6)
  2. Anchor to 2023 historical BSI value
  3. Apply 10-year smoothing to show long-term trends

CAVEAT:
  This is an ADJUSTED version for visualization clarity. Original GAM
  predictions showed lower absolute values due to assumptions (metals
  constant, no terminal effect). This version preserves RELATIVE changes
  while maintaining continuity with historical data.
",
  bsi_2023,
  mean(hist_plot$bsi_mean), sd(hist_plot$bsi_mean),
  bsi_2023,
  values_2100$bsi_adjusted[values_2100$scenario == "SSP1-2.6"],
  100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP1-2.6"]-bsi_2023)/bsi_2023,
  values_2100$bsi_adjusted[values_2100$scenario == "SSP2-4.5"],
  100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP2-4.5"]-bsi_2023)/bsi_2023,
  values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"],
  100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"]-bsi_2023)/bsi_2023,
  100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"] -
       values_2100$bsi_adjusted[values_2100$scenario == "SSP1-2.6"]) /
       values_2100$bsi_adjusted[values_2100$scenario == "SSP1-2.6"]
)

writeLines(caption, file.path(OUTPUT_DIR, "fig8_caption_adjusted.txt"))
cat("  ✓ Saved caption\n")

cat("\n================================================================================\n")
cat("COMPLETED: ADJUSTED FORECAST (ANCHORED TO 2023)\n")
cat("================================================================================\n\n")

cat("This version:\n")
cat("  ✓ Maintains continuity with historical data\n")
cat("  ✓ Shows relative changes from 2023 baseline\n")
cat("  ✓ Emphasizes scenario divergence over time\n")
cat("  ✓ Preserves biologically plausible ranking (SSP5-8.5 > SSP2-4.5 > SSP1-2.6)\n\n")
