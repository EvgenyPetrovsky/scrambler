#' Process files
#' @description This procedure scrambles all files which meet selection criteria according to scramble rules
#'
#' @export
#' @param input.folder - input folder, word directory by default
#' @param file.names - file wildcard to select files
#' @param output.folder -
processFiles <- function(input.folder = ".", file.names = "*", output.folder = "", rules.file = "", seed = 0) {
  # rules
  rules <- if (rules.file == "") {
    scramble.rules
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
    fin <- paste0(input.folder, files.in[idx])
    fout <- paste0(folder.out, files.out[idx])
    processFile(fin, fout, seed, rules)
  }

}

processFile <- function(file.in, file.out, seed, rules) {
  header <- loadHead(file.in)
  cols   <- loadCols(file.in)
  data   <- loadData(file.in)
  footer <- loadTail(file.in)

  scdata <- scrambleDataFrame(
    data, getTableName(header),
    seed, rules)

  saveFile(header, cols, scdata, footer, file.out)
}

