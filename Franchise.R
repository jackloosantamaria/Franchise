#installing packages
install.packages("readr")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("rlang")
install.packages("tidyr")
install.packages("RMariaDB")
install.packages("DBI")

#libraries
library(dplyr)
library(readr)
library(ggplot2)
library(rlang)
library(tidyr)
library(DBI)
library(RMariaDB)

#reading file
data <- read.csv("ABC_Licensee_List_20260205.csv")

#viewing data columns
head(data)

#getting summary of data and knowing how many restaurants are in Utah 2019
summary(data)
#1811 restaurants by 2019

#viewing data of LICENSE COLUMN
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

# Separating latitude and longitude of location.1
data <- data %>%
  separate(Location.1, into = c("Address2", "Coordinates"), sep = " \\(", remove = FALSE, fill = "right") %>%
  mutate(Coordinates = gsub("\\)", "", Coordinates)) %>%
  separate(Coordinates, into = c("Latitude", "Longitude"), sep = ", ", convert = TRUE)

# Selecting important columns for Tableau
data_for_tableau <- data %>%
  select(LICENSE, DBA, LOCATION.ADDRESS, COUNTY, PHONE, category, sells_liquor, Latitude, Longitude)

# Save clean CSV ready to use in Tableau
write_csv(data_for_tableau, "ABC_Licensee_List_ReadyForTableau.csv")

#Preparation for SQL

#Connect DB to MariaDB
con <- dbConnect(
    RMariaDB::MariaDB(),
    user = "root",
    password = "casa2081992",
    host = "127.0.0.1",
    port = 3306,
    dbname = 
)

#Creating SQL Tables
dbExecute(con, "
CREATE TABLE IF NOT EXISTS licenses(
LICENSE VARCHAR(20) PRIMARY KEY, 
DBA VARCHAR(100), 
COUNTY VARCHAR(50), 
PHONE VARCHAR(50), 
category VARCHAR(50), 
sells_liquor BOOLEAN);
"
)

#location table
dbExecute(con, "
CREATE TABLE IF NOT EXISTS locations(
LICENSE VARCHAR(20), 
`LOCATION.ADDRESS` VARCHAR(255), 
Latitude  VARCHAR(100), 
Longitude VARCHAR(100), 
FOREIGN KEY (LICENSE) REFERENCES licenses(LICENSE)
);
"
)

#Adding data from R
#Insert in licenses

dbWriteTable(con, "licenses", data_for_tableau %>%
                select(LICENSE, DBA, COUNTY, PHONE, category, sells_liquor),
            append = TRUE, row.names = FALSE)

#Insert in locations
dbWriteTable(con, "locations", data_for_tableau %>%
                select(LICENSE, LOCATION.ADDRESS, Latitude, Longitude),
            append = TRUE, row.names = FALSE)

#SQL Queries
#Amount of restaurants that sale alcohol in every county
query1 <- "
SELECT l.COUNTY, COUNT(*) AS num_licensias
FROM licenses l
JOIN locations loc ON l.LICENSE = loc.LICENSE
WHERE l.sells_liquor = 1 AND l.category = 'Restaurant'
GROUP BY l.COUNTY
ORDER BY num_licensias DESC;
"

result1 <- dbGetQuery(con, query1)
print(result1)

#Average Latitude and Longitude for each category of establishment
query2 <- "
SELECT l.category, 
       AVG(CAST(loc.Latitude AS DOUBLE)) AS avg_lat, 
       AVG(CAST(loc.Longitude AS DOUBLE)) AS avg_long
FROM licenses l
JOIN locations loc ON l.LICENSE = loc.LICENSE
GROUP BY l.category;
"

result2 <- dbGetQuery(con, query2)
print(result2)

#update
dbExecute(con, "
UPDATE licenses
SET PHONE = '999-999-9999'
WHERE LICENSE = 'AL00002'
"
)

#Check update
check_update <- dbGetQuery(con, "
SELECT LICENSE, DBA, PHONE
FROM licenses
WHERE LICENSE = 'AL00002'
"
)
print(check_update)

#delete
dbExecute(con, "
DELETE FROM licenses
WHERE LICENSE = 'AL00002'
"
)

