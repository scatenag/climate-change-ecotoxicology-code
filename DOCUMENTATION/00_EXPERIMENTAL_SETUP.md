# EXPERIMENTAL SETUP AND STUDY AREA

## Project Overview

**Study Type**: Marine environmental monitoring using mussel biomarkers
**Organism**: *Mytilus galloprovincialis* (Mediterranean mussel)
**Location**: Ligurian Sea, Mediterranean Sea, Italy
**Temporal Coverage**: 2014-2023 (9-year monitoring period)

---

## Study Area

### Geographic Locations

**Control Site: Gorgona Island**
- **Coordinates**: 43°25'43.36"N, 9°54'27.87"E (decimal: 43.4287°N, 9.9078°E)
- **Type**: Natural marine environment
- **Characteristics**: No industrial influence, pristine conditions
- **Distance from terminal**: ~15 km north

**Exposure Area: OLT Regasification Terminal**
- **Coordinates**: 43.6333°N, 9.9833°E (43°38'00"N, 9°59'00"E)
- **Type**: Offshore industrial facility
- **Location**: Off Livorno coast, Tuscany
- **Water depth**: ~100m
- **Infrastructure**: Floating LNG regasification terminal with subsea discharge

**Terminal Operational Characteristics**:
- Thermal discharge: Cooled seawater (-7°C below ambient temperature)
- Chemical discharge: Chlorination byproducts from biofouling prevention
- Discharge location: Multiple points at terminal stern
- Operational period: 2014-present (continuous operation)

---

## Spatial Monitoring Network

### Station Layout

**Station Types and Distances from Terminal (43.6333°N, 9.9833°E)**:

**Control Stations** (1000-2000m from terminal):
- **MG1, MG2**: Northern control stations
- **MG9, MG10**: Southern distant controls
- **Function**: Reference sites outside terminal influence zone

**Intermediate Impact Stations** (300-500m from terminal):
- **MG3, MG4, MG5, MG6, MG7, MG8**: Gradient characterization
- **Function**: Assess intermediate-distance effects

**High Impact Zone** (100-300m from terminal):
- **MG11, MG12, MG13, MG14**: Near-discharge stations
- **Function**: Maximum exposure assessment

**Biomarker Deployment Stations** (around terminal discharge):
- **pos1, pos2, pos3, pos4**: Mussel cages deployed around terminal
- **Position**: STA-POS1, STB, STC, STD-POS4 (metric scale: -25 to +85m from discharge)
- **Deployment depth**: ~10m (mussel habitat depth)
- **Function**: Direct biological response assessment

---

## Experimental Design

### Baseline (T0) - Control Population

**Sample Size**: 238 mussels
**Origin**: Aquaculture farm (controlled conditions)
**Sampling Period**: Before deployment (2014-2016)
**Purpose**: Establish baseline biological variability before environmental exposure
**Key Consideration**: T0 population shows inherent variability due to handling/transport

### Control vs Exposure Design

**Control Site**: Gorgona Island natural environment
- Sample size: 312 biomarker samples
- Purpose: Natural environmental reference

**Exposure Sites**: pos1-pos4 terminal stations
- Sample size: 920 biomarker samples
- Purpose: Terminal area biological response

**Comparison Logic**: T0 → Control (Gorgona) vs Exposure (pos1-4)

### Temporal Design

**Campaign Coding System**: [Season][Year]
- **P** (Primavera/Spring): March-May
- **E** (Estate/Summer): June-August
- **A** (Autunno/Autumn): September-November
- **I** (Inverno/Winter): December-February

**Campaign Examples**: P14, E15, A16, I17

**Temporal Coverage**:
- Total campaigns: 37 biomarker campaigns (2014-2023)
- Seasonal campaigns: P14-P16 (Spring), E14-E23 (Summer), A14-A23 (Autumn), I14-I25 (Winter)
- Sampling frequency: Quarterly to capture seasonal variability

---

## Sampling Types and Measurements

### Biomarker Sampling (pos1-pos4, Gorgona, T0)

**Sample Type**: Mussel soft tissue and hemolymph
**Deployment**: Mussel cages at ~10m depth
**Exposure Period**: Seasonal campaigns (typically 3-4 months deployment)
**Measurements**:
- Hemocyte count (immune response)
- NRRT - Neutral Red Retention Time (lysosomal stability)
- Comet assay (DNA damage)
- Gill epithelium histopathology (tissue damage)

### CTD Oceanographic Profiles (MG1-MG14 + terminal area)

**Instrument**: Sea-Bird CTD (Conductivity-Temperature-Depth profiler)
**Stations**: MG1-MG14 complete monitoring network
**Depth Range**: Surface to 117m (complete water column)
**Measurements**:
- Temperature (°C)
- pH (seawater pH units)
- Salinity (PSU - Practical Salinity Units)
- Dissolved oxygen (optional, not all profiles)
**Campaigns**: E15-E25 (Summer), I16-I25 (Winter) - 21 total campaigns
**Temporal Coverage**: 2015-2025 (11 years)

### Environmental Data (Copernicus Marine Service)

**Source**: Copernicus Marine Service Mediterranean reanalysis products
**Spatial Points**: Gorgona Island + OLT Terminal area coordinates
**Temporal Alignment**: ±15 day windows around biomarker sampling dates
**Variables**:
- Temperature (°C)
- Salinity (PSU)
- Dissolved Oxygen (mmol/m³)
- Nitrates (mmol/m³)
- Phosphates (mmol/m³)

### Satellite Observations (Copernicus Marine Service)

**Source**: Copernicus Marine Service satellite remote sensing
**Spatial Coverage**: Terminal area + Control points (Nord/Sud/Est/Ovest)
**Resolution**: ~4km grid
**Variables**:
- SST - Sea Surface Temperature (°C)
- Chlorophyll-a concentration (mg/m³)
**Quality**: Cloud-free observations only

### Heavy Metals Analysis

**Sample Type**: Mussel soft tissue (whole body)
**Stations**: T0 baseline + pos1-pos4 exposure stations
**Elements Analyzed** (12 total):
- High toxicity: Arsenic (As), Cadmium (Cd), Mercury (Hg)
- Moderate toxicity: Lead (Pb), Chromium (Cr), Nickel (Ni), Vanadium (V), Copper (Cu), Barium (Ba)
- Essential elements: Iron (Fe), Manganese (Mn), Zinc (Zn)
**Units**: mg/kg dry weight
**Method**: ICP-MS (Inductively Coupled Plasma Mass Spectrometry)

---

## Data Types Overview

### 1. Biomarkers (biomarkers.csv)
- **Records**: 1,470 samples (2014-2023)
- **Stations**: T0 (238), Gorgona (312), pos1-pos4 (920)
- **Variables**: 4 individual biomarkers (hemocytes, NRRT, comet assay, gill epithelium)

### 2. Heavy Metals (heavy_metals.csv)
- **Records**: 228 samples (2014-2023)
- **Stations**: T0 + pos1-pos4
- **Variables**: 12 heavy metal concentrations

### 3. CTD Oceanographic (ctd_oceanographic.csv)
- **Records**: 68,164 measurements (2015-2025)
- **Stations**: MG1-MG14 + terminal area
- **Variables**: Temperature, pH, salinity, depth

### 4. Copernicus Environmental Models (copernicus_models.csv)
- **Records**: 75 observations (2014-2023)
- **Sites**: Gorgona, Terminal
- **Variables**: 5 environmental parameters (temp, salinity, oxygen, nutrients)

### 5. Copernicus Satellite Observations (copernicus_satellite.csv)
- **Records**: 423 observations (2014-2023)
- **Points**: Control points + Terminal area
- **Variables**: SST, Chlorophyll-a

### 6. Marine Heatwaves (marine_heatwaves/)
- **daily_temperature_heatwaves.csv**: 3,438 daily records (2014-2023)
  - Daily SST, P90 threshold, heatwave status
- **heatwave_events.csv**: 19 discrete events
  - Event duration, intensity, category
- **climatology_p90_thresholds.csv**: 366 P90 reference thresholds
  - One threshold per day of year (including leap year)

---

## Sampling Protocols Summary

### Mussel Collection and Processing
1. **Field Collection**: SCUBA divers collect mussels at standardized depth (~10m)
2. **Transport**: Immediate transfer to cooled containers (4°C), <4 hours to laboratory
3. **Acclimation**: 24h in aerated seawater (18°C, salinity 38 PSU)
4. **Sample Processing**: Hemolymph extraction (sterile), tissue fixation (Davidson's solution)

### CTD Deployment
1. **Vessel Deployment**: CTD lowered from research vessel at each station
2. **Descent Rate**: 0.5 m/s (manufacturer recommendation)
3. **Sampling**: 4 Hz autonomous logging
4. **QC**: Real-time data quality check on deck

### Heavy Metals Sample Preparation
1. **Tissue Extraction**: Soft tissue (whole body excluding shell)
2. **Rinsing**: 3× filtered seawater, 1× Milli-Q water
3. **Drying**: Freeze-drying (lyophilization) at -80°C, 48 hours
4. **Homogenization**: Ceramic mortar (metal-free), fine powder (<100 μm)

---

## Key Experimental Considerations

### Temporal Coverage
- **Biomarkers**: Complete 2014-2023
- **CTD**: 2015-2025 (no 2013-2014 data despite file name)
- **Environmental data**: 2014-2023 aligned with biomarker campaigns
- **Missing campaigns**: 2020 winter campaign (I20) not conducted

### Spatial Considerations
- **Distance gradients**: Control (>1000m) → Intermediate (300-500m) → High impact (<300m)
- **Deployment depth**: ~10m for mussel cages (habitat depth, thermal/light zone)
- **Grid resolution**: Copernicus ~4km (may not resolve fine-scale plume dynamics)

### Sample Size Evolution
- **Comet assay**: Increased from n=5 to n=7 animals per site after campaign I16
- **Campaign I21**: Missing Gorgona control samples (only pos1-4 available)

### LOD (Limit of Detection) Handling
- Format: "LOD_X,XX" (comma decimal separator, European format)
- Example: "LOD_1,20" = Below detection limit of 1.20 mg/kg
- Metals frequently <LOD: Nickel (100%), Barium (>80%)

---

## Quality Assurance Notes

### Data Corrections Applied
- **Year assignment**: 1,008 biomarker samples corrected (extracted from sampling_date)
- **CTD dates**: 100% real dates (25.2% updated October 2025)
- **Copernicus processing**: 375 NetCDF files integrated (100% success rate)

### Validation Status
- **CTD vs Copernicus models**: Spearman ρ=0.886-0.899 (GOOD agreement)
- **Mediterranean value ranges**: All variables validated against expected regional ranges

---

## This Dataset Enables

✓ **Spatial gradient analysis**: Control vs exposure site comparison
✓ **Temporal trend analysis**: 9-year monitoring period
✓ **Seasonal pattern detection**: Quarterly sampling across years
✓ **Multi-parameter correlation**: Biomarker vs environmental data
✓ **Extreme events characterization**: Marine heatwave documentation

---

**For detailed variable descriptions, see DATA_DICTIONARIES/ directory**
