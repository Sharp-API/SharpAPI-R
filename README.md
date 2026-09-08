# SharpAPI R SDK

[![license](https://img.shields.io/badge/license-MIT-06b6d4)](LICENSE)
[![CRAN](https://img.shields.io/badge/CRAN-submission%20in%20progress-lightgrey)](https://github.com/Sharp-API/SharpAPI-R/issues/1)
[![docs](https://img.shields.io/badge/docs-docs.sharpapi.io-06b6d4)](https://docs.sharpapi.io)

R client for [SharpAPI](https://sharpapi.io), the real-time sports betting odds API: live odds from 45+ sportsbooks in one schema, no-vig fair odds, +EV and arbitrage detection.

## Install

```r
# CRAN submission in progress; until then:
remotes::install_github("Sharp-API/SharpAPI-R")
```

## Usage

```r
Sys.setenv(SHARPAPI_KEY = "your-key")   # free tier: https://sharpapi.io/pricing

sports <- sharpapi_sports()                                        # sports + live event counts
odds   <- sharpapi_odds(league = "mlb", market_type = "moneyline") # flat data frame, one row per price
evs    <- sharpapi_ev(sport = "basketball")                        # +EV opportunities (Pro tier)
arbs   <- sharpapi_arbitrage()                                     # arbitrage opportunities (Hobby tier)

# best price per selection across books
ml <- odds[order(-odds$odds_decimal), ]
head(ml[!duplicated(ml$selection), c("selection", "sportsbook", "odds_american")])
```

## Functions

| Function | Endpoint | Tier |
|---|---|---|
| `sharpapi_sports()` | `/sports` | Free |
| `sharpapi_odds(...)` | `/odds` | Free |
| `sharpapi_ev(...)` | `/opportunities/ev` | Pro+ |
| `sharpapi_arbitrage(...)` | `/opportunities/arbitrage` | Hobby+ |

No key yet? Play offline with the free [sample dataset](https://github.com/Sharp-API/SharpAPI-Sample-Data) (2026 World Cup + MLB snapshots, CC BY 4.0).

## Status

Initial release; CRAN submission status is tracked in [#1](https://github.com/Sharp-API/SharpAPI-R/issues/1). MIT license.
