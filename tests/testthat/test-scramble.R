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
