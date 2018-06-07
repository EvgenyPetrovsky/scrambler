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
