# ===================================================================
# PROJECT: Comprehensive Time Series Analysis
# DATASET: Electric Production
# AUTHOR: Ritik Srivastava
# DATE: 2024-09-21
# DESCRIPTION:
#   This script performs an end-to-end ARIMA/SARIMA analysis on the
#   'Electric Production' dataset, including data exploration,
#   transformation, model identification, validation, and forecasting.
# ===================================================================


# -------------------------------------------------------------------
# 1. SETUP & LIBRARY INSTALLATION
# -------------------------------------------------------------------
# Ensures that all required libraries are installed and loaded.

required_packages <- c(
  "forecast", "tseries", "ggplot2", "readr",
  "lubridate", "Metrics", "dplyr", "knitr"
)

new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) install.packages(new_packages)

lapply(required_packages, library, character.only = TRUE)


# ===================================================================
# PART A: DATA EXPLORATION & PREPARATION
# ===================================================================
cat("=== PART A: Data Exploration & Preparation ===\n\n")

# -------------------------------------------------------------------
# 2. DATA LOADING & CONVERSION
# -------------------------------------------------------------------
# Ensure 'Electric_Production.csv' is present in your working directory.

electric_df <- read_csv("Electric_Production.csv", show_col_types = FALSE)
names(electric_df) <- c("Date", "Value")

# Convert to a time series object (monthly frequency)
start_date <- as.Date(min(electric_df$Date), format = "%m/%d/%Y")
electric_ts <- ts(
  electric_df$Value,
  start = c(year(start_date), month(start_date)),
  frequency = 12
)


# -------------------------------------------------------------------
# 3. VISUALIZATION & STATIONARITY TESTING
# -------------------------------------------------------------------
cat("Performing exploratory analysis and checking stationarity...\n")

# Original time series plot
autoplot(electric_ts) +
  labs(
    title = "Monthly Electric Production",
    x = "Year", y = "Electric Production"
  ) +
  theme_minimal()

# Log transformation to stabilize variance
electric_ts_log <- log(electric_ts)
autoplot(electric_ts_log) +
  labs(title = "Log-Transformed Electric Production", x = "Year", y = "Log(Value)") +
  theme_minimal()

# Decomposition into trend, seasonality, and remainder
autoplot(decompose(electric_ts_log)) +
  labs(title = "Decomposition of Log-Transformed Series") +
  theme_minimal()

# Differencing to remove trend and seasonality
electric_ts_log_d1 <- diff(electric_ts_log)
electric_ts_log_d1_D1 <- diff(electric_ts_log_d1, lag = 12)

autoplot(electric_ts_log_d1_D1) +
  labs(
    title = "Differenced and Seasonally Differenced Series",
    subtitle = "Stationarity expected after differencing",
    x = "Year", y = "Differenced Value"
  ) +
  theme_minimal()

# --- Stationarity Tests ---
cat("\n--- ADF and KPSS Tests ---\n")
cat("ADF Test (H0: Non-stationary):\n")
print(adf.test(electric_ts_log_d1_D1, alternative = "stationary"))

cat("\nKPSS Test (H0: Stationary):\n")
print(kpss.test(electric_ts_log_d1_D1))


# ===================================================================
# PART B: MODEL IDENTIFICATION & TRAINING
# ===================================================================
cat("\n=== PART B: Model Identification & Training ===\n\n")

# -------------------------------------------------------------------
# 4. TRAIN-TEST SPLIT
# -------------------------------------------------------------------
cat("Splitting dataset into training and testing sets...\n")

# Last 24 months reserved as test set
train_ts_log <- window(electric_ts_log, end = c(end(electric_ts_log)[1] - 2, 12))
test_ts_log <- window(electric_ts_log, start = c(end(electric_ts_log)[1] - 1, 1))

cat("Training set length:", length(train_ts_log), "\n")
cat("Testing set length:", length(test_ts_log), "\n")

# -------------------------------------------------------------------
# 5. MODEL SELECTION (AUTO ARIMA)
# -------------------------------------------------------------------
cat("\nRunning auto.arima() for optimal model selection...\n")

auto_model_train <- auto.arima(
  train_ts_log,
  stepwise = FALSE,
  approximation = FALSE,
  trace = TRUE
)

cat("\n--- Best Model on Training Data ---\n")
print(summary(auto_model_train))

# Residual diagnostics
checkresiduals(auto_model_train)


# ===================================================================
# PART C: MODEL VALIDATION & FORECASTING
# ===================================================================
cat("\n=== PART C: Model Validation & Forecasting ===\n\n")

# -------------------------------------------------------------------
# 6. FORECASTING ON TEST SET & MODEL EVALUATION
# -------------------------------------------------------------------
cat("Evaluating model on the test set...\n")

# Forecast next 24 months
test_forecast <- forecast(auto_model_train, h = length(test_ts_log))

# Back-transform to original scale
test_forecast$mean  <- exp(test_forecast$mean)
test_forecast$lower <- exp(test_forecast$lower)
test_forecast$upper <- exp(test_forecast$upper)
test_forecast$x     <- exp(test_forecast$x)

# Actual test values (original scale)
test_ts <- window(electric_ts, start = c(end(electric_ts)[1] - 1, 1))

# Accuracy metrics
accuracy_metrics <- forecast::accuracy(test_forecast$mean, test_ts)
print(accuracy_metrics)

# Plot forecast vs actuals
autoplot(test_ts, series = "Actual") +
  autolayer(test_forecast$mean, series = "Forecast") +
  labs(
    title = "Forecast vs Actual (Test Set)",
    x = "Year", y = "Electric Production",
    subtitle = "Model evaluation on unseen data"
  ) +
  theme_minimal()


# -------------------------------------------------------------------
# 7. FINAL MODEL & LONG-TERM FORECASTING
# -------------------------------------------------------------------
cat("\nTraining final model on the full dataset...\n")

final_model <- Arima(electric_ts_log, model = auto_model_train)

cat("\n--- Final Model Summary ---\n")
print(summary(final_model))

# Residual diagnostics
checkresiduals(final_model)

# Forecast next 24 months
final_forecast <- forecast(final_model, h = 24)

# Back-transform to original scale
final_forecast$mean  <- exp(final_forecast$mean)
final_forecast$lower <- exp(final_forecast$lower)
final_forecast$upper <- exp(final_forecast$upper)
final_forecast$x     <- exp(final_forecast$x)

# Plot final forecast
autoplot(electric_ts) +
  autolayer(final_forecast, series = "24-Month Forecast", PI = TRUE) +
  labs(
    title = "Electric Production Forecast (Next 24 Months)",
    x = "Year", y = "Electric Production",
    subtitle = "Final model retrained on entire dataset"
  ) +
  theme_minimal()

cat("\n=== Script Execution Complete ===\n")
