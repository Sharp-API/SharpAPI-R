# Build a fake httr2 response carrying `body` as a JSON string.
#
# Every test in this package goes through with_mocked_responses(), so no test
# ever performs a live request. That is a CRAN requirement (checks run on
# machines with no network and no API key), and it also keeps the suite
# deterministic against a feed whose contents change by the second.
fake_json_response <- function(body, status = 200L) {
  httr2::response(
    status_code = status,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(body)
  )
}

# Capture the request the package builds without performing it.
#
# Returns a list(request = <the httr2 request>, value = <the return value>) so a
# test can assert on both the wire format and the parsed result.
capture_request <- function(body, expr) {
  seen <- NULL
  value <- httr2::with_mocked_responses(
    function(req) {
      seen <<- req
      fake_json_response(body)
    },
    expr
  )
  list(request = seen, value = value)
}

# A minimal but shape-accurate /sports payload. Field names match the live
# API response verified on 2026-08-27.
SPORTS_JSON <- '{
  "data": [
    {"id": "baseball", "name": "Baseball", "numerical_id": 3, "event_count": 51, "live_count": 4},
    {"id": "soccer",   "name": "Soccer",   "numerical_id": 1, "event_count": 812, "live_count": 37}
  ],
  "updated_at": "2026-08-27T11:00:00Z"
}'

ODDS_JSON <- '{
  "data": [
    {"id": "row-1", "sportsbook": "pinnacle", "event_id": "evt-1", "sport": "baseball",
     "league": "mlb", "home_team": "Yankees", "away_team": "Red Sox",
     "market_type": "moneyline", "selection": "Yankees", "selection_type": "home",
     "odds_american": -145, "odds_decimal": 1.69, "odds_probability": 0.5918}
  ],
  "pagination": {"limit": 1, "offset": 0},
  "updated_at": "2026-08-27T11:00:00Z"
}'

EV_JSON <- '{
  "data": [
    {"event_id": "evt-1", "sportsbook": "draftkings", "market_type": "moneyline",
     "selection": "Yankees", "ev_percentage": 3.42}
  ]
}'

ARB_JSON <- '{
  "data": [
    {"event_id": "evt-1", "sport": "baseball", "market_type": "moneyline",
     "profit_percent": 1.8}
  ]
}'
