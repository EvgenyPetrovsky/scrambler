#' Scramble dataframe values
#' @description The function scrambles vector or values based on method provided
#'
#' @return Function returns data frame with scrambled values.
#'
#' @export
#' @param data - dataframe with data to be scrambles
#' @param seed - seed value for randomization
#' @param scrambling.rules - scrambling rules dataframe that contains Column, Method, Fixed.Value, Max.Lenght columns
scrambleDataFrame <- function(data, seed = 100, scrambling.rules) {
  rules <- subset(scrambling.rules, Column %in% colnames(data))

  applyRule <- function(data, idx) {
    rule    <- rules[idx,]
    col     <- rule$Column
    method  <- tolower(rule$Method)
    fix.val <- rule$Fixed.Value
    max.len <- rule$Max.Length

    write.log("scrambling", col, "using", method, "method")
    data[, c(col)] <- scrambleValue(data[, col], method, seed, fix.val, max.len)

    return(data)
  }

  scdata <- if (nrow(rules) > 0) {
    Reduce(f = applyRule, x = (1:nrow(rules)), init = data)
  } else {
    data
  }
}

#' Scramble values
#' @description The function scrambles vector or values based on method provided
#'
#' @export
#' @param value - vector of values to scramble
#' @param method - obfuscation bethod. Supported methods are \code{shuffle},
#'   \code{hash}, \code{random.hash}, \code{random.num}, \code{rnorm.num}
#' @param seed - seed value for random generation and sampling
#' @param new.value - fixed value to replace original one (works only with \code{fixed.value} method)
#' @param max.len - maximum length of scrabled value (useful when data column is of limited length)
scrambleValue <- function(value, method, seed = 100, new.value = "", max.len = "") {
  set.seed(seed)
  result <- if (method == "shuffle") {
    shuffle(value)
  } else if (method == "hash") {
    if (max.len == "") hash(value)
    else hash(value, as.numeric(max.len))
  } else if (method == "random.hash") {
    random.hash(max.len)
  } else if (method == "random.num") {
    random.num(value)
  } else if (method == "rnorm.num") {
    rnorm.num(value)
  } else if (method == "random.date") {
    random.date(value)
  } else if (method == "fixed.value") {
    fixed.value(value, new.value)
  } else {
    fixed.value(value, new.value)
  }
  result
}

shuffle <- function (v) {
  sample(v, length(v), replace = F)
}

hash <- function(v, max.len = 1000000L) {
  hashfun <- function(x) {
    digest::digest(x, algo = "md5")
  }
  h <- sapply(X = v, FUN = hashfun, USE.NAMES = F)
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
