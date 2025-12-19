#!/usr/bin/env Rscript
################################################################################
# FIGURE 8 - ALTERNATIVE VISUALIZATIONS
################################################################################
# Multiple ways to show BSI forecast scenarios
################################################################################

cat("\n================================================================================\n")
cat("FIGURE 8 ALTERNATIVE VISUALIZATIONS\n")
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

cat("[1/7] Loading and preparing data...\n")

bsi_historical <- read_csv(file.path(BASE_DIR, "PHASE_6.5_BSI_FORECASTING/data/bsi_climate_timeseries.csv"))
bsi_forecast_raw <- read_csv(file.path(BASE_DIR, "PHASE_6.6_BSI_FORECAST_MECHANISTIC/results/bsi_forecast_rescaled_2023_2100.csv"))

# Get 2023 baseline
bsi_2023 <- bsi_historical %>%
  filter(year == 2023) %>%
  summarise(bsi_2023 = mean(bsi_mean, na.rm = TRUE)) %>%
  pull(bsi_2023)

# Prepare forecast data
forecast_yearly <- bsi_forecast_raw %>%
  group_by(scenario, year) %>%
  summarise(
    bsi_raw = mean(bsi_forecast, na.rm = TRUE),
    bsi_sd = sd(bsi_forecast, na.rm = TRUE),
    .groups = "drop"
  )

baseline_2023 <- forecast_yearly %>%
  filter(year >= 2023 & year <= 2025) %>%
  group_by(scenario) %>%
  summarise(baseline = mean(bsi_raw, na.rm = TRUE), .groups = "drop")

forecast_adjusted <- forecast_yearly %>%
  left_join(baseline_2023, by = "scenario") %>%
  mutate(
    delta_from_baseline = bsi_raw - baseline,
    bsi_adjusted = bsi_2023 + delta_from_baseline,
    bsi_lower = pmax(0, bsi_adjusted - bsi_sd),
    bsi_upper = pmin(100, bsi_adjusted + bsi_sd)
  )

ssp_colors <- c(
  "SSP1-2.6" = "#3498DB",
  "SSP2-4.5" = "#F39C12",
  "SSP5-8.5" = "#E74C3C"
)

cat("  ✓ Data prepared\n")

################################################################################
# VISUALIZATION 1: Barplot Comparison 2100
################################################################################

cat("\n[2/7] Creating barplot comparison (2100 values)...\n")

values_2100 <- forecast_adjusted %>%
  filter(year == 2100) %>%
  mutate(
    pct_change = 100 * (bsi_adjusted - bsi_2023) / bsi_2023,
    scenario = factor(scenario, levels = c("SSP1-2.6", "SSP2-4.5", "SSP5-8.5"))
  )

p1 <- ggplot(values_2100, aes(x = scenario, y = bsi_adjusted, fill = scenario)) +
  geom_col(width = 0.7, color = "black", linewidth = 1) +
  geom_errorbar(aes(ymin = bsi_lower, ymax = bsi_upper),
                width = 0.2, linewidth = 1) +

  # Baseline reference line
  geom_hline(yintercept = bsi_2023, linetype = "dashed",
             color = "grey30", linewidth = 1.2) +
  annotate("text", x = 2.5, y = bsi_2023 + 2,
           label = sprintf("2023 baseline (%.1f)", bsi_2023),
           hjust = 0, size = 4, color = "grey30") +

  # Value labels on bars
  geom_text(aes(label = sprintf("%.0f\n(%+.0f%%)", bsi_adjusted, pct_change)),
            vjust = -0.5, size = 5, fontface = "bold") +

  scale_fill_manual(values = ssp_colors) +
  scale_y_continuous(limits = c(0, 80), breaks = seq(0, 80, by = 10)) +

  labs(
    title = "BSI Forecast Comparison by 2100",
    subtitle = "Projected biological stress under different climate scenarios",
    x = "IPCC Climate Scenario",
    y = "Biological Stress Index (BSI)",
    fill = "Scenario"
  ) +

  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 18, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey40"),
    legend.position = "none",
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12, color = "black"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank()
  )

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt1_barplot_2100.png"),
  plot = p1, width = 10, height = 7, dpi = 300, bg = "white"
)
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt1_barplot_2100.pdf"),
  plot = p1, width = 10, height = 7, device = "pdf"
)

cat("  ✓ Barplot saved\n")

################################################################################
# VISUALIZATION 2: Heatmap by Decade
################################################################################

cat("\n[3/7] Creating decade heatmap...\n")

decades_data <- forecast_adjusted %>%
  mutate(decade = floor(year / 10) * 10) %>%
  filter(decade >= 2020 & decade <= 2090) %>%
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
    midpoint = 44, limits = c(20, 70),
    name = "BSI"
  ) +

  labs(
    title = "BSI Forecast Evolution by Decade",
    subtitle = "Average biological stress index per decade (2020-2090)",
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
  plot = p2, width = 12, height = 6, dpi = 300, bg = "white"
)
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_alt2_heatmap_decades.pdf"),
  plot = p2, width = 12, height = 6, device = "pdf"
)

cat("  ✓ Heatmap saved\n")

################################################################################
# VISUALIZATION 3: Divergence Plot (Relative to SSP1-2.6)
################################################################################

cat("\n[4/7] Creating divergence plot...\n")

# Calculate difference from SSP1-2.6
baseline_ssp126 <- forecast_adjusted %>%
  filter(scenario == "SSP1-2.6") %>%
  select(year, bsi_baseline = bsi_adjusted)

divergence_data <- forecast_adjusted %>%
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

  # Annotate 2100 values
  geom_point(data = filter(divergence_data, year == 2100),
             aes(x = year, y = pct_divergence), size = 5) +

  geom_text(
    data = filter(divergence_data, year == 2100),
    aes(label = sprintf("%+.0f%%", pct_divergence)),
    hjust = -0.2, size = 5, fontface = "bold"
  ) +

  scale_color_manual(values = ssp_colors) +
  scale_fill_manual(values = ssp_colors) +
  scale_x_continuous(breaks = seq(2030, 2100, by = 10), limits = c(2023, 2110)) +

  labs(
    title = "Climate Scenario Divergence from Low-Emission Baseline",
    subtitle = "Percentage difference in BSI relative to SSP1-2.6 (2023-2100)",
    x = "Year",
    y = "Divergence from SSP1-2.6 (%)",
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

cat("\n[5/7] Creating faceted panel plot...\n")

# Add smoothing
forecast_smooth <- forecast_adjusted %>%
  filter(year >= 2023) %>%
  arrange(scenario, year) %>%
  group_by(scenario) %>%
  mutate(
    bsi_trend = rollmean(bsi_adjusted, k = 10, fill = NA, align = "center", partial = TRUE)
  ) %>%
  ungroup() %>%
  mutate(scenario = factor(scenario, levels = c("SSP1-2.6", "SSP2-4.5", "SSP5-8.5")))

p4 <- ggplot(forecast_smooth, aes(x = year, y = bsi_adjusted)) +
  geom_ribbon(aes(ymin = bsi_lower, ymax = bsi_upper, fill = scenario),
              alpha = 0.3) +
  geom_line(aes(y = bsi_trend, color = scenario), linewidth = 2) +

  # Baseline reference
  geom_hline(yintercept = bsi_2023, linetype = "dashed", color = "grey30") +

  # 2100 value annotation
  geom_point(data = filter(forecast_smooth, year == 2100),
             aes(color = scenario), size = 4) +

  geom_text(
    data = filter(forecast_smooth, year == 2100),
    aes(label = sprintf("%.0f", bsi_adjusted), color = scenario),
    hjust = -0.5, size = 5, fontface = "bold"
  ) +

  facet_wrap(~scenario, ncol = 1) +

  scale_color_manual(values = ssp_colors) +
  scale_fill_manual(values = ssp_colors) +
  scale_x_continuous(breaks = seq(2030, 2100, by = 10)) +
  scale_y_continuous(limits = c(0, 80)) +

  labs(
    title = "BSI Forecast by Climate Scenario (2023-2100)",
    subtitle = "Individual scenario trajectories with uncertainty (10-year smoothing)",
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

cat("\n[6/7] Creating rate of change plot...\n")

# Calculate 10-year rate of change
rate_data <- forecast_adjusted %>%
  filter(year >= 2030) %>%
  arrange(scenario, year) %>%
  group_by(scenario) %>%
  mutate(
    # Rate = change per decade
    bsi_lag10 = lag(bsi_adjusted, 10),
    rate_of_change = (bsi_adjusted - bsi_lag10) / 10  # Change per year
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
  annotate("text", x = 2045, y = 0.5, label = "Increasing stress →",
           hjust = 0, size = 4.5, color = "firebrick", fontface = "italic") +
  annotate("text", x = 2045, y = -0.5, label = "← Decreasing stress",
           hjust = 0, size = 4.5, color = "steelblue", fontface = "italic") +

  scale_color_manual(values = ssp_colors) +
  scale_fill_manual(values = ssp_colors) +
  scale_x_continuous(breaks = seq(2040, 2100, by = 10)) +

  labs(
    title = "Rate of BSI Change Over Time",
    subtitle = "10-year average rate of change (BSI units per year)",
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

cat("\n[7/7] Summary...\n\n")

cat("ALTERNATIVE VISUALIZATIONS CREATED:\n\n")

cat("1. BARPLOT 2100 (fig8_alt1_barplot_2100)\n")
cat("   - Direct comparison of 2100 values\n")
cat("   - Shows absolute BSI with error bars\n")
cat("   - Clear % change from 2023 baseline\n\n")

cat("2. DECADE HEATMAP (fig8_alt2_heatmap_decades)\n")
cat("   - Color-coded evolution by decade\n")
cat("   - Easy to spot temporal patterns\n")
cat("   - Compact matrix format\n\n")

cat("3. DIVERGENCE PLOT (fig8_alt3_divergence)\n")
cat("   - Shows % difference from SSP1-2.6\n")
cat("   - Highlights scenario spread\n")
cat("   - Emphasizes mitigation benefits\n\n")

cat("4. FACETED PANELS (fig8_alt4_panels)\n")
cat("   - Individual scenario trajectories\n")
cat("   - Detailed uncertainty ribbons\n")
cat("   - Side-by-side comparison\n\n")

cat("5. RATE OF CHANGE (fig8_alt5_rate_of_change)\n")
cat("   - Shows acceleration/deceleration\n")
cat("   - Highlights turning points\n")
cat("   - Useful for policy timelines\n\n")

cat("================================================================================\n")
cat("ALL 5 ALTERNATIVE VISUALIZATIONS COMPLETED\n")
cat("================================================================================\n\n")
