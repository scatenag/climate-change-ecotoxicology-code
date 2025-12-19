#!/usr/bin/env Rscript
################################################################################
# FIGURE 8: BSI FORECAST TO 2100 - IMPROVED VERSION
################################################################################
# Emphasizes long-term trends and scenario divergence
################################################################################

cat("\n================================================================================\n")
cat("FIGURE 8: BSI MECHANISTIC FORECAST TO 2100 (IMPROVED)\n")
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
dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)

cat("[1/4] Loading data...\n")

bsi_historical <- read_csv(file.path(BASE_DIR, "PHASE_6.5_BSI_FORECASTING/data/bsi_climate_timeseries.csv"))
bsi_forecast <- read_csv(file.path(BASE_DIR, "PHASE_6.6_BSI_FORECAST_MECHANISTIC/results/bsi_forecast_rescaled_2023_2100.csv"))

cat(sprintf("  ✓ Historical: %d campaigns (2014-2023)\n", nrow(bsi_historical)))
cat(sprintf("  ✓ Forecast: %d quarters (2023-2100)\n", nrow(bsi_forecast)))

cat("\n[2/4] Preparing data with long-term trends...\n")

# Historical
hist_plot <- bsi_historical %>%
  mutate(year_decimal = year + (month - 1) / 12) %>%
  arrange(year_decimal)

# Forecast - aggregate by year with SD
forecast_yearly <- bsi_forecast %>%
  group_by(scenario, year) %>%
  summarise(
    bsi_mean = mean(bsi_forecast, na.rm = TRUE),
    bsi_sd = sd(bsi_forecast, na.rm = TRUE),
    bsi_min = min(bsi_forecast, na.rm = TRUE),
    bsi_max = max(bsi_forecast, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    year_decimal = year,
    # Calculate uncertainty bands
    bsi_lower = pmax(0, bsi_mean - bsi_sd),
    bsi_upper = pmin(100, bsi_mean + bsi_sd)
  )

# Apply 10-year smoothing for long-term trend
forecast_smooth <- forecast_yearly %>%
  arrange(scenario, year_decimal) %>%
  group_by(scenario) %>%
  mutate(
    bsi_trend = rollmean(bsi_mean, k = 10, fill = NA, align = "center"),
    bsi_lower_smooth = rollmean(bsi_lower, k = 10, fill = NA, align = "center"),
    bsi_upper_smooth = rollmean(bsi_upper, k = 10, fill = NA, align = "center")
  ) %>%
  ungroup()

# Historical smoothing
hist_smooth <- hist_plot %>%
  arrange(year_decimal) %>%
  mutate(bsi_smooth = rollmean(bsi_mean, k = 5, fill = NA, align = "center"))

# Get 2100 values
values_2100 <- forecast_yearly %>% filter(year == 2100)

cat("  ✓ Data prepared with 10-year trend smoothing\n")
cat("\n  Historical BSI: %.1f ± %.1f\n", mean(hist_plot$bsi_mean), sd(hist_plot$bsi_mean))
cat("  2100 forecast:\n")
for (i in 1:nrow(values_2100)) {
  cat(sprintf("    %s: %.1f ± %.1f\n",
              values_2100$scenario[i],
              values_2100$bsi_mean[i],
              values_2100$bsi_sd[i]))
}

cat("\n[3/4] Creating plot with uncertainty ribbons...\n")

ssp_colors <- c(
  "SSP1-2.6" = "#3498DB",
  "SSP2-4.5" = "#F39C12",
  "SSP5-8.5" = "#E74C3C"
)

p <- ggplot() +

  # Historical uncertainty ribbon
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

  # Forecast uncertainty ribbons (±1 SD, smoothed)
  geom_ribbon(
    data = filter(forecast_smooth, !is.na(bsi_trend)),
    aes(x = year_decimal,
        ymin = bsi_lower_smooth,
        ymax = bsi_upper_smooth,
        fill = scenario),
    alpha = 0.2
  ) +

  # Forecast trend lines (10-year smooth)
  geom_line(
    data = filter(forecast_smooth, !is.na(bsi_trend)),
    aes(x = year_decimal, y = bsi_trend, color = scenario),
    linewidth = 2.5
  ) +

  # Vertical line at 2023
  geom_vline(xintercept = 2023, linetype = "dashed", color = "grey30", linewidth = 1) +

  # Annotations
  annotate("text", x = 2018, y = 95,
           label = "Historical\nData\n(2014-2023)",
           hjust = 0.5, size = 5, fontface = "bold", color = "grey20") +

  annotate("text", x = 2062, y = 95,
           label = "Climate Projections\n(Mechanistic Forecast)\n(2023-2100)",
           hjust = 0.5, size = 5, fontface = "bold", color = "grey20") +

  # 2100 value labels with arrows
  geom_segment(
    data = values_2100,
    aes(x = 2100, xend = 2103,
        y = bsi_mean, yend = bsi_mean,
        color = scenario),
    linewidth = 1, arrow = arrow(length = unit(0.2, "cm"))
  ) +

  annotate("text", x = 2104,
           y = values_2100$bsi_mean[values_2100$scenario == "SSP1-2.6"],
           label = sprintf("SSP1-2.6\n%.1f",
                          values_2100$bsi_mean[values_2100$scenario == "SSP1-2.6"]),
           hjust = 0, vjust = 0.5, size = 4, fontface = "bold",
           color = ssp_colors["SSP1-2.6"]) +

  annotate("text", x = 2104,
           y = values_2100$bsi_mean[values_2100$scenario == "SSP2-4.5"],
           label = sprintf("SSP2-4.5\n%.1f",
                          values_2100$bsi_mean[values_2100$scenario == "SSP2-4.5"]),
           hjust = 0, vjust = 0.5, size = 4, fontface = "bold",
           color = ssp_colors["SSP2-4.5"]) +

  annotate("text", x = 2104,
           y = values_2100$bsi_mean[values_2100$scenario == "SSP5-8.5"],
           label = sprintf("SSP5-8.5\n%.1f",
                          values_2100$bsi_mean[values_2100$scenario == "SSP5-8.5"]),
           hjust = 0, vjust = 0.5, size = 4, fontface = "bold",
           color = ssp_colors["SSP5-8.5"]) +

  # Color/fill scales
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

  # Axes
  scale_x_continuous(
    breaks = seq(2015, 2100, by = 10),
    limits = c(2014, 2115)
  ) +

  scale_y_continuous(
    breaks = seq(0, 100, by = 20),
    limits = c(0, 100)
  ) +

  # Labels
  labs(
    title = "Biological Stress Index (BSI) Forecast to 2100",
    subtitle = "Mechanistic GAM forecast under IPCC climate scenarios (10-year smoothed trends ± 1 SD)",
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
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3)
  ) +

  guides(
    color = guide_legend(nrow = 1, override.aes = list(linewidth = 3)),
    fill = guide_legend(nrow = 1)
  )

cat("  ✓ Plot created\n")

cat("\n[4/4] Saving figure...\n")

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_bsi_forecast_improved.png"),
  plot = p,
  width = 12,
  height = 7,
  dpi = 300,
  bg = "white"
)

ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_bsi_forecast_improved.pdf"),
  plot = p,
  width = 12,
  height = 7,
  device = "pdf"
)

cat("  ✓ Saved PNG and PDF\n")

cat("\n================================================================================\n")
cat("FIGURE 8 COMPLETED (IMPROVED VERSION)\n")
cat("================================================================================\n\n")

cat("Key features:\n")
cat("  • 10-year trend smoothing (removes short-term noise)\n")
cat("  • Uncertainty ribbons (±1 SD, smoothed)\n")
cat("  • Clear 2100 scenario labels with arrows\n")
cat("  • Emphasis on long-term divergence\n\n")

cat("Output files:\n")
cat(sprintf("  • %s/fig8_bsi_forecast_improved.png\n", OUTPUT_DIR))
cat(sprintf("  • %s/fig8_bsi_forecast_improved.pdf\n", OUTPUT_DIR))
cat("\n")
