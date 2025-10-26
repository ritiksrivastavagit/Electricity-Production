# Electricity-Production
A time series project in R to forecast monthly electricity production using a SARIMA model.
This repository contains the R code and final report for a time series analysis project focused on forecasting monthly electricity production.
# **Project Objective**
The primary objective of this project is to build a reliable statistical model to forecast monthly electricity production for the next 24 months. The analysis uses the Seasonal Autoregressive Integrated Moving Average (SARIMA) modeling technique, which is a powerful method for handling time series data that exhibits both a non-stationary trend and strong seasonality.
# **Tech Stack**
•	Language: R
•	Core Libraries: tidyverse, forecast, tseries, lubridate, ggplot2
# **Methodology**
The project followed a structured, three-part process:
1. Data Exploration & Preparation
•	Visualization: The raw data was plotted, revealing an upward trend, strong annual seasonality, and increasing variance over time (heteroscedasticity).
•	Transformation: A log transform was applied to stabilize the variance.
•	Stationarity: First-order differencing (d=1) and seasonal differencing (D=1, lag=12) were used to make the series stationary. Stationarity was confirmed using the Augmented Dickey-Fuller (ADF) and KPSS tests.
2. Model Identification & Training
•	Train-Test Split: The data was split into a training set and a 24-month test set.
•	Model Selection: Using R's auto.arima() function on the training set, the optimal model with the lowest AICC was identified as SARIMA(1,1,1)(2,1,1)12.
•	Residual Analysis: The model's residuals were checked and confirmed to resemble white noise (i.e., no remaining autocorrelation), which was validated by a Ljung-Box test (p-value > 0.05).
3. Model Validation & Forecasting
•	Validation: The trained model was used to forecast the 24-month test period. The predictions were highly accurate, achieving a Mean Absolute Percentage Error (MAPE) of approximately 3% against the unseen data.
•	Final Forecast: The validated model was re-trained on the entire dataset to produce a robust 24-month forecast, complete with 80% and 95% prediction intervals.
# **How to Use**
1.	Clone this repository.
2.	Download the Electric_Production.csv file.
3.	Place the .csv file in the same directory as the R script.
4.	Run the R script to reproduce the analysis and forecasts.

