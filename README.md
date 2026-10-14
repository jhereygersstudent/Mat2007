# Dutch Supermarket Price Analysis

This project compares the price of the same shopping basket at the six largest Dutch supermarket chains, using public price data from checkjebon.nl.

## 🧠 Research Question
**Which of the six largest Dutch supermarket chains offered the cheapest everyday shopping basket between November 2022 and October 2026, and did the ranking change over time?**

## 📊 Dataset
- Source: [checkjebon on GitHub](https://github.com/supermarkt/checkjebon)
- File used: `data/supermarkets.json` (one snapshot per month, 48 in total)
- Chains: Albert Heijn, Jumbo, Lidl, Plus, Aldi, Dirk
- The script downloads the data itself. No manual cleaning is needed.

## 🧪 What the script does
- Downloads the 48 monthly price snapshots
- Cleans the data: keeps the six chains, converts pack sizes, removes wrong matches
- Finds the cheapest match for each of 30 basket products per chain and month
- Compares each chain with the average and ranks the chains per month
- Visualizes:
  - Basket cost per chain over time
  - Ranking of the chains over all months

## 📁 Output
The script generates:
- `figures/plot1_basket_over_time.png`
- `figures/plot2_ranking.png`
- `results/*.csv` (all numbers behind the plots)

## ▶️ How to run
Install R and the two required packages once:
```r
install.packages(c("jsonlite", "ggplot2"))
```
Then run from the project folder:
```bash
Rscript supermarket_analysis.R
```
The first run needs an internet connection to download the data (~500 MB) and takes a few minutes.
