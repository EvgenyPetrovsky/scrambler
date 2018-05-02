#' Rules for data scrambling
#'
#' A dataset contains rules that a subsequently applied to data-frame columns.
#' Each rule scrambles column using set of package functions.
#'
#' @format A dataframe with 5 variables
#' \describe{
#'   \item{File}{
#'     File name / regular expression - used to store different rules for different files
#'   }
#'   \item{Column}{
#'     dataframe column
#'   }
#'   \item{Method}{
#'     scrambling method; possible values are described in
#'     \code{method} parameter of \code{scrambleValue} function
#'   }
#'   \item{Fixed.Value}{
#'     use fixed value to replace original values - works together with
#'     \code{fixed.value} method
#'   }
#'   \item{Max.Length}{
#'     maximum length of scrambled value
#'   }
#' }
"scrambling.rules"
