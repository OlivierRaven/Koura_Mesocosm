# Kōura Artificial Reef Mesocosm Study

Oliver V. Raven | olivier.raven@icloud.com

[![DOI](https://zenodo.org/badge/DOI/placeholder.svg)]()

## Overview

This repository contains all data, analysis code, and manuscript 
files for a mesocosm study testing artificial reef structure 
preferences of the Aotearoa-New Zealand freshwater crayfish kōura 
(*Paranephrops planifrons*). Four experiments compared reef types 
varying in material and configuration to identify design principles 
for freshwater crayfish restoration.

**Key findings:**
- Refuge configuration and structural stability predict kōura 
  habitat selection more strongly than material type
- Individual kōura preferred enclosed wooden log structures; 
  group kōura preferred flat and piled stone configurations
- Reef preference was size-dependent, strengthening with body 
  size in stone vs wood comparisons
- Stone pile configurations are recommended for lake-based 
  kōura restoration


## Repository structure
├── data/
│   ├── raw/          # Raw field and experimental data
│   └── derived/      # Processed data and model outputs (.rds)
├── images/           # Experimental setup photographs
├── references/       # Bibliography (.bib)
├── _quarto.yml       # Quarto project configuration
├── analysis.qmd      # Full statistical analysis notebook
└── index.qmd         # Manuscript

## Reproducing the analysis

This project uses [Quarto](https://quarto.org/) and R. 
All analyses are contained in `analysis.qmd`.

### Requirements

- R ≥ 4.5
- Quarto ≥ 1.4
- R packages: `brms`, `tidyverse`, `patchwork`, `XNomial`, 
  `DescTools`, `coin`, `bib2df`

### Install R packages

```r
install.packages(c("brms", "tidyverse", "patchwork", 
                   "XNomial", "DescTools", "coin"))
```

### Render the manuscript

```bash
quarto render
```

The rendered HTML manuscript will be available at:  
🌐 https://olivierraven.github.io/Reefs_Mesocosm/

### Bayesian models

Pre-fitted Bayesian models are stored as `.rds` files in 
`data/derived/`. To refit models from scratch, delete the 
relevant `.rds` file before rendering. Models were fitted 
using `brms` with `adapt_delta = 0.99` and 4000 iterations.

## Data availability

Raw data are available in `data/raw/`. Animal collection 
was conducted under ethics approval [add ethics number]. 
Kōura were sourced from lakes Ōkāreka and Tikitapu, 
Rotorua Te Arawa Lakes, Aotearoa New Zealand.

## Funding

This research was supported by the Fish Futures programme 
funded through a Ministry of Business, Innovation and 
Employment grant (CAWX2101).

## Citation

Raven, O.V., Holmes, R., Kusabs, I.A.K., Burdon, F.J., & 
Özkundakci, D. (in review). [Title]. *Freshwater Biology*.

## Licence

Code: [MIT License](LICENSE)  
Data: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)