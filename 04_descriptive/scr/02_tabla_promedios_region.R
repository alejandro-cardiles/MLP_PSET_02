rm(list = ls())
source("00_packages.R")
options(modelsummary_factory_latex = "kableExtra")

#================================#
# 01 import data
#================================#

# filtrando observaciones 
data = import("02_prepare_data/output/01_data_gdp_war.rds") |> 
       filter(year >= 1990 & year <= 2014)

# iso3 -> region
iso3_region <- codelist[, c("iso3c", "region")] |> distinct()

#================================#
# 02 prepare data
#================================#
# join region
data = data |>
      left_join(iso3_region, by = c("countrycode" = "iso3c"))

## mantenemos solo las observaciones que no tengan missing values 
## en war share gdp, gdp per capita 
data = data |>  
       group_by(country) |> 
       mutate(gdp_per_capita = rgdpo / pop,
             missing_1 = sum(is.na(gdp_per_capita)),
             missing_2 = sum(is.na(war_share_gdp)), 
             missing_3 = sum(is.na(rtfpna))) |> 
       filter(missing_1 == 0 & missing_2 == 0 & missing_3 == 0) |>
       group_by(country) |> 
       filter(max(hostlev ) == 0)

data = data |> 
       mutate(war_share_gdp = war_share_gdp*100)


#================================#
# 02 regressions
#================================#
data = data |> 
  mutate( region = case_when(
      region == "Latin America & Caribbean"  ~ "América Latina y el Caribe",
      region == "Sub-Saharan Africa"         ~ "África subsahariana",
      region == "Europe & Central Asia"      ~ "Europa",
      region == "Middle East & North Africa" ~ "Medio Oriente y Norte de África",
      region == "East Asia & Pacific"        ~ "Asia y el Pacífico",
      region == "South Asia"                 ~ "Asia y el Pacífico",
      region == "North America"              ~ "América del Norte",
      TRUE ~ region
    )
  )

#================================#
# 04 regional means table
#================================#

tabla_regiones = data |> 
  group_by(region) |> 
  summarise(
    `PIB per cápita`            = sum(rgdpo) / sum(pop),
    `Gasto en defensa (% PIB)`  = mean(war_share_gdp, na.rm = TRUE),
    `PTF`                       = mean(rtfpna, na.rm = TRUE),
    `Depreciación`              = mean(delta, na.rm = TRUE),
    `Inversión per cápital`     = sum(csh_i *rgdpo) / sum(pop) ,
    `Capital per cápita`        = sum(csh_c *rgdpo) / sum(pop) ,
    `Núm. países`               = n_distinct(country),
    .groups = "drop"
  )|> 
  arrange(region)

tabla_general = data |> 
  mutate(region = "General") |> 
  group_by(region) |> 
  summarise(
    `PIB per cápita`            = sum(rgdpo) / sum(pop),
    `Gasto en defensa (% PIB)`  = mean(war_share_gdp, na.rm = TRUE),
    `PTF`                       = mean(rtfpna, na.rm = TRUE),
    `Depreciación`              = mean(delta, na.rm = TRUE),
    `Inversión per cápital`     = sum(csh_i * rgdpo) / sum(pop),
    `Capital per cápita`        = sum(csh_c * rgdpo) / sum(pop),
    `Núm. países`               = n_distinct(country)
  )

tabla_regiones = bind_rows(tabla_regiones, tabla_general)


tabla = tabla_regiones |>
  mutate(across(where(is.numeric), ~round(., 2))) |>
  kbl(
    format = "latex",
    booktabs = TRUE,
    align = "lccccccc"  ) |>
  kable_styling(latex_options = c("hold_position")) |> 
  row_spec(nrow(tabla_regiones) - 1, extra_latex_after = "\\midrule")

writeLines(tabla, "04_descriptive/output/02_promedio_region.txt")

a = readLines("04_descriptive/output/02_promedio_region.txt")
a = a[-c(1:2,length(a))]

#================================#
# 05 export
#================================#
writeLines(a, "04_descriptive/output/02_promedio_region.txt")