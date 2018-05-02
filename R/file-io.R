# load tabular data from file and return it as data.frame
loadData <- function(file, skip.lines, data.lines) {
  df <- read.csv(
    file = file, header = T, sep = ";", quote = "\"", dec = ",",
    nrows = data.lines, skip = skip.lines,
    stringsAsFactors = F
  )
  return(df)
}

getTableName <- function(header) {
  unlist(strsplit(header, split = ";"))[4]
}

# Get CSA Table name from file
loadTableName <- function(file) {
  getTableName(loadHead(file))
}

# Write data into file
# function takes parts of file and writes it in OFSAA compatible format
saveFile <- function(header, data, footer, file) {
  write.table(
    x = header, file = file, append = F,
    quote = F, row.names = F, col.names = F,
    fileEncoding = "UTF-8")
  write.table(
    x = data, file = file, append = T,
    #eol = ";\r\n",
    quote = T, sep = ";", dec = ",", na = "", row.names = F, col.names = F,
    fileEncoding = "UTF-8")
  write.table(
    x = footer, file = file, append = T,
    quote = F, row.names = F, col.names = F,
    fileEncoding = "UTF-8")
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
  csv.data <- subset(
    read.csv(file, colClasses = "character"),
    subset = TRUE,
    select = c("File", "Column", "Method", "Fixed.Value", "Max.Length")
  )
  rules <- Reduce(
    f = function(t, c) {t[,c] <- toupper(t[,c]); t},
    x = c("File", "Column"),
    init = csv.data
  )
}

#write log
write.log <- function(msg, ...) {
  composed <- paste(
    as.character(Sys.time()),
    msg,
    ...
  )
  print(composed)
}


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
