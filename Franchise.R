install.packages("readr")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("rlang")
install.packages("tidyr")

library(dplyr)
library(readr)
library(ggplot2)
library(rlang)
library(tidyr)

data <- read.csv("ABC_Licensee_List_20260205.csv")

head(data)

summary(data)
#1811 restaurants by 2019

unique(data$LICENSE)


#getting type of license
data <- data %>%
    mutate(prefix = substr(LICENSE, 1, 2)) 
    #substr extract part of text and then 1 and 2 belongs to characters

sort(unique(data$prefix))

#group restaurantes by categories
data <- data %>%
    mutate(
        category = case_when(
            prefix %in% c("RE", "RL", "RB") ~ "Restaurant",
            prefix %in% c("CL", "TV") ~ "Bar / Club",
            prefix %in% c("PS", "AL") ~ "Liquor Store / Manufacturer",
            prefix == "BE" ~ "Banquet / Event",
            TRUE ~ "Other"
        ),
        sells_liquor = case_when(
            prefix %in% c("RE", "RL", "CL", "AL", "PS", "TV") ~ TRUE,
            TRUE ~ FALSE
        )
    )

data$category <- factor(
    data$category,
    levels = c("Restaurant", "Bar / Club", "Liquor Store / Manufacturer", "Banquet / Event", "Other")
)

data %>%
    group_by(category, sells_liquor) %>%
    summarise(count = n(), .groups = "drop") %>%
    arrange(category)

# Separar latitud y longitud de Location.1
data <- data %>%
  separate(Location.1, into = c("Address2", "Coordinates"), sep = " \\(", remove = FALSE, fill = "right") %>%
  mutate(Coordinates = gsub("\\)", "", Coordinates)) %>%
  separate(Coordinates, into = c("Latitude", "Longitude"), sep = ", ", convert = TRUE)

# Seleccionar columnas importantes para Tableau
data_for_tableau <- data %>%
  select(LICENSE, DBA, LOCATION.ADDRESS, COUNTY, PHONE, category, sells_liquor, Latitude, Longitude)

# Guardar CSV limpio para Tableau
write_csv(data_for_tableau, "ABC_Licensee_List_ReadyForTableau.csv")
