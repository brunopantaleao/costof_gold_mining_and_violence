# The Cost of Gold: Mining Booms, Violence, and Agrarian Conflict in Brazil

**Sofia Amaral** (Harvard Kennedy School), **Bruno Pantaleão** (FGV-Analytics), **Daniel Rio Tinto** (FGV-RI)

## Overview

This repository contains the Stata replication code for "The Cost of Gold: Commodity Shocks and Violence Against Peasants in Brazil." The paper investigates how international gold price shocks, transmitted via local mining exposure, affect homicide rates, agrarian conflicts, and peasant displacement in Brazil.

## Abstract

Commodity booms can generate social costs, particularly where institutions are weak. We examine whether higher gold prices are associated with mining expansion, violence, and agrarian conflict in Brazilian municipalities during 2001--2019. A shift-share (Bartik) design combines predetermined municipal exposure to gold mining with international gold prices and exchange rates, to recover the effects of mining incentives on mining expansion and violence. Price-induced exposure expands artisanal (_garimpo_) and gold mining, measured using remote sensing. In our preferred specifications, a one-standard deviation increase in the _garimpo_ Bartik is associated with a 36\% increase in homicides. Agrarian-conflict estimates are positive but less precise. _Garimpo-_based homicide effects concentrate where gold occurrences are geologically recorded and are similar in cities where gold extraction is formally registered. We find that _ garimpo_ exposure is more strongly associated with lethal violence, while gold-mining exposure is more closely associated with agrarian conflicts and affected families. These patterns are consistent with mining expansion being an important channel through which gold-price shocks affect local social conflict.
 

## Contents

### Main Analysis File

- **`Data_analysis_paper_only_v4.do`** — Paper-only Stata replication script (Stata 14.1+)
  - Generates all tables and figures except the maps
  - Contains 7 main sections covering descriptive, reduced-form, and IV analyses

### What This File Does NOT Contain

- Sections 1–4 of the full replication pipeline (auxiliary dataset construction, panel assembly, Bartik baseline calculation)
  - *Starts from:* `panel_replication.dta` (pre-constructed)
- Thematic maps: total affected families, environmental hazards, baseline mining)
- Sample-construction flowchart)
- Tables 7 and A5 (hand-typed summaries)

## Software Requirements

**Stata version:** 14.1 or later

**Required packages:**
```stata
ssc install reghdfe
ssc install ivreghdfe
ssc install ivreg2
ssc install ranktest
ssc install outreg2
ssc install coefplot
ssc install binscatter
```

## Data Requirements

**Input file:** `panel_replication.dta`

This dataset should contain:
- Municipal-level panel (1991–2019)
- Homicide outcomes: `taxa_homicidio_geral`, `taxa_homicidio_indigena`
- Conflict/displacement: `fam` (displaced families), `num_con` (number of conflicts), `lfam`, `lconf` (log-transformed)
- Mining exposure: `mb_total_km2`, `mb_garimpo_km2`, `mb_industrial_km2`, `mb_gold_km2`, `accum_atv_km2`
- Baseline shares (year-specific): `base_gold_sh_*`, `base_garimpo_sh_*`
- Bartik instruments: `lbartik_gold_2000`, `lbartik_garimpo_2000`, `lbartik_usd_prices`, `cont2`, `cont3`
- Controls: `lpop` (log population), `empregos_pc` (employment per capita), `lmb_gold`, `lmb_garimpo`, `lmb_industrial`
- Geography: `codmun` (municipality code), `ano` (year), `amazonia_legal`, `ouro_ever`, `ouro_ever2`, `ever_conflict`

## Usage

1. **Set the working directory:**
   ```stata
   global out "your/path/to/output"
   ```

2. **Run the do-file:**
   ```stata
   do Data_analysis_paper_only_v4.do
   ```

3. All output files (tables and figures) will be saved to `$out` with descriptive names.

## Output Files

### Tables (Excel)
- `rf_baseline_robustness_*.xls` — Table 1: baseline reduced-form with robustness
- `lbartik_garimpo_2000_*.xls` — Table 2: heterogeneous effects (age, race, gender)
- `rf_main_gold_only.xls`, `rf_main_no_gold.xls` — Table 3: gold vs. all mining
- `iv_mapbio_*_main.xls` — Tables 4–5: main IV results
- `iv_garimpo_sigmin.xls`, `iv_gold_sigmin.xls` — Tables 4 & 6: SIGMIN mine-level IV
- `pretrend_leads.xls`, `placebo_*.xls` — Tables A6–A8: pre-trends & placebo tests
- Plus 15+ additional robustness and subsample tables (see detailed index below)

### Figures (PDF)
- `f1_agg_usd_fam.pdf`, `f2_agg_brl_fam.pdf` — Figure 3: gold price vs. displaced families
- `f3_agg_usd_homicidios.pdf`, `f4_agg_brl_homicidios.pdf` — Figure 2: gold price vs. homicides
- `f1_agg_usd_num_con.pdf`, `f2_agg_brl_num_con.pdf` — Figure 3: gold price vs. conflicts
- `f5_usd_mining_mb.pdf`, `f6_brl_mining_mb.pdf` — Figure 1: gold price vs. mining expansion
- `ts_mapbiomas_mining.pdf` — Figure A4: mining area time series
- `coefplot_pretrends.pdf`, `coefplot_placebo_future.pdf` — Figures A5–A6: parallel trends
- `binscatter_dose_response*.pdf` — Figure A7: dose-response relationships

## Detailed Section Index

| **Paper Item** | **Section** | **Primary Output** |
|---|---|---|
| Tables A1, A2, A4 | 1 | Log file summaries |
| Figures 1, 2, 3 | 2a | Time-series scatter plots |
| Figure A4 | 2b | Mining area trends |
| Figures A2, A3 | 2c | Baseline share histograms |
| Table 1 | 3a | Baseline reduced-form |
| Table A20 | 3b | Log Bartik reduced-form |
| Table 2 (Panels A–C) | 3c | Heterogeneous effects |
| Table 3 (Panels A–D) | 3d | Gold vs. all mining specs |
| Tables 4, 5, A9 | 4a | IV with MapBiomas mining |
| Tables 4 (cols. 5–6), 6 | 4b | IV with SIGMIN mines |
| Tables A6–A8, Figs A5–A6 | 5 | Pre-trends & placebo tests |
| Tables A10, A11 | 6a | USD-only and USD Bartik |
| Table A12 | 6b | Cocaine control variable |
| Tables A13, A14 | 6c | Legal Amazon & CPT-only samples |
| Tables A15, A16 | 6d | Protected areas & indigenous lands |
| Table A17 | 6e | Gold inclusion/exclusion |
| Table A18 | 6f | Uninstrumented associations |
| Table A19, Fig. A7 | 7 | Extreme-share robustness (Callaway method) |

## Notes

- All Bartik instruments are constructed as: `Bartik = baseline_share × price_shock`
- Log transformations use: `ln(1 + x)` for outcomes with zeros
- Standard errors are clustered at the municipality level throughout
- All specifications include municipality and year fixed effects (unless otherwise noted)

## Contact

For questions or data requests, contact:
- Sofia Amaral: [santonelliamaral@hks.harvard.edu](mailto:santonelliamaral@hks.harvard.edu)
- Bruno Pantaleão: [bruno.oliveira@sciencespo.fr](mailto:bruno.oliveira@sciencespo.fr)
- Daniel Rio Tinto: [daniel.riotinto@fgv.br](mailto:daniel.riotinto@fgv.br)


**Last updated:** 2024  
**Stata version tested:** 14.1–17.0
