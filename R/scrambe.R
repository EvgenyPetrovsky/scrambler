#' Scramble dataframe values
#' @description The function scrambles vector or values based on method provided
#'
scrambleDataFrame <- function(data, tablename, seed = 100, scramble.rules) {
  rules <- subset(scramble.rules, Table == tablename)
  cols  <- colnames(data)
  cols  <- cols[cols %in% rules$Column]

  updateCol <- function(data, col) {
    rule <- subset(rules, Column == col)
    method <- tolower(rule$Method[1])
    fix.val <- rule$Fixed.Value[1]
    max.len <- rule$Max.Length[1]

    data[, col] <- scrambleValue(data[, col], method, seed, fix.value, max.len)

    return(data)
  }

  scdata <- Reduce(f = updateCol, x = cols, init = data)
}

#' Scramble values
#' @description The function scrambles vector or values based on method provided
#'
#' @export
#' @param value - vector of values to scramble
#' @param method - obfuscation bethod. Supported methods are \code{shuffle},
#'   \code{hash}, \code{random.hash}, \code{random.num}, \code{rnorm.num}
#'
scrambleValue <- function(value, method, seed = 100, new.value = "", max.len) {
  set.seed(seed)
  if (method == "shuffle") {
    shuffle(value)
  } else if (method == "hash") {
    hash(value, max.len)
  } else if (method == "random.hash") {
    random.hash(max.len)
  } else if (method == "random.num") {
    random.num(value)
  } else if (method == "rnorm.num") {
  } else if (method == "random.date") {
    random.date(value)
  } else if (method == "fixed.value") {
    fixed.value(value, new.value)
  } else {
    fixed.value(value, new.value)
  }
}

shuffle <- function (v) {
  sample(v, length(v), replace = F)
}

hash <- function(v, max.len = 1000000L) {
  h <- sapply(X = v,
              FUN = digest::digest, algo = "md5",
              USE.NAMES = F)
  substring(h, 1, max.len)
}

rnorm.num <- function(v) {
  cnt <- length(v)
  std <- sd(v, na.rm = T)
  nrm <- rnorm(cnt, 0, std)
  sign(v) * abs(v + nrm)
}

random.num <- function(v) {
  NULL
}

random.date <- function(v) {
  NULL
}

random.hash <- function(max.len) {
  NULL
}

fixed.value <- function(v, fix.value) {
  replicate(length(v), fix.value)
}
