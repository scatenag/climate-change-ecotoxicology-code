# Heavy Metals Variables Documentation

## Dataset Overview

**File**: `heavy_metals.csv`
**Sample Size**: 201 samples
**Temporal Coverage**: 2014-2023 (10 years)
**Campaigns**: 38 seasonal campaigns
**Measurement Type**: Heavy metal concentrations in mussel tissue
**Analytical Method**: ICP-MS (Inductively Coupled Plasma Mass Spectrometry)
**Units**: mg/kg dry weight

---

## Variable Descriptions

### Temporal and Campaign Variables

#### `campaign`
- **Description**: Campaign identifier code
- **Format**: [Season][Year] (e.g., A14, E14, I14, P14)
- **Season Codes**:
  - A = Autunno (Autumn)
  - E = Estate (Summer)
  - I = Inverno (Winter)
  - P = Primavera (Spring)
- **Year**: 2-digit year (14 = 2014, 23 = 2023)
- **Example Values**: "A14", "E15", "I16", "P16"
- **Total Campaigns**: 38 campaigns across 2014-2023

#### `year`
- **Description**: Sampling year (4-digit format)
- **Range**: 2014-2023
- **Type**: Integer
- **Derivation**: Extracted from campaign code and sampling metadata

#### `season`
- **Description**: Meteorological season of sampling
- **Values**: Autumn, Summer, Winter, Spring
- **Temporal Distribution**: Quarterly seasonal coverage (some years have incomplete coverage)

#### `sampling_date`
- **Description**: Date of mussel collection
- **Format**: YYYY-MM-DD
- **Range**: 2014-2023
- **Quality**: Most campaigns have confirmed sampling dates
- **Note**: Some T0 samples (2014-2016) have estimated dates based on campaign timing

---

### Spatial Variables

#### `station`
- **Description**: Sampling station identifier
- **Station Types**:
  - **T0**: Baseline aquaculture farm samples (before deployment)
  - **Gorgona**: Natural control site (Gorgona Island 43.4287°N, 9.9078°E)
  - **pos1, pos2, pos3, pos4**: Exposure stations around OLT regasification terminal (43.6333°N, 9.9833°E)
- **Spatial Design**: Control vs Exposure comparison
- **Sample Distribution**:
  - T0 baseline samples (2014-2016)
  - Gorgona control samples (2014-2023)
  - Terminal exposure samples pos1-4 (2014-2023)

#### `station_type`
- **Description**: Station classification by exposure status
- **Values**:
  - **baseline**: T0 aquaculture farm pre-deployment samples
  - **control**: Gorgona natural environment (no industrial influence)
  - **exposure**: pos1-pos4 stations around regasification terminal

---

### Heavy Metal Measurements

All metal concentrations measured using **ICP-MS (Inductively Coupled Plasma Mass Spectrometry)**. Units: **mg/kg dry weight** of mussel soft tissue.

#### `arsenico` (Arsenic, As)
- **Description**: Total arsenic concentration
- **Toxicity**: High toxicity metal (carcinogenic)
- **Environmental Significance**: Industrial contamination indicator
- **LOD Handling**: Values below detection limit reported as "LOD_X,XX" format
- **Range**: Variable depending on contamination levels

#### `bario` (Barium, Ba)
- **Description**: Total barium concentration
- **Toxicity**: Moderate toxicity
- **Environmental Significance**: Drilling fluids, industrial processes
- **LOD Handling**: "LOD_X,XX" format for values below detection

#### `cadmio` (Cadmium, Cd)
- **Description**: Total cadmium concentration
- **Toxicity**: High toxicity metal (bioaccumulative, carcinogenic)
- **Environmental Significance**: Critical marine pollution indicator
- **LOD Handling**: "LOD_X,XX" format for sub-LOD values
- **Regulatory Importance**: EU maximum levels in bivalves

#### `rame` (Copper, Cu)
- **Description**: Total copper concentration
- **Toxicity**: Moderate toxicity (essential element at low concentrations, toxic at high)
- **Environmental Significance**: Antifouling paints, industrial effluents
- **LOD Handling**: "LOD_X,XX" format when applicable

#### `cromo_totale` (Total Chromium, Cr)
- **Description**: Total chromium concentration (all oxidation states)
- **Toxicity**: Moderate-high toxicity (Cr(VI) is carcinogenic)
- **Environmental Significance**: Industrial contamination, stainless steel production
- **LOD Handling**: "LOD_X,XX" format for sub-LOD values

#### `ferro` (Iron, Fe)
- **Description**: Total iron concentration
- **Toxicity**: Low toxicity (essential element)
- **Environmental Significance**: Natural crustal element, industrial sources
- **LOD Handling**: "LOD_X,XX" format when applicable
- **Note**: Generally high natural background levels

#### `nichel` (Nickel, Ni)
- **Description**: Total nickel concentration
- **Toxicity**: Moderate-high toxicity (carcinogenic, allergenic)
- **Environmental Significance**: Industrial contamination indicator
- **LOD Handling**: "LOD_X,XX" format for sub-LOD values

#### `manganese` (Manganese, Mn)
- **Description**: Total manganese concentration
- **Toxicity**: Low-moderate toxicity (essential element)
- **Environmental Significance**: Natural element, industrial sources
- **LOD Handling**: "LOD_X,XX" format when applicable

#### `piombo` (Lead, Pb)
- **Description**: Total lead concentration
- **Toxicity**: High toxicity (neurotoxic, bioaccumulative)
- **Environmental Significance**: Critical pollution indicator (historical leaded fuel)
- **LOD Handling**: "LOD_X,XX" format for sub-LOD values
- **Regulatory Importance**: EU maximum levels in bivalves

#### `vanadio` (Vanadium, V)
- **Description**: Total vanadium concentration
- **Toxicity**: Moderate toxicity
- **Environmental Significance**: Fuel oil combustion, industrial processes
- **LOD Handling**: "LOD_X,XX" format for sub-LOD values

#### `zinco` (Zinc, Zn)
- **Description**: Total zinc concentration
- **Toxicity**: Low toxicity (essential element at physiological concentrations)
- **Environmental Significance**: Natural element, industrial/urban sources
- **LOD Handling**: "LOD_X,XX" format when applicable
- **Note**: Essential for biological processes, toxic only at very high concentrations

#### `mercurio` (Mercury, Hg)
- **Description**: Total mercury concentration
- **Toxicity**: Very high toxicity (neurotoxic, bioaccumulative, biomagnifies in food chains)
- **Environmental Significance**: Critical global pollution concern
- **LOD Handling**: "LOD_X,XX" format for sub-LOD values
- **Regulatory Importance**: Strict EU maximum levels in fish/bivalves
- **Note**: Methylmercury form is particularly dangerous

---

## Analytical Methods

### ICP-MS Analysis Protocol
- **Instrument**: Inductively Coupled Plasma Mass Spectrometry
- **Sample Preparation**: Acid digestion of dried mussel tissue
- **Detection**: Trace metal concentrations down to μg/kg levels
- **Quality Control**: Certified reference materials, procedural blanks, replicate analysis

### LOD (Limit of Detection) Handling
- **Format**: "LOD_X,XX" where X,XX is the detection limit value
- **Note**: Comma (,) used as decimal separator in original Italian format
- **Statistical Treatment**: LOD values require special handling in statistical analysis (substitution or censored data methods)

---

## Quality Assurance

### Data Corrections Applied
- **Year Assignment**: Corrected from campaign codes and sampling metadata
- **Station Standardization**: Consistent station naming across campaigns
- **LOD Format**: Preserved original "LOD_X,XX" format for transparency

### Data Quality Notes
- **Temporal Coverage**: Complete seasonal coverage 2014-2023 (some gaps in 2020)
- **Analytical Consistency**: Same ICP-MS laboratory protocol throughout study period
- **Sample Replication**: Multiple individuals pooled per sample for representative measurements

---

## Usage Notes

### This is a CLEAN dataset
- **Raw measurements only**: No calculated indices included
- **No composite indices**: Metal Contamination Index (MCI) NOT included in this version
- **No statistical transformations**: Original concentration values preserved
- **Ready for analysis**: Start fresh analysis without preconceptions

### Recommended Analysis Approaches
- **LOD handling**: Consider censored data methods or LOD/2 substitution
- **Non-parametric methods**: Metals often non-normally distributed
- **Seasonal patterns**: Test for bioaccumulation seasonal cycling
- **Spatial gradients**: Compare control vs exposure stations
- **Toxicity weighting**: Consider differential toxicity when creating composite indices

---

**Data Origin**: Field campaigns 2014-2023, ICP-MS laboratory analysis, quality-controlled dataset validated for environmental monitoring research.
