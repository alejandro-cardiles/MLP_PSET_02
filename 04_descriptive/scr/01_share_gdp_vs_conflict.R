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

# cantidad de conflictos en mi region
data = data |> 
       mutate(hostlev = ifelse(hostlev==0, yes = 0, no = 1)) |> 
       group_by(region, year) |> 
       mutate(region_hostlev = sum(hostlev, na.rm =T)/n())

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
       mutate(war_share_gdp =  ifelse(war_share_gdp>  quantile(war_share_gdp, probs = 0.99), yes = NA, no = war_share_gdp)) |> 
       group_by(countrycode) |> 
       fill(war_share_gdp, .direction ="updown") 



#================================#
# 03 plot data
#================================#

plot = data |>
  filter(war_share_gdp<0.15) |> 
  ggplot(aes(x = region_hostlev, y = war_share_gdp)) +
  geom_point(position = position_jitter(width = 0.002, height = 0),
             alpha = 0.5,
             size = 2,
             color = "gray30") +
  geom_smooth(method = "lm",
              se = TRUE,
              color = "#2C7FB8",
              linewidth = 1) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1), breaks = seq(0, 0.15, by = 0.05)) +
  labs(x = "Proporción de países en la región con conflicto",
       y = "Gasto en defensa (% del PIB)",
       caption = "**Nota:** Se eliminaron 6 observaciones con gasto militar superior al 15% del PIB.  Eje x presenta un leve 'jitter' horizontal para evitar superposición.<br><br>
                  **Fuentes:** PWT, MIDB, SIPRI. **Creación propia.**") +
  theme_bw(base_size = 13) +
  theme(plot.caption = element_markdown(size = 10, hjust = 0))

plot

#================================#
# 04 export data
#================================#
ggsave(plot = plot, "04_descriptive/output/01_share_gdp_vs_conflict.png", width =  347, height = 199, units  = "mm")