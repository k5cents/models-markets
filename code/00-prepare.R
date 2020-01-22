### kiernan nicholls
### american university
### spring, 2020
### markets and models
### prepare software

# install packages ---------------------------------------------------------------------------

# install.packages("remotes")
# remotes::install_cran(pkgs = c(
#   "lubridate", # managing dates
#   "magrittr", # pipe utilities
#   "ggplot2", # visualization
#   "scales" # string formatting
#   "readr", # reading flat files
#   "dplyr", # data manipulation
#   "tidyr", # data reshaping
#   "here", # relative storage
#   "fs", # storage managment
# ))
# remotes::install_github(repo = c(
#   "hrbrmstr/wayback" # archived data
# ))

# attach packages ----------------------------------------------------------------------------

library(lubridate)
library(magrittr)
library(wayback)
library(ggplot2)
library(scale)
library(readr)
library(dplyr)
library(tidyr)
library(here)
library(fs)

# define functions ---------------------------------------------------------------------------

write_memento <- function(url, date, dir) {
  path <- here::here("data", "raw", dir, basename(url))
  if (!fs::file_exists(path)) {
    data <- wayback::read_memento(url, date, as = "text")
    fs::dir_create(dirname(path))
    readr::write_lines(data, path)
  }
}
