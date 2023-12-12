rm(list = ls())

library(readr)
library(stringr)
library(purrr)
library(dplyr)

# This script downloads, unzips, and renames each of the annual auxillary files.
# Then, it combines them into integrated files for each analytical level.

# function to download, unzip, and rename files
download_auxillary_file <- function(year){
  # the path to save the ZIP file
  year.path <- paste0("source-data/FARS", year, "NationalAuxiliaryCSV")
  
  # the URL of the ZIP file
  # handle typo in 1996 file name
  aux.url <- ifelse(year == 1996,
                    yes = paste0("https://static.nhtsa.gov/nhtsa/downloads/FARS/",
                                 year, "/National/FARS", year, "NationalAuxiliaryCVS.zip"),
                    no = paste0("https://static.nhtsa.gov/nhtsa/downloads/FARS/",
                                year, "/National/FARS", year, "NationalAuxiliaryCSV.zip"))
  
  # download the file
  download.file(url = aux.url,
                destfile = paste0(year.path, ".zip"))
  
  # unzip the file
  unzip(paste0(year.path, ".zip"), exdir = year.path)
  
  # move the files OUT of the unzip subdirectory and INTO the main source-data subdirectory
  #   add the year of the file to the name
  file.copy(from = list.files(year.path, full.names = T, recursive = T),
            to = paste0("source-data/", paste0(str_remove(word(list.files(year.path, recursive = T), -1, sep = "/"),
                                                   ".CSV"),
                                        "_", year, ".CSV")))
  
  # delete the ZIP file and the now-empty zip sub-directory
  unlink(c(year.path, paste0(year.path, ".zip")), recursive = T)
}

# apply the function to each year available
map(1982:2021, download_auxillary_file, .progress = TRUE)

# combine the person (PER), vehicle (VEH), and accident (ACC) level files
per.aux <- map_df(list.files("source-data", pattern = "PER*", full.names = T), read_csv)
veh.aux <- map_df(list.files("source-data", pattern = "VEH*", full.names = T), read_csv)
acc.aux <- map_df(list.files("source-data", pattern = "ACC*", full.names = T), read_csv)

# save the files
write_csv(per.aux, "data/PER_AUX_1982-2021.csv.gz")
write_csv(veh.aux, "data/VEH_AUX_1982-2021.csv.gz")
write_csv(acc.aux, "data/ACC_AUX_1982-2021.csv.gz")
