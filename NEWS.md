# sharpapi 0.1.1

* Every help page now has a small example that runs offline, with no API key
  and no network connection.
* Requires httr2 1.2.0 or later. From that version the API key is kept out of
  saved or printed request objects, not only masked when a request is printed.
* Now distributed through [r-universe](https://sharp-api.r-universe.dev/sharpapi),
  with pre-built binaries for Windows, macOS and Linux.

# sharpapi 0.1.0

* First version: `sharpapi_sports()`, `sharpapi_odds()`, `sharpapi_ev()` and
  `sharpapi_arbitrage()`, each returning a plain data frame.
* The API key is read from the `SHARPAPI_KEY` environment variable and sent in
  a request header. Redirects are not followed, so the key is never forwarded
  to another host.
* A getting-started vignette and a test suite that runs without a key.
