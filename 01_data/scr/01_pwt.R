rm(list = ls())
source("00_packages.R")

#================================#
# 01 import data
#================================#
data = import("01_data/input/pwt110.xlsx", sheet = 3)

#================================#
# 02 export variables
#================================#
export(data, "01_data/output/01_pwt.rds")