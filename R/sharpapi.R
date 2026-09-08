BASE_URL <- "https://api.sharpapi.io/api/v1"

sharpapi_key <- function() {
  key <- Sys.getenv("SHARPAPI_KEY")
  if (!nzchar(key)) {
    stop("Set SHARPAPI_KEY. Get a free key at https://sharpapi.io", call. = FALSE)
  }
  key
}

sharpapi_get <- function(path, ...) {
  params <- list(...)
  req <- httr2::request(paste0(BASE_URL, path))
  # `.redact` keeps the key out of a printed request AND out of the request
  # object httr2 attaches to its error conditions. The realistic leak is not an
  # attacker: it is a user hitting an error and sharing `dput(err)` or
  # `err$request` in a bug report.
  req <- httr2::req_headers(req, `X-API-Key` = sharpapi_key(), .redact = "X-API-Key")
  req <- httr2::req_user_agent(req, "sharpapi-r (https://github.com/Sharp-API/sharpapi-r)")
  # Do not follow redirects. curl forwards custom headers to the redirect target
  # (it strips `Authorization` across hosts, but not an arbitrary header such as
  # `X-API-Key`), so one misconfigured redirect would hand the user's key to
  # whoever operates the destination. Every endpoint here is a fixed path on one
  # HTTPS origin, so there is no legitimate redirect to follow.
  req <- httr2::req_options(req, followlocation = FALSE)
  if (length(params) > 0) {
    req <- do.call(httr2::req_url_query, c(list(req), params))
  }
  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(cnd) {
      # Re-raise WITHOUT chaining the original condition. httr2 attaches the
      # request to HTTP and transport errors, and a chained condition survives
      # `try()`, `saveRDS()` and `dput()`. Redaction covers printing; dropping
      # the chain covers serialisation.
      status <- tryCatch(httr2::resp_status(cnd$resp), error = function(e) NA_integer_)
      detail <- tryCatch(httr2::resp_body_string(cnd$resp), error = function(e) "")
      msg <- if (!is.na(status)) {
        paste0("SharpAPI request failed (HTTP ", status, ").")
      } else {
        "SharpAPI request failed: could not reach the API."
      }
      if (nzchar(detail)) {
        msg <- paste0(msg, " Response: ", substr(detail, 1, 200))
      }
      stop(msg, call. = FALSE)
    }
  )
  # `fromJSON()` treats a bare URL or an existing file path as a source to fetch
  # or read, so a response body that is not JSON could trigger a further request
  # or a local file read. `parse_json()` only ever parses the literal string.
  # The three `simplify*` arguments reproduce `fromJSON()`'s default shape, which
  # the exported functions rely on when they call `as.data.frame()`.
  jsonlite::parse_json(
    httr2::resp_body_string(resp),
    simplifyVector = TRUE,
    simplifyDataFrame = TRUE,
    simplifyMatrix = TRUE
  )
}

#' List sports with live event counts
#'
#' @return A data frame with one row per sport. Columns include `id`,
#'   `name`, `numerical_id`, `event_count` and `live_count`.
#' @examples
#' \donttest{
#' # Requires SHARPAPI_KEY to be set; get a free key at https://sharpapi.io
#' if (nzchar(Sys.getenv("SHARPAPI_KEY"))) {
#'   sports <- sharpapi_sports()
#'   head(sports)
#' }
#' }
#' @export
sharpapi_sports <- function() {
  as.data.frame(sharpapi_get("/sports")$data)
}

#' Current odds as a data frame
#'
#' @param ... Filters passed to the API, e.g. sport = "soccer",
#'   league = "mlb", sportsbook = "pinnacle", market_type = "moneyline",
#'   limit = 500.
#' @return A data frame with one row per odds line. Columns include
#'   `event_id`, `sportsbook`, `market_type`, `selection`, `odds_american`,
#'   `odds_decimal` and `odds_probability`.
#' @examples
#' \donttest{
#' if (nzchar(Sys.getenv("SHARPAPI_KEY"))) {
#'   odds <- sharpapi_odds(sport = "baseball", limit = 5)
#'   head(odds)
#' }
#' }
#' @export
sharpapi_odds <- function(...) {
  as.data.frame(sharpapi_get("/odds", ...)$data)
}

#' Positive expected value opportunities
#'
#' Requires a Pro tier key or higher.
#'
#' @param ... Filters passed to the API.
#' @return A data frame with one row per +EV opportunity. Columns include
#'   `event_id`, `sportsbook`, `market_type`, `selection` and `ev_percentage`.
#'   A key below the Pro tier raises an HTTP error rather than returning an
#'   empty frame.
#' @examples
#' \donttest{
#' if (nzchar(Sys.getenv("SHARPAPI_KEY"))) {
#'   ev <- sharpapi_ev(sport = "baseball")
#'   head(ev)
#' }
#' }
#' @export
sharpapi_ev <- function(...) {
  as.data.frame(sharpapi_get("/opportunities/ev", ...)$data)
}

#' Arbitrage opportunities
#'
#' Requires a Hobby tier key or higher.
#'
#' @param ... Filters passed to the API.
#' @return A data frame with one row per arbitrage opportunity. Columns
#'   include `event_id`, `sport`, `market_type` and `profit_percent`. The
#'   individual sides live in a nested `legs` column rather than as top-level
#'   fields. A key below the Hobby tier raises an HTTP error rather than
#'   returning an empty frame.
#' @examples
#' \donttest{
#' if (nzchar(Sys.getenv("SHARPAPI_KEY"))) {
#'   arb <- sharpapi_arbitrage(sport = "baseball")
#'   head(arb)
#' }
#' }
#' @export
sharpapi_arbitrage <- function(...) {
  as.data.frame(sharpapi_get("/opportunities/arbitrage", ...)$data)
}
