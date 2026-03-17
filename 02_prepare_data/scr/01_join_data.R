rm(list = ls())
source("00_packages.R")

#================================#
# 01 import data
#================================#
pwt = import("01_data/output/01_pwt.rds") |> mutate(country = tolower(country))
sipri = import("01_data/output/02_SIPRI.rds") |> mutate(country = tolower(country))
midb = import("01_data/output/03_midb.rds")

#===============================#
# 02 prepare data
#===============================#

# create id to check which countrys did not join
sipri = sipri |> group_by(country) |> mutate(c = cur_group_id())

sipri = sipri |>
  mutate(country = case_when(
    country == "cape verde" ~ "cabo verde",
    country == "congo, dr" ~ "d.r. of the congo",
    country == "congo, republic" ~ "congo",
    country == "cote d'ivoire" ~ "côte d'ivoire",
    country == "gambia, the" ~ "gambia",
    country == "united states of america" ~ "united states",
    country == "bolivia" ~ "bolivia (plurinational state of)",
    country == "venezuela" ~ "venezuela (bolivarian republic of)",
    country == "brunei" ~ "brunei darussalam",
    country == "laos" ~ "lao people's dr",
    country == "korea, south" ~ "republic of korea",
    country == "moldova" ~ "republic of moldova",
    country == "russia" ~ "russian federation",
    country == "syria" ~ "syrian arab republic",
    country == "tanzania" ~ "u.r. of tanzania: mainland",
    country == "iran" ~ "iran (islamic republic of)",
    TRUE ~ country
  ))

# join data
output = left_join(x = pwt, y = sipri)

# countrys that did not join (none of them are relevant)
sipri$country[!sipri$c %in% output$c] |> unique()

output = output |> mutate(country = str_to_title(country)) |> select(-c)

#===============================#
# 02.1 prepare MID panel
#===============================#

midb = midb |>
  filter(!is.na(styear) & !is.na(endyear)) |>
  rowwise() |>
  mutate(year = list(seq(styear, endyear))) |>
  unnest(year) |>
  ungroup() |>
  select(stabb, year, hostlev)

# collapse conflicts to country-year using max hostility
midb = midb |>
  rename(countrycode = stabb) |>
  group_by(countrycode, year) |>
  summarise(hostlev = max(hostlev, na.rm = TRUE), .groups = "drop")

#===============================#
# 02.2 merge MID with macro data
#===============================#

output = output |>
  left_join(midb, by = c("countrycode", "year"))

# replace missing conflicts with zero
output = output |> mutate(hostlev = replace_na(hostlev, 0))

#===============================#
# 03 export data
#===============================#
rio::export(output, "02_prepare_data/output/01_data_gdp_war.rds")