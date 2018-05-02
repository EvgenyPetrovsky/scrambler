library(scrambler)

ns <- (-100:100)

test_that("size preservation", {
  s <- scrambleValue(ns, "fixed.value")
  expect_equal(length(ns), length(s))
  expect_equal(length(scrambleValue(1, "fixed.value")), 1)
})

test_that("reshuffling", {
  s <- scrambleValue(ns, "shuffle")
  expect_equal(sum(s, na.rm = T), sum(ns, na.rm = T))
  expect_equal(sort(s), sort(ns))
  expect_false(isTRUE(all.equal(s, ns)))
})

test_that("scramblr data.frame", {
  df <- data.frame(
    stringsAsFactors = F,
    Client  = c("Client 1", "Client 2", "Client 3"),
    Account = c("Account 1", "Account 2", "Account 3"),
    Balance = c(100, 200, 300)
  )
  sr <- data.frame(
    stringsAsFactors = F,
    Column = c("Client", "Account"),
    Method = c("hash", "hash"),
    Fixed.Value = c("", ""),
    Max.Length  = c("", "16")
  )
  sd <- scrambleDataFrame(df, scrambling.rules = sr)
  expect_true(TRUE)
})
