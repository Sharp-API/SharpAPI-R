# One test per exported function: it hits the documented path and returns a
# data frame whose columns are the ones the roxygen @return promises.

test_that("sharpapi_sports() returns the documented columns", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  expect_s3_class(got$value, "data.frame")
  expect_equal(nrow(got$value), 2L)
  expect_true(all(c("id", "name", "numerical_id", "event_count", "live_count")
                  %in% names(got$value)))
  expect_identical(got$value$id, c("baseball", "soccer"))
})

test_that("sharpapi_odds() hits /odds and returns the documented columns", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(ODDS_JSON, sharpapi_odds(sport = "baseball", limit = 1))

  expect_match(got$request$url, "/api/v1/odds", fixed = TRUE)
  expect_s3_class(got$value, "data.frame")
  expect_true(all(c("event_id", "sportsbook", "market_type", "selection",
                    "odds_american", "odds_decimal", "odds_probability")
                  %in% names(got$value)))
  # expect_equal, not expect_identical: jsonlite may parse a whole number as
  # integer or double depending on the value, and the type is not the contract.
  expect_equal(got$value$odds_american, -145)
})

test_that("sharpapi_ev() hits /opportunities/ev", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(EV_JSON, sharpapi_ev(sport = "baseball"))

  expect_match(got$request$url, "/api/v1/opportunities/ev", fixed = TRUE)
  expect_s3_class(got$value, "data.frame")
  expect_true(all(c("event_id", "sportsbook", "market_type", "selection",
                    "ev_percentage") %in% names(got$value)))
})

test_that("sharpapi_arbitrage() hits /opportunities/arbitrage", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(ARB_JSON, sharpapi_arbitrage(sport = "baseball"))

  expect_match(got$request$url, "/api/v1/opportunities/arbitrage", fixed = TRUE)
  expect_s3_class(got$value, "data.frame")
  expect_true(all(c("event_id", "sport", "market_type", "profit_percent")
                  %in% names(got$value)))
})

test_that("the response envelope is unwrapped — callers get $data, not the envelope", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  # `updated_at` sits beside `data` in the envelope. If unwrapping regressed,
  # it would surface as a column (or the frame would be one row of lists).
  expect_false("updated_at" %in% names(got$value))
  expect_false("data" %in% names(got$value))
})
