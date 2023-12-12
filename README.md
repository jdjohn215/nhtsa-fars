This repo provides easy access to the summary auxillary datasets from the [NHTSA's Fatality Analysis Reporting System (FARS)](https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars). FARS provides annual versions of these files. This repository combines those annual files into single files at the accident, vehicle, and person levels.

See `data/` for combined 1982-2021 auxillary files, along with the most recent codebook I could find.

The entire FARS database includes many datapoints with standards that can change from year to year. The auxillary files integrate the most commonly used variables. [See here for more details](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/811364).

For a demonstration of how to quickly download and combine the annual auxillary files, see [this script](processing-scripts/retrieve-annual-aux-files.R).

See the `analysis-scripts` directory for examples of combining information from the different levels to create graphs like these.

![](plots/USA_by_year-tod-mode.svg?)

![](plots/WI_by_year-tod-mode.svg?)
