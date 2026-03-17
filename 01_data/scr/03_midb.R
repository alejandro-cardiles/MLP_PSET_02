rm(list = ls())
source("00_packages.R")

#================================#
# 01 import data
#================================#
midb = import("01_data/input/MIDB 5.0.csv") |> select(stabb, styear, endyear, hostlev)

#================================#
# 02 export variables
#================================#
export(midb, "01_data/output/03_midb.rds")