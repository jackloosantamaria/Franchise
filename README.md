# Overview

{This software demonstrates how to integrate **R with a SQL Relational Database** to manage and analyze structured data. The project reads a dataset of license holders (restaurants, bars, liquor stores, etc.), processes it in R for cleaning and categorization, and stores it in a relational database for querying and analysis.}

{The purpose of this software is to provide a practical example of relational database design, SQL queries, and integration with R for data analysis. It allows the user to insert, retrieve, update, and delete records, as well as perform aggregation queries to summarize the data.}

[Software Demo Video](http://youtube.link.goes.here)

# Relational Database

{This project uses **MariaDB**, which is fully compatible with MySQL. The database consists of two tables:  
}

{1. **licenses** – stores information about license holders:  
   - `LICENSE` (VARCHAR(20), PRIMARY KEY)  
   - `DBA` (VARCHAR(100))  
   - `COUNTY` (VARCHAR(50))  
   - `PHONE` (VARCHAR(50))  
   - `category` (VARCHAR(50))  
   - `sells_liquor` (BOOLEAN)  

2. **locations** – stores location information and links to `licenses`:  
   - `LICENSE` (VARCHAR(20), FOREIGN KEY referencing licenses.LICENSE)  
   - `LOCATION.ADDRESS` (VARCHAR(255))  
   - `Latitude` (VARCHAR(100))  
   - `Longitude` (VARCHAR(100)) }

{The software performs JOIN queries between these tables and executes aggregation queries, such as counting restaurants that sell alcohol per county or calculating the average latitude/longitude for each category.}

# Development Environment

{- **Programming Language:** R  
- **Libraries:** `dplyr`, `readr`, `ggplot2`, `tidyr`, `rlang`, `DBI`, `RMariaDB`  
- **Database:** MariaDB (MySQL-compatible)  
- **IDE:** RStudio}

# Useful Websites

{Make a list of websites that you found helpful in this project}

- [RStudio Documentation](https://resources.rstudio.com/resources/webinars/data-wrangling-with-r-and-rstudio/)
- [MariaDB Documentation](https://mariadb.com/kb/en/)
- [R & MariaDB Integration Guide](https://db.rstudio.com/)
- [SQL JOIN Examples](https://www.w3schools.com/sql/sql_join.asp)

# Future Work

- Add proper data type for latitude and longitude to enable numeric aggregation without casting.  
- Implement date-based queries if date columns are added to the dataset.  
- Improve error handling for database connection and data insertion.  
- Add more visualization of aggregated data in R using `ggplot2` or Tableau.  