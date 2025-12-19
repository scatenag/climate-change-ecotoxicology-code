# Climate Change Ecotoxicology - Analysis Code Repository
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17989514.svg)](https://doi.org/10.5281/zenodo.17989514)


**Study**: Climate Change Exceeds Metal Contamination as the Primary Driver of Biological Stress in Mediterranean Mussels

**Manuscript Status**: Under review at *Global Change Biology*

**Study Period**: 2014-2023 (10 years)
**Study Area**: Ligurian Sea, Northwestern Mediterranean

---

## Overview

This repository contains the **analysis code** to reproduce all publication figures from our manuscript submitted to *Global Change Biology*.

### ⚠️ Data Availability

**Raw datasets and processed results will be made publicly available upon manuscript acceptance**:
- **Code** (this repository): Available now on GitHub
- **Data**: Will be deposited on Zenodo with DOI upon acceptance
- **Timeline**: Data release planned for [Q1 2025 / upon acceptance]

This staged approach ensures:
- ✅ Code transparency and review during peer review
- ✅ Compliance with data sharing agreements
- ✅ Proper data archival with permanent DOI

---

## Repository Contents

### ✅ Currently Available

**Analysis Scripts** :
- `00_master_config_FIXED.R` - Configuration with relative paths
- `02_fig1_climate_dashboard.R` - Climate trends + marine heatwaves
- `03_fig2_climate_effects_heatmap.R` - Climate-metal correlation matrix
- `04_fig3_variance_partitioning_PHASE5.5.R` - Multi-method variance partitioning ⭐
- `05_fig4_scenario_projections.R` - IPCC climate scenarios (2014-2100)
- `06_fig6_cci_bsi_time_series.R` - CCI-BSI temporal trends
- `07_fig7_mhw_biomarker_response.R` - Marine heatwave delay effects
- `99_render_all_figures.R` - Master script (renders all figures)

**Software Environment** (`ENVIRONMENT/`):
- `requirements.R` - R package dependencies
- `requirements.txt` - Python package dependencies (for data preprocessing)

**Documentation** (`DOCUMENTATION/`):
- Variable descriptions for all datasets (00-08 markdown files)
- Experimental design and methods
- Data format specifications

### 📦 To Be Released (Upon Acceptance)

**Raw Data** (will be added to Zenodo):
- `biomarkers.csv` - 1,470 biomarker samples (4 variables)
- `heavy_metals.csv` - 201 metal samples (12 elements)
- `ctd_oceanographic.csv` - 68,164 CTD measurements
- `copernicus_models_daily.csv` - 6,876 daily environmental observations
- `copernicus_co2_daily.csv` - 3,438 daily CO₂ system data
- `copernicus_satellite.csv` - 423 satellite observations
- `marine_heatwaves/` - Marine heatwave events (2014-2023)

**Processed Data** (will be added to Zenodo):
- Phase 1 climate trend analysis outputs
- Phase 4 climate-metal linkage results
- Phase 5.5 multi-method variance partitioning tables
- Phase 6 composite indices (CCI, BSI, MCI)

**Results** (will be added after publication):
- Publication-quality figures (PDF + PNG)
- Summary tables (variance partitioning, correlations)

---

## Expected Data Structure

The scripts expect data files in the following structure (to be created when data is released):

```
DATA_AVAILABILITY_REPOSITORY/
├── DATA/                              # Raw datasets (CSV)
│   ├── biomarkers.csv
│   ├── heavy_metals.csv
│   ├── ctd_oceanographic.csv
│   ├── copernicus_models.csv
│   ├── copernicus_models_daily.csv
│   ├── copernicus_co2_daily.csv
│   ├── copernicus_satellite.csv
│   └── marine_heatwaves/
│       ├── daily_temperature_heatwaves.csv
│       ├── heatwave_events.csv
│       └── climatology_p90_thresholds.csv
│
├── PROCESSED_DATA/                    # Intermediate results
│   ├── phase1_climate_trends/
│   ├── phase4_climate_metals/
│   └── phase6_indices/
│
├── SCRIPTS/ (this folder)             # Analysis code ✅ AVAILABLE NOW
├── DOCUMENTATION/ (this folder)       # Variable descriptions ✅ AVAILABLE NOW
└── ENVIRONMENT/ (this folder)         # Software requirements ✅ AVAILABLE NOW
```

See `DOCUMENTATION/` folder for detailed specifications of all expected data files.

---

## Software Requirements

### R Environment

**Minimum R version**: 4.3.0

**Required packages**:
```r
# Install all dependencies
source("ENVIRONMENT/requirements.R")
```

Core packages:
- `ggplot2`, `tidyr`, `dplyr`, `readr` - Data manipulation and visualization
- `patchwork` - Multi-panel figures
- `scales`, `RColorBrewer`, `viridis` - Color palettes
- `zoo` - Time series operations

### Python Environment (Optional)

For data preprocessing steps (not required for figure generation):
```bash
pip install -r ENVIRONMENT/requirements.txt
```

---

## Usage (After Data Release)

### Step 1: Obtain Data

**Upon manuscript acceptance**, data will be available at:
- **Zenodo DOI**: [To be added]
- **GitHub release**: [To be added]

Download and extract data files into the repository structure shown above.

### Step 2: Install Dependencies

```r
setwd("/path/to/repository")
source("ENVIRONMENT/requirements.R")
```

### Step 3: Generate Figures

**Option A: All figures at once**
```r
source("SCRIPTS/99_render_all_figures.R")
```

**Option B: Individual figures**
```r
# Figure 1: Climate trends
source("SCRIPTS/02_fig1_climate_dashboard.R")

# Figure 3: Variance partitioning (PRIMARY RESULT)
source("SCRIPTS/04_fig3_variance_partitioning_PHASE5.5.R")

# ... (see other scripts in SCRIPTS/ folder)
```

**Output**: Figures saved in `RESULTS/figures/` as PDF (vector) and PNG (300 DPI)

---

## Key Methodological Details

### Study Design

- **Control Site**: Gorgona Island (Marine Protected Area, pristine)
- **Exposure Site**: OLT Offshore LNG Terminal (industrial facility)
- **Sampling**: Quarterly campaigns (2014-2023), N=32 campaigns
- **Biomarkers**: Comet Assay (DNA damage), NRRT (lysosomal stability), Hemocytes (immune), Gill epithelium (tissue integrity)
- **Metals**: 12 elements (As, Ba, Cd, Cu, Cr, Fe, Hg, Mn, Ni, Pb, V, Zn) via ICP-MS

### Analysis Pipeline

**Phase 1**: Climate trend analysis (Mann-Kendall, marine heatwave detection)
**Phase 2**: T0 population homogeneity tests
**Phase 3**: T0 normalization validation
**Phase 4**: HGAM climate-metal interference models
**Phase 5**: Multi-method variance partitioning (SEM, 3 Bayesian Networks, LMG)
**Phase 6**: Composite indices construction (CCI, BSI, MCI)
**Phase 7**: Publication figure generation ← **THIS REPOSITORY**

---

## Citation
TBD

**Upon acceptance**, full citation with DOI will be provided.
See `CITATION.cff` for machine-readable metadata.

---

## License

**Code**: MIT License

You are free to use, modify, and distribute this code with proper attribution.

**Data**: CC-BY 4.0 (upon release)

---

## Contact

**Questions about the code?**
- Open an issue on GitHub
- Email: [To be added upon acceptance]

**Requesting early access to data for review purposes?**
- Contact corresponding author directly
- Data can be shared privately with editors/reviewers during peer review

---

## Roadmap

- [x] **Phase 1** (Current): Code repository public
- [ ] **Phase 2**: Data deposited on Zenodo (upon acceptance)
- [ ] **Phase 3**: Repository updated with data links
- [ ] **Phase 4**: Full reproduction workflow documented

---

## Acknowledgments

**Data Sources**:
- Copernicus Marine Service (environmental data)
- OLT Offshore LNG Toscana (biomonitoring program)

**Funding**: [To be added]

---

**Repository Status**: ✅ Code Available | 📦 Data Pending Acceptance

**Last Updated**: 2025-12-18
**Version**: 1.0 (Code-Only)
