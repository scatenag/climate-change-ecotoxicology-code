# BIOMARKERS DATASET - VARIABLE DESCRIPTIONS

**File**: `biomarkers.csv`
**Records**: 1,470 samples (2014-2023)
**Organism**: *Mytilus galloprovincialis* (Mediterranean mussel)

---

## Temporal and Campaign Variables

### `sampling_date`
- **Type**: Date (YYYY-MM-DD)
- **Description**: Date of mussel collection from deployment site
- **Range**: 2014-05-07 to 2023-06-08
- **Origin**: Field sampling records
- **Note**: For T0 samples, represents collection date before deployment

### `campaign`
- **Type**: Categorical (2-character code)
- **Format**: [Season][Year]
  - P = Primavera (Spring)
  - E = Estate (Summer)
  - A = Autunno (Autumn)
  - I = Inverno (Winter)
- **Examples**: P14, E15, A16, I17
- **Range**: P14 to I25 (37 campaigns)

### `year`
- **Type**: Numeric (float with .0 decimal)
- **Range**: 2014.0 to 2023.0
- **Origin**: Extracted from sampling_date

### `period`
- **Type**: Categorical (single letter)
- **Values**: P, E, A, I
- **Description**: Season abbreviation

---

## Spatial Variables

### `station`
- **Type**: Categorical
- **Values**:
  - **t0**: Baseline mussels from aquaculture farm before deployment (n=238)
  - **Gorgona**: Control site, natural environment (n=312)
    - Location: 43°25'43.36"N, 9°54'27.87"E
    - Distance from terminal: ~15 km
  - **pos1, pos2, pos3, pos4**: Exposure stations around OLT terminal (n=920)
    - Location: Around 43.6333°N, 9.9833°E
    - Deployment depth: ~10m
    - Distances from discharge: 100-300m

### `station_type`
- **Type**: Categorical
- **Values**: "T0 (Baseline)", "Control (Gorgona)", "Exposure (pos1-4)"

---

## Biomarker Measurements

### `hemocytes_count`
- **Type**: Numeric (float, ×10⁶ cells/ml)
- **Description**: Hemocyte concentration in hemolymph (circulating immune cells)
- **Biological Function**: Immune system response indicator
- **Range**: 0.5 to 82.0 ×10⁶/ml
- **Analytical Method**:
  - Hemolymph extraction via adductor muscle puncture
  - Trypan blue viability staining
  - Hemocytometer counting (duplicate counts, mean reported)
  - QC: CV <15% between duplicates
- **Interpretation**:
  - High values: Enhanced immune response
  - Low values: Immunosuppression

### `nrrt_min`
- **Type**: Numeric (integer, minutes)
- **Description**: Neutral Red Retention Time - duration lysosomes retain dye
- **Biological Function**: Lysosomal membrane stability, cellular stress indicator
- **Range**: 15 to 240 minutes
- **Analytical Method**:
  - Neutral red dye (40 μg/ml) uptake in live hemocytes
  - Microscopic observation every 15 minutes
  - Endpoint: ≥50% cells show dye leakage
  - Temperature: 18°C ± 1°C (standardized)
  - QC: Positive control must retain >180 min
- **Interpretation**:
  - High values (>120 min): Healthy, stable lysosomes
  - Low values (<60 min): Membrane destabilization, stress

### `comet_assay_pct_dna`
- **Type**: Numeric (float, percentage)
- **Description**: Percentage of DNA in comet tail (DNA strand breaks)
- **Biological Function**: Genotoxic damage assessment
- **Range**: 5.2% to 52.8%
- **Analytical Method**:
  - Single-cell gel electrophoresis (Comet Assay)
  - Hemocyte isolation and agarose embedding
  - Alkaline lysis (DNA unwinding)
  - Electrophoresis (20V, 20 min)
  - SYBR Green staining
  - Image analysis (50 cells/sample scored)
  - QC: Negative control <10%, Positive control >40%
- **Sample Size Evolution**:
  - Campaigns P14-I16: n=5 animals per site
  - Campaigns E17-I25: n=7 animals per site (increased for statistical power)
- **Interpretation**:
  - Low values (<20%): Minimal DNA damage
  - High values (>35%): Significant genotoxicity

### `gill_epithelium_score`
- **Type**: Ordinal (integer 1-5)
- **Description**: Histopathological damage score of gill epithelium
- **Biological Function**: Tissue pathology assessment
- **Range**: 1 to 5
- **Scoring System**:
  - **1**: Normal epithelium, intact cilia, regular cells
  - **2**: Mild alterations, slight cilia loss (<25% area)
  - **3**: Moderate damage, epithelial thinning, cilia loss 25-50%
  - **4**: Severe damage, extensive cilia loss (>50%), cell necrosis
  - **5**: Very severe, complete epithelial breakdown, hemorrhage
- **Analytical Method**:
  - Tissue fixation: Davidson's solution, 24h
  - Paraffin embedding, 5μm sections
  - Hematoxylin-Eosin (H&E) staining
  - Microscopic examination (400× magnification)
  - Blind scoring (scorer unaware of station/treatment)
  - 10 fields of view per sample, modal score reported
  - QC: Inter-observer κ=0.82 (substantial agreement)
- **Biological Relevance**: Gills = primary contact with water (respiration, feeding, osmoregulation)

---

## Data Quality

### Missing Data
- **Overall completeness**: 95-100% for individual biomarkers
- **Campaign I21**: Gorgona control missing (only pos1-4 available)

### Temporal Distribution (after 2025 correction)
- 2014: 85 samples
- 2015: 115 samples
- 2016: 168 samples
- 2017: 168 samples
- 2018: 168 samples
- 2019: 133 samples
- 2020: 161 samples
- 2021: 168 samples
- 2022: 168 samples
- 2023: 126 samples

### Sample Size by Station
- T0 (Baseline): 238 samples (16.2%)
- Gorgona (Control): 312 samples (21.2%)
- pos1-pos4 (Exposure): 920 samples (62.6%)

---

## Analytical Considerations

### Laboratory QA/QC
- **Hemocyte count**: Duplicate counts, CV <15%, viability >80%
- **NRRT**: Duplicate assays, positive control >180 min, temperature controlled
- **Comet assay**: 50 cells/sample, negative control <10%, inter-scorer agreement >85%
- **Histopathology**: Blind scoring, 10 fields/sample, reference atlas standardization

### Data Origin
- **Field sampling**: SCUBA collection at ~10m depth
- **Transport**: <4 hours to laboratory, cooled (4°C)
- **Processing**: 24h acclimation, standardized protocols
- **Laboratory**: Certified marine ecotoxicology facility
- **Data recording**: LIMS (Laboratory Information Management System)

---

## Usage Notes

✓ **Biological data**: Typically non-normal distributions
✓ **Recommended statistics**: Non-parametric methods (Mann-Whitney U, Kruskal-Wallis, Spearman)
✓ **Temporal coverage**: Complete 2014-2023
✓ **Spatial design**: T0 baseline → Control (Gorgona) vs Exposure (pos1-4)

**Note**: This dataset contains RAW biomarker measurements only. No calculated composite indices included (e.g., BSI - Biological Stress Index removed from this clean version).
