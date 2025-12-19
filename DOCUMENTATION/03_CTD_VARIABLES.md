# CTD Oceanographic Variables Documentation

## Dataset Overview

**File**: `ctd_oceanographic.csv`
**Sample Size**: 68,164 measurements
**Temporal Coverage**: 2015-2025 (11 years)
**Campaigns**: 21 seasonal campaigns
- Summer (Estate): E15-E25 (11 campaigns)
- Winter (Inverno): I16-I25 (10 campaigns)
**Measurement Type**: In-situ oceanographic profiles
**Instrument**: CTD (Conductivity-Temperature-Depth) profilers
**Spatial Coverage**: Complete monitoring network (MG1-MG14 stations plus terminal area)

---

## Variable Descriptions

### Temporal Variables

#### `campaign`
- **Description**: Campaign identifier code
- **Format**: [E/I][YY] where E=Estate (Summer), I=Inverno (Winter), YY=year
- **Example Values**: "E15", "I16", "E17", "I18"
- **Total Campaigns**: 21 campaigns (11 summer + 10 winter)
- **Temporal Range**: 2015-2025

#### `sampling_date`
- **Description**: Date of CTD measurement
- **Format**: YYYY-MM-DD
- **Quality**: 100% real dates (October 2025 update - all estimated dates replaced with confirmed dates)
- **Range**: 2015-2025
- **Validation**: Cross-validated with campaign metadata and field logs

#### `year`
- **Description**: Sampling year (4-digit format)
- **Range**: 2015-2025
- **Type**: Integer
- **Derivation**: Extracted from confirmed sampling dates

#### `season`
- **Description**: Seasonal period of measurement
- **Values**:
  - **Summer**: Estate campaigns (E15-E25)
  - **Winter**: Inverno campaigns (I16-I25)
- **Oceanographic Significance**: Mediterranean seasonal stratification patterns

---

### Spatial Variables

#### `station`
- **Description**: CTD sampling station identifier
- **Station Network**:
  - **MG1, MG2**: Control stations (1000-2000m from terminal)
  - **MG3-MG8**: Intermediate impact zone (300-500m from terminal)
  - **MG9, MG10**: Distant southern controls (1000-2000m)
  - **MG11-MG14**: High impact zone (100-300m from terminal)
  - **Terminal area**: Direct measurements near discharge points
- **Total Stations**: 14 primary stations (MG1-MG14) plus additional terminal positions
- **Spatial Design**: Gradient sampling design around OLT regasification terminal

#### `station_type`
- **Description**: Station classification by distance from terminal
- **Values**:
  - **control**: Distant stations (MG1-MG2, MG9-MG10) >1000m from terminal
  - **intermediate**: Mid-distance stations (MG3-MG8) 300-500m from terminal
  - **impact**: Near-terminal stations (MG11-MG14) 100-300m from terminal
  - **terminal**: Direct terminal area measurements
- **Purpose**: Spatial gradient analysis of terminal influence

#### `depth_m`
- **Description**: Measurement depth below sea surface
- **Units**: Meters (m)
- **Range**: 0-50m (most measurements)
- **Distribution**:
  - Surface (0-2m): 7.8% of measurements
  - Near-surface (5-15m): 10.1% - mussel deployment zone
  - Deep (>25m): 72.5% - deep reference measurements
- **Significance**: 10m depth critical for mussel biomarker correlation

---

### Oceanographic Variables

#### `temperature_c`
- **Description**: In-situ seawater temperature
- **Units**: Degrees Celsius (°C)
- **Instrument**: CTD temperature sensor (precision ±0.002°C)
- **Range**: ~12-26°C (Mediterranean seasonal range)
- **Depth Variation**: Surface warmer, deep cooler (thermal stratification)
- **Validation**: Spearman ρ=0.886-0.899 vs Copernicus Marine models (GOOD-EXCELLENT agreement)

#### `ph`
- **Description**: Seawater pH (acidity/alkalinity)
- **Units**: pH units (dimensionless)
- **Scale**: Total pH scale
- **Range**: 7.9-8.4 (typical Mediterranean seawater)
- **Instrument**: CTD pH sensor or discrete water sample analysis
- **Environmental Significance**: Ocean acidification monitoring, biomarker stress correlation
- **Note**: pH decreases with depth (CO₂ increase)

#### `salinity_psu`
- **Description**: Seawater salinity (Practical Salinity Units)
- **Units**: PSU (dimensionless, equivalent to ppt)
- **Instrument**: CTD conductivity sensor (derived from conductivity and temperature)
- **Range**: 37.5-38.5 PSU (characteristic Mediterranean high salinity)
- **Precision**: ±0.003 PSU
- **Environmental Significance**: Mediterranean salinity higher than global ocean average (~35 PSU)

#### `dissolved_oxygen_mg_l`
- **Description**: Dissolved oxygen concentration
- **Units**: mg/L (milligrams per liter)
- **Alternative Units**: Can be converted to μmol/kg or % saturation
- **Instrument**: CTD oxygen sensor (optical or Clark electrode)
- **Range**: Variable with depth and season
- **Environmental Significance**: Hypoxia assessment, biomarker respiratory stress correlation
- **Depth Pattern**: Generally decreases with depth (oxygen consumption)

---

## Data Processing

### Original Data Sources
- **Primary Source**: `Letture CTD totali 2013 2025.xlsx` (3.0 MB Excel file)
- **Sheet Formats**: 3 different Excel sheet structures requiring multi-pattern conversion
- **Processing Pipeline**:
  1. Multi-pattern Excel sheet detection and conversion
  2. Date extraction and validation
  3. Station name standardization
  4. Depth binning and quality control

### Date Quality (October 2025 Update)
- **100% Real Dates**: All 68,164 measurements now have confirmed sampling dates
- **Previous Status**: 25.2% estimated dates using T0+15 day logic
- **Improvement**: Complete replacement of estimated dates with field-confirmed dates
- **Validation**: Cross-checked with campaign metadata and logbooks

---

## Quality Assurance

### CTD Validation Against Copernicus Marine Models

**Surface Temperature (0-2m depth vs Copernicus SST)**:
- **Spearman ρ**: 0.899 (p=1.24×10⁻⁵) - GOOD correlation
- **Bootstrap 95% CI**: [0.606, 0.991]
- **Lin's CCC**: 0.995 - EXCELLENT agreement
- **RMSE**: 0.573°C
- **Bias**: +0.159°C (CTD slightly warmer)

**10m Depth (9-11m depth vs Copernicus thetao_10m)**:
- **Spearman ρ**: 0.886 (p=2.50×10⁻⁵) - GOOD correlation
- **Bootstrap 95% CI**: [0.576, 0.978]
- **Lin's CCC**: 0.996 - EXCELLENT agreement
- **RMSE**: 0.508°C
- **Bias**: -0.069°C (minimal systematic difference)

### Statistical Validation Methodology
- **Conservative Non-parametric**: Spearman correlation (no normality assumption)
- **Bootstrap CI**: 10,000 bootstrap samples for small sample correction (n=14 campaigns)
- **Agreement Assessment**: Lin's Concordance Correlation Coefficient (precision + accuracy)
- **Outlier Detection**: Modified Z-score method (14.3% outlier rate)

---

## Measurement Protocols

### CTD Profiling Procedure
- **Deployment**: Vertical casts from surface to maximum depth
- **Sampling Rate**: Continuous measurements (typically 4-24 Hz)
- **Descent Speed**: Slow controlled descent (~0.5 m/s) for accurate measurements
- **Quality Control**: Pre-deployment calibration, post-deployment validation

### Depth Binning
- **Surface**: 0-2m (direct surface layer)
- **Near-surface**: 5-15m (thermal mixing layer, mussel habitat)
- **Mid-depth**: 15-25m (seasonal thermocline)
- **Deep**: >25m (deep reference layer)

---

## Usage Notes

### This is a CLEAN dataset
- **Raw measurements only**: No calculated climate indices
- **No derived variables**: No Climate Change Index (CCI) or Climate Variability Index (CVI)
- **Original CTD data**: Direct instrument measurements preserved
- **Ready for analysis**: Start fresh oceanographic analysis

### Recommended Analysis Approaches
- **Vertical Profiling**: Analyze temperature/salinity/oxygen stratification
- **Seasonal Comparison**: Compare summer vs winter oceanographic conditions
- **Spatial Gradients**: Test for terminal discharge effects on water column properties
- **Biomarker Correlation**: Match 10m depth measurements with mussel deployment depth
- **Climate Trends**: Analyze multi-year temperature and pH trends

### Depth Selection Guidance
- **Surface (0-2m)**: Surface water characterization, satellite validation
- **10m depth**: **CRITICAL** - mussel deployment depth for biomarker correlation
- **>25m depth**: Deep reference conditions, vertical gradient assessment

---

**Data Origin**: CTD oceanographic campaigns 2015-2025, in-situ measurements with professional CTD profilers, validated against Copernicus Marine Service model data (GOOD-EXCELLENT agreement), 100% confirmed sampling dates (October 2025 update).
