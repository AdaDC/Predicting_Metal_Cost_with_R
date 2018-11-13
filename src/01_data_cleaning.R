###################################################
#  Data Prep: Historical Copper and Zinc Prices   #
#  AUTHOR: Adamma Morrison                        #
#  Nov 10, 2018                                   #
###################################################

## The data for this analysis was pulled from https://fred.stlouisfed.org.  It contains
## quarterly information for 13 variables.  The first two variables contain the price
## for copper and zinc.

# First load necessary libraries
require(dplyr)

# Then load information
data <- read.csv("data/fredgraph.csv")

# Preview the data
head(data)

## The S&P500 data is missing for 1991-2008. We can pull this data from https://datahub.io/core/s-and-p-500#r

## Import from datahub.io
require("jsonlite")
json_file <- 'https://datahub.io/core/s-and-p-500/datapackage.json'
json_data <- fromJSON(paste(readLines(json_file), collapse=""))
# get list of all resources:
print(json_data$resources$name)
# print all tabular data(if exists any)
for(i in 1:length(json_data$resources$datahub$type)){
  if(json_data$resources$datahub$type[i]=='derived/csv'){
    path_to_file = json_data$resources$path[i]
    missing <- read.csv(url(path_to_file)) #missing is called data on the script from the website. rename to avoid overwritting our data
    print(data)
  }
}

## We only need first two columns of missing, which contain the date and SP500
missing <- missing[1:2]
## Delete json_file and json_data, since they take up a lot of memory
json_data <- NULL
json_file <- NULL


## missing contains SP500 data for every month since 1871, but we only need January, April, July, and October for 1991-2008
## We use the following command to pull a list of all the dates that we need.  
missing_dates <- data$DATE[data$SP500 == "."] # pull a list of every date that has "." in the column for SP500

## Now extract the dates and SP500 info for the 72 missing dates
need <- subset(missing, missing$Date %in% missing_dates)

## Join this info together
data$SP500 <- as.character(data$SP500)
data$SP500[1:72] <- need$SP500[1:72]

## For clarity, rename variables
colnames(data) <- c("date", "copper_price", "zinc_price", "libor12", "libor3", "crude_oil", "natural_gas", "sp500", "nasdaq", "industrial_mining", "pc_copper", "pc_zinc", "pc_gdp")

## Save this cleaned data into new file
#write.csv(data, "data/cleaned_data.csv", row.names = F)


