# Using R to Predict Copper and Zinc Quarterly Prices
---

To run this project download or clone repository.  Double click the .Rproj file to start analysis.  The scripts are contained in the src folder and the .csv files are in the data folder.


### Method
The data for the analysis was obtained from the [Federal Reserve Bank of St. Louis](https://fred.stlouisfed.org/series/PCOPPUSDQ) and [Datahub.io](Datahub.io).  Please see below for list of variables.  

1.	Date
2.	Global price of Copper, U.S. Dollars per Metric Ton, Not Seasonally Adjusted (PCOPPUSDM)
3.	Global price of Zinc, U.S. Dollars per Metric Ton, Not Seasonally Adjusted (PZINCUSDM)
4.	12-Month London Interbank Offered Rate (LIBOR), based on U.S. Dollar, Percent, Not Seasonally Adjusted (USD12MD156N)
5.	3-Month London Interbank Offered Rate (LIBOR), based on U.S. Dollar, Percent, Not Seasonally Adjusted (USD3MTD156N)
6.	Global price of Brent Crude, U.S. Dollars per Barrell, Not Seasonally Adjusted (POILBREUSDQ)
7.	Global price of Natural Gas, US Henry Hub Gas, U.S. Dollars per Million Metric British Thermal Unit, Not Seasonally Adjusted (PNGASUSUSDM)
8.	S&P 500, Index, Not Seasonally Adjusted (SP500)
9.	NASDAQ Composite Index, Index Feb 5, 1971=100, Not Seasonally Adjusted (NASDAQCOM)
10.	Industrial Production: Mining: Copper, nickel, lead, and zinc mining, Index 2012=100, Not Seasonally Adjusted (IPG21223NQ)
11.	Global price of Copper, U.S. Dollars per Metric Ton, Not Seasonally Adjusted (PCOPPUSDM) – end of period, percent change
12.	Global price of Zinc, U.S. Dollars per Metric Ton, Not Seasonally Adjusted (PZINCUSDM) – end of period, percent change
13.	Real Gross Domestic Product, Percent Change from Quarter One Year Ago, Seasonally Adjusted (A191RO1Q156NBEA)


### Step 1- Data Preparation – 01_data_cleaning.R

The script for this step generates a file called cleaned_data.csv.  This file with cleaned data will be used later to build our models.

The original dataset from the Federal Reserve Bank contained 111 observations of 13 variables.  S&P500 information was missing for 1991 – 2008.

An API call to Datahub.io was used to obtain the missing S&P500 values.  This information was stored in a dataframe called `missing`.
```
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
```

The command `missing_dates <- data$DATE[data$SP500 == "."]` was used to create a list of all the dates with missing information.  Next `need <- subset(missing, missing$Date %in% missing_dates)` was used to extract this information from the `missing` dataframe.

Next, the extracted information was combined with the bank data.
```
## Join this info together
data$SP500 <- as.character(data$SP500)
data$SP500[1:72] <- need$SP500[1:72]
```
Finally, all of the columns were renamed for ease of analysis.
```
colnames(data) <- c("date", "copper_price", "zinc_price", "libor12", "libor3", "crude_oil", "natural_gas", "sp500", "nasdaq", "industrial_mining", "pc_copper", "pc_zinc", "pc_gdp")
```

Finally, all of this cleaned and combined data was written to a file called cleaned_data.csv.

### Step 2 – Exploratory Data Analysis – 02_eda.R

This script will perform exploratory data analysis, and generate graphs of the cleaned dataset.  

![missing data](results/missing_data.jpeg)
There were 5 rows with missing information for percent change zinc, percent change copper, natural gas, crude oil, zinc price, and copper price.  These 5 rows were for the dates 2017-07-01 to 2018-07-01.

![historic prices](results/historic prices for metals.jpeg)

The price for copper and zinc show a similar pattern with dips and spikes in the same years.  Copper has always been more expensive than zinc, but this difference increased dramatically in 2007.  The price of both metals dropped in 2009, with copper experiencing a much greater reduction in price.   

![price dif](results/difference_cost.jpeg)

A quick look at the time series for all variables shows the price for zinc and copper seems to be most closely related to LIBOR rate.  The London Interbank Offered Rate is the rate of interest for wholesale money markets in London.  This input was included in the model because [Bilal Zonjy](https://bilalzonjy.github.io/432/index.html) found it to be a good predictor of copper prices.  Our models will include the 3 month and 12 month LIBOR rates.

![time series all vars](results/time_series_all_variables.jpeg)

The correlation graph shows which inputs are positively and negatively correlated with each other.  Blue means negative correlation; as one variable increases the other one decreases.  Red means positive correlation; as one variable increases so does the other.

![corr](results/input_correlations.jpeg)

The prices for zinc and copper are strongly correlated with each other (r = 0.82), and as expected, so are the NASDAQ and SP500 (r = 0.96).  Copper’s and zinc’s prices are strongly negatively correlated with industrial mining production for precious metals, crude oil price, and the LIBOR rate. This mean that when the LIBOR rate is higher so is the price for crude oil.  During these times the prices for zinc and copper are low.  This inverse relationship between metal and crude oil price is interesting, and should be further explored.


### Step 3 – Model Building – 03_model_building.R

Separate models were made for zinc and copper price with the following four algorithms.

1.	Simple Linear Regression – this is the simplest kind of model, and is the easiest to interpret.  It will serve as a baseline for comparison.  These regression models did not include the percent change variables.  There variables are related to zinc and copper price, and linear regression models do not work with [highly correlated predictors](https://en.wikipedia.org/wiki/Multicollinearity).  

2.	ARIMA Time Series Forecasting – See <https://www.statmethods.net/advstats/timeseries.html> for explanation

3.	Neural Network Time Series Forecasting – See <http://kourentzes.com/forecasting/2017/02/10/forecasting-time-series-with-neural-networks-in-r/> for explanation.  Neural networks are a deep learning algorithm, and often do well with nonlinear data.  Our dataset is a bit small for this method, but we will try it any way.
4.	Random Forest Model – Our models combines 600 decision trees.

### Step 4 – Model Evaluation – 04_model_evaluation.R

This step looks at the predictions for each model to determine which one is the best.  You can run this script to see predictions and test the models.

![copper](results/predict_copper.jpeg)

![zinc](results/predict_zinc.jpeg)

The blue line shows the true price of zinc and copper.  The linear regression (red line) and random forest (green line) models are very close to the actual metal prices (shown in blue) for the years before 2010.  This is because that price information was used to train the models. The parts of the graph that are highlighted in orange are the models' predictions.

The simple linear regression model has the most error.  It dramatically overpredicts values before 2015, and underpredicts values afterwards.  The random forest models are better predictors for both copper and zinc.  

### Conclusion

Linear regression is not a good fit for the data, and the predictions from the ARIMA model are too broad.

![forecast copper](results/forecast_copper.jpeg)
![forecast zinc](results/forecast_zinc.jpeg)

The Neural Network and Random Forest models are promising, but they need more data.  There is not enough information to build a model that <b>predicts quarterly prices</b>.  Instead the analysis should be repeated with either <b>bi-monthly or daily prices</b>. Deep learning techniques need a lot of data in order to build a good model.  

<b>Suggestions for future analysis</b>:
Python and the Keras or Tensorflow library should be used to build a Long short-term memory (LSTM) model with either daily or monthly prices.  A LSTM model is a special kind of neural network that it optimized for time series data.
