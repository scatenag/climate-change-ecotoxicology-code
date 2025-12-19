# CO2 and Carbon Cycle Variables (Copernicus Marine Service)

**Dataset**: `copernicus_co2_daily.csv`
**Source**: Copernicus Marine Service - Mediterranean Sea Biogeochemistry Reanalysis
**Product ID**: MEDSEA_MULTIYEAR_BGC_006_008
**Temporal Coverage**: 2014-01-01 to 2023-05-31 (3,438 days)
**Spatial Coverage**: Ligurian Sea study area (43.4-43.7°N, 9.9-10.0°E)
**Depth**: Surface layer (0-10 m)
**Completeness**: 99.4% (excellent data coverage)

---

## Scientific Rationale

The carbon cycle and CO2 system are **critical climate change indicators** that have been missing from the previous analyses. Ocean acidification and changing carbonate chemistry affect:

1. **Marine Organism Physiology**: pH changes affect calcification, metabolism, and stress response
2. **Metal Bioavailability**: pH alters metal speciation and toxicity
3. **Climate-Biomarker Interactions**: Carbonate stress compounds other climate stressors
4. **Regional Carbon Dynamics**: Mediterranean Sea acts as atmospheric CO2 sink

This dataset provides the **first complete CO2/carbon cycle characterization** for the study area.

---

## Variables Description

### 1. **spco2** - Surface Partial Pressure of CO2
- **Units**: Pa (Pascals)
- **Description**: Partial pressure of dissolved CO2 at the ocean surface
- **Range**: 29-37 Pa (typical Mediterranean values)
- **Climate Relevance**: Direct indicator of ocean-atmosphere CO2 exchange
- **Biological Relevance**: Influences carbonate system equilibrium, affecting calcifying organisms

**Interpretation**:
- Higher pCO2 → More dissolved CO2 → Lower pH (ocean acidification)
- Rising trend indicates increasing oceanic CO2 uptake from atmosphere
- Seasonal variation reflects biological productivity and temperature effects

### 2. **fpco2** - Air-Sea CO2 Flux
- **Units**: kg/m²/s (kilograms per square meter per second)
- **Description**: Net flux of CO2 between atmosphere and ocean
- **Range**: 0 - 2×10⁻⁹ kg/m²/s
- **Climate Relevance**: Quantifies Mediterranean Sea role as carbon sink
- **Sign Convention**: Positive = ocean uptake (atmosphere → ocean)

**Interpretation**:
- Positive flux → Ocean absorbing atmospheric CO2 (typical for study period)
- Temporal variation reflects seasonal biological cycles and mixing
- Critical for regional carbon budget calculations

### 3. **dissic** - Dissolved Inorganic Carbon
- **Units**: mol/m³ (moles per cubic meter)
- **Description**: Total concentration of inorganic carbon species (CO2 + HCO3⁻ + CO3²⁻)
- **Range**: 2.28-2.35 mol/m³ (Mediterranean typical)
- **Climate Relevance**: Main carbon reservoir in seawater
- **Biological Relevance**: Substrate for photosynthesis, buffer capacity indicator

**Interpretation**:
- Increasing DIC → More carbon stored in ocean (climate mitigation)
- But also increases pCO2 and reduces pH (acidification)
- Trade-off between carbon sequestration and ecosystem stress

### 4. **talk** - Total Alkalinity
- **Units**: mol/m³ (moles per cubic meter)
- **Description**: Acid-buffering capacity of seawater
- **Range**: 2.61-2.67 mol/m³ (Mediterranean high alkalinity)
- **Climate Relevance**: Determines ocean buffering capacity against acidification
- **Biological Relevance**: Critical for calcification processes in marine organisms

**Interpretation**:
- Higher alkalinity → Better pH buffering (protects against acidification)
- Mediterranean has high alkalinity due to high evaporation and riverine inputs
- Relatively stable compared to DIC (controls pH changes)

### 5. **ph** - pH on Total Scale
- **Units**: Dimensionless (total scale at in-situ temperature)
- **Description**: Measure of hydrogen ion concentration
- **Range**: 8.11-8.21 (typical modern ocean values)
- **Climate Relevance**: **Primary ocean acidification indicator**
- **Biological Relevance**: Affects all metabolic processes, stress response, metal toxicity

**Interpretation**:
- Declining pH = ocean acidification (already detected in STEP 1.1)
- Each -0.1 pH unit = 26% increase in acidity (logarithmic scale)
- Below 8.0 considered "acidified" relative to pre-industrial baseline (~8.2)

---

## Data Structure

**File**: `copernicus_co2_daily.csv`

**Columns** (29 total):

### Primary Variables (Mean Values)
- `spco2_mean`, `fpco2_mean`, `dissic_mean`, `talk_mean`, `ph_mean`

### Statistical Measures (for each variable)
- `_std`: Standard deviation across spatial grid
- `_min`: Minimum value in study area
- `_max`: Maximum value in study area
- `_median`: Median value (robust central tendency)

### Temporal Identifiers
- `date`: YYYY-MM-DD format (ISO 8601)
- `year`: Integer year (2014-2023)
- `month`: Integer month (1-12)
- `day`: Integer day (1-31)
- `doy`: Day of year (1-366)

---

## Data Quality

### Completeness
- **3,438 daily observations** (2014-01-01 to 2023-05-31)
- **99.4% data coverage** - exceptional quality
- **No systematic gaps** - continuous daily time series

### Validation
Copernicus Mediterranean Biogeochemistry Reanalysis is:
- Assimilated with satellite observations (chlorophyll, SST)
- Validated against BGC-Argo floats and research cruises
- Used in >500 peer-reviewed publications
- CMEMS quality-controlled with uncertainty quantification

### Consistency Checks
All values within expected Mediterranean ranges:
- ✅ `spco2`: 29-37 Pa (consistent with atmospheric equilibrium ~410 ppm CO2)
- ✅ `ph`: 8.11-8.21 (modern ocean, slight acidification)
- ✅ `dissic`: 2.28-2.35 mol/m³ (typical Mediterranean DIC)
- ✅ `talk`: 2.61-2.67 mol/m³ (high Mediterranean alkalinity)
- ✅ `fpco2`: Positive values (Mediterranean acts as CO2 sink)

---

## Analytical Considerations

### 1. Carbonate System Relationships
The CO2 system variables are **thermodynamically linked**:
- pH = f(DIC, TA, T, S, P)
- Knowing any 2 parameters determines the full system
- **Do NOT treat as independent** in multivariate analyses

### 2. Temperature Dependence
- All CO2 variables are **temperature-sensitive**
- pH decreases ~0.015 units per °C warming (thermodynamic effect)
- Must separate thermodynamic vs. chemical pH changes in trend analysis

### 3. Seasonal Cycles
- Strong seasonal variation in all variables
- Driven by: temperature, biological productivity, mixing depth
- **Detrend or account for seasonality** before trend analysis

### 4. Integration with Other Variables
**Synergistic effects** with existing climate variables:
- Temperature × pH (both changing, compound stress)
- Oxygen × DIC (respiration produces CO2, consumes O2)
- Chlorophyll × pCO2 (photosynthesis draws down CO2)

---

## Usage in Analysis Workflow

### STEP 1.1: Trends Quantification
- **Add 5 CO2 variables** to linear trend analysis
- Expected finding: **Declining pH** (already detected), **Rising pCO2**, **Rising DIC**
- Compare rates with Mediterranean/global literature

### STEP 1.2: Marine Heatwaves
- Evaluate CO2 system behavior **during MHW events**
- Hypothesis: Heatwaves accelerate acidification (temperature + respiration effects)
- Plot pH/pCO2 anomalies during MHW periods

### STEP 1.3: Satellite Validation
- **No in-situ CO2 measurements** available (CTD does not measure CO2)
- Document as limitation, rely on Copernicus validation
- Possible: validate pH against calculated pH from other biogeochemical data

### STEP 1.4: Seasonal Variation
- Quantify **seasonal amplitude** of CO2 variables
- Important for Phase 2-3: T0 baseline may vary seasonally in carbonate stress
- Identify peak acidification periods (likely late summer)

### STEP 1.5: Final Report Integration
- **Update Climate Change Index** to include pH/pCO2 (critical omission)
- Revise key findings to include ocean acidification
- Add carbonate chemistry to Phase 4-5 stress partitioning models

---

## Key Literature

**Ocean Acidification - Mediterranean**:
- Álvarez et al. (2014): -0.028 pH units/decade in Mediterranean
- Coppola et al. (2020): Mediterranean acidification 1.5× faster than global ocean
- Kapsenberg & Hofmann (2016): pH variability in coastal Mediterranean

**CO2 System - Ligurian Sea**:
- Gemayel et al. (2015): Seasonal carbonate dynamics, northwestern Mediterranean
- Kessouri et al. (2021): High-resolution Mediterranean biogeochemistry modeling
- D'Ortenzio et al. (2005): Seasonal variability, Ligurian Sea

**Biological Effects**:
- Kroeker et al. (2013): Meta-analysis of OA effects on marine organisms
- Gazeau et al. (2014): Mediterranean bivalves response to acidification
- Richir et al. (2022): Combined warming + acidification stress

---

## Critical Importance for This Study

**This is NOT a minor addition** - CO2/pH data fill a **critical gap**:

1. **Ocean acidification is a primary climate stressor** (on par with warming)
2. **pH directly affects metal toxicity** - changes speciation and bioavailability
3. **Carbonate stress compounds biomarker response** - metabolic costs of pH regulation
4. **Previous analyses missed a key climate variable** - incomplete climate characterization

The fact that pH trends were already detected in STEP 1.1 (from the existing `copernicus_models.csv` which included pH) validates the importance, but **the complete CO2 system (pCO2, DIC, TA, flux)** provides much richer mechanistic understanding.

---

## Data Citation

**When using this dataset, cite**:

> Copernicus Marine Service (2023). Mediterranean Sea Biogeochemistry Reanalysis.
> Product: MEDSEA_MULTIYEAR_BGC_006_008.
> https://doi.org/10.25423/CMCC/MEDSEA_MULTIYEAR_BGC_006_008

**Model Reference**:
> Teruzzi, A., et al. (2021). Mediterranean Sea Biogeochemical Reanalysis (CMEMS MED-Biogeochemistry, MedBFM3 system).
> *Copernicus Marine Service*.

---

**File Created**: October 2025
**Status**: Integrated into CLEAN_DATA_PACKAGE
**Next**: Update Phase 1 analyses to include CO2 variables
