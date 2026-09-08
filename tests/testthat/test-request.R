test_that("sharpapi_get() targets the documented base URL and path", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  expect_equal(got$request$url, "https://api.sharpapi.io/api/v1/sports")
})

test_that("the API key travels in the X-API-Key header, not the query string", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  expect_true("X-API-Key" %in% names(got$request$headers))
  # The header is redacted, so the stored value is a weak reference rather than a
  # string and cannot be compared directly. req_dry_run() resolves it exactly as
  # req_perform() would, without touching the network, which is what proves the
  # real key still reaches the wire after redaction.
  wire <- httr2::req_dry_run(got$request, quiet = TRUE)
  expect_true("test-key-123" %in% unlist(wire$headers))

  # A key leaked into the URL would end up in server logs and browser history.
  expect_false(grepl("test-key-123", got$request$url, fixed = TRUE))
})

test_that("the API key is redacted, so a saved request cannot leak it", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  # The property that actually matters, and the reason `.redact` is set: httr2
  # keeps a redacted header behind a weak reference, so the plaintext is not in
  # the serialised object graph. A user who hits an error and shares dput(err),
  # err$request or a saved .rds must not ship their own key with it.
  dumped <- paste(utils::capture.output(dput(got$request)), collapse = "")
  expect_false(grepl("test-key-123", dumped, fixed = TRUE))
})

test_that("a user agent identifying the client is sent", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(SPORTS_JSON, sharpapi_sports())

  expect_match(got$request$options$useragent, "sharpapi-r", fixed = TRUE)
})

test_that("dots become query parameters", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(ODDS_JSON, sharpapi_odds(sport = "baseball", limit = 5))

  expect_match(got$request$url, "sport=baseball", fixed = TRUE)
  expect_match(got$request$url, "limit=5", fixed = TRUE)
})

test_that("no query string is appended when no filters are given", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  got <- capture_request(ODDS_JSON, sharpapi_odds())

  expect_false(grepl("?", got$request$url, fixed = TRUE))
})

test_that("an HTTP error is raised rather than returned as data", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  # Documented behaviour for a key below the required tier: sharpapi_ev() and
  # sharpapi_arbitrage() "raise an HTTP error rather than returning an empty
  # frame". Assert that, so the docs cannot drift away from the code silently.
  expect_error(
    httr2::with_mocked_responses(
      function(req) fake_json_response('{"error":"tier"}', status = 403L),
      sharpapi_ev(sport = "baseball")
    )
  )
})
