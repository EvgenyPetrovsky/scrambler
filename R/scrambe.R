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
    mparam  <- rule$Method.Param
    max.len <- rule$Max.Length

    write.log("scrambling", col, "using", method, "method")
    scr <- data
    scr[, c(col)] <- scrambleValue(data[, col], method, seed, mparam, max.len)

    return(scr)
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
#' @param method.param - additional information associated with method; for example hash algorithm or exact fixed value
#' @param max.len - maximum length of scrabled value (useful when data column is of limited length)
scrambleValue <- function(value, method, seed = 100, method.param = "", max.len = "") {
  set.seed(seed)
  result <- if (method == "shuffle") {
    shuffle(value)
  } else if (method == "hash") {
    hash(value, method.param)
  } else if (method == "random.hash") {
    random.hash(value, method.param)
  } else if (method == "random.num") {
    random.num(value)
  } else if (method == "rnorm.num") {
    rnorm.num(value)
  } else if (method == "random.date") {
    random.date(value)
  } else if (method == "fixed.value") {
    fixed.value(value, method.param)
  } else {
    fixed.value(value, method.param)
  }

  if (max.len == "") {
    result
  } else {
    substring(result, 1, as.integer(max.len))
  }

}

shuffle <- function (v) {
  sample(v, length(v), replace = F)
}

hash <- function(v, algo = "md5") {
  hashfun <- function(x) {
    digest::digest(x, algo)
  }
  h <- sapply(X = v, FUN = hashfun, USE.NAMES = F)
}

rnorm.num <- function(v) {
  cnt <- length(v)
  std <- sd(v, na.rm = T)
  nrm <- rnorm(cnt, 0, std)
  sign(v) * abs(v + nrm)
}

random.num <- function(v) {
  m   <- mean(v, na.rm = T)
  cnt <- length(v)
  std <- sd(v, na.rm = T)
  nrm <- rnorm(cnt, 0, std)
  sign(v) * abs(nrm + m)}

random.date <- function(v) {
  NULL
}

random.hash <- function(method.param) {
  NULL
}

fixed.value <- function(v, fix.value) {
  replicate(length(v), fix.value)
}
