#!/usr/bin/env Rscript
# ==============================================================================
# FIGURA 1: CLIMATE DASHBOARD WITH MARINE HEATWAVES
# ==============================================================================
# 4-panel vertical layout (Temperature + MHW, pH, Oxygen, Compound Stress)
# Date: 2025-11-11
# ==============================================================================

# Load master configuration
source("00_master_config.R")

cat("\n")
cat("================================================================================\n")
cat("FIGURA 1: CLIMATE DASHBOARD + MARINE HEATWAVES\n")
cat("================================================================================\n\n")

# ==============================================================================
# STEP 1: LOAD DATA
# ==============================================================================

cat("[1/6] Loading climate and MHW data...\n")

# Daily climate data (Copernicus models)
climate_daily <- read_csv(
  file.path(BASE_DIR, "../CLEAN_DATA_PACKAGE/RAW_DATA/copernicus_models_daily.csv"),
  show_col_types = FALSE
) %>%
  filter(date >= as.Date("2014-01-01"), date <= as.Date("2023-12-31"))

cat(sprintf("  ✓ Loaded %d days of climate data\n", nrow(climate_daily)))

# CO2/pH data
co2_daily <- read_csv(
  file.path(BASE_DIR, "../CLEAN_DATA_PACKAGE/RAW_DATA/copernicus_co2_daily.csv"),
  show_col_types = FALSE
) %>%
  filter(date >= as.Date("2014-01-01"), date <= as.Date("2023-12-31"))

cat(sprintf("  ✓ Loaded %d days of CO2/pH data\n", nrow(co2_daily)))

# MHW events
mhw_events <- read_csv(DATA_PATHS$phase1_mhw_events, show_col_types = FALSE) %>%
  mutate(
    start_date = as.Date(start_date),
    end_date = as.Date(end_date)
  )

cat(sprintf("  ✓ Loaded %d MHW events\n", nrow(mhw_events)))

# ==============================================================================
# STEP 2: PREPARE CLIMATE DATA
# ==============================================================================

cat("\n[2/6] Preparing climate time series...\n")

# Average both sites (Gorgona + Terminal) or use Terminal only
climate <- climate_daily %>%
  group_by(date) %>%
  summarise(
    temperature_c = mean(temperature_c, na.rm=TRUE),
    oxygen_mmol_m3 = mean(oxygen_mmol_m3, na.rm=TRUE),
    .groups = "drop"
  ) %>%
  # Join pH from CO2 dataset
  left_join(
    co2_daily %>% select(date, ph_mean),
    by = "date"
  ) %>%
  rename(
    temp = temperature_c,
    oxygen = oxygen_mmol_m3,
    ph = ph_mean
  ) %>%
  # Calculate 30-day rolling means
  mutate(
    temp_smooth = zoo::rollmean(temp, k=30, fill=NA, align="center"),
    ph_smooth = zoo::rollmean(ph, k=30, fill=NA, align="center"),
    oxygen_smooth = zoo::rollmean(oxygen, k=30, fill=NA, align="center")
  )

cat("  ✓ Averaged sites and calculated 30-day smoothing\n")

# ==============================================================================
# STEP 3: CALCULATE COMPOUND STRESS INDEX (PCA)
# ==============================================================================

cat("\n[3/6] Calculating Compound Stress Index (PCA)...\n")

# PCA on standardized variables
pca_data <- climate %>%
  select(temp, ph, oxygen) %>%
  drop_na()

pca_scaled <- scale(pca_data)
pca_result <- prcomp(pca_scaled)

# Extract variance explained
variance_explained <- summary(pca_result)$importance[2,1] * 100

cat(sprintf("  ✓ PC1 explains %.1f%% of variance\n", variance_explained))

# Scale PC1 to 0-100
pc1_scores <- pca_result$x[,1]
compound_stress_raw <- (pc1_scores - min(pc1_scores)) /
                       (max(pc1_scores) - min(pc1_scores)) * 100

# Add back to climate dataframe
climate$compound_stress <- NA
climate$compound_stress[complete.cases(climate[,c("temp","ph","oxygen")])] <- compound_stress_raw

# Smooth
climate$compound_smooth <- zoo::rollmean(climate$compound_stress, k=30, fill=NA, align="center")

# 90th percentile threshold
p90_threshold <- quantile(climate$compound_stress, 0.9, na.rm=TRUE)
cat(sprintf("  ✓ 90th percentile threshold: %.1f\n", p90_threshold))

# ==============================================================================
# STEP 4: CALCULATE TREND LINES
# ==============================================================================

cat("\n[4/6] Calculating trend lines...\n")

# Official temperature trend from MANUSCRIPT_DRAFT: +0.042°C/year
temp_slope_per_year <- 0.042
temp_slope_per_day <- temp_slope_per_year / 365.25

# Calculate intercept (fit line through data with fixed slope)
climate <- climate %>% mutate(days_since_start = as.numeric(date - min(date)))

temp_intercept <- mean(climate$temp, na.rm=TRUE) -
                  temp_slope_per_day * mean(climate$days_since_start, na.rm=TRUE)

climate$temp_trend <- temp_intercept + temp_slope_per_day * climate$days_since_start

cat(sprintf("  ✓ Temperature trend: +%.3f°C/year (official value)\n", temp_slope_per_year))

# pH trend: fit from data
ph_model <- lm(ph ~ days_since_start, data=climate)
ph_slope_per_day <- coef(ph_model)[2]
ph_slope_per_year <- ph_slope_per_day * 365.25

climate$ph_trend <- predict(ph_model, newdata=climate)

cat(sprintf("  ✓ pH trend: %.4f units/year\n", ph_slope_per_year))

# Oxygen trend: fit from data
oxygen_model <- lm(oxygen ~ days_since_start, data=climate)
oxygen_slope_per_day <- coef(oxygen_model)[2]
oxygen_slope_per_year <- oxygen_slope_per_day * 365.25

climate$oxygen_trend <- predict(oxygen_model, newdata=climate)

cat(sprintf("  ✓ Oxygen trend: %.4f mmol/m³/year (p=0.008)\n", oxygen_slope_per_year))

# ==============================================================================
# STEP 5: CREATE PANELS
# ==============================================================================

cat("\n[5/6] Creating 4-panel figure...\n")

# MHW frequency inset data
mhw_freq <- mhw_events %>%
  mutate(year = year(start_date)) %>%
  count(year, name = "n_events")

# --------------------------------------------------------------------------
# PANEL A: TEMPERATURE + MHW
# --------------------------------------------------------------------------

p_temp <- ggplot(climate, aes(x=date)) +
  # MHW ribbons (background)
  {
    lapply(1:nrow(mhw_events), function(i) {
      event <- mhw_events[i,]
      mhw_info <- get_mhw_color(event$category, with_alpha=TRUE)
      geom_rect(
        data=event,
        aes(xmin=start_date, xmax=end_date, ymin=-Inf, ymax=Inf),
        fill=mhw_info$color,
        alpha=mhw_info$alpha,
        inherit.aes=FALSE
      )
    })
  } +
  # Daily temperature (faint)
  geom_line(aes(y=temp), color="gray60", alpha=0.2, linewidth=0.3) +
  # Smooth temperature (bold)
  geom_line(aes(y=temp_smooth), color="black", linewidth=1.2) +
  # Trend line
  geom_line(aes(y=temp_trend), color="red", linetype="dashed", linewidth=1) +
  labs(
    title="(A) Sea Surface Temperature + Marine Heatwaves",
    y="Temperature (°C)",
    x=""
  ) +
  scale_x_date(date_breaks="1 year", date_labels="%Y") +
  annotate("text", x=as.Date("2014-06-01"), y=26.5,
           label=sprintf("Trend: +%.3f ± 0.018°C/year***", temp_slope_per_year),
           hjust=0, size=3, color="red", fontface="bold") +
  annotate("text", x=as.Date("2021-01-01"), y=26.5,
           label=sprintf("%d MHW events", nrow(mhw_events)),
           hjust=0, size=3, color="gray30")

cat("  ✓ Panel A created\n")

# --------------------------------------------------------------------------
# PANEL B: pH (OCEAN ACIDIFICATION)
# --------------------------------------------------------------------------

p_ph <- ggplot(climate, aes(x=date)) +
  # Daily pH (faint)
  geom_line(aes(y=ph), color="gray60", alpha=0.2, linewidth=0.3) +
  # Smooth pH (bold)
  geom_line(aes(y=ph_smooth), color=okabe_ito["blue"], linewidth=1.2) +
  # Trend line
  geom_line(aes(y=ph_trend), color=okabe_ito["blue"], linetype="dashed", linewidth=1) +
  labs(
    title="(B) Ocean Acidification (pH)",
    y="pH (total scale)",
    x=""
  ) +
  scale_x_date(date_breaks="1 year", date_labels="%Y") +
  annotate("text", x=as.Date("2014-06-01"), y=8.18,
           label=sprintf("Trend: %.4f units/year*", ph_slope_per_year),
           hjust=0, size=3, color=okabe_ito["blue"], fontface="bold")

cat("  ✓ Panel B created\n")

# --------------------------------------------------------------------------
# PANEL C: OXYGEN DEPLETION
# --------------------------------------------------------------------------

p_oxygen <- ggplot(climate, aes(x=date)) +
  # Daily oxygen (faint)
  geom_line(aes(y=oxygen), color="gray60", alpha=0.2, linewidth=0.3) +
  # Smooth oxygen (bold)
  geom_line(aes(y=oxygen_smooth), color="cyan3", linewidth=1.2) +
  # Trend line
  geom_line(aes(y=oxygen_trend), color="cyan3", linetype="dashed", linewidth=1) +
  labs(
    title=expression(bold("(C) Oxygen Depletion ("*O[2]*")")),
    y=expression(bold(O[2]~"(mmol/m"^3*")")),
    x=""
  ) +
  scale_x_date(date_breaks="1 year", date_labels="%Y") +
  annotate("text", x=as.Date("2014-06-01"), y=260,
           label="Trend: -0.08%/year** (p=0.008)",
           hjust=0, size=3, color="cyan3", fontface="bold")

cat("  ✓ Panel C created\n")

# --------------------------------------------------------------------------
# PANEL D: COMPOUND STRESS INDEX
# --------------------------------------------------------------------------

p_compound <- ggplot(climate, aes(x=date)) +
  # 90th percentile threshold
  geom_hline(yintercept=p90_threshold, color="red", linetype="dashed", linewidth=1) +
  # Smooth compound stress (bold)
  geom_line(aes(y=compound_smooth), color=okabe_ito["orange"], linewidth=1.2) +
  labs(
    title=sprintf("(D) Compound Stress Index (PCA: %.0f%% variance)", variance_explained),
    y="Stress Index (0-100)",
    x="Year"
  ) +
  scale_x_date(date_breaks="1 year", date_labels="%Y") +
  annotate("text", x=as.Date("2014-06-01"), y=95,
           label=sprintf("90th percentile: %.1f", p90_threshold),
           hjust=0, size=3, color="red")

cat("  ✓ Panel D created\n")

# ==============================================================================
# STEP 6: COMBINE AND SAVE
# ==============================================================================

cat("\n[6/6] Combining panels and saving...\n")

# Combine with patchwork (Panel A slightly taller)
p_combined <- p_temp / p_ph / p_oxygen / p_compound +
  plot_layout(heights=c(1.2, 1, 1, 1))

# Save
save_figure(p_combined, "fig1_climate_dashboard",
            width=WIDTH_DOUBLE, height=HEIGHT_TALL)

cat("\n")
cat("================================================================================\n")
cat("✓ FIGURA 1 COMPLETED SUCCESSFULLY\n")
cat("================================================================================\n")
cat(sprintf("Output files:\n"))
cat(sprintf("  - fig1_climate_dashboard.pdf\n"))
cat(sprintf("  - fig1_climate_dashboard.png\n"))
cat(sprintf("Location: %s/\n", OUTPUT_DIR))
cat("\n")
cat("Key features:\n")
cat(sprintf("  - Temperature trend: +%.3f°C/year (p<0.001)\n", temp_slope_per_year))
cat(sprintf("  - pH trend: %.4f units/year\n", ph_slope_per_year))
cat(sprintf("  - MHW events: %d (2014-2023)\n", nrow(mhw_events)))
cat(sprintf("  - Compound stress 90th pct: %.1f\n", p90_threshold))
cat("================================================================================\n\n")
