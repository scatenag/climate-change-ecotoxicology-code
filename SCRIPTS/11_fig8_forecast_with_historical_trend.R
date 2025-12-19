#!/usr/bin/env Rscript
################################################################################
# FIGURE 8: BSI FORECAST WITH HISTORICAL TREND PROJECTION
################################################################################
# Incorporates observed historical trend (2014-2023) into future projections
# Ensures all scenarios start from current trajectory, not arbitrary baseline
################################################################################

cat("\n================================================================================\n")
cat("FIGURE 8: BSI FORECAST WITH HISTORICAL TREND INCORPORATED\n")
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

cat("[1/8] Loading historical data...\n")

bsi_historical <- read_csv(file.path(BASE_DIR, "PHASE_6.5_BSI_FORECASTING/data/bsi_climate_timeseries.csv"))

hist_plot <- bsi_historical %>%
  mutate(year_decimal = year + (month - 1) / 12) %>%
  arrange(year_decimal)

cat(sprintf("  ✓ Historical: %d campaigns (2014-2023)\n", nrow(hist_plot)))

cat("\n[2/8] Calculating historical trend (linear regression)...\n")

# Fit linear model to historical data
trend_model <- lm(bsi_mean ~ year_decimal, data = hist_plot)
trend_summary <- summary(trend_model)

# Extract trend parameters
intercept <- coef(trend_model)[1]
slope <- coef(trend_model)[2]
r_squared <- trend_summary$r.squared
p_value <- trend_summary$coefficients[2, 4]

cat(sprintf("  HISTORICAL TREND (2014-2023):\n"))
cat(sprintf("    Slope: %+.3f BSI units/year\n", slope))
cat(sprintf("    R²: %.3f\n", r_squared))
cat(sprintf("    p-value: %.4f %s\n", p_value, ifelse(p_value < 0.05, "***", "")))
cat(sprintf("    Interpretation: BSI %s by %.2f units per decade\n",
            ifelse(slope > 0, "INCREASING", "DECREASING"),
            abs(slope * 10)))

# Calculate 2023 baseline from trend
bsi_2023_trend <- intercept + slope * 2023

cat(sprintf("\n  2023 baseline (from trend): %.1f\n", bsi_2023_trend))
cat(sprintf("  2023 observed mean: %.1f\n", mean(hist_plot[hist_plot$year == 2023, ]$bsi_mean)))

cat("\n[3/8] Projecting historical trend to future...\n")

# Project trend to 2050 and 2100
years_future <- seq(2024, 2100, by = 1)
trend_projection <- data.frame(
  year = years_future,
  year_decimal = years_future,
  bsi_trend = intercept + slope * years_future
) %>%
  mutate(
    # Ensure BSI stays within 0-100
    bsi_trend = pmax(0, pmin(100, bsi_trend))
  )

cat(sprintf("  Trend projection:\n"))
cat(sprintf("    2030: %.1f\n", trend_projection$bsi_trend[trend_projection$year == 2030]))
cat(sprintf("    2050: %.1f\n", trend_projection$bsi_trend[trend_projection$year == 2050]))
cat(sprintf("    2100: %.1f\n", trend_projection$bsi_trend[trend_projection$year == 2100]))

cat("\n[4/8] Loading climate forecast data...\n")

bsi_forecast_raw <- read_csv(file.path(BASE_DIR, "PHASE_6.6_BSI_FORECAST_MECHANISTIC/results/bsi_forecast_rescaled_2023_2100.csv"))

# Aggregate to yearly
forecast_yearly <- bsi_forecast_raw %>%
  group_by(scenario, year) %>%
  summarise(
    bsi_climate_only = mean(bsi_forecast, na.rm = TRUE),
    bsi_sd = sd(bsi_forecast, na.rm = TRUE),
    .groups = "drop"
  )

cat("  ✓ Climate forecast loaded (3 scenarios)\n")

cat("\n[5/8] Calculating climate effect DELTA (relative to 2023)...\n")

# Get 2023-2025 climate baseline for each scenario
climate_baseline_2023 <- forecast_yearly %>%
  filter(year >= 2023 & year <= 2025) %>%
  group_by(scenario) %>%
  summarise(baseline_2023 = mean(bsi_climate_only, na.rm = TRUE), .groups = "drop")

# Calculate climate DELTA = change from scenario's own 2023 value
forecast_climate_delta <- forecast_yearly %>%
  left_join(climate_baseline_2023, by = "scenario") %>%
  mutate(
    # Climate delta: how much does climate change from 2023 baseline?
    climate_delta = bsi_climate_only - baseline_2023
  )

cat("  ✓ Climate deltas calculated\n")

cat("\n[6/8] Combining historical trend + climate effect...\n")

# COMBINED FORECAST:
# BSI_future = Historical_Trend_Projection + Climate_Delta
forecast_combined <- forecast_climate_delta %>%
  left_join(trend_projection, by = "year") %>%
  mutate(
    # Final forecast = inertial trend + climate modification
    bsi_forecast = bsi_trend + climate_delta,

    # Bounds
    bsi_lower = pmax(0, bsi_forecast - bsi_sd),
    bsi_upper = pmin(100, bsi_forecast + bsi_sd)
  )

# Smoothing
forecast_smooth <- forecast_combined %>%
  arrange(scenario, year) %>%
  group_by(scenario) %>%
  mutate(
    bsi_smooth = rollmean(bsi_forecast, k = 10, fill = NA, align = "center", partial = TRUE),
    bsi_lower_smooth = rollmean(bsi_lower, k = 10, fill = NA, align = "center", partial = TRUE),
    bsi_upper_smooth = rollmean(bsi_upper, k = 10, fill = NA, align = "center", partial = TRUE),
    trend_smooth = rollmean(bsi_trend, k = 10, fill = NA, align = "center", partial = TRUE)
  ) %>%
  ungroup()

# Get values at key years
values_2050 <- forecast_smooth %>% filter(year == 2050)
values_2100 <- forecast_smooth %>% filter(year == 2100)

cat("\n  COMBINED FORECAST (Trend + Climate):\n")
cat("\n  2050:\n")
for (i in 1:nrow(values_2050)) {
  cat(sprintf("    %s: %.1f (Trend: %.1f + Climate: %+.1f)\n",
              values_2050$scenario[i],
              values_2050$bsi_forecast[i],
              values_2050$bsi_trend[i],
              values_2050$climate_delta[i]))
}

cat("\n  2100:\n")
for (i in 1:nrow(values_2100)) {
  cat(sprintf("    %s: %.1f (Trend: %.1f + Climate: %+.1f)\n",
              values_2100$scenario[i],
              values_2100$bsi_forecast[i],
              values_2100$bsi_trend[i],
              values_2100$climate_delta[i]))
}

cat("\n[7/8] Creating plot...\n")

ssp_colors <- c(
  "SSP1-2.6" = "#3498DB",
  "SSP2-4.5" = "#F39C12",
  "SSP5-8.5" = "#E74C3C"
)

# Historical smoothed
hist_smooth <- hist_plot %>%
  mutate(bsi_smooth = rollmean(bsi_mean, k = 5, fill = NA, align = "center"))

# Add trend line to historical plot
hist_with_trend <- hist_plot %>%
  mutate(bsi_trend_fit = intercept + slope * year_decimal)

p <- ggplot() +

  # Background shading
  annotate("rect", xmin = 2014, xmax = 2023, ymin = 0, ymax = 100,
           fill = "grey95", alpha = 0.5) +

  # Historical uncertainty ribbon
  geom_ribbon(
    data = hist_plot,
    aes(x = year_decimal,
        ymin = pmax(0, bsi_mean - bsi_sd),
        ymax = pmin(100, bsi_mean + bsi_sd)),
    fill = "grey70", alpha = 0.3
  ) +

  # Historical data points
  geom_point(
    data = hist_plot,
    aes(x = year_decimal, y = bsi_mean),
    color = "black", size = 2.5, shape = 21, fill = "white", stroke = 1
  ) +

  # Historical smooth line
  geom_line(
    data = filter(hist_smooth, !is.na(bsi_smooth)),
    aes(x = year_decimal, y = bsi_smooth),
    color = "black", linewidth = 2.5
  ) +

  # Historical TREND LINE (dashed, extended into forecast)
  geom_line(
    data = hist_with_trend,
    aes(x = year_decimal, y = bsi_trend_fit),
    color = "black", linewidth = 1.2, linetype = "dashed", alpha = 0.7
  ) +

  # INERTIAL TREND projected to future (baseline if no climate change)
  geom_line(
    data = filter(forecast_smooth, !is.na(trend_smooth)),
    aes(x = year_decimal, y = trend_smooth),
    color = "grey30", linewidth = 1.5, linetype = "dashed", alpha = 0.8
  ) +

  # Forecast uncertainty ribbons
  geom_ribbon(
    data = filter(forecast_smooth, !is.na(bsi_smooth)),
    aes(x = year_decimal,
        ymin = bsi_lower_smooth,
        ymax = bsi_upper_smooth,
        fill = scenario),
    alpha = 0.25
  ) +

  # Forecast lines (TREND + CLIMATE)
  geom_line(
    data = filter(forecast_smooth, !is.na(bsi_smooth)),
    aes(x = year_decimal, y = bsi_smooth, color = scenario),
    linewidth = 2.5
  ) +

  # Vertical line at 2023
  geom_vline(xintercept = 2023, linetype = "dashed", color = "grey30", linewidth = 0.8) +

  # Annotations
  annotate("text", x = 2018.5, y = 95,
           label = "Historical\nData\n(2014-2023)",
           hjust = 0.5, size = 4.5, fontface = "bold", color = "grey20") +

  annotate("text", x = 2062, y = 95,
           label = "Forecast (Historical Trend + Climate Scenarios)",
           hjust = 0.5, size = 4.5, fontface = "bold", color = "grey20") +

  # Trend line annotation
  annotate("text", x = 2040, y = trend_projection$bsi_trend[trend_projection$year == 2040] + 5,
           label = sprintf("Inertial trend\n(%+.2f/yr)", slope),
           hjust = 0.5, size = 3.5, color = "grey30", fontface = "italic") +

  # 2050 labels
  geom_segment(
    data = values_2050,
    aes(x = 2050, xend = 2053,
        y = bsi_forecast, yend = bsi_forecast,
        color = scenario),
    linewidth = 1.2, arrow = arrow(length = unit(0.25, "cm"), type = "closed")
  ) +

  annotate("text", x = 2054,
           y = values_2050$bsi_forecast[values_2050$scenario == "SSP5-8.5"],
           label = sprintf("SSP5-8.5\n2050: %.0f",
                          values_2050$bsi_forecast[values_2050$scenario == "SSP5-8.5"]),
           hjust = 0, vjust = 0.5, size = 3.5, fontface = "bold",
           color = ssp_colors["SSP5-8.5"]) +

  annotate("text", x = 2054,
           y = values_2050$bsi_forecast[values_2050$scenario == "SSP2-4.5"],
           label = sprintf("SSP2-4.5\n2050: %.0f",
                          values_2050$bsi_forecast[values_2050$scenario == "SSP2-4.5"]),
           hjust = 0, vjust = 0.5, size = 3.5, fontface = "bold",
           color = ssp_colors["SSP2-4.5"]) +

  annotate("text", x = 2054,
           y = values_2050$bsi_forecast[values_2050$scenario == "SSP1-2.6"],
           label = sprintf("SSP1-2.6\n2050: %.0f",
                          values_2050$bsi_forecast[values_2050$scenario == "SSP1-2.6"]),
           hjust = 0, vjust = 0.5, size = 3.5, fontface = "bold",
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
    breaks = seq(2015, 2050, by = 5),
    limits = c(2014, 2060)
  ) +

  scale_y_continuous(
    breaks = seq(0, 100, by = 20),
    limits = c(0, 100)
  ) +

  # Labels
  labs(
    title = "BSI Forecast Incorporating Historical Trend (2014-2050)",
    subtitle = sprintf("Historical trend: %+.2f BSI/year (p=%.3f) | Dashed line = inertial trajectory without climate change",
                      slope, p_value),
    x = "Year",
    y = "Biological Stress Index (BSI)",
    color = "Climate Scenario",
    fill = "Climate Scenario"
  ) +

  # Theme
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 9, hjust = 0.5, color = "grey30"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 11),
    legend.text = element_text(size = 10),
    axis.title = element_text(face = "bold", size = 13),
    axis.text = element_text(size = 11, color = "black"),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90")
  ) +

  guides(
    color = guide_legend(nrow = 1, override.aes = list(linewidth = 3)),
    fill = guide_legend(nrow = 1)
  )

cat("  ✓ Plot created\n")

cat("\n[8/8] Saving figures...\n")

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_forecast_with_trend.png"),
  plot = p,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_forecast_with_trend.pdf"),
  plot = p,
  width = 12,
  height = 7,
  device = "pdf"
)

cat("  ✓ Saved PNG and PDF\n")

cat("\n================================================================================\n")
cat("COMPLETED: FORECAST WITH HISTORICAL TREND\n")
cat("================================================================================\n\n")

cat("KEY APPROACH:\n")
cat("  1. Calculate historical trend (linear regression 2014-2023)\n")
cat("  2. Project inertial trend to future (dashed line)\n")
cat("  3. Add climate scenario DELTA on top of trend\n")
cat("  4. Result: All scenarios start from current trajectory\n\n")

cat("BIOLOGICAL INTERPRETATION:\n")
cat(sprintf("  • Historical trend: %s at %.2f/year\n",
            ifelse(slope > 0, "INCREASING", "DECREASING"),
            abs(slope)))
cat("  • Inertial projection (if trend continues): BSI %.0f by 2050\n",
    trend_projection$bsi_trend[trend_projection$year == 2050])
cat("  • Climate scenarios MODIFY this baseline trajectory:\n")
cat(sprintf("    - SSP1-2.6 mitigates: %.0f (climate delta: %+.1f)\n",
            values_2050$bsi_forecast[values_2050$scenario == "SSP1-2.6"],
            values_2050$climate_delta[values_2050$scenario == "SSP1-2.6"]))
cat(sprintf("    - SSP2-4.5 moderate: %.0f (climate delta: %+.1f)\n",
            values_2050$bsi_forecast[values_2050$scenario == "SSP2-4.5"],
            values_2050$climate_delta[values_2050$scenario == "SSP2-4.5"]))
cat(sprintf("    - SSP5-8.5 worsens: %.0f (climate delta: %+.1f)\n",
            values_2050$bsi_forecast[values_2050$scenario == "SSP5-8.5"],
            values_2050$climate_delta[values_2050$scenario == "SSP5-8.5"]))

cat("\n✓ All scenarios now follow upward trajectory from historical data\n\n")
