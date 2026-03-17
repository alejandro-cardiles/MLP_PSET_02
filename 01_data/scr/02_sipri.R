rm(list = ls())
source("00_packages.R")

#================================#
# 01 import data
#================================#
import_data = function(page, name){

  data = import("01_data/input/SIPRI-Milex-data-1949-2025.xlsx", sheet = page)
  
  data = import("01_data/input/SIPRI-Milex-data-1949-2025.xlsx", sheet = page, skip = which(str_to_lower(data[,1]) == "country")) 

  names(data) = str_replace(names(data), pattern = "\\.0", replacement = "")

  data = data |> 
        filter(!is.na(`2020`))

  data = data |> 
        select(Country, matches("\\d")) 

  data = data |> 
        pivot_longer(cols = 2:ncol(data), names_to = "year", values_to = name)

  data = data |> 
        mutate(!!name := as.numeric(.data[[name]]) , 
               year = as.numeric(year) ) |> 
        clean_names()
}

# unificar datos
data = list(import_data(page = 2, "war_gdp_constant_2024"), 
     import_data(page = 3, "war_share_gdp"),
     import_data(page = 4, "war_gdp_per_capita"),
     import_data(page = 5, "war_share_gov_spending")) |> 
  reduce(full_join, by = c("country", "year"))


# filtrar por años en na
data = data |> 
       filter(!is.na(year))

#================================#
# 02_export_data
#================================#
export(data, "01_data/output/02_SIPRI.rds")