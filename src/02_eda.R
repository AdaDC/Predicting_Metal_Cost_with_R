################################
#  Exploratory Data Analysis   #
#  AUTHOR: Adamma Morrison     #
#  Nov 10, 2018                #
################################

# Now let's explore the cleaned data with a few graphs

# First load necessary libraries
require(tidyverse)
require(ggplot2)
require(plotly)
require(reshape2) # for melt function
require(ggthemes)

# Then load information
data <- read_csv("data/cleaned_data.csv") # The read_csv command is faster, and it automatically parses most of the data
data[c(2,3,6,7,11,12)] <- lapply(data[c(2,3,6,7,11,12)], as.numeric) # these columns need to be changed to numeric

# See summary for data - min, quartiles, mean, median, and max
summary(data)

# First look at time series graph for two variables of interest; price for copper and zinc
output_vars_melted <- melt(data[1:3], id = "date")
ggplot(output_vars_melted, aes(x=date, y=value, col=variable)) + geom_line() +
      ggtitle("Historic Prices for Copper and Zinc") +
      theme_stata()

## Generate time series of all variables
all_vars_melted <- melt(data, id = "date")
qplot(date, value, data = all_vars_melted, geom = "line", group = variable) +
    facet_grid(variable ~ ., scale = "free_y") +
    theme_bw() +
      ggtitle("Time Series of all Variables") +

# We can quickly perform EDA with the DataExplorer package
#Install if the package doesn't exist 
#install.packages('DataExplorer') 
library(DataExplorer)
plot_missing(data) # show missing values
plot_histogram(data) # see distribution of values
plot_correlation(data[1:106, -1], type = 'all') #correlation, without the last five rows of missing data and date


