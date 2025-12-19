# Marine Heatwaves Variables Documentation

## Dataset Overview

**Files**:
- `marine_heatwaves/daily_temperature_heatwaves.csv` - Daily temperature and heatwave status (3,438 records)
- `marine_heatwaves/heatwave_events.csv` - Discrete heatwave events summary (19 events)
- `marine_heatwaves/climatology_p90_thresholds.csv` - Climatological thresholds (366 daily values)

**Temporal Coverage**: 2014-01-01 to 2023-05-31 (3,438 days)
**Data Source**: Copernicus Marine Service Mediterranean temperature reanalysis
**Spatial Coverage**: Ligurian Sea monitoring area (Gorgona and Terminal sites)
**Methodology**: 90th percentile threshold with 5+ consecutive day minimum duration
**Event Detection**: 19 discrete marine heatwave events identified

---

## File 1: Daily Temperature and Heatwave Status

**File**: `daily_temperature_heatwaves.csv`
**Records**: 3,438 daily observations

### Temporal Variables

#### `date`
- **Description**: Calendar date of observation
- **Format**: YYYY-MM-DD
- **Range**: 2014-01-01 to 2023-05-31
- **Temporal Resolution**: Daily (complete daily coverage, no gaps)
- **Total Days**: 3,438 consecutive days

#### `year`
- **Description**: Calendar year
- **Range**: 2014-2023 (10 years)
- **Type**: Integer
- **Purpose**: Annual aggregation and trend analysis

#### `month`
- **Description**: Calendar month (1-12)
- **Range**: 1 (January) to 12 (December)
- **Type**: Integer
- **Purpose**: Seasonal pattern analysis

#### `day_of_year`
- **Description**: Day number within year (Julian day)
- **Range**: 1-366 (accounts for leap years)
- **Type**: Integer
- **Purpose**: Climatology alignment, seasonal cycle analysis

---

### Temperature Variables

#### `sst_c` (Sea Surface Temperature)
- **Description**: Daily sea surface temperature
- **Units**: Degrees Celsius (°C)
- **Source**: Copernicus Marine Service Mediterranean temperature reanalysis
- **Product**: med-cmcc-tem-rean-d (Mediterranean CMCC Temperature Reanalysis Daily)
- **Spatial Resolution**: ~4 km grid
- **Temporal Resolution**: Daily
- **Range**: ~12-27°C (Mediterranean seasonal range)
- **Derivation**: Extracted from thetao_5m (5-meter depth temperature) as surface reference
- **Quality**: 100% data coverage (no missing days)

#### `threshold_p90_c` (90th Percentile Threshold)
- **Description**: Climatological 90th percentile temperature threshold for this day of year
- **Units**: Degrees Celsius (°C)
- **Methodology**: Calculated from full time series (2014-2023) for each day of year
- **Purpose**: Marine heatwave definition threshold
- **Range**: Variable by season (higher in summer, lower in winter)
- **Calculation**: 90th percentile of all temperatures observed on this calendar day across all years
- **Leap Year Handling**: 366 unique thresholds (includes Feb 29)

#### `intensity_above_p90`
- **Description**: Temperature anomaly above 90th percentile threshold
- **Units**: Degrees Celsius (°C)
- **Calculation**: `sst_c - threshold_p90_c`
- **Positive Values**: Temperature exceeds threshold (potential heatwave condition)
- **Negative Values**: Temperature below threshold (normal conditions)
- **Zero**: Temperature exactly at threshold
- **Maximum Observed**: +1.66°C above threshold (strong marine heatwave)
- **Purpose**: Quantify heatwave intensity

---

### Heatwave Status Variables

#### `is_heatwave`
- **Description**: Boolean flag indicating if this day meets heatwave temperature criterion
- **Values**:
  - **True (1)**: Temperature exceeds 90th percentile threshold
  - **False (0)**: Temperature below threshold
- **Type**: Boolean
- **Note**: Single day above threshold does NOT constitute a heatwave event (requires 5+ consecutive days)

#### `in_event`
- **Description**: Boolean flag indicating if this day is part of a discrete marine heatwave event
- **Values**:
  - **True (1)**: Part of event (≥5 consecutive days above threshold)
  - **False (0)**: Not part of event
- **Type**: Boolean
- **Event Definition**: ≥5 consecutive days with temperature above 90th percentile threshold
- **Total Event Days**: 366 days across 19 discrete events (10.6% of study period)

#### `event_id`
- **Description**: Unique identifier for discrete marine heatwave events
- **Values**: 1-19 (for days within events), NaN (for non-event days)
- **Type**: Integer (nullable)
- **Purpose**: Group consecutive heatwave days into discrete events
- **Event Count**: 19 discrete marine heatwave events detected (2014-2023)

#### `event_category`
- **Description**: Scientific classification of marine heatwave intensity
- **Values**:
  - **Moderate**: 0-1°C above 90th percentile threshold
  - **Strong**: 1-2°C above 90th percentile threshold
  - **Severe**: 2-3°C above threshold (not observed in this study)
  - **Extreme**: >3°C above threshold (not observed in this study)
- **Type**: String (categorical)
- **Methodology**: Based on Hobday et al. (2018) marine heatwave classification
- **Distribution**: 15 Moderate events, 4 Strong events (no Severe or Extreme observed)

---

## File 2: Heatwave Events Summary

**File**: `heatwave_events.csv`
**Records**: 19 discrete marine heatwave events

### Event Identification Variables

#### `event_id`
- **Description**: Unique sequential identifier for each discrete event
- **Range**: 1-19
- **Type**: Integer
- **Purpose**: Link daily data to event summary

---

### Event Timing Variables

#### `start_date`
- **Description**: First day of marine heatwave event
- **Format**: YYYY-MM-DD
- **Range**: 2014-2023
- **Definition**: First day in sequence of ≥5 consecutive days above threshold

#### `end_date`
- **Description**: Last day of marine heatwave event
- **Format**: YYYY-MM-DD
- **Range**: 2014-2023
- **Definition**: Last day before temperature drops below threshold for event termination

#### `duration_days`
- **Description**: Event duration in days
- **Units**: Days (integer)
- **Range**: 5-44 days
- **Mean**: 17.7 days (average event duration)
- **Minimum**: 5 days (by definition)
- **Maximum**: 44 days (longest event observed)
- **Total**: 366 heatwave days across all 19 events

---

### Event Intensity Variables

#### `max_intensity_celsius_above_p90`
- **Description**: Maximum temperature anomaly during event
- **Units**: Degrees Celsius (°C)
- **Range**: 0.1-1.66°C above threshold
- **Mean**: ~0.6°C above threshold (average peak intensity)
- **Maximum**: 1.66°C (strongest event observed)
- **Purpose**: Quantify peak thermal stress during event

#### `mean_intensity_celsius_above_p90`
- **Description**: Average temperature anomaly across event duration
- **Units**: Degrees Celsius (°C)
- **Range**: Variable (always positive by definition)
- **Calculation**: Mean of daily `intensity_above_p90` values during event
- **Purpose**: Quantify sustained thermal stress level

#### `cumulative_intensity_celsius_days`
- **Description**: Integrated thermal stress over event duration
- **Units**: Degree-days (°C × days)
- **Calculation**: Sum of daily `intensity_above_p90` values during event
- **Range**: Variable (higher for longer and/or more intense events)
- **Purpose**: Quantify total thermal stress exposure (duration × intensity)
- **Ecological Relevance**: Cumulative stress often more relevant than peak intensity for biological impacts

---

### Event Classification Variables

#### `category`
- **Description**: Scientific classification of event intensity
- **Values**:
  - **Moderate**: 0-1°C above threshold (15 events)
  - **Strong**: 1-2°C above threshold (4 events)
- **Type**: String (categorical)
- **Methodology**: Based on maximum intensity during event
- **Distribution**: Majority moderate events, minority strong events
- **Note**: No Severe (2-3°C) or Extreme (>3°C) events observed in this study period

---

## File 3: Climatological Thresholds

**File**: `climatology_p90_thresholds.csv`
**Records**: 366 daily thresholds (includes leap year Feb 29)

### Variables

#### `day_of_year`
- **Description**: Day number within year (Julian day)
- **Range**: 1-366 (includes leap year day 366 = Feb 29)
- **Type**: Integer
- **Purpose**: Link daily observations to climatological threshold

#### `p90_threshold_celsius`
- **Description**: 90th percentile temperature threshold for this day of year
- **Units**: Degrees Celsius (°C)
- **Calculation**: 90th percentile of all SST values observed on this calendar day across 2014-2023
- **Range**: Variable (seasonal cycle from ~13°C winter to ~25°C summer)
- **Sample Size**: ~10 observations per day of year (10 years of data)
- **Purpose**: Define marine heatwave temperature criterion for each calendar day

#### `date_reference`
- **Description**: Example calendar date (for visualization, uses 2020 as reference year)
- **Format**: YYYY-MM-DD (all dates show 2020-MM-DD)
- **Purpose**: Visual reference for seasonal timing (month-day identification)
- **Note**: Year 2020 chosen arbitrarily for leap year compatibility

---

## Marine Heatwave Methodology

### Definition (Based on Hobday et al. 2018)

**Temperature Threshold**: 90th percentile of climatological distribution for each day of year

**Duration Criterion**: ≥5 consecutive days with temperature above threshold

**Intensity Calculation**: Temperature anomaly above threshold (°C)

**Category Classification**:
- **Moderate**: 0-1°C above threshold
- **Strong**: 1-2°C above threshold
- **Severe**: 2-3°C above threshold
- **Extreme**: >3°C above threshold

### Climatology Construction

**Reference Period**: 2014-2023 (full study period)

**Baseline Calculation**:
- For each day of year (1-366)
- Calculate 90th percentile of all temperatures observed on that calendar day
- Accounts for seasonal temperature cycle

**Leap Year Handling**: 366 thresholds (includes Feb 29)

### Event Detection Algorithm

**Step 1**: Identify days with temperature > threshold (is_heatwave = True)

**Step 2**: Find consecutive sequences of ≥5 days

**Step 3**: Assign unique event_id to each sequence

**Step 4**: Calculate event metrics (duration, max intensity, mean intensity, cumulative intensity)

**Step 5**: Classify event category based on maximum intensity

---

## Ecological and Environmental Significance

### Marine Heatwave Impacts

**Thermal Stress**: Exceeds normal thermal adaptation range for marine organisms

**Biomarker Correlation**: Elevated temperatures correlate with biomarker stress responses

**Ecosystem Disruption**: Can cause mortality events, range shifts, community changes

**Climate Change Context**: Mediterranean experiencing increased frequency and intensity of marine heatwaves

### Study Period Statistics (2014-2023)

**Total Events**: 19 discrete marine heatwave events

**Total Heatwave Days**: 366 days (10.6% of study period)

**Event Frequency**: ~2 events per year on average

**Average Event Duration**: 17.7 days

**Longest Event**: 44 days

**Strongest Event**: +1.66°C above threshold

**Seasonal Distribution**: Events occur all seasons with summer concentration

---

## Quality Assurance

### Data Completeness
- **3,438 Daily Records**: Complete daily coverage 2014-2023 (no missing days)
- **366 Threshold Values**: Complete climatology including leap year (Feb 29)
- **19 Complete Events**: All events fully characterized with start/end dates and intensity metrics

### Methodology Validation
- **90th Percentile Threshold**: Standard marine heatwave definition (Hobday et al. 2018)
- **5-Day Minimum Duration**: International standard for marine heatwave definition
- **Temperature Source**: Validated Copernicus Marine Service reanalysis product
- **Climatology Period**: 2014-2023 provides robust 10-year baseline

### Value Validation
- **Temperature Range**: 12-27°C consistent with Mediterranean seasonal range
- **Threshold Range**: 90th percentiles consistent with expected seasonal cycle
- **Intensity Range**: 0-1.66°C above threshold consistent with Moderate-Strong classification
- **Duration Range**: 5-44 days within typical marine heatwave event duration range

---

## Usage Notes

### This is a CLEAN dataset
- **Raw heatwave detection only**: No calculated Heat Exposure Indices (HEI)
- **No biomarker correlation**: HEI indices linking heatwaves to biomarker stress NOT included
- **No annual metrics**: Annual heatwave summary statistics NOT included
- **Basic event detection**: Standard marine heatwave definition applied
- **Ready for analysis**: Start fresh heatwave impact analysis

### Recommended Analysis Approaches
- **Biomarker Correlation**: Correlate heatwave events with biomarker stress responses
- **Temporal Trend Analysis**: Test for increasing frequency/intensity over 2014-2023
- **Seasonal Patterns**: Analyze seasonal distribution of events
- **Cumulative Stress**: Use cumulative intensity for biological impact assessment
- **Event Comparison**: Compare Moderate vs Strong event characteristics

### Data Files Integration
- **Daily Data**: Primary dataset for time series analysis and biomarker correlation
- **Event Summary**: Secondary dataset for event-level statistics
- **Climatology**: Reference dataset for threshold visualization and methodology documentation

### Important Methodological Notes
- **Relative Definition**: Thresholds based on local climatology (not absolute temperatures)
- **Conservative Detection**: 5-day minimum excludes brief warm spells
- **Intensity Matters**: Both peak and cumulative intensity relevant for biological impacts
- **Event Independence**: Events separated by ≥1 day below threshold

---

**Data Origin**: Copernicus Marine Service Mediterranean temperature reanalysis (med-cmcc-tem-rean-d), daily SST 2014-2023, marine heatwave detection using standard 90th percentile threshold methodology (Hobday et al. 2018), 19 discrete events identified with scientific intensity classification (Moderate/Strong), complete daily coverage with no missing data.
