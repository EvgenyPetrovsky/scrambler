% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/file-io.R
\name{loadRules}
\alias{loadRules}
\title{Load scrambling rules from file}
\usage{
loadRules(file)
}
\arguments{
\item{file}{- path to file with rules}
}
\value{
dataframe in the format of \code{scrambling.rules} data example
}
\description{
Function takes filename and returns dataframe with rules.
Rules must be stored in scv file with header. Column names should be equal to
columns of \code{scrambling.rules} data example
}
