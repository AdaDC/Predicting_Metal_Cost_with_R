################################
#  Model Building              #
#  AUTHOR: Adamma Morrison     #
#  Nov 10, 2018                #
################################

# This script will generate several models for the data
# 1.	Simple linear regression
# 2.  Time Series Forecasting - ARIMA
# 3.	Time Series Forecasting - Neural Network
# 4.	Random Forest

# First load libraries, uncomment and install if you don't have them already
require(tidyverse)
require(forecast)
require(randomForest)

# Load information
data <- read_csv("data/cleaned_data.csv") # The read_csv command is faster, and it automatically parses most of the data
data[c(2,3,6,7,11,12)] <- lapply(data[c(2,3,6,7,11,12)], as.numeric) # these columns need to be changed to numeric

# Use roughly 70/30 split for training and test data
train <- data[1:77,]
test <- data[78:111,]

################
# 1. Simple linear regression, without percent change vars. http://r-statistics.co/Linear-Regression.html
################

simple_LR_copper <- lm(copper_price ~ libor12 + libor3 + crude_oil + natural_gas + sp500 + nasdaq + industrial_mining,
            data = train)
simple_LR_zinc <- lm(zinc_price ~ libor12 + libor3 + crude_oil + natural_gas + sp500 + nasdaq + industrial_mining,
            data = train)

## See info about linear models ##
summary(simple_LR_copper)
summary(simple_LR_zinc)



##################
# 2. Time series forecasting - ARIMA  (from https://www.statmethods.net/advstats/timeseries.html) - no training and test sets
#################

# Fit models for copper and zinc - use auto.arima on time series version of data
fit_copper <- auto.arima(ts(data[1:104, 2],start=c(1991, 1), end=c(2016, 4), frequency=4),D=1)
fit_zinc <- auto.arima(ts(data[1:104, 3],start=c(1991, 1), end=c(2016, 4), frequency=4),D=1)

# Forecast copper and zinc for 16 periods - four years
forecast_copper <- forecast(fit_copper, h=16)
forecast_zinc <- forecast(fit_zinc, h=16)

##See results of ARIMA forecast##
# Plot predictions
plot(forecast_copper, main ="ARIMA Forecast for copper")
plot(forecast_zinc, main ="ARIMA Forecast for zinc")

# Numeric predictions - the mean ARIMA predictions
ARIMA_copper_pred <- as.numeric(forecast_copper$mean)
ARIMA_zinc_pred <- as.numeric(forecast_zinc$mean)




###################
# 3. Time Series Forecasting - Neural Network
##################
# Put info in time series
copper_ts <- ts(data[1:104, 2], start=c(1991, 1), end=c(2016, 4), frequency=4) 
zinc_ts <- ts(data[1:104, 3], start=c(1991, 1), end=c(2016, 4), frequency=4)

# Make neural network forecast
nn_forecast_copper <- forecast(nnetar(copper_ts), h=16)
nn_forecast_zinc <- forecast(nnetar(zinc_ts), h=16)

## See results of NN forecast##
# Plot predictions
plot(nn_forecast_copper, main ="NN Forecast for copper")
plot(nn_forecast_zinc, main ="NN Forecast for zinc")

# Numeric predictions - NN forecast model
NN_copper_pred <- data.frame(nn_forecast_copper)
NN_zinc_pred <- data.frame(nn_forecast_zinc)



#################
# 4. Decision Trees - Random Forest - 600 trees
#################

set.seed(1234567) # so analysis can be replicated

# Use roughly 70/30 split for training and test data
train <- data[1:77,]
test <- data[78:111,]

# We will use all but first three variables (date, copper, and zinc price) to make predictive models
RF_copper <- randomForest(copper_price ~ libor12 + libor3 + crude_oil + natural_gas + sp500 + nasdaq + industrial_mining 
                          + pc_copper + pc_zinc + pc_gdp, 
                          data = data, ntree=600, subset=1:77, mtry=8, na.action = na.omit)

RF_zinc <- randomForest(zinc_price ~ libor12 + libor3 + crude_oil + natural_gas + sp500 + nasdaq + industrial_mining
                        + pc_copper + pc_zinc + pc_gdp, 
                          data = data, ntree=600, subset=1:77, mtry=8, na.action = na.omit)

print(RF_copper)
importance(RF_copper)

print(RF_zinc)
importance(RF_zinc)

## Save models
#save.image(file="bin/models.RData")
