library(scrambler)

# general variables
ns <- (-100:100)
testdata.dir <- "./data-temp/test"
algos <- c(
  "md5", "sha1", "crc32", "sha256", "sha512", "xxhash32", "xxhash64", "murmur32"
)

fhash <- function(x, m = "md5") scrambleValue(x, "hash", method.param = m)
fdgst <- function(x, m = "md5") digest::digest(x, algo = m)

test_that("size preservation", {
  s <- scrambleValue(ns, "fixed.value")
  expect_equal(length(ns), length(s))
  expect_equal(length(scrambleValue(1, "fixed.value")), 1)
})

test_that("hashing vector of values is vector of hased values", {
  expect_equal(
    fhash(ns),
    sapply(X = ns, FUN = fhash, USE.NAMES = F)
  )
  expect_equal(
    fhash(LETTERS),
    sapply(X = LETTERS, FUN = fhash, USE.NAMES = F)
  )
})

test_that("scrambling works as digest", {
  expect_equal(
    sapply(X = algos, FUN = function(x) {fhash(1, m = x)}, USE.NAMES = F),
    sapply(X = algos, FUN = function(x) {fdgst(1, m = x)}, USE.NAMES = F)
  )
  expect_equal(
    sapply(X = algos, FUN = function(x) {fhash("A", m = x)}, USE.NAMES = F),
    sapply(X = algos, FUN = function(x) {fdgst("A", m = x)}, USE.NAMES = F)
  )
})

test_that("scrambling of NA value is NA value", {
  expect_true(is.na(fhash(NA)))
})

test_that("randomization of NA number is NA number", {
  expect_equal(is.na(scrambleValue(c(0, 1, 2), "rnorm.num")), c(FALSE, FALSE, FALSE))
  expect_equal(is.na(scrambleValue(c(NA, 1, 2), "rnorm.num")), c(TRUE, FALSE, FALSE))
  expect_equal(is.na(scrambleValue(c(NA, NA, 2), "random.num")), c(TRUE, TRUE, FALSE))
  expect_equal(is.na(scrambleValue(c(NA, NA, NA), "random.num")), c(TRUE, TRUE, TRUE))
  expect_equal(is.na(scrambleValue(c(0, 1, 2), "random.num")), c(FALSE, FALSE, FALSE))
  expect_equal(is.na(scrambleValue(c(NA, 1, 2), "random.num")), c(TRUE, FALSE, FALSE))
  expect_equal(is.na(scrambleValue(c(NA, NA, 2), "random.num")), c(TRUE, TRUE, FALSE))
  expect_equal(is.na(scrambleValue(c(NA, NA, NA), "random.num")), c(TRUE, TRUE, TRUE))
})

test_that("randomization of 0 number is 0 number", {
  expect_equal(scrambleValue(c(-1, 0, 1), "rnorm.num")[2], 0)
  expect_equal(scrambleValue(c(NA, 0, 0), "rnorm.num")[2], 0)
  expect_equal(scrambleValue(c(NA, 0, NA), "rnorm.num")[2], 0)
  expect_equal(scrambleValue(c(-1, 0, 1), "random.num")[2], 0)
  expect_equal(scrambleValue(c(NA, 0, 0), "random.num")[2], 0)
  expect_equal(scrambleValue(c(NA, 0, NA), "random.num")[2], 0)
})

test_that("reshuffling", {
  s <- scrambleValue(ns, "shuffle")
  expect_equal(sum(s, na.rm = T), sum(ns, na.rm = T))
  expect_equal(sort(s), sort(ns))
  expect_false(isTRUE(all.equal(s, ns)))
})

test_that("scramble data.frame", {
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
    Method.Param = c("sha1", "sha256"),
    Max.Length  = c("", "16")
  )
  sd <- scrambleDataFrame(df, scrambling.rules = sr)
  expect_true(TRUE)
})

test_that("scramble data frame using eval method", {
  df <- data.frame(
    stringsAsFactors = F,
    Client  = c("Client 1", "Client 2", "Client 3"),
    Account = c("Account 1", "Account 2", "Account 3"),
    Balance = c(100, 200, 300)
  )
  sr <- data.frame(
    stringsAsFactors = F,
    Column = c("Balance"),
    Method = c("eval"),
    Method.Param  = "(x + 1333) / 1344 + Balance",
    Max.Length  = c(NA)
  )
  sd <- scrambleDataFrame(df, scrambling.rules = sr)
  expect_equal((df$Balance + 1333) / 1344 + df$Balance, sd$Balance)
})

test_that("scramble using eval method: access by \"x\"",{
  data <- data.frame(
    stringsAsFactors = F,
    Balance = c(100, 200, 300),
    Charges = c(1, 7, 3)
  )
  fun <- function(x, formula) {
    scrambleValue(
      value = x, method = "eval", seed = 123,
      method.param = formula, max.len = NA, data = data
    )
  }
  x <- data$Balance

  expect_equal(fun(x, "x + x"            ), x + x)
  expect_equal(fun(x, "x + data$Balance" ), x + data$Balance)
  expect_equal(fun(x, "x + data[[1]]"    ), x + data[[1]])
  expect_equal(fun(x, "Balance + Charges"), data$Balance + data$Charges)

})

save_testfile <- function(lines, filename) {
  if (!dir.exists(testdata.dir)) {
    dir.create(testdata.dir, recursive = T)
  }
  file <- paste(testdata.dir, filename, sep = "/")
  saveLines(lines = lines, file = file, append = F)
}

load_testfile <- function(filename) {
  file <- paste(testdata.dir, filename, sep = "/")
  loadLines(file, start.line = 1, count.lines = 10000L)
}

ctln_testfile <- function(filename) {
  file <- paste(testdata.dir, filename, sep = "/")
  countFileLines(file)
}

test_that("test file without data", {
  data <- c("0;header", "1;header", "9;footer")
  save_testfile(data, "header-footer.csv")
  empty.rules <- paste(colnames(scrambling.rules), collapse = ",")
  save_testfile(empty.rules, "empty-rules.csv")
  processFiles(
    input.folder   = paste0(testdata.dir, "/"),
    file.names     = "^header-footer.csv$",
    rules.file     = paste0(testdata.dir, "/", "empty-rules.csv"),
    skip.headlines = 1,
    skip.taillines = 1,
    seed           = 1
  )

  lines.in.original.file  <- ctln_testfile("header-footer.csv")
  lines.in.scrambled.file <- ctln_testfile("header-footer.csv.scrambled")

  expect_equal(lines.in.original.file, lines.in.scrambled.file)
})
