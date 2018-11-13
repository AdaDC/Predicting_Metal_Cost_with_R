################################
#  Model Evaluation            #
#  AUTHOR: Adamma Morrison     #
#  Nov 10, 2018                #
################################

# This script will generate predictions and compare models

# First load models
load("bin/models.RData")

require(tidyverse)
require(forecast)
require(randomForest)
require(ggplot2)
require(reshape2) # for melt function
require(lubridate) # for highlighting dates on graphs
require(ggthemes) # for plot themes

# Get predictions for the 4 types of models. 
simple_LR_copper_pred <- predict(simple_LR_copper, test)
simple_LR_zinc_pred <- predict(simple_LR_zinc, test)

ARIMA_copper_pred <- as.numeric(forecast_copper$mean)
ARIMA_zinc_pred <- as.numeric(forecast_zinc$mean)

NN_copper_pred <- data.frame(nn_forecast_copper)
NN_zinc_pred <- data.frame(nn_forecast_zinc)

RF_copper_pred <-predict(RF_copper, newdata = test)
RF_zinc_pred <-predict(RF_zinc, newdata = test)

## Let's compare each models' predictions 

# Model Results Graph 
all_results_copper <- data.frame(predict(simple_LR_copper, data), predict(RF_copper, data), data[2], data[1])
all_results_zinc <- data.frame(predict(simple_LR_zinc, data), predict(RF_zinc, data), data[3], data[1])

# Graph for copper
copper_melt <- melt(all_results_copper, id = "date")
ggplot() +  
       geom_line(data=copper_melt, aes(x=date, y=value, col=variable)) +
       ggtitle("Predictions for Copper") + 
       scale_color_discrete(name  ="Models",
                           breaks=c("predict.simple_LR_copper..data.", "predict.RF_copper..data.", "copper_price"),                           
                           labels=c("Linear Regression", "Random Forest", "Actual Price")) +
      geom_rect(data=data.frame(xmin=(as.Date(c("2010-01-01"))),
                            xmax=(as.Date(c("2018-01-01"))),
                            ymin=-Inf,
                            ymax=Inf),
            aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax),
            fill="orange",alpha=0.3) +
      xlab("Year") +
      ylab("Price in USD") +
      theme_stata()

# Graph for zinc
zinc_melt <- melt(all_results_zinc, id = "date")
ggplot() +  
       geom_line(data=zinc_melt, aes(x=date, y=value, col=variable)) +
       ggtitle("Predictions for Zinc") + 
       scale_color_discrete(name  ="Models",
                           breaks=c("predict.simple_LR_zinc..data.", "predict.RF_zinc..data.", "zinc_price"),                           
                           labels=c("Linear Regression", "Random Forest", "Actual Price")) +
      geom_rect(data=data.frame(xmin=(as.Date(c("2010-01-01"))),
                            xmax=(as.Date(c("2018-01-01"))),
                            ymin=-Inf,
                            ymax=Inf),
            aes(xmin=xmin,xmax=xmax,ymin=ymin,ymax=ymax),
            fill="orange",alpha=0.3) +
      xlab("Year") +
      ylab("Price in USD") +
      theme_stata()


# Now let's see forecast models
par(mfrow=c(1,2))
plot(forecast_copper, main ="ARIMA Forecast for Copper")
plot(nn_forecast_copper, main ="NN Forecast for Copper")

par(mfrow=c(1,2))
plot(forecast_zinc, main ="ARIMA Forecast for Zinc")
plot(nn_forecast_zinc, main ="NN Forecast for Zinc")

################################
# This part of the script will output csv files with the results of all models

#write.csv(nn_forecast_zinc, "results/nn_results_zinc.csv", row.names = F)
#write.csv(nn_forecast_copper, "results/nn_results_copper.csv", row.names = F)
#write.csv(all_results_zinc, "results/all_results_zinc.csv", row.names = F)
#write.csv(all_results_copper, "results/all_results_copper.csv", row.names = F)

