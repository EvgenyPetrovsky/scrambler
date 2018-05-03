#' Process files
#' @description This procedure scrambles all files which meet selection criteria according to scramble rules
#'
#' @export
#' @param input.folder - input folder, word directory by default
#' @param file.names - file wildcard to select files
#' @param output.folder - folder name to store results. Folder should exist if specified
#' @param rules.file - filename with rules
#' @param seed - seed value for random generation and sampling
#' @param skip.headlines - number of lines in a file before data starts
#' @param skip.taillines - number of lines before end of a file where data ends
processFiles <- function(
  input.folder = ".",
  file.names = "*",
  output.folder = "",
  rules.file = "",
  seed = 0,
  skip.headlines = 0,
  skip.taillines = 0
) {
  # log start
  write.log(
    "Staring process with parameters",
    "-input.folder:", input.folder,
    "-file.names:", file.names,
    "-output.folder:", output.folder,
    "-rules.file:", rules.file,
    "-seed:", seed
  )

  # rules
  rules <- if (rules.file == "") {
    scrambling.rules
  } else {
    loadRules(rules.file)
  }
  # input file names
  files.in <- dir(path = input.folder, pattern = file.names, full.names = F)
  # output folder
  folder.out <- ifelse(output.folder == "", input.folder, output.folder)
  # output file names
  files.out <- paste0(
    files.in,
    ifelse(folder.out == input.folder, ".scrambled", "")
  )
  # walk through files and process 1 by 1
  for (idx in 1:length(files.in)) {
    write.log("processing file", files.in[idx])
    fin <- paste0(input.folder, files.in[idx])
    fout <- paste0(folder.out, files.out[idx])
    processFile(fin, fout, seed, rules, skip.headlines, skip.taillines)
  }

  write.log("Process complete")

}

processFile <- function(file.in, file.out, seed, rules, skip.headlines, skip.taillines) {
  file.lines <- countFileLines(file.in)
  data.lines <- file.lines - skip.headlines - skip.taillines - 1
  write.log("loading original file", file.in)
  # always load header because we take table column names as they are
  header <- loadLines(file.in, 1, skip.headlines + 1)
  data   <- loadData(file.in, skip.headlines, data.lines)
  # load footer only if file has it
  footer <- if (skip.taillines > 0) {
    loadLines(file.in, file.lines - skip.taillines + 1, skip.taillines)
  } else {
    NA
  }

  filteredRules <- subset(
    rules,
    sapply(
      X = File, FUN = grepl, x = basename(file.in),
      ignore.case = T, USE.NAMES = F
    )
  )

  if (nrow(filteredRules) > 0) {
    write.log("scrambling data of", basename(file.in))
    scdata <- scrambleDataFrame(data, seed, filteredRules)
  } else {
    write.log("no rules to apply for file", basename(file.in))
    scdata <- data
  }

  write.log("saving result file", file.out)
  saveFile(header, scdata, footer, file.out)
}

