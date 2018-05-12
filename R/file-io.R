# Write data into file
# function takes parts of file and writes it in OFSAA compatible format
saveFile <- function(header, data, footer, file) {
  # check if directory exists and create if necessary
  filedir <- dirname(file)
  if (!dir.exists(filedir)) dir.create(filedir, recursive = T)
  # save
  saveLines(lines = header, file = file, append = F)
  if (nrow(data) > 0) {
    saveData(data, file)
  }
  if(!is.na(footer[1])) {
    saveLines(lines = footer, file = file, append = T)
  }
}

#' Load scrambling rules from file
#' @description Function takes filename and returns dataframe with rules.
#' Rules must be stored in scv file with header. Column names should be equal to
#' columns of \code{scrambling.rules} data example
#'
#' @return dataframe in the format of \code{scrambling.rules} data example
#'
#' @export
#' @param file - path to file with rules
#'
loadRules <- function(file) {
  csv.data <- read.csv(file, colClasses = "character")
  # subset loaded data
  csv.data[, c("File", "Column", "Method", "Method.Param", "Max.Length")]
}

#write log
write.log <- function(msg, ...) {
  composed <- paste(
    as.character(Sys.time()),
    msg,
    ...
  )
  write(composed, stdout())
}

# count number of lines in a file
countFileLines <- function(file) {
  con <- file(file, "r")
  cnt <- 0
  while(TRUE) {
    line = readLines(con, 1)
    if(length(line) == 0) break
    else cnt <- cnt + 1
  }
  close(con)
  cnt
}

# loan specified number of lines in a file starting from specific file
loadLines <- function(file, start.line = 1, count.lines) {
  con <- file(file, "r")
  end.line <- start.line + count.lines
  lines <- c()
  cnt <- 0
  while(TRUE) {
    line = readLines(con, 1)
    if(length(line) == 0) break
    if(cnt > end.line) break
    cnt <- cnt + 1
    if(cnt >= start.line & cnt < end.line) lines <- c(lines, line)
  }
  close(con)
  lines
}

saveLines <- function(lines, file, append) {
  write.table(
    x = lines, file = file, append = append,
    quote = F, row.names = F, col.names = F,
    fileEncoding = "UTF-8")
}

# load tabular data from file and return it as data.frame
loadData <- function(file, skip.lines, data.lines) {
  df <- read.csv(
    file = file, header = T, sep = ";", quote = "\"", dec = ",",
    nrows = data.lines, skip = skip.lines, colClasses = "character",
    stringsAsFactors = F
  )
  return(df)
}
# save vector of data into file as separate lines
saveData <- function(data, file) {
  write.table(
    x = data, file = file, append = T,
    quote = T, sep = ";", dec = ",", na = "", row.names = F, col.names = F,
    fileEncoding = "UTF-8"
  )
}
