# Copernicus Daily Time Series Variables Documentation

## Dataset Overview

**File**: `copernicus_models_daily.csv`
**Version**: 1.0 (October 2025)
**Sample Size**: 6,876 daily observations (3,438 days × 2 sites)
**Temporal Coverage**: 2014-01-01 to 2023-05-31
**Data Source**: Copernicus Marine Service (Mediterranean Sea Reanalysis products)
**Spatial Coverage**: Two monitoring sites in Ligurian Sea
- **Gorgona (Control)**: 43.4287°N, 9.9078°E - Natural environment
- **Terminal (Exposure)**: 43.6333°N, 9.9833°E - Regasification facility
**Extraction Method**: Nearest-neighbor selection from daily NetCDF files
**Grid Resolution**: ~4 km spatial resolution
**Depth**: 10m (mussel deployment zone)
**Temporal Resolution**: Daily (continuous time series)
**Processing Status**: Complete extraction from 80 NetCDF files (25 GB total)
**Data Completeness**: 100% coverage for all 6 variables

---

## Purpose and Advantages

This dataset represents a **significant improvement** over the campaign-based Copernicus data (`copernicus_models.csv`) for climate trend analysis:

### Why This Dataset is Needed

1. **Statistical Power**: ~3,400 daily observations vs ~75 campaign dates
   - **46× more data points** for trend detection
   - Adequate sample size for robust Mann-Kendall tests
   - Better confidence intervals for trend estimation

2. **Temporal Continuity**: No sampling gaps
   - Captures all seasonal variations
   - No bias from campaign scheduling
   - Complete annual cycles for all years

3. **Climate Analysis Validity**:
   - Campaign-based data: Unsuitable for decadal trend analysis (too sparse)
   - Daily data: Standard approach for climate studies (IPCC, literature)
   - Enables comparison with published Mediterranean warming rates

4. **New Variable**: **pH included for first time**
   - Ocean acidification monitoring
   - Critical climate change indicator
   - Never analyzed in previous campaign data

### Comparison with Campaign Data

| Aspect | Campaign Data | Daily Data (This File) |
|--------|---------------|------------------------|
| **Data Points** | ~75 per site | ~3,438 per site |
| **Temporal Resolution** | Quarterly (sparse) | Daily (continuous) |
| **Trend Power** | Low (inadequate) | High (adequate) |
| **Seasonal Bias** | Possible | None |
| **Variables** | 5 (no pH) | **6 (includes pH)** |
| **Use Case** | Biomarker correlation | **Climate trend analysis** |

---

## Variable Descriptions

### Temporal Variables

#### `date`
- **Description**: Calendar date of measurement
- **Format**: YYYY-MM-DD (ISO 8601)
- **Range**: 2014-01-01 to 2023-05-31
- **Temporal Resolution**: Daily (no gaps within coverage period)
- **Total Days**: 3,438 consecutive days
- **Note**: 2023 data ends May 31 (partial year)

#### `year`
- **Description**: Calendar year
- **Range**: 2014-2023 (10 years, 2023 partial)
- **Type**: Integer
- **Complete Years**: 2014-2022 (9 complete years)
- **Partial Year**: 2023 (January-May only, 151 days)

#### `month`
- **Description**: Calendar month (1-12)
- **Range**: 1 (January) to 12 (December)
- **Type**: Integer

#### `day_of_year`
- **Description**: Day number within year (Julian day)
- **Range**: 1-366 (accounts for leap years)
- **Type**: Integer
- **Purpose**: Seasonal cycle analysis, climatology alignment

#### `season`
- **Description**: Meteorological season
- **Values**:
  - **Winter**: December, January, February
  - **Spring**: March, April, May
  - **Summer**: June, July, August
  - **Autumn**: September, October, November
- **Mediterranean Significance**: Pronounced seasonal oceanographic patterns

---

### Spatial Variables

#### `site`
- **Description**: Monitoring site identifier
- **Values**:
  - **Gorgona**: Natural control site (Gorgona Island)
  - **Terminal**: OLT regasification terminal exposure area
- **Coordinates**:
  - Gorgona: 43.4287°N, 9.9078°E
  - Terminal: 43.6333°N, 9.9833°E
- **Distance**: ~22 km between sites
- **Spatial Design**: Control vs Exposure comparison

#### `site_type`
- **Description**: Site classification
- **Values**:
  - **Control**: Gorgona natural environment
  - **Exposure**: Terminal industrial influence zone

---

### Environmental Variables from Copernicus Marine Service

All variables extracted at **10m depth** (mussel deployment zone) using nearest-neighbor method from daily NetCDF reanalysis products.

#### `temperature_c`
- **Description**: Sea water temperature
- **Units**: Degrees Celsius (°C)
- **Source Variable**: `thetao` (potential temperature)
- **Copernicus Product**: Mediterranean Sea Physics Reanalysis (med-cmcc-tem-rean-d)
- **Depth**: 10m (pre-extracted)
- **Range**: ~12-26°C (Mediterranean seasonal range)
- **Data Coverage**: 100% (3,438 days × 2 sites = 6,876 values)
- **Temporal Resolution**: Daily
- **Environmental Significance**: Primary climate variable, thermal stress indicator
- **Quality**: Validated against CTD measurements (Spearman ρ=0.886-0.899)

#### `salinity_psu`
- **Description**: Seawater salinity
- **Units**: PSU (Practical Salinity Units, dimensionless)
- **Source Variable**: `so` (sea water salinity)
- **Copernicus Product**: Mediterranean Sea Physics Reanalysis (med-cmcc-sal-rean-d)
- **Depth**: 10m (nearest-neighbor extraction from depth dimension)
- **Range**: ~37.5-38.5 PSU (Mediterranean high salinity)
- **Data Coverage**: 100% (6,876 values)
- **Temporal Resolution**: Daily
- **Environmental Significance**: Osmotic stress indicator, water mass characterization
- **Note**: Higher than global ocean average (~35 PSU) due to Mediterranean evaporation excess

#### `oxygen_mmol_m3`
- **Description**: Dissolved oxygen concentration
- **Units**: mmol/m³ (millimoles per cubic meter)
- **Source Variable**: `o2` (dissolved oxygen)
- **Copernicus Product**: Mediterranean Sea Biogeochemistry Reanalysis (med-ogs-bio-rean-d)
- **Depth**: 10m (nearest-neighbor extraction)
- **Range**: ~210-250 mmol/m³ (Mediterranean oxygen levels)
- **Data Coverage**: 100% (6,876 values)
- **Temporal Resolution**: Daily
- **Environmental Significance**: Hypoxia stress indicator, respiratory stress biomarker correlation
- **Conversion**: Can be converted to mg/L (divide by ~31.25) or μmol/kg

#### `ph`
- **Description**: Seawater pH (acidity/alkalinity)
- **Units**: pH units (dimensionless)
- **Source Variable**: `ph` (pH on total scale)
- **Copernicus Product**: Mediterranean Sea Biogeochemistry Carbon Reanalysis (med-ogs-car-rean-d)
- **Depth**: 10m (nearest-neighbor extraction)
- **Scale**: Total pH scale (standard for seawater)
- **Range**: ~8.05-8.15 (typical Mediterranean seawater)
- **Data Coverage**: 100% (6,876 values)
- **Temporal Resolution**: Daily
- **Environmental Significance**: **Ocean acidification monitoring (critical climate indicator)**
- **Research Context**: **First time pH included in analysis** - enables ocean acidification trend assessment
- **Expected Trend**: Decreasing pH (acidification) consistent with global CO₂ increase

#### `nitrate_mmol_m3`
- **Description**: Dissolved nitrate (NO₃⁻) concentration
- **Units**: mmol/m³ (millimoles per cubic meter)
- **Source Variable**: `no3` (nitrate)
- **Copernicus Product**: Mediterranean Sea Biogeochemistry Nutrients Reanalysis (med-ogs-nut-rean-d)
- **Depth**: 10m (nearest-neighbor extraction)
- **Range**: ~0.01-1.5 mmol/m³
- **Data Coverage**: 100% (6,876 values)
- **Temporal Resolution**: Daily
- **Environmental Significance**: Nutrient pollution indicator, eutrophication assessment
- **Ecological Role**: Limiting nutrient for phytoplankton growth in Mediterranean

#### `phosphate_mmol_m3`
- **Description**: Dissolved phosphate (PO₄³⁻) concentration
- **Units**: mmol/m³ (millimoles per cubic meter)
- **Source Variable**: `po4` (phosphate)
- **Copernicus Product**: Mediterranean Sea Biogeochemistry Nutrients Reanalysis (med-ogs-nut-rean-d)
- **Depth**: 10m (nearest-neighbor extraction)
- **Range**: ~0.005-0.040 mmol/m³
- **Data Coverage**: 100% (6,876 values)
- **Temporal Resolution**: Daily
- **Environmental Significance**: Eutrophication stress indicator, ecosystem stress assessment
- **Note**: Typically lower concentration than nitrate in Mediterranean waters

---

## Data Extraction Methodology

### Source NetCDF Files

**Total Files Processed**: 80 NetCDF files (~25 GB total)
**Extraction Date**: September 2025
**Storage Location**: `/home/guido/SRC/andrea/definitive_copernicus_data/`

#### Physics Variables (Temperature, Salinity)
- **Temperature**: Single multi-year file
  - File: `complete_temperature_downloads/thetao_depth_10m_2014_2023.nc`
  - Pre-extracted at 10m depth
  - 3,438 daily time steps

- **Salinity**: 10 annual files
  - Pattern: `complete_daily_downloads/so_med-cmcc-sal-rean-d_{YEAR}_daily_complete.nc`
  - Years: 2014-2023 (2023 partial)
  - Extracted from depth dimension at 10.54m (nearest to 10m)

#### Biogeochemistry Variables (Oxygen, pH, Nutrients)
- **Oxygen**: 10 annual files (med-ogs-bio-rean-d)
- **pH**: 10 annual files (med-ogs-car-rean-d)
- **Nitrate**: 10 annual files (med-ogs-nut-rean-d)
- **Phosphate**: 10 annual files (med-ogs-nut-rean-d)
- All extracted from depth dimension at 10.54m (nearest to 10m)

### Spatial Extraction Protocol

**Method**: Nearest-neighbor selection using exact site coordinates
- **Gorgona**: Lat 43.4287°N, Lon 9.9078°E
  - Grid match: Lat 43.4375°N, Lon 9.9167°E
  - Distance: **1.39 km** (excellent match)

- **Terminal**: Lat 43.6333°N, Lon 9.9833°E
  - Grid match: Lat 43.6458°N, Lon 10.0000°E
  - Distance: **2.32 km** (good match)

**Grid Resolution**: ~4 km (adequate for site characterization)
**Quality**: Grid points within acceptable distance (<3 km) for both sites

### Depth Extraction Protocol

**Target Depth**: 10m (mussel deployment zone)
**Grid Depth**: 10.54m (nearest available depth level)
**Vertical Resolution**: Multiple depth levels available in models
**Depth Accuracy**: Within 0.54m of target (excellent)

### Temporal Extraction Protocol

**Start Date**: 2014-01-01 (first day of study period)
**End Date**: 2023-05-31 (last available data)
**Temporal Continuity**: Daily, no gaps within coverage period
**Leap Years**: Properly handled (2016, 2020 have 366 days)
**Time Zone**: UTC (standard for Copernicus Marine Service)
**Time Format**: Converted from "minutes since 1900-01-01" to calendar dates

---

## Data Quality and Validation

### Completeness Assessment

✅ **100% coverage** for all variables (6,876 values each, zero missing data)
✅ **Continuous daily series** (no temporal gaps)
✅ **Both sites** present for all days
✅ **All 6 variables** successfully extracted

### Spatial Accuracy

✅ **Gorgona match**: 1.39 km from target (excellent)
✅ **Terminal match**: 2.32 km from target (good)
✅ **Grid resolution**: ~4 km (adequate for basin-wide patterns)
✅ **Consistent grid points**: Same grid cells used throughout time series

### Depth Accuracy

✅ **Target depth**: 10m (mussel deployment zone)
✅ **Grid depth**: 10.54m (within 5% of target)
✅ **Vertical positioning**: Appropriate for surface layer variability

### Temporal Quality

✅ **Complete years**: 2014-2022 (9 full years)
⚠ **Partial year**: 2023 (January-May only, 151 days)
✅ **Leap years**: Properly handled (366 days for 2016, 2020)
✅ **Seasonal balance**: All seasons represented (in complete years)

### Temperature Validation

**Cross-validation with CTD measurements** (previous studies):
- Spearman correlation: ρ = 0.886-0.899 (**GOOD to EXCELLENT agreement**)
- Lin's CCC: 0.995-0.996 (**EXCELLENT concordance**)
- Conclusion: Copernicus temperature data validated against in-situ measurements

---

## Important Notes for Analysis

### 1. Partial 2023 Data

**⚠ CRITICAL**: 2023 contains only **151 days** (January-May)

**Impact on analysis:**
- **Annual means** for 2023 will be biased (colder, only winter-spring)
- **Trend analysis**: Exclude 2023 or use only complete years (2014-2022)
- **Seasonal analysis**: 2023 missing summer-autumn data

**Recommendation**:
```
For trend analysis: Use 2014-2022 only (9 complete years)
For seasonal analysis: Exclude 2023
For daily analysis: Can use 2023 data with caution
```

### 2. Ocean Acidification (pH)

**First-time inclusion**: pH has **never been analyzed** in previous work

**Research significance:**
- Global ocean acidification: ~-0.002 pH units/year (IPCC AR6)
- Mediterranean expected trend: Similar to global
- This dataset enables **first assessment** of pH trends in study area

**Analysis priority**: HIGH (new variable, climate change indicator)

### 3. Comparison with Campaign Data

**Do NOT replace** campaign data (`copernicus_models.csv`) completely:

**Use daily data for**:
- Decadal climate trend analysis
- Seasonal pattern assessment
- Ocean acidification monitoring
- Continuous time series analysis

**Keep campaign data for**:
- Direct temporal alignment with biomarker sampling dates
- ±15 day window matching with biological measurements
- Validation of daily data aggregation

---

## Usage Examples

### Loading Data

```python
import pandas as pd

# Load daily time series
df = pd.read_csv('copernicus_models_daily.csv')
df['date'] = pd.to_datetime(df['date'])

# Filter complete years only (2014-2022)
df_complete = df[df['year'] <= 2022]

print(f"Total days: {len(df_complete) // 2}")  # Divide by 2 sites
print(f"Date range: {df_complete['date'].min()} to {df_complete['date'].max()}")
```

### Trend Analysis Example

```python
import numpy as np
from scipy import stats

# Annual means for trend analysis (complete years only)
df_trend = df[df['year'] <= 2022].copy()

for site in ['Gorgona', 'Terminal']:
    site_data = df_trend[df_trend['site'] == site]
    annual_means = site_data.groupby('year')['temperature_c'].mean()

    # Mann-Kendall test
    years = annual_means.index.values
    temps = annual_means.values

    # Calculate trend...
```

### pH Analysis Example

```python
# First-time ocean acidification assessment
ph_data = df[df['year'] <= 2022].copy()

for site in ['Gorgona', 'Terminal']:
    site_ph = ph_data[ph_data['site'] == site]
    annual_ph = site_ph.groupby('year')['ph'].mean()

    print(f"{site} pH trend:")
    print(annual_ph)
    # Expected: decreasing trend (acidification)
```

---

## Relationship to Other Datasets

### Copernicus Campaign Data (`copernicus_models.csv`)
- **Temporal alignment**: Campaign dates are subset of daily dates
- **Variable overlap**: Temperature, Salinity, Oxygen (3 common variables)
- **New in daily data**: pH, Nitrate, Phosphate (3 additional variables)
- **Use case difference**: Campaign for biomarker correlation, Daily for climate trends

### CTD Data (`ctd_oceanographic.csv`)
- **Purpose**: In-situ validation of Copernicus models
- **Temporal coverage**: 2015-2025 (overlaps with this dataset)
- **Spatial coverage**: 14 stations (includes sites near Gorgona and Terminal)
- **Variables overlap**: Temperature, pH, Salinity, Oxygen
- **Validation status**: ✓ Temperature validated (ρ=0.886-0.899)

### Satellite Data (`copernicus_satellite.csv`)
- **Complementary**: Satellite provides SST and Chlorophyll
- **Temporal resolution**: Campaign-based (not continuous)
- **Spatial resolution**: Higher (~1 km) but surface-only
- **This dataset advantage**: Subsurface (10m depth) continuous data

### Marine Heatwaves Data (`marine_heatwaves/daily_temperature_heatwaves.csv`)
- **Source**: Derived from same Copernicus temperature data
- **Temporal coverage**: 2014-2023 (same period)
- **Variable**: Temperature only (SST from surface data)
- **This dataset advantage**: Multiple variables at deployment depth (10m)

---

**Document Version**: 1.0
**Last Updated**: October 2025
**Extraction Script**: `extract_continuous_copernicus_data.py`
**Total Processing Time**: ~5 minutes (80 NetCDF files)
**Total Data Volume**: ~25 GB NetCDF → 1 MB CSV (efficient extraction)
**Quality Control**: ✓ Complete (100% coverage, validated coordinates, proper depth)
**Ready for Analysis**: ✓ YES (suitable for publication-quality climate trend analysis)
