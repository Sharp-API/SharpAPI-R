# sharpapi 0.1.1

Resubmission of 0.1.0 (submitted 2026-09-08). Thank you to Leonore
Hochhauser for the review. Both points raised are addressed.

## 1. The maintainer is now a person, not an organisation

`Authors@R` now names a first and last name:

    person("Mike", "Lazarski", email = "hello@sharpapi.io",
           role = c("aut", "cre"))

SharpAPI is kept as copyright holder (`cph`), which matches the
`COPYRIGHT HOLDER` line in the `LICENSE` file. The maintainer address is
unchanged.

## 2. The examples are now testable

Every exported function talks to a REST API that needs a key, so the live
call stays inside `\donttest{}`. Each Rd file now also carries a small toy
example ABOVE that wrapper, unwrapped and run automatically:

* it serves a canned response through `httr2::with_mocked_responses()`, so
  it needs no API key, makes no network request and finishes in
  milliseconds;
* it exercises the real code path -- request construction, redirect and
  header handling, `jsonlite::parse_json()` and the data-frame conversion
  -- and returns exactly the columns the `\value` section documents.

The key is set only for the duration of the toy example, via
`withr::with_envvar()`, so it cannot leak into a later example in the same
check session. The toy block is guarded by `requireNamespace("withr")`;
`withr` is in `Suggests`.

## Test environments

* GitHub Actions, ubuntu-latest: R-devel, R-release and R-oldrel-1,
  running `R CMD check --as-cran`.

## R CMD check results

0 errors | 0 warnings | 0 notes

The CI job is configured with `error-on: "note"`, so the package cannot be
merged with an outstanding NOTE on any of the three R versions above.
