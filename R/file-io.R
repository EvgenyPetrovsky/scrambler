#' load file data and return it as vector of character strings

loadFile <- function(file, row.type) {
  con <- file(file, "r")
  pattern <- paste0("^", row.type, ";.*")
  lines <- c()
  while(TRUE) {
    line = readLines(con, 1)
    if(length(line) == 0) break
    else if(grepl(pattern, line)) lines <- c(lines, line)
  }
  close(con)
  lines
}

#' load tabular data from file and return it as data.frame
loadData <- function(file) {
  nm <- colnames(read.csv(
    text = paste0(loadFile(file = file, row.type = 1), collapse = "\n"),
    header = T, sep = ";"
  ))
  df <- read.csv(
    text = paste0(loadFile(file = file, row.type = 2), collapse = "\n"),
    header = F, sep = ";", quote = "\"", dec = ",",
    na.strings = "", stringsAsFactors = F
  )
  colnames(df) <- nm

  return(df)
}

loadHead <- function(file) {
  loadFile(file = file, row.type = 0)
}

loadCols <- function(file) {
  loadFile(file = file, row.type = 1)
}

loadTail <- function(file) {
  loadFile(file = file, row.type = 9)
}

getTableId <- function() {
  NULL
}

getTableName <- function(header) {
  unlist(strsplit(header, split = ";"))[4]
}


#' Get CSA Table name from file
#' @description Function takes filename and returns corresponding table name.
#'   Table name is stored in row_type = 0 in position 4
#'
#' @return Character value that represents OFSAA CSA table name \code{STG_...}
loadTableName <- function(file) {
  getTableName(loadHead(file))
}

#' Write data into file
#' function takes parts of file and writes it in OFSAA compatible format
saveFile <- function(header, columns, data, footer, file) {
  write.table(
    x = header, file = file, append = F,
    quote = F, row.names = F, col.names = F,
    fileEncoding = "UTF-8")
  write.table(
    x = columns, file = file, append = T,
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
#' columns of \code{scramble.rules} data example
#'
#' @return dataframe in the format of \code{scramble.rules} data example
#'
#' @export
#' @param file - path to file with rules
loadRules <- function(file) {
  csv.data <- subset(
    read.csv(file, colClasses = "character"),
    subset = TRUE,
    select = c("Table", "Column", "Method", "Fixed.Value", "Max.Length")
  )
  rules <- Reduce(
    f = function(t, c) {t[,c] <- toupper(t[,c]); t},
    x = c("Table", "Column"),
    init = csv.data
  )
}
