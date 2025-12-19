# Copernicus Marine Models Variables Documentation

## Dataset Overview

**File**: `copernicus_models.csv`
**Version**: 2.0 (October 2025)
**Sample Size**: 150 data points (75 campaigns × 2 sites)
**Temporal Coverage**: 2014-2023
**Data Source**: Copernicus Marine Service (Mediterranean Sea Reanalysis products)
**Spatial Coverage**: Two monitoring sites in Ligurian Sea
- **Gorgona (Control)**: 43.4287°N, 9.9078°E - Natural environment
- **Terminal (Exposure)**: 43.6333°N, 9.9833°E - Regasification facility
**Extraction Method**: Site-specific nearest-neighbor extraction from source NetCDF files
**Grid Resolution**: ~4 km spatial resolution
**Processing Status**: 375 NetCDF files successfully processed (100% success rate)

---

## Variable Descriptions

### Temporal Variables

#### `campaign`
- **Description**: Biomarker campaign identifier for temporal alignment
- **Format**: [Season][Year] (e.g., A14, E14, I14, P14)
- **Season Codes**: A=Autumn, E=Summer, I=Winter, P=Spring
- **Total Campaigns**: 75 campaign-site combinations
- **Purpose**: Enables direct temporal alignment with biomarker sampling dates

#### `sampling_date`
- **Description**: Biomarker sampling date (campaign reference date)
- **Format**: YYYY-MM-DD
- **Range**: 2014-2023
- **Temporal Window**: Copernicus data extracted ±15 days around this date
- **Purpose**: Temporal anchor for environmental variable retrieval

#### `year`
- **Description**: Sampling year (4-digit format)
- **Range**: 2014-2023
- **Type**: Integer
- **Derivation**: Extracted from campaign code and sampling date

#### `season`
- **Description**: Meteorological season of sampling
- **Values**: Autumn, Summer, Winter, Spring
- **Mediterranean Significance**: Seasonal oceanographic patterns

---

### Spatial Variables

#### `station`
- **Description**: Monitoring site identifier
- **Values**:
  - **Gorgona**: Natural control site (Gorgona Island)
  - **Terminal** (or pos1-pos4): OLT regasification terminal exposure area
- **Coordinates**:
  - Gorgona: 43.4287°N, 9.9078°E
  - Terminal: 43.6333°N, 9.9833°E
- **Spatial Design**: Control vs Exposure comparison

#### `station_type`
- **Description**: Station classification
- **Values**:
  - **control**: Gorgona natural environment
  - **exposure**: Terminal area (industrial influence zone)

---

### Environmental Variables from Copernicus Marine Service

All environmental variables extracted from validated Mediterranean Sea reanalysis and forecast products using Copernicus Marine Service official data products.

#### `thetao` (Sea Water Potential Temperature)
- **Description**: Seawater temperature at measurement depth
- **Units**: Degrees Celsius (°C)
- **Depth**: Near-surface to 10m depth (mussel deployment zone)
- **Range**: 13.5-26.1°C (Mediterranean seasonal range documented)
- **Temporal Resolution**: Daily data available
- **Copernicus Product**: Mediterranean Sea Physics Reanalysis
- **Environmental Significance**: Primary climate variable, biomarker thermal stress correlation
- **Quality**: Complete coverage 2014-2023 with no missing data

#### `so` (Sea Water Salinity)
- **Description**: Practical salinity of seawater
- **Units**: PSU (Practical Salinity Units, dimensionless)
- **Depth**: Near-surface to 10m depth
- **Range**: 37.7-38.2 PSU (characteristic Mediterranean high salinity)
- **Temporal Resolution**: Daily data available
- **Copernicus Product**: Mediterranean Sea Physics Reanalysis
- **Environmental Significance**: Osmotic stress indicator, Mediterranean water mass characterization
- **Note**: Higher than global ocean average (~35 PSU) due to Mediterranean evaporation excess

#### `o2` (Dissolved Oxygen)
- **Description**: Dissolved oxygen concentration in seawater
- **Units**: mmol/m³ (millimoles per cubic meter)
- **Conversion**: Can be converted to mg/L (divide by ~31.25) or μmol/kg
- **Depth**: Near-surface to 10m depth
- **Range**: 213-255 mmol/m³ (Mediterranean oxygen levels)
- **Temporal Resolution**: Daily data available
- **Copernicus Product**: Mediterranean Sea Biogeochemistry Reanalysis
- **Environmental Significance**: Hypoxia/eutrophication stress indicator, biomarker respiratory stress correlation
- **Note**: Oxygen decreases with depth due to biological consumption

#### `no3` (Nitrate Concentration)
- **Description**: Dissolved nitrate (NO₃⁻) concentration
- **Units**: mmol/m³ (millimoles per cubic meter)
- **Depth**: Near-surface to 10m depth
- **Range**: 0.009-0.690 mmol/m³
- **Temporal Resolution**: Daily data available
- **Copernicus Product**: Mediterranean Sea Biogeochemistry Reanalysis
- **Environmental Significance**: Nutrient pollution indicator, primary productivity stress assessment, eutrophication impact
- **Ecological Role**: Limiting nutrient for phytoplankton growth in Mediterranean

#### `po4` (Phosphate Concentration)
- **Description**: Dissolved phosphate (PO₄³⁻) concentration
- **Units**: mmol/m³ (millimoles per cubic meter)
- **Depth**: Near-surface to 10m depth
- **Range**: 0.009-0.031 mmol/m³
- **Temporal Resolution**: Daily data available
- **Copernicus Product**: Mediterranean Sea Biogeochemistry Reanalysis
- **Environmental Significance**: Eutrophication stress indicator, nutrient dynamics, ecosystem stress complementary indicator
- **Note**: Typically lower concentration than nitrate in Mediterranean waters

---

## Data Extraction Methodology

### Copernicus Marine Service Products Used

**Physics Reanalysis** (Temperature, Salinity):
- **Product ID**: Mediterranean Sea Physics Reanalysis
- **Spatial Resolution**: ~4 km horizontal grid
- **Temporal Coverage**: 1987-present (used 2014-2023 for this study)
- **Variables**: thetao, so

**Biogeochemistry Reanalysis** (Oxygen, Nutrients):
- **Product ID**: Mediterranean Sea Biogeochemistry Reanalysis
- **Spatial Resolution**: ~4 km horizontal grid
- **Temporal Coverage**: 1999-present (used 2014-2023 for this study)
- **Variables**: o2, no3, po4

### Extraction Protocol (Version 2.0 - October 2025)

**Site-Specific Extraction** (Critical Update):
- **Method**: Nearest-neighbor selection using exact site coordinates
- **Gorgona**: 43.4287°N, 9.9078°E (Control site)
- **Terminal**: 43.6333°N, 9.9833°E (Exposure site)
- **Improvement**: Previous BBOX method didn't preserve spatial distinction between sites
- **Result**: Complete dataset enabling proper Control vs Exposure comparison

**Temporal Alignment**:
- Campaign sampling date ± 15 days window
- Daily values averaged within window
- Ensures environmental conditions representative of biomarker sampling period

**Spatial Alignment**:
- Nearest grid point to each station's exact coordinates
- Grid resolution ~4 km sufficient for site characterization
- Independent extractions for Gorgona and Terminal sites
- Each campaign produces 2 records (1 per site)

**Depth Selection**:
- Near-surface to 10m depth range
- Matches mussel deployment depth zone
- Enables direct environmental-biomarker correlation

**Processing Pipeline**:
1. Campaign metadata extraction (date, both site coordinates)
2. NetCDF file access from source data (375 files total)
3. For each site: Spatial subset using nearest-neighbor selection
4. Temporal subset (±15 day window)
5. Depth subset (surface to 10m)
6. Temporal averaging within window
7. Quality control (range validation, missing data check)
8. Combine Gorgona + Terminal records for each campaign

---

## Quality Assurance

### Data Completeness (v2.0)
- **100% Campaign Coverage**: All 75 campaigns with data for both sites (150 total records)
- **100% Site Coverage**: Both Gorgona (75 records) and Terminal (75 records) complete
- **Zero Missing Data**: Complete environmental variable coverage 2014-2023
- **Processing Success**: 375 NetCDF files processed (100% success rate)

### Value Validation (v2.0)
- **Temperature**: 13.57-26.28°C - within expected Mediterranean range ✓
- **Salinity**: 37.41-38.28 PSU - characteristic Mediterranean high salinity ✓
- **Oxygen**: 211.87-254.47 mmol/m³ - within Mediterranean oxygen range ✓
- **Nitrate**: 0.28-1.74 mmol/m³ - typical Mediterranean nutrient levels ✓
- **Phosphate**: 0.00-0.08 mmol/m³ - typical Mediterranean nutrient levels ✓

### Cross-Validation
- **CTD Validation**: Copernicus temperature validated against in-situ CTD measurements
  - Surface: Spearman ρ=0.899 (GOOD correlation)
  - 10m depth: Spearman ρ=0.886 (GOOD correlation)
  - Agreement: Lin's CCC=0.995-0.996 (EXCELLENT)
- **Validation Methodology**: Conservative non-parametric framework with bootstrap confidence intervals

### Data Source Authority
- **Copernicus Marine Service**: Official EU Earth observation program
- **Scientific Validation**: Peer-reviewed model products used in international research
- **Operational Status**: Production-quality data used for Mediterranean monitoring and forecasting
- **No Synthetic Data**: 100% real measurements from validated oceanographic models

---

## Oceanographic Context

### Mediterranean Sea Characteristics
- **High Salinity**: Evaporation > Precipitation + River Input
- **Oligotrophic**: Low nutrient concentrations (phosphorus-limited)
- **Warm Temperate**: Seasonal temperature range 13-26°C
- **Deep Water Formation**: Winter cooling drives vertical mixing
- **Climate Sensitivity**: Warming faster than global ocean average

### Ligurian Sea Specifics
- **Northern Mediterranean**: Cooler winter temperatures than southern Mediterranean
- **Seasonal Stratification**: Strong summer thermocline, winter mixing
- **Nutrient Dynamics**: Winter mixing brings nutrients to surface, summer depletion
- **Oxygen Levels**: Generally well-oxygenated (no major hypoxia zones)

---

## Usage Notes

### This is a CLEAN dataset
- **Raw environmental variables only**: No calculated climate indices
- **No trend analysis**: Climate Change Index (CCI) NOT included
- **No detrended variables**: Climate Variability Index (CVI) NOT included
- **Original Copernicus data**: Model output values preserved
- **Ready for analysis**: Start fresh climate correlation analysis

### Recommended Analysis Approaches
- **Climate Trend Analysis**: Multi-year temperature, pH, oxygen trends
- **Seasonal Patterns**: Mediterranean seasonal oceanographic cycles
- **Biomarker Correlation**: Direct correlation with biomarker responses
- **Spatial Comparison**: Gorgona control vs Terminal exposure environmental differences
- **Multi-Variable Integration**: Combined environmental stress assessment

### Variable Selection Guidance
- **Temperature (thetao)**: Primary climate variable, strongest biomarker correlation
- **pH**: Ocean acidification indicator (if available from additional sources)
- **Oxygen (o2)**: Hypoxia stress, respiratory biomarker correlation
- **Nutrients (no3, po4)**: Eutrophication indicators, ecosystem stress

### Temporal Alignment Considerations
- **±15 Day Window**: Balances temporal specificity with data availability
- **Campaign-Based**: Aligns with biomarker sampling campaigns
- **Seasonal Representation**: Captures environmental conditions during exposure period

---

**Data Origin**: Copernicus Marine Service official Mediterranean Sea reanalysis products (Physics and Biogeochemistry), 2014-2023 temporal coverage, ~4km spatial resolution, validated against in-situ CTD measurements (GOOD-EXCELLENT agreement), 100% campaign coverage with zero missing data.
