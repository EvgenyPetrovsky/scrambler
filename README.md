# scrambler

[![Build
Status](https://travis-ci.org/EvgenyPetrovsky/scrambler.svg?branch=master)](https://travis-ci.org/EvgenyPetrovsky/scrambler)

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
