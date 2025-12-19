# Copernicus Satellite Variables Documentation

## Dataset Overview

**File**: `copernicus_satellite.csv`
**Sample Size**: 423 satellite observations
**Temporal Coverage**: 2014-2023
**Data Source**: Copernicus Marine Service satellite products
**Spatial Coverage**: Ligurian Sea - Gorgona Island and OLT Terminal area
**Observation Type**: Remote sensing from space (satellite-based measurements)
**Temporal Alignment**: ±15 day windows around 37 biomarker campaigns
**Quality**: Cloud-free observations with validated coordinates

---

## Variable Descriptions

### Temporal Variables

#### `campaign`
- **Description**: Biomarker campaign identifier for temporal alignment
- **Format**: [Season][Year] (e.g., A14, E14, I14, P14)
- **Season Codes**: A=Autumn, E=Summer, I=Winter, P=Spring
- **Total Campaigns**: 37 unique campaigns with satellite data
- **Temporal Window**: Each campaign has multiple satellite observations within ±15 days

#### `observation_date`
- **Description**: Date of satellite observation (overpass date)
- **Format**: YYYY-MM-DD
- **Range**: 2014-2023
- **Temporal Resolution**: Daily satellite coverage (cloud conditions permitting)
- **Quality**: Cloud-free observations selected for reliable measurements

#### `year`
- **Description**: Observation year (4-digit format)
- **Range**: 2014-2023
- **Type**: Integer
- **Derivation**: Extracted from observation date

#### `season`
- **Description**: Meteorological season of observation
- **Values**: Autumn, Summer, Winter, Spring
- **Purpose**: Seasonal environmental pattern analysis

#### `days_from_campaign`
- **Description**: Temporal offset from campaign sampling date
- **Units**: Days (integer)
- **Range**: -15 to +15 days
- **Negative values**: Satellite observation before biomarker sampling
- **Positive values**: Satellite observation after biomarker sampling
- **Purpose**: Quantify temporal alignment quality

---

### Spatial Variables

#### `station`
- **Description**: Monitoring site identifier
- **Values**:
  - **Gorgona**: Natural control site (Gorgona Island)
  - **Terminal**: OLT regasification terminal exposure area
  - **Nord, Sud, Est, Ovest**: Directional control points around terminal
- **Spatial Design**: Control vs Exposure comparison with directional references

#### `station_type`
- **Description**: Station classification
- **Values**:
  - **control**: Gorgona + directional control points (Nord, Sud, Est, Ovest)
  - **exposure**: Terminal area (within thermal discharge influence zone)
- **Purpose**: Spatial gradient analysis

#### `latitude`
- **Description**: Geographic latitude of observation
- **Units**: Decimal degrees (°N)
- **Range**: ~43.4-43.7°N (Ligurian Sea)
- **Precision**: Satellite pixel center coordinates
- **Reference Datum**: WGS84

#### `longitude`
- **Description**: Geographic longitude of observation
- **Units**: Decimal degrees (°E)
- **Range**: ~9.9-10.0°E (Ligurian Sea)
- **Precision**: Satellite pixel center coordinates
- **Reference Datum**: WGS84

---

### Satellite Environmental Variables

#### `sst` (Sea Surface Temperature)
- **Description**: Temperature of the ocean surface skin layer
- **Units**: Degrees Celsius (°C)
- **Measurement Depth**: Top few micrometers of ocean surface
- **Range**: ~12-27°C (Mediterranean seasonal range)
- **Satellite Sensor**: Thermal infrared radiometer
- **Temporal Resolution**: Daily (cloud conditions permitting)
- **Spatial Resolution**: ~1-4 km (depends on satellite product)
- **Environmental Significance**:
  - Primary thermal stress indicator
  - Regasification terminal thermal discharge detection
  - Climate warming trend analysis
- **Quality Control**: Cloud masking, quality flags applied

#### `chlorophyll_a` (Chlorophyll-a Concentration)
- **Description**: Concentration of chlorophyll-a pigment in surface waters
- **Units**: mg/m³ (milligrams per cubic meter)
- **Measurement Depth**: Surface euphotic layer (~1-10m optical depth)
- **Range**: Variable (oligotrophic Mediterranean typically 0.05-2.0 mg/m³)
- **Satellite Sensor**: Ocean color radiometer (visible spectrum)
- **Algorithm**: Standard ocean color algorithm for chlorophyll retrieval
- **Temporal Resolution**: Daily (cloud and sun glint permitting)
- **Spatial Resolution**: ~1-4 km
- **Environmental Significance**:
  - Phytoplankton biomass proxy
  - Primary productivity indicator
  - Eutrophication stress assessment
  - Terminal discharge effect detection (chlorine impact on phytoplankton)
- **Quality Control**: Atmospheric correction, cloud masking, quality flags

---

## Satellite Remote Sensing Methodology

### Satellite Platforms and Sensors

**Sea Surface Temperature**:
- **Sensors**: AVHRR (Advanced Very High Resolution Radiometer), MODIS (Moderate Resolution Imaging Spectroradiometer), VIIRS (Visible Infrared Imaging Radiometer Suite)
- **Measurement Principle**: Thermal infrared emission from ocean surface
- **Wavelengths**: 10-12 μm (thermal infrared window)
- **Accuracy**: ±0.3-0.5°C typical

**Chlorophyll-a**:
- **Sensors**: MODIS, VIIRS, Sentinel-3 OLCI (Ocean and Land Color Instrument)
- **Measurement Principle**: Ocean color reflectance in blue-green spectrum
- **Wavelengths**: 412-670 nm (multiple bands)
- **Algorithm**: Band ratio algorithms (blue/green ratio correlates with chlorophyll)
- **Accuracy**: ±35% typical for oligotrophic waters

### Data Extraction Protocol

**Temporal Alignment**:
- Campaign sampling date ± 15 days window
- All cloud-free observations within window retained
- Multiple observations per campaign enable statistical robustness

**Spatial Alignment**:
- Station coordinates matched to nearest satellite pixel
- Pixel-level extraction (no spatial averaging for maximum spatial resolution)
- Separate extractions for each monitoring site

**Quality Control**:
- Cloud masking algorithms applied
- Quality flags checked (only high-quality observations retained)
- Sun glint masking for chlorophyll (glint contamination removed)
- Land contamination masking

**Processing Pipeline**:
1. Campaign metadata extraction (date, station coordinates)
2. Satellite data download from Copernicus Marine Service
3. Temporal subset (±15 day window)
4. Spatial subset (nearest pixel to station coordinates)
5. Quality control (cloud masking, quality flags)
6. Multiple observations per campaign retained for statistical analysis

---

## Spatial Monitoring Network

### Terminal Area Vertices (Exposure Zone)
- **North Boundary**: 43°39'00"N
- **South Boundary**: 43°37'00"N
- **East Boundary**: 10°00'00"E
- **West Boundary**: 9°58'00"E
- **Total Area**: ~9.2 km²
- **Purpose**: Satellite detection zone for thermal and chemical discharge signatures

### Directional Control Points
- **Nord (North)**: Positioned north of terminal outside discharge influence
- **Sud (South)**: Positioned south of terminal outside discharge influence
- **Est (East)**: Positioned east of terminal outside discharge influence
- **Ovest (West)**: Positioned west of terminal outside discharge influence
- **Purpose**: Reference points for spatial gradient assessment

### Gorgona Control Site
- **Coordinates**: 43.4287°N, 9.9078°E
- **Distance from Terminal**: ~22 km southwest
- **Characteristics**: Natural marine environment, no industrial influence
- **Purpose**: Natural background reference for comparison

---

## Quality Assurance

### Data Completeness
- **423 Satellite Observations**: 37 campaigns with multiple observations per campaign
- **Temporal Coverage**: 2014-2023 (9-year satellite monitoring record)
- **Cloud-Free Selection**: Only high-quality cloud-free observations retained
- **Spatial Coverage**: Complete monitoring network (Gorgona + Terminal + directional controls)

### Observation Quality
- **Cloud Masking**: Automated cloud detection and masking applied
- **Quality Flags**: Satellite product quality flags checked (high-quality only)
- **Atmospheric Correction**: Standard atmospheric correction algorithms applied for chlorophyll
- **Validation**: Satellite SST cross-validated with in-situ measurements where available

### Temporal Alignment Quality
- **±15 Day Window**: Balances temporal specificity with cloud-free observation availability
- **Multiple Observations**: Typically 5-15 observations per campaign enable statistical robustness
- **Days from Campaign**: Temporal offset quantified for each observation

---

## Remote Sensing Advantages

### Spatial Coverage
- **Synoptic View**: Entire monitoring area observed simultaneously
- **Spatial Patterns**: Thermal plume extent and chlorophyll spatial distribution visible
- **Gradient Detection**: Satellite resolution sufficient for discharge gradient detection

### Temporal Coverage
- **Daily Observations**: Potential for daily coverage (cloud permitting)
- **Long-Term Record**: Multi-year consistent observations from similar sensors
- **Seasonal Patterns**: Complete seasonal cycle documentation

### Independence
- **Objective Measurement**: Independent from in-situ biomarker sampling
- **Multi-Evidence Validation**: Satellite provides independent line of evidence
- **Large-Scale Context**: Connects local monitoring to regional oceanographic conditions

---

## Usage Notes

### This is a CLEAN dataset
- **Raw satellite observations only**: No calculated thermal signatures or gradients
- **No statistical comparisons**: Terminal vs control statistical tests NOT included
- **No effect sizes**: Effect size calculations NOT included
- **Original satellite data**: Remote sensing retrievals preserved
- **Ready for analysis**: Start fresh satellite-based environmental analysis

### Recommended Analysis Approaches
- **Spatial Gradient Analysis**: Compare terminal area vs control points
- **Temporal Trend Analysis**: Multi-year SST warming trends
- **Seasonal Patterns**: Mediterranean seasonal temperature and chlorophyll cycles
- **Discharge Detection**: Test for thermal and chlorophyll signatures near terminal
- **Multi-Evidence Integration**: Combine satellite + biomarker + CTD data

### Data Limitations
- **Cloud Cover**: Gaps in temporal coverage due to clouds (especially winter)
- **Surface Only**: Satellite measures surface layer only (no depth information)
- **Spatial Resolution**: ~1-4 km limits small-scale feature detection
- **Chlorophyll Algorithm**: Less accurate in oligotrophic Mediterranean (low chlorophyll)

### Optimal Use Cases
- **Terminal Thermal Signature**: Detect -7°C cooling discharge from regasification
- **Chlorophyll Impact**: Assess chlorine discharge effects on phytoplankton
- **Climate Trend Documentation**: Multi-year SST warming analysis
- **Independent Validation**: Cross-validate in-situ measurements with satellite observations

---

**Data Origin**: Copernicus Marine Service satellite products (ocean color and sea surface temperature), 2014-2023 temporal coverage, ~1-4km spatial resolution, 423 cloud-free observations aligned with biomarker campaigns, quality-controlled remote sensing data from multiple satellite platforms (MODIS, VIIRS, Sentinel-3).
