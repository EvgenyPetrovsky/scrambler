library(scrambler)

# general variables
ns <- (-100:100)
testdata.dir <- "./data-temp/test"

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
    #rules.file     = paste0(testdata.dir, "/", "empty-rules.csv"),
    skip.headlines = 1,
    skip.taillines = 1,
    seed           = 1
  )

  lines.in.original.file  <- ctln_testfile("header-footer.csv")
  lines.in.scrambled.file <- ctln_testfile("header-footer.csv.scrambled")

  expect_equal(lines.in.original.file, lines.in.scrambled.file)
})
