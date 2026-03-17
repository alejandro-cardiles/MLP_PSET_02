if(require("pacman") == F){install.packages("pacman")} else require("pacman")
pacman::p_load(tidyverse)


wd = dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(dir = wd)

files = list.files(pattern = ".R$", full.names = T, recursive = T) 
files = files[str_detect(string = files, pattern = "scr")]
        

walk(.x = files, .f = function(x){
  source(x)
})


