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
    scr[, c(col)] <- scrambleValue(data[, col], method, seed, mparam, max.len, data)

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
#' @param method.param - additional information associated with method; for
#'   example hash algorithm or exact fixed value
#' @param max.len - maximum length of scrabled value (useful when data column is
#'   of limited length)
#' @param data - data frame optionaly provided for evaluation (method = eval);
#'   columns of data frame can be addressed directly or via \code{data} alias
#'   (like \code{data$Field} to get data from \code{Field})
scrambleValue <- function(value, method, seed = 100, method.param = "", max.len, data = NULL) {
  set.seed(seed)
  result <- if (method == "shuffle") {
    shuffle(value)
  } else if (method == "hash") {
    hash(value, method.param)
  } else if (method == "random.hash") {
    random.hash(method.param)
  } else if (method == "random.num") {
    random.num(as.numeric(sub(",", ".", value, fixed = T)))
  } else if (method == "rnorm.num") {
    rnorm.num(as.numeric(sub(",", ".", value, fixed = T)))
  } else if (method == "random.date") {
    random.date(value)
  } else if (method == "fixed.value") {
    fixed.value(value, method.param)
  } else if (method == "eval") {
    eval.formula(value, method.param, data)
  } else {
    fixed.value(value, method.param)
  }

  if (missing(max.len) || is.na(max.len)) {
    result
  } else {
    substring(result, 1, max.len)
  }

}

shuffle <- function (v) {
  sample(v, length(v), replace = F)
}

hash <- function(v, algo = "md5") {
  hashfun <- function(x) {
    ifelse(is.na(x) | x == "", x, digest::digest(x, algo))
  }
  h <- sapply(X = v, FUN = hashfun, USE.NAMES = F)
}

rnorm.num <- function(v) {
  cnt <- length(v)
  std <- sd(v, na.rm = T)
  nrm <- rnorm(cnt, 0, ifelse(is.na(std), 0, std))
  h   <- sign(v) * abs(v + nrm)
  ifelse(is.na(v) | v == 0, v, h)
}

random.num <- function(v) {
  m   <- mean(v, na.rm = T)
  cnt <- length(v)
  std <- sd(v, na.rm = T)
  nrm <- rnorm(cnt, 0, ifelse(is.na(std), 0, std))
  h   <- sign(v) * abs(nrm + m)
  ifelse(is.na(v) | v == 0, v, h)
}

random.date <- function(v) {
  NULL
}

random.hash <- function(method.param) {
  NULL
}

fixed.value <- function(v, fix.value) {
  replicate(length(v), fix.value)
}

eval.formula <- function(x, formula, data) {
  result <- with(
    data,
    eval(parse(text = formula))
  )
  result
}
