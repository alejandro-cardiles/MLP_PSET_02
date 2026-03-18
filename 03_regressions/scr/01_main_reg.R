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

data = data  |> 
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

m1 = feols((gdp_per_capita/l(gdp_per_capita)-1)*100 ~ war_share_gdp | country + year, data = data, panel.id = ~ country + year)
m1

m3 = feols((technologie/l(technologie)-1)*100  ~ war_share_gdp | country + year, data = data, panel.id = ~ country + year)
m3 

m4 = feols(delta ~ war_share_gdp  | country + year, data = data |> filter(year != min(year)))
m4 

#================================#
# 03 table
#================================#

models <- list(
  "Crec. PIB(PC)" = m1,
  "Crec. TFP"     = m3,
  "Depreciación"               = m4
)

ef_rows <- data.frame(
  term = c("Efectos fijos: país", "Efectos fijos: año"),
  "Crec. PIB pc"           = c("Sí", "Sí"),
  "Crec. TFP"              = c("Sí", "Sí"),
  "Depreciación"     = c("Sí", "Sí")
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
    "{\\\\scriptsize Crecimiento se define como: $\\\\left(\\\\frac{Y_t}{Y_{t-1}} - 1\\\\right) \\\\times 100$.}",
    "{\\\\scriptsize Primera observación se remueve debido a transformación en tasa de crecimiento.}",
    "{\\\\scriptsize Abreviaturas: PC = per cápita; Crec. = crecimiento.}" 
  ),
  fmt = fmt_decimal(decimal.mark = ".", big.mark = ","),
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
