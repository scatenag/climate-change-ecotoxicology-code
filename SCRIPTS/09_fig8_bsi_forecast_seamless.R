#!/usr/bin/env Rscript
################################################################################
# FIGURE 8: BSI FORECAST TO 2100 - SEAMLESS VERSION (NO GAP)
################################################################################
# Eliminates visual gap between historical and forecast data
################################################################################

cat("\n================================================================================\n")
cat("FIGURE 8: BSI FORECAST TO 2100 (SEAMLESS - NO GAP)\n")
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

cat("[1/6] Loading data...\n")

bsi_historical <- read_csv(file.path(BASE_DIR, "PHASE_6.5_BSI_FORECASTING/data/bsi_climate_timeseries.csv"))
bsi_forecast_raw <- read_csv(file.path(BASE_DIR, "PHASE_6.6_BSI_FORECAST_MECHANISTIC/results/bsi_forecast_rescaled_2023_2100.csv"))

# Get 2023 baseline (last historical value)
bsi_2023 <- bsi_historical %>%
  filter(year == 2023) %>%
  summarise(bsi_2023 = mean(bsi_mean, na.rm = TRUE)) %>%
  pull(bsi_2023)

cat(sprintf("  ✓ Historical BSI (2023 baseline): %.1f\n", bsi_2023))

cat("\n[2/6] Preparing historical data...\n")

hist_plot <- bsi_historical %>%
  mutate(year_decimal = year + (month - 1) / 12) %>%
  arrange(year_decimal)

# Apply smoothing to historical
hist_smooth <- hist_plot %>%
  mutate(bsi_smooth = rollmean(bsi_mean, k = 5, fill = NA, align = "center"))

cat(sprintf("  ✓ Historical: %d campaigns (2014-2023)\n", nrow(hist_plot)))

cat("\n[3/6] Adjusting forecast to anchor at 2023...\n")

# Aggregate forecast by year and scenario
forecast_yearly <- bsi_forecast_raw %>%
  group_by(scenario, year) %>%
  summarise(
    bsi_raw = mean(bsi_forecast, na.rm = TRUE),
    bsi_sd = sd(bsi_forecast, na.rm = TRUE),
    .groups = "drop"
  )

# Get 2023-2025 baseline for each scenario from raw forecast
baseline_2023 <- forecast_yearly %>%
  filter(year >= 2023 & year <= 2025) %>%
  group_by(scenario) %>%
  summarise(baseline = mean(bsi_raw, na.rm = TRUE), .groups = "drop")

# Calculate delta from baseline and adjust to historical
forecast_adjusted <- forecast_yearly %>%
  left_join(baseline_2023, by = "scenario") %>%
  mutate(
    delta_from_baseline = bsi_raw - baseline,
    bsi_adjusted = bsi_2023 + delta_from_baseline,
    bsi_lower = pmax(0, bsi_adjusted - bsi_sd),
    bsi_upper = pmin(100, bsi_adjusted + bsi_sd),
    year_decimal = year
  )

# **KEY FIX**: Add explicit transition point at 2023.5 (mid-2023)
# This bridges the last historical data point with forecast
transition_points <- forecast_adjusted %>%
  filter(year == 2023) %>%
  mutate(year_decimal = 2023.5)  # Explicit bridge point

# Combine forecast with transition
forecast_with_bridge <- bind_rows(
  transition_points,
  filter(forecast_adjusted, year >= 2024)
)

# Apply smoothing with adaptive window
forecast_smooth <- forecast_with_bridge %>%
  arrange(scenario, year_decimal) %>%
  group_by(scenario) %>%
  mutate(
    # Use smaller window for early years to preserve transition
    n_points = n(),
    window_size = ifelse(year_decimal < 2030, 5, 10),
    bsi_trend = rollapply(bsi_adjusted, width = window_size,
                          FUN = mean, fill = NA, align = "center", partial = TRUE),
    bsi_lower_smooth = rollapply(bsi_lower, width = window_size,
                                  FUN = mean, fill = NA, align = "center", partial = TRUE),
    bsi_upper_smooth = rollapply(bsi_upper, width = window_size,
                                  FUN = mean, fill = NA, align = "center", partial = TRUE)
  ) %>%
  ungroup()

# 2100 values
values_2100 <- forecast_smooth %>%
  filter(year == 2100)

cat("  ✓ Forecast adjusted and bridged to 2023\n")
cat("\n  2100 forecast (adjusted):\n")
for (i in 1:nrow(values_2100)) {
  pct_change <- 100 * (values_2100$bsi_adjusted[i] - bsi_2023) / bsi_2023
  cat(sprintf("    %s: %.1f (%+.0f%% from 2023)\n",
              values_2100$scenario[i],
              values_2100$bsi_adjusted[i],
              pct_change))
}

cat("\n[4/6] Creating seamless plot...\n")

ssp_colors <- c(
  "SSP1-2.6" = "#3498DB",
  "SSP2-4.5" = "#F39C12",
  "SSP5-8.5" = "#E74C3C"
)

p <- ggplot() +

  # Background shading
  annotate("rect", xmin = 2014, xmax = 2023, ymin = 0, ymax = 100,
           fill = "grey95", alpha = 0.5) +

  # Historical ribbon (uncertainty)
  geom_ribbon(
    data = hist_plot,
    aes(x = year_decimal,
        ymin = pmax(0, bsi_mean - bsi_sd),
        ymax = pmin(100, bsi_mean + bsi_sd)),
    fill = "grey70", alpha = 0.3
  ) +

  # Historical smooth line
  geom_line(
    data = filter(hist_smooth, !is.na(bsi_smooth)),
    aes(x = year_decimal, y = bsi_smooth),
    color = "black", linewidth = 2.5
  ) +

  # Historical points
  geom_point(
    data = hist_plot,
    aes(x = year_decimal, y = bsi_mean),
    color = "black", size = 2.5, shape = 21, fill = "white", stroke = 1
  ) +

  # **TRANSITION CONNECTOR**: Explicit line from last historical to first forecast
  geom_segment(
    data = data.frame(
      x = max(hist_plot$year_decimal),
      xend = 2023.5,
      y = bsi_2023,
      yend = bsi_2023
    ),
    aes(x = x, xend = xend, y = y, yend = yend),
    color = "grey50", linewidth = 1.5, linetype = "dashed"
  ) +

  # Forecast ribbons (uncertainty)
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
  geom_vline(xintercept = 2023, linetype = "dashed", color = "grey30", linewidth = 0.8) +

  # Annotations
  annotate("text", x = 2018.5, y = 95,
           label = "Historical\nData\n(2014-2023)",
           hjust = 0.5, size = 5, fontface = "bold", color = "grey20") +

  annotate("text", x = 2062, y = 95,
           label = "Climate Scenario Projections",
           hjust = 0.5, size = 5.5, fontface = "bold", color = "grey20") +

  # 2100 labels with arrows
  geom_segment(
    data = values_2100,
    aes(x = 2100, xend = 2105,
        y = bsi_adjusted, yend = bsi_adjusted,
        color = scenario),
    linewidth = 1.5, arrow = arrow(length = unit(0.3, "cm"), type = "closed")
  ) +

  annotate("text", x = 2106,
           y = values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"],
           label = sprintf("SSP5-8.5\nBSI = %.0f\n(+%.0f%%)",
                          values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"],
                          100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP5-8.5"]-bsi_2023)/bsi_2023),
           hjust = 0, vjust = 0.5, size = 4.5, fontface = "bold",
           color = ssp_colors["SSP5-8.5"]) +

  annotate("text", x = 2106,
           y = values_2100$bsi_adjusted[values_2100$scenario == "SSP2-4.5"],
           label = sprintf("SSP2-4.5\nBSI = %.0f\n(%+.0f%%)",
                          values_2100$bsi_adjusted[values_2100$scenario == "SSP2-4.5"],
                          100*(values_2100$bsi_adjusted[values_2100$scenario == "SSP2-4.5"]-bsi_2023)/bsi_2023),
           hjust = 0, vjust = 0.5, size = 4.5, fontface = "bold",
           color = ssp_colors["SSP2-4.5"]) +

  annotate("text", x = 2106,
           y = values_2100$bsi_adjusted[values_2100$scenario == "SSP1-2.6"],
           label = sprintf("SSP1-2.6\nBSI = %.0f\n(%+.0f%%)",
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
    subtitle = "Mechanistic GAM projections under IPCC climate scenarios (seamless historical-forecast transition)",
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
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90")
  ) +

  guides(
    color = guide_legend(nrow = 1, override.aes = list(linewidth = 3)),
    fill = guide_legend(nrow = 1)
  )

cat("  ✓ Seamless plot created\n")

cat("\n[5/6] Saving figure...\n")

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_bsi_forecast_seamless.png"),
  plot = p,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_bsi_forecast_seamless.pdf"),
  plot = p,
  width = 12,
  height = 7,
  device = "pdf"
)

cat("  ✓ Saved PNG and PDF (seamless version)\n")

cat("\n[6/6] Summary statistics...\n")

cat("\nHistorical (2014-2023):\n")
cat(sprintf("  Mean BSI: %.1f ± %.1f SD\n", mean(hist_plot$bsi_mean), sd(hist_plot$bsi_mean)))
cat(sprintf("  2023 baseline: %.1f\n", bsi_2023))

cat("\nForecast 2100:\n")
for (i in 1:nrow(values_2100)) {
  cat(sprintf("  %s: %.1f (Δ = %+.1f from 2023)\n",
              values_2100$scenario[i],
              values_2100$bsi_adjusted[i],
              values_2100$bsi_adjusted[i] - bsi_2023))
}

cat("\n================================================================================\n")
cat("COMPLETED: SEAMLESS FORECAST (NO GAP)\n")
cat("================================================================================\n\n")

cat("KEY FIX:\n")
cat("  ✓ Added explicit transition point at 2023.5\n")
cat("  ✓ Dashed connector from last historical to forecast\n")
cat("  ✓ Adaptive smoothing window (5-year near 2023, 10-year after 2030)\n")
cat("  ✓ Partial smoothing enabled to avoid edge NAs\n\n")
