rm(list = ls())
source("00_packages.R")
options(modelsummary_factory_latex = "kableExtra")

#================================#
# 01 import data
#================================#

# filtrando observaciones 
data = import("02_prepare_data/output/01_data_gdp_war.rds") |> 
       filter(year >= 1990 & year <= 2014)


#================================#
# 02 prepare data
#================================#

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
       mutate(war_share_gdp =  ifelse(war_share_gdp>  (mean(war_share_gdp) +(2*sd(war_share_gdp))), yes = NA, no = war_share_gdp)) |> 
       group_by(countrycode) |> 
       fill(war_share_gdp, .direction ="updown") |> 
       mutate(war_share_gdp = war_share_gdp*100)


#================================#
# 02 regressions
#================================#

# creating variables 
data = data |> 
  mutate(
    technologie = rtfpna,
    delta = delta*100
  ) 

m1 = feols(log(gdp_per_capita) ~ war_share_gdp | country + year, data = data)
m1

m3 = feols(log(technologie) ~ war_share_gdp | country + year, data = data)
m3 

m4 = feols(delta ~ war_share_gdp  | country + year, data = data)
m4 

#================================#
# 03 table
#================================#

models <- list(
  "Log. PIB(PC)" = m1,
  "Log. TFP"     = m3,
  "Depreciación"               = m4
)

ef_rows <- data.frame(
  term = c("Efectos fijos: país", "Efectos fijos: año"),
  "Log. PIB pc"           = c("Sí", "Sí"),
  "Log. TFP"              = c("Sí", "Sí"),
  "Depreciación"           = c("Sí", "Sí")
)

# tabla
modelsummary(
  models,
  coef_map = c("war_share_gdp" = "Gasto en defensa (\\% del PIB)"),
  stars = TRUE,
  gof_map = c("nobs", "r.squared.within"),
  add_rows = ef_rows,
  escape = FALSE,
  notes = c(
    "{\\\\scriptsize Errores estándar robustos entre paréntesis.}",
    "{\\\\scriptsize Abreviaturas: PC = per cápita}"
  ),
 output = "03_regressions/output/01_tabla_reg_principal.tex"
)

# small changes

## quitar begin and end table
a = readLines("03_regressions/output/01_tabla_reg_principal.tex")
a = a[-c(1:2,length(a))]


## Replace stars 
a[str_detect(string = a, "\\*\\* p")] = paste0("\\multicolumn{",length(models)+1,"}{l}{\\rule{0pt}{1em}{\\scriptsize $^{*}$ $p<0.05$, $^{**}$ $p<0.01$, $^{***}$ $p<0.001$}}\\\\")
a[str_detect(string = a, "multicolumn")]  = paste0(a[str_detect(string = a, "multicolumn")],"[-1.1em]")

#================================#
# 04 export
#================================#
writeLines(a, "03_regressions/output/01_tabla_reg_principal.tex")
