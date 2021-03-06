#' Process files
#' @description This procedure scrambles all files which meet selection criteria
#'   according to scramble rules
#'
#' @export
#' @param input.folder input folder, word directory by default
#' @param file.names file wildcard to select files
#' @param output.folder folder name to store results. Folder should exist if
#'   specified
#' @param rules.file filename with rules
#' @param seed seed value for random generation and sampling
#' @param skip.headlines number of lines in a file before data starts
#' @param skip.taillines number of lines before end of a file where data ends
#' @param data.header flag that data starts with header
#' @param chunksize specifies if file should be read and processed by portions,
#'   portion denotes number of lines
processFiles <- function(
  input.folder = ".",
  file.names = "*",
  output.folder = "",
  rules.file = "",
  seed = 0,
  skip.headlines = 0,
  skip.taillines = 0,
  data.header = T,
  chunksize = 0
) {
  # log start
  write.log(
    "Staring process with parameters",
    "-input.folder:", input.folder,
    "-file.names:", file.names,
    "-output.folder:", output.folder,
    "-rules.file:", rules.file,
    "-seed:", seed,
    "-skip.headlines:", skip.headlines,
    "-skip.taillines:", skip.taillines,
    "-data.header:", data.header,
    "-chunksize:", chunksize
  )

  # rules
  rules <- if (rules.file == "") {
    scrambler::scrambling.rules
  } else {
    loadRules(rules.file)
  }
  # input file names
  files.in <- dir(path = input.folder, pattern = file.names, full.names = F)
  # output folder
  folder.out <- ifelse(output.folder == "", input.folder, output.folder)
  # walk through files and process 1 by 1
  if (length(files.in) == 0) {
    write.log("nothing to process")
  } else {
    for (file.in in files.in) {
      write.log("processing file", file.in)
      fin  <- paste0(input.folder, file.in)
      fout <- paste0(
        folder.out,
        file.in,
        ifelse(folder.out == input.folder, ".scrambled", "")
      )
      processFile(fin, fout, seed, rules, skip.headlines, skip.taillines, data.header, chunksize)
    }
  }

  write.log("Process complete")

}

processFile <- function(
  file.in, file.out,
  seed, rules,
  skip.headlines, skip.taillines, data.header = T, chunksize = 0
) {
  write.log("processing original file", file.in)
  # count lines in file
  file.lines <- countFileLines(file.in)
  data.lines <- file.lines - skip.headlines - as.integer(data.header) - skip.taillines
  # take rules related to file
  filteredRules <- if (nrow(rules) == 0) rules else {
    subset(
      rules,
      sapply(
        X = File, FUN = grepl, x = basename(file.in),
        ignore.case = T, USE.NAMES = F
      )
    )
  }
  # ----------------------------------------------------------------------------
  # process HEADER
  # always load header because we take table column names as they are
  header <- loadLines(
    file = file.in,
    start.line = 1,
    skip.headlines + as.integer(data.header)
  )
  createFile(file = file.out)
  saveLines(lines = header, file = file.out, append = T)
  # ----------------------------------------------------------------------------
  # process CONTENT
  # function to process chunks
  processData <- function(data) {
    scdata <- if (nrow(filteredRules) > 0) {
      write.log("scrambling data of", basename(file.in))
      scrambleDataFrame(data, seed, filteredRules)
    } else {
      data
    }
    scdata
  }

  if (data.lines == 0) {
    NULL
  } else if (chunksize == 0) {
    data <- loadData(
      file = file.in,
      skip.lines = skip.headlines,
      max.lines = data.lines,
      header = data.header)
    scdata <- processData(data)
    saveData(data = scdata, file = file.out)
  } else {
    chunks <- (data.lines %/% chunksize) + if (data.lines %% chunksize > 0) 1 else 0
    for (chunk in 1:chunks) {
      data <- loadData(
        file = file.in,
        skip.lines = skip.headlines,
        max.lines = data.lines,
        header = data.header,
        chunk.no = chunk,
        chunk.size = chunksize)
      scdata <- processData(data)
      saveData(data = scdata, file = file.out)
    }
  }
  # ----------------------------------------------------------------------------
  # process FOOTER
  # load footer only if file has it
  if (skip.taillines > 0) {
    footer <- loadLines(file.in, file.lines - skip.taillines + 1, skip.taillines)
    saveLines(lines = footer, file = file.out, append = T)
  }
}

# in development
main <- function() {
  args <- commandArgs(trailingOnly = T)

  folder.in  <- args[1]
  file.names <- args[2]
  folder.out <- args[3]
  rules      <- args[4]
  seed       <- args[5]
  skip.headlines <- 0
  skip.taillines <- 0
}
