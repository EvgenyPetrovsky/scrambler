# scrambler

[![Build
Status](https://travis-ci.org/EvgenyPetrovsky/scrambler.svg?branch=master)](https://travis-ci.org/EvgenyPetrovsky/scrambler) [![codecov](https://codecov.io/gh/EvgenyPetrovsky/scrambler/branch/master/graphs/badge.svg)](https://codecov.io/gh/EvgenyPetrovsky/scrambler)

R Package that scrambles sensitive data.

## Installation

Since it is R package you need to have R installed. Please refer to [CRAN](https://cran.r-project.org/) __Download and Install R__ section for additional details and instructions on how to do it.

If you are windows user then please install dependendent packages manually

```R
install.packages("digest")
```

Install `devtools` if you don't have it

```R
install.packages("devtools")
```

And finally install scrambler package from github

```R
devtools::install_github("EvgenyPetrovsky/scrambler")
```

## Use

This is very short information about options to use package. Please refer to package documentation for details. 

Package provides access to scrambling on several levels.

You can process files using `processFiles` function. Function picks files from `input.folder`, and stores them in `output.folder`. Example of call 

```R
scrambler::processFiles(
  input.folder = "./data/in/", file.names = "F_A12054_*", output.folder = "./data/out/", 
  rules.file = "./data/rules/A12054-rules.csv", seed = 1000, skip.headlines = 1, skip.taillines = 1
)
```
You can scramble dataframe by using `scrambleDataFrame` by specifying input data frame, rules data frame, seed value

```R
scrambler::scrambleDataFrame(data = mydata, seed = 123, scrambling.rules = myrules)
```

You can scramble vector of values by using `scrambleValue` function and specifying input values, scrambling method, seed

```R
scrambler::scrambleValue(value = myvector, method = "hash", seed = 112)
```

## Rules

Scrambiling rules are defined and maintained locally. They define how scrambling applies to file / column and what algorithm has to be used.

Depending on use (see section above) rules can be provided as a data.frame (for `scrambleDataFrame`) or path to .csv file (for `processFiles`) which contains them.

Rules structure is represented in table below:

| Attribute      | Desctiption                                    |
|----------------|------------------------------------------------|
| File | Regular expression for file name to process by rule. This value is ignored when scrambling applied to data.frame directly (via call of `scrambleDataFrame` function) | 
| Column | Exact column name to be processed by rule |
| Method | Scrambling method to be applied (see Methods table below) |
| Method.Param | Method parameter (see Methods table below) |
| Max.Length | maximum number of characters, in case when light of result should be of limited length |

You can always refer to demo-rules in [`scrambler::scrambling.rules`](/data-raw/scrambling-rules.csv) for some examples.

## Methods

List of supported methods and their parameters

| Method      | Parameter   | Desctiption                                    |
|-------------|-------------|------------------------------------------------|
| shuffle     |             | Shuffle values in column according to `seed` (parameter of function call) |
| hash        | algo        | Digest value according to `algo` parameter of digest function of [`digest`](https://cran.r-project.org/package=digest) package. Keep empty values empty. |
| random.hash | algo        | _Not yet implemented_ |
| random.num  |             | Generate random numbers using mean value and standard deviation of numbers provided. Keep empty and zero values. |
| rnorm.num   |             | Generate random numbers with maen = 0 and standard deviation of given values; add generated values to given values. Keep empty and zero values. |
| fixed.value | value       | Use fixed value given as a parameter |

## Examples

In this section you will find working examples. You need to run R session, copy paste code snippets and execute them. 

### Vectors

```R
# generate input values
input.vector <- c("John", "Mike", "Alice")
# scramble values
output.vector <- scrambler::scrambleValue(
  value = input.vector, method = "hash", seed = 112
)
# show results
output.vector
```

### Data frames

```R
# generate some input data
input.data <- data.frame(
  Name = c("John", "Mike", "Alice"), 
  Balance = c(10, 12, 100), 
  Country = c("US", "GB", "SG")
)
# define rules for Name and Balance
rules <- data.frame(
  File = c(NA, NA), 
  Column = c("Name", "Balance"), 
  Method = c("hash", "random.num"), 
  Method.Param = c("md5", NA), 
  Max.Length = c(NA, NA), 
  stringsAsFactors = F
)
# scramble data
output.data <- scrambler::scrambleDataFrame(
  data = input.data, seed = 100, scrambling.rules = rules
)
# show results
output.data
```

### Files

Please be aware that script below generates folders and files, writes and reads data. You have to check that working directory (you can check it with `getwd()` function) will not be negatively affected.

```R
# create folder structure
folders <- c("./demo", "./demo/in", "./demo/out")
for (folder in folders) if (!dir.exists(folder)) dir.create(folder)
# generate some input data
input.data <- data.frame(
  Name = c("John", "Mike", "Alice"), 
  Balance = c(10, 12, 100), 
  Country = c("US", "GB", "SG")
)
write.table(
  x = input.data, file = "./demo/in/ACCOUNTS_20180430.dat", 
  sep = ";", dec = ",", append = F, row.names = F
)
# define rules for Name and Balance
rules <- data.frame(
  File = c("ACCOUNTS_\\d{8}\\.dat", "ACCOUNTS_\\d{8}\\.dat"), 
  Column = c("Name", "Balance"), 
  Method = c("hash", "random.num"), 
  Method.Param = c("md5", NA), 
  Max.Length = c(NA, NA), 
  stringsAsFactors = F
)
write.csv(
  x = rules, file = "./demo/rules.csv", row.names = F
)
# scramble data
scrambler::processFiles(
  input.folder = "./demo/in/", file.names = "ACCOUNTS_.*", output.folder = "./demo/out/",
  rules.file = "./demo/rules.csv", seed = 100
)
```

For huge files there is an option to process them in portions (chunks), size can be specified via `chunksize` parameter. below is example of previous call but with parameter specified

```R
scrambler::processFiles(
  input.folder = "./demo/in/", file.names = "ACCOUNTS_.*", output.folder = "./demo/out/",
  rules.file = "./demo/rules.csv", seed = 100, chunksize = 100000
)
```
