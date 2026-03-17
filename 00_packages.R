if(require("pacman") == F){install.packages("pacman")} else require("pacman")

p_load(countrycode,
       #clean data
       rio, 
       sf, 
       tidyverse, 
       janitor,
       
       # reg
       fixest,
       modelsummary,
       
       # plot
       scales,
       ggtext)