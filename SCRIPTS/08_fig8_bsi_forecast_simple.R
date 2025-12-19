#!/usr/bin/env Rscript
################################################################################
# FIGURE 8: BSI MECHANISTIC FORECAST TO 2100 (PHASE 6.6) - SIMPLIFIED
################################################################################

cat("\n================================================================================\n")
cat("FIGURE 8: BSI MECHANISTIC FORECAST TO 2100\n")
cat("================================================================================\n\n")

# Load only essential packages
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(zoo)
})

# Helper function
read_csv <- function(file, show_col_types = FALSE, ...) {
  df <- read.csv(file, stringsAsFactors = FALSE, ...)
  date_cols <- grep("date|Date", names(df), value = TRUE)
  for (col in date_cols) {
    df[[col]] <- as.Date(df[[col]])
  }
  return(df)
}

# Paths
BASE_DIR <- "/home/user/climate-change-ecotoxicology/ANALYSIS"
OUTPUT_DIR <- file.path(BASE_DIR, "RESULTS/figures")
dir.create(OUTPUT_DIR, showWarnings = FALSE, recursive = TRUE)

cat("[1/4] Loading data...\n")

# Load data
bsi_historical <- read_csv(file.path(BASE_DIR, "PHASE_6.5_BSI_FORECASTING/data/bsi_climate_timeseries.csv"))
bsi_forecast <- read_csv(file.path(BASE_DIR, "PHASE_6.6_BSI_FORECAST_MECHANISTIC/results/bsi_forecast_rescaled_2023_2100.csv"))

cat(sprintf("  ✓ Historical: %d campaigns\n", nrow(bsi_historical)))
cat(sprintf("  ✓ Forecast: %d quarters\n", nrow(bsi_forecast)))

cat("\n[2/4] Preparing plot data...\n")

# Prepare historical
historical_plot <- bsi_historical %>%
  mutate(
    year_decimal = year + (month - 1) / 12,
    bsi_value = bsi_mean
  )

# Aggregate forecast by year
forecast_yearly <- bsi_forecast %>%
  group_by(scenario, year) %>%
  summarise(
    bsi_value = mean(bsi_forecast, na.rm = TRUE),
    bsi_sd = sd(bsi_forecast, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(year_decimal = year)

# Apply smoothing
historical_smooth <- historical_plot %>%
  arrange(year_decimal) %>%
  mutate(bsi_smooth = rollmean(bsi_value, k = 5, fill = NA, align = "center"))

forecast_smooth <- forecast_yearly %>%
  arrange(scenario, year_decimal) %>%
  group_by(scenario) %>%
  mutate(bsi_smooth = rollmean(bsi_value, k = 5, fill = NA, align = "center")) %>%
  ungroup()

# Get 2100 values
values_2100 <- forecast_smooth %>%
  filter(year == 2100)

cat("  ✓ Data prepared\n")
cat(sprintf("  Historical BSI mean: %.1f\n", mean(historical_plot$bsi_value, na.rm = TRUE)))
cat("  2100 forecast:\n")
for (i in 1:nrow(values_2100)) {
  cat(sprintf("    %s: %.1f\n", values_2100$scenario[i], values_2100$bsi_value[i]))
}

cat("\n[3/4] Creating plot...\n")

# Colors
ssp_colors <- c(
  "SSP1-2.6" = "#3498DB",
  "SSP2-4.5" = "#F39C12",
  "SSP5-8.5" = "#E74C3C"
)

# Create plot
p <- ggplot() +

  # Historical line
  geom_line(
    data = filter(historical_smooth, !is.na(bsi_smooth)),
    aes(x = year_decimal, y = bsi_smooth),
    color = "black", linewidth = 1.5
  ) +

  # Historical points
  geom_point(
    data = historical_plot,
    aes(x = year_decimal, y = bsi_value),
    color = "black", size = 2.5, shape = 21, fill = "white"
  ) +

  # Forecast lines
  geom_line(
    data = filter(forecast_smooth, !is.na(bsi_smooth)),
    aes(x = year_decimal, y = bsi_smooth, color = scenario),
    linewidth = 2
  ) +

  # Vertical line at 2023
  geom_vline(xintercept = 2023, linetype = "dashed", color = "grey30", linewidth = 1) +

  # Annotations
  annotate("text", x = 2018.5, y = 95, label = "Historical\nData",
           hjust = 0.5, size = 4.5, fontface = "bold") +
  annotate("text", x = 2061.5, y = 95, label = "Climate\nProjections",
           hjust = 0.5, size = 4.5, fontface = "bold") +

  # 2100 labels
  annotate("text", x = 2102,
           y = values_2100$bsi_value[values_2100$scenario == "SSP1-2.6"],
           label = sprintf("%.1f", values_2100$bsi_value[values_2100$scenario == "SSP1-2.6"]),
           hjust = 0, size = 4, fontface = "bold", color = ssp_colors["SSP1-2.6"]) +
  annotate("text", x = 2102,
           y = values_2100$bsi_value[values_2100$scenario == "SSP2-4.5"],
           label = sprintf("%.1f", values_2100$bsi_value[values_2100$scenario == "SSP2-4.5"]),
           hjust = 0, size = 4, fontface = "bold", color = ssp_colors["SSP2-4.5"]) +
  annotate("text", x = 2102,
           y = values_2100$bsi_value[values_2100$scenario == "SSP5-8.5"],
           label = sprintf("%.1f", values_2100$bsi_value[values_2100$scenario == "SSP5-8.5"]),
           hjust = 0, size = 4, fontface = "bold", color = ssp_colors["SSP5-8.5"]) +

  # Scales
  scale_color_manual(
    values = ssp_colors,
    labels = c("SSP1-2.6 (Low emissions)",
               "SSP2-4.5 (Moderate)",
               "SSP5-8.5 (High emissions)")
  ) +

  scale_x_continuous(breaks = seq(2015, 2100, by = 10), limits = c(2014, 2107)) +
  scale_y_continuous(breaks = seq(0, 100, by = 20), limits = c(0, 100)) +

  # Labels
  labs(
    title = "Biological Stress Index (BSI) Forecast to 2100",
    subtitle = "Mechanistic GAM forecast under IPCC climate scenarios",
    x = "Year",
    y = "Biological Stress Index (BSI)",
    color = "Climate Scenario"
  ) +

  # Theme
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 11, hjust = 0.5),
    legend.position = "bottom",
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(size = 12, color = "black"),
    panel.grid.minor = element_blank()
  )

cat("  ✓ Plot created\n")

cat("\n[4/4] Saving plot...\n")

# Save PNG
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_bsi_mechanistic_forecast_2100.png"),
  plot = p,
  width = 10,
  height = 6,
  dpi = 300,
  bg = "white"
)

# Save PDF
ggsave(
  filename = file.path(OUTPUT_DIR, "fig8_bsi_mechanistic_forecast_2100.pdf"),
  plot = p,
  width = 10,
  height = 6,
  device = "pdf"
)

cat("  ✓ Saved PNG and PDF\n")

cat("\n================================================================================\n")
cat("FIGURE 8 COMPLETED\n")
cat("================================================================================\n\n")

cat("Output files:\n")
cat(sprintf("  • %s/fig8_bsi_mechanistic_forecast_2100.png\n", OUTPUT_DIR))
cat(sprintf("  • %s/fig8_bsi_mechanistic_forecast_2100.pdf\n", OUTPUT_DIR))
cat("\n")
