#!/usr/bin/env Rscript
################################################################################
# FIGURE 8 - ALTERNATIVE VISUALIZATIONS (UPDATED WITH HYBRID MODEL)
################################################################################
# Uses same methodology as script 16 (hybrid HGAM + trend, weight 0.5, k=3)
# Shows BSI forecast to 2050 in 5 different visualization styles
################################################################################

cat("\n================================================================================\n")
cat("FIGURE 8 ALTERNATIVE VISUALIZATIONS (HYBRID MODEL)\n")
cat("================================================================================\n\n")

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(tidyr)
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

# Observed trend
trend_model <- lm(bsi_mean ~ year_decimal, data = hist_plot)
slope_obs <- coef(trend_model)[2]

# Last observation
last_obs <- hist_plot %>%
  slice_max(year_decimal, n = 1) %>%
  select(year_decimal, bsi = bsi_mean, bsi_sd)

cat(sprintf("  ✓ Historical: %d campaigns (2014-2023)\n", nrow(hist_plot)))
cat(sprintf("  ✓ Observed trend: %+.3f BSI/year (p=0.016)\n", slope_obs))
cat(sprintf("  ✓ Last observation: %.2f (BSI = %.1f)\n", last_obs$year_decimal, last_obs$bsi))

cat("\n[2/8] Loading HGAM forecast and building hybrid model...\n")

bsi_hgam <- read_csv(file.path(BASE_DIR, "PHASE_6.6_BSI_FORECAST_MECHANISTIC/results/bsi_forecast_rescaled_2023_2100.csv"))

hgam_yearly <- bsi_hgam %>%
  group_by(scenario, year) %>%
  summarise(
    bsi_hgam = mean(bsi_forecast, na.rm = TRUE),
    bsi_sd = sd(bsi_forecast, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(year_decimal = year)

# HGAM baseline and dynamics (same as script 16)
hgam_baseline <- hgam_yearly %>%
  filter(year >= 2023 & year <= 2025) %>%
  group_by(scenario) %>%
  summarise(baseline = mean(bsi_hgam, na.rm = TRUE), .groups = "drop")

hgam_dynamics <- hgam_yearly %>%
  left_join(hgam_baseline, by = "scenario") %>%
  mutate(
    deviation = bsi_hgam - baseline,
    years_from_2023 = year_decimal - 2023
  ) %>%
  filter(year >= 2023 & year <= 2050)

# Correction multipliers (same as script 16)
correct_multipliers <- data.frame(
  scenario = c("SSP1-2.6", "SSP2-4.5", "SSP5-8.5"),
  multiplier = c(0.55, 1.00, 1.20),
  stringsAsFactors = FALSE
)

cat("  Correction multipliers: 0.55, 1.00, 1.20 (SSP1/SSP2/SSP5)\n")

# Build hybrid forecast (SAME AS SCRIPT 16)
years_forecast <- seq(last_obs$year_decimal, 2050.75, by = 0.25)

forecast_all <- do.call(rbind, lapply(1:nrow(correct_multipliers), function(i) {
  scenario <- correct_multipliers$scenario[i]
  multiplier <- correct_multipliers$multiplier[i]

  hgam_dev <- hgam_dynamics %>%
    filter(scenario == !!scenario) %>%
    select(year, hgam_deviation = deviation)

  forecast_df <- data.frame(
    scenario = scenario,
    year = floor(years_forecast),
    year_decimal = years_forecast,
    years_from_last = years_forecast - last_obs$year_decimal
  ) %>%
    mutate(
      # HYBRID: Observed linear trend component
      trend_component = slope_obs * multiplier * years_from_last
    ) %>%
    left_join(hgam_dev, by = "year") %>%
    mutate(
      hgam_deviation = ifelse(is.na(hgam_deviation), 0, hgam_deviation),
      # SAME WEIGHT AS SCRIPT 16: 0.5
      hgam_component = hgam_deviation * multiplier * 0.5,
      bsi_forecast = last_obs$bsi + trend_component + hgam_component,
      uncertainty = last_obs$bsi_sd + 0.4 * years_from_last,
      bsi_lower = pmax(0, bsi_forecast - uncertainty),
      bsi_upper = pmin(100, bsi_forecast + uncertainty)
    ) %>%
    select(scenario, year, year_decimal, bsi_forecast, bsi_lower, bsi_upper)

  return(forecast_df)
}))

# Add connection points and smoothing (SAME AS SCRIPT 16)
connection_points <- data.frame(
  scenario = rep(c("SSP1-2.6", "SSP2-4.5", "SSP5-8.5"), each = 1),
  year = floor(last_obs$year_decimal),
  year_decimal = last_obs$year_decimal,
  bsi_forecast = last_obs$bsi,
  bsi_lower = last_obs$bsi - last_obs$bsi_sd,
  bsi_upper = last_obs$bsi + last_obs$bsi_sd
)

forecast_with_connection <- bind_rows(
  connection_points,
  filter(forecast_all, year_decimal > last_obs$year_decimal)
) %>%
  arrange(scenario, year_decimal)

# SAME SMOOTHING AS SCRIPT 16: k=3
forecast_smooth <- forecast_with_connection %>%
  group_by(scenario) %>%
  mutate(
    bsi_smooth = rollmean(bsi_forecast, k = 3, fill = NA, align = "center", partial = TRUE),
    bsi_lower_smooth = rollmean(bsi_lower, k = 3, fill = NA, align = "center", partial = TRUE),
    bsi_upper_smooth = rollmean(bsi_upper, k = 3, fill = NA, align = "center", partial = TRUE),
    bsi_smooth = ifelse(is.na(bsi_smooth), bsi_forecast, bsi_smooth),
    bsi_lower_smooth = ifelse(is.na(bsi_lower_smooth), bsi_lower, bsi_lower_smooth),
    bsi_upper_smooth = ifelse(is.na(bsi_upper_smooth), bsi_upper, bsi_upper_smooth)
  ) %>%
  ungroup()

cat("  ✓ Hybrid forecast built (weight=0.5, k=3 smooth)\n")

# Convert to yearly for alternative visualizations (aggregate by year)
forecast_yearly <- forecast_smooth %>%
  group_by(scenario, year) %>%
  summarise(
    bsi_adjusted = mean(bsi_smooth, na.rm = TRUE),
    bsi_lower = mean(bsi_lower_smooth, na.rm = TRUE),
    bsi_upper = mean(bsi_upper_smooth, na.rm = TRUE),
    .groups = "drop"
  )

# Debug: check if data exists
cat(sprintf("  Yearly data points: %d rows across %d scenarios\n",
            nrow(forecast_yearly),
            length(unique(forecast_yearly$scenario))))

ssp_colors <- c(
  "SSP1-2.6" = "#3498DB",
  "SSP2-4.5" = "#F39C12",
  "SSP5-8.5" = "#E74C3C"
)

################################################################################
# VISUALIZATION 1: Barplot Comparison 2050
################################################################################

cat("\n[3/8] Creating barplot comparison (2050 values)...\n")

values_2050 <- forecast_yearly %>%
  filter(year == 2050) %>%
  mutate(
    pct_change = 100 * (bsi_adjusted - last_obs$bsi) / last_obs$bsi,
    scenario = factor(scenario, levels = c("SSP1-2.6", "SSP2-4.5", "SSP5-8.5"))
  )

cat("  2050 values:\n")
for (i in 1:nrow(values_2050)) {
  cat(sprintf("    %s: %.1f (%+.0f%%)\n",
              values_2050$scenario[i],
              values_2050$bsi_adjusted[i],
              values_2050$pct_change[i]))
}

p1 <- ggplot(values_2050, aes(x = scenario, y = bsi_adjusted, fill = scenario)) +
  geom_col(width = 0.7, color = "black", linewidth = 1) +
  geom_errorbar(aes(ymin = bsi_lower, ymax = bsi_upper),
                width = 0.2, linewidth = 1) +

  # Baseline reference line
  geom_hline(yintercept = last_obs$bsi, linetype = "dashed",
             color = "grey30", linewidth = 1.2) +
  annotate("text", x = 2.5, y = last_obs$bsi + 2,
           label = sprintf("2023 baseline (%.1f)", last_obs$bsi),
           hjust = 0, size = 4, color = "grey30") +

  # Threshold lines
  geom_hline(yintercept = 70, linetype = "dotted", color = "darkred", linewidth = 1) +
  geom_hline(yintercept = 90, linetype = "dotted", color = "darkred", linewidth = 1) +

  # Value labels on bars
  geom_text(aes(label = sprintf("%.0f\n(%+.0f%%)", bsi_adjusted, pct_change)),
            vjust = -0.5, size = 5, fontface = "bold") +

  scale_fill_manual(values = ssp_colors) +
  scale_y_continuous(limits = c(0, 110), breaks = seq(0, 100, by = 10)) +

  labs(
    title = "BSI Forecast Comparison by 2050",
    subtitle = "Projected biological stress under different climate scenarios (Hybrid HGAM + Trend model)",
    x = "IPCC Climate Scenario",
    y = "Biological Stress Index (BSI)",
    fill = "Scenario"
  ) +

  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "grey40"),
    legend.position = "none",
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12, color = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt1_barplot_2050.png"),
  plot = p1, width = 10, height = 7, dpi = 300, bg = "white"
)
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt1_barplot_2050.pdf"),
  plot = p1, width = 10, height = 7, device = "pdf"
)

cat("  ✓ Barplot saved\n")

################################################################################
# VISUALIZATION 2: Heatmap by Decade
################################################################################

cat("\n[4/8] Creating decade heatmap...\n")

decades_data <- forecast_yearly %>%
  mutate(decade = floor(year / 10) * 10) %>%
  filter(decade >= 2020 & decade <= 2050) %>%
  group_by(scenario, decade) %>%
  summarise(
    bsi_mean = mean(bsi_adjusted, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    scenario = factor(scenario, levels = c("SSP5-8.5", "SSP2-4.5", "SSP1-2.6"))
  )

p2 <- ggplot(decades_data, aes(x = as.factor(decade), y = scenario, fill = bsi_mean)) +
  geom_tile(color = "white", linewidth = 2) +
  geom_text(aes(label = sprintf("%.0f", bsi_mean)),
            size = 6, fontface = "bold", color = "white") +

  scale_fill_gradient2(
    low = "#2E86AB", mid = "#F6AE2D", high = "#E63946",
    midpoint = 60, limits = c(40, 100),
    name = "BSI"
  ) +

  labs(
    title = "BSI Forecast Evolution by Decade",
    subtitle = "Average biological stress index per decade (2020-2050) - Hybrid Model",
    x = "Decade",
    y = "Climate Scenario"
  ) +

  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey40"),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12, color = "black"),
    legend.position = "right",
    legend.title = element_text(face = "bold"),
    panel.grid = element_blank()
  )

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt2_heatmap_decades.png"),
  plot = p2, width = 10, height = 6, dpi = 300, bg = "white"
)
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt2_heatmap_decades.pdf"),
  plot = p2, width = 10, height = 6, device = "pdf"
)

cat("  ✓ Heatmap saved\n")

################################################################################
# VISUALIZATION 3: Divergence Plot (Relative to SSP1-2.6)
################################################################################

cat("\n[5/8] Creating divergence plot...\n")

# Calculate difference from SSP1-2.6
baseline_ssp126 <- forecast_yearly %>%
  filter(scenario == "SSP1-2.6") %>%
  select(year, bsi_baseline = bsi_adjusted)

divergence_data <- forecast_yearly %>%
  filter(year >= 2023) %>%
  left_join(baseline_ssp126, by = "year") %>%
  mutate(
    divergence = bsi_adjusted - bsi_baseline,
    pct_divergence = 100 * divergence / bsi_baseline
  )

p3 <- ggplot(divergence_data, aes(x = year, y = pct_divergence,
                                   color = scenario, fill = scenario)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", linewidth = 1) +

  geom_ribbon(aes(ymin = 0, ymax = pct_divergence), alpha = 0.3, color = NA) +
  geom_line(linewidth = 2) +

  # Annotate 2050 values
  geom_point(data = filter(divergence_data, year == 2050),
             aes(x = year, y = pct_divergence), size = 5) +

  geom_text(
    data = filter(divergence_data, year == 2050),
    aes(label = sprintf("%+.0f%%", pct_divergence)),
    hjust = -0.2, size = 5, fontface = "bold"
  ) +

  scale_color_manual(values = ssp_colors) +
  scale_fill_manual(values = ssp_colors) +
  scale_x_continuous(breaks = seq(2025, 2050, by = 5), limits = c(2023, 2055)) +

  labs(
    title = "Climate Scenario Divergence from Low-Emission Baseline",
    subtitle = "Percentage difference in BSI relative to SSP1-2.6 (2023-2050) - Hybrid Model",
    x = "Year",
    y = "Divergence from SSP1-2.6 (%)",
    color = "Scenario",
    fill = "Scenario"
  ) +

  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "grey40"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 12),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12, color = "black"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt3_divergence.png"),
  plot = p3, width = 12, height = 7, dpi = 300, bg = "white"
)
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt3_divergence.pdf"),
  plot = p3, width = 12, height = 7, device = "pdf"
)

cat("  ✓ Divergence plot saved\n")

################################################################################
# VISUALIZATION 4: Small Multiples (Faceted Panels)
################################################################################

cat("\n[6/8] Creating faceted panel plot...\n")

forecast_for_panels <- forecast_yearly %>%
  filter(year >= 2023) %>%
  mutate(scenario = factor(scenario, levels = c("SSP1-2.6", "SSP2-4.5", "SSP5-8.5")))

p4 <- ggplot(forecast_for_panels, aes(x = year, y = bsi_adjusted)) +
  geom_ribbon(aes(ymin = bsi_lower, ymax = bsi_upper, fill = scenario),
              alpha = 0.3) +
  geom_line(aes(color = scenario), linewidth = 2) +

  # Baseline reference
  geom_hline(yintercept = last_obs$bsi, linetype = "dashed", color = "grey30") +

  # Thresholds
  geom_hline(yintercept = 70, linetype = "dotted", color = "darkred", alpha = 0.6) +
  geom_hline(yintercept = 90, linetype = "dotted", color = "darkred", alpha = 0.6) +

  # 2050 value annotation
  geom_point(data = filter(forecast_for_panels, year == 2050),
             aes(color = scenario), size = 4) +

  geom_text(
    data = filter(forecast_for_panels, year == 2050),
    aes(label = sprintf("%.0f", bsi_adjusted), color = scenario),
    hjust = -0.5, size = 5, fontface = "bold"
  ) +

  facet_wrap(~scenario, ncol = 1) +

  scale_color_manual(values = ssp_colors) +
  scale_fill_manual(values = ssp_colors) +
  scale_x_continuous(breaks = seq(2025, 2050, by = 5)) +
  scale_y_continuous(limits = c(0, 110), breaks = seq(0, 100, by = 20)) +

  labs(
    title = "BSI Forecast by Climate Scenario (2023-2050)",
    subtitle = "Individual scenario trajectories with uncertainty - Hybrid HGAM + Trend Model",
    x = "Year",
    y = "Biological Stress Index (BSI)"
  ) +

  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5, color = "grey40"),
    legend.position = "none",
    axis.title = element_text(face = "bold", size = 13),
    axis.text = element_text(size = 11, color = "black"),
    strip.text = element_text(size = 14, face = "bold", color = "white"),
    strip.background = element_rect(fill = "grey30", color = "grey30"),
    panel.spacing = unit(1, "lines"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt4_panels.png"),
  plot = p4, width = 12, height = 10, dpi = 300, bg = "white"
)
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt4_panels.pdf"),
  plot = p4, width = 12, height = 10, device = "pdf"
)

cat("  ✓ Panel plot saved\n")

################################################################################
# VISUALIZATION 5: Rate of Change (Slope)
################################################################################

cat("\n[7/8] Creating rate of change plot...\n")

# Calculate yearly rate of change
rate_data <- forecast_yearly %>%
  filter(year >= 2024) %>%
  arrange(scenario, year) %>%
  group_by(scenario) %>%
  mutate(
    bsi_prev = lag(bsi_adjusted, 1),
    rate_of_change = bsi_adjusted - bsi_prev
  ) %>%
  filter(!is.na(rate_of_change)) %>%
  ungroup()

p5 <- ggplot(rate_data, aes(x = year, y = rate_of_change,
                             color = scenario, fill = scenario)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", linewidth = 1) +

  geom_ribbon(aes(ymin = 0, ymax = rate_of_change), alpha = 0.3, color = NA) +
  geom_line(linewidth = 2) +
  geom_point(size = 2) +

  # Annotate acceleration/deceleration
  annotate("text", x = 2030, y = 2, label = "Increasing stress →",
           hjust = 0, size = 4.5, color = "firebrick", fontface = "italic") +

  scale_color_manual(values = ssp_colors) +
  scale_fill_manual(values = ssp_colors) +
  scale_x_continuous(breaks = seq(2025, 2050, by = 5)) +

  labs(
    title = "Annual Rate of BSI Change",
    subtitle = "Year-to-year change in BSI (units per year) - Hybrid Model",
    x = "Year",
    y = "ΔBSI / year",
    color = "Scenario",
    fill = "Scenario"
  ) +

  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey40"),
    legend.position = "bottom",
    legend.title = element_text(face = "bold", size = 12),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12, color = "black"),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt5_rate_of_change.png"),
  plot = p5, width = 12, height = 7, dpi = 300, bg = "white"
)
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt5_rate_of_change.pdf"),
  plot = p5, width = 12, height = 7, device = "pdf"
)

cat("  ✓ Rate of change plot saved\n")

################################################################################
# Summary
################################################################################

cat("\n[8/8] Summary...\n\n")

cat("ALTERNATIVE VISUALIZATIONS CREATED (HYBRID MODEL):\n\n")

cat("1. BARPLOT 2050 (fig8_alt1_barplot_2050)\n")
cat("   - Direct comparison of 2050 values\n")
cat("   - Shows absolute BSI with error bars\n")
cat(sprintf("   - Values: SSP5-8.5=%.1f, SSP2-4.5=%.1f, SSP1-2.6=%.1f\n\n",
            values_2050$bsi_adjusted[values_2050$scenario == "SSP5-8.5"],
            values_2050$bsi_adjusted[values_2050$scenario == "SSP2-4.5"],
            values_2050$bsi_adjusted[values_2050$scenario == "SSP1-2.6"]))

cat("2. DECADE HEATMAP (fig8_alt2_heatmap_decades)\n")
cat("   - Color-coded evolution by decade (2020-2050)\n")
cat("   - Easy to spot temporal patterns\n")
cat("   - Compact matrix format\n\n")

cat("3. DIVERGENCE PLOT (fig8_alt3_divergence)\n")
cat("   - Shows % difference from SSP1-2.6\n")
cat("   - Highlights scenario spread over time\n")
cat("   - Emphasizes mitigation benefits\n\n")

cat("4. FACETED PANELS (fig8_alt4_panels)\n")
cat("   - Individual scenario trajectories\n")
cat("   - Detailed uncertainty ribbons\n")
cat("   - Side-by-side comparison\n\n")

cat("5. RATE OF CHANGE (fig8_alt5_rate_of_change)\n")
cat("   - Shows annual acceleration/deceleration\n")
cat("   - Highlights turning points\n")
cat("   - Useful for policy timelines\n\n")

cat("MODEL CONFIGURATION:\n")
cat(sprintf("  • Observed trend: %+.3f BSI/year\n", slope_obs))
cat("  • HGAM weight: 0.5 (50%)\n")
cat("  • Smoothing: k=3\n")
cat("  • Multipliers: 0.55, 1.00, 1.20\n")
cat("  • Period: 2023-2050\n\n")

cat("================================================================================\n")
cat("ALL 5 ALTERNATIVE VISUALIZATIONS COMPLETED\n")
cat("================================================================================\n\n")
