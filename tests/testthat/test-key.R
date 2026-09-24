test_that("sharpapi_key() errors with an actionable message when unset", {
  withr::local_envvar(SHARPAPI_KEY = "")
  expect_error(sharpapi_key(), "Set SHARPAPI_KEY")
  # The message must carry the signup URL — it is the only thing a new user
  # gets, and there is no other prompt in the package.
  expect_error(sharpapi_key(), "sharpapi\\.io", fixed = FALSE)
})

test_that("sharpapi_key() returns the key when set", {
  withr::local_envvar(SHARPAPI_KEY = "test-key-123")
  expect_identical(sharpapi_key(), "test-key-123")
})

test_that("an unset key stops before any request is attempted", {
  withr::local_envvar(SHARPAPI_KEY = "")
  # If the check were ordered after request construction this would perform a
  # request; with_mocked_responses would then record one. It must not.
  attempted <- FALSE
  expect_error(
    httr2::with_mocked_responses(
      function(req) {
        attempted <<- TRUE
        fake_json_response(SPORTS_JSON)
      },
      sharpapi_sports()
    ),
    "Set SHARPAPI_KEY"
  )
  expect_false(attempted)
})
