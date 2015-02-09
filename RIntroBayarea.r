library(plyr)
library(ggplot2)
library(ggmap)
library(dplyr)
library(mgcv)

# read house sales data
path = system.file(package='RIntroBayarea')
sales_file <- paste0(path, "/extdata/house-sales.csv")
sales <- read.csv(sales_file, stringsAsFactors=FALSE)

# read in geolocation data
ad_file <- paste0(path, '/extdata/addresses.csv')
ad <- read.csv(ad_file, stringsAsFactors=FALSE)

# by default everything is read in as strings
# we need to convert date strings into date objects
sales$date <- as.POSIXct(strptime(sales$date, '%Y-%m-%d'))

# and prices into numeric values
sales$price <- as.numeric(sales$price)

# check if there are missing vaules in sales or date
any(is.na(sales$price))
any(is.na(sales$date))

# remove missing rows with missing dates
sales <- sales[!is.na(sales$date), ]

# combine sales data with geospatial information
names(sales)
names(ad)

# by common columns
intersect_cols <- intersect(names(sales), names(ad))
geo <- join(sales, ad, by = intersect_cols)

# choose only records with goog quality geocoding
precise_qual <- c(
  "QUALITY_ADDRESS_RANGE_INTERPOLATION", "QUALITY_EXACT_PARCEL_CENTROID",
  "gpsvisualizer")
precise <- subset(geo, quality %in% precise_qual)

# choose cities with at least 20 sales a week
# how many weeks does our dataset cover?
n_weeks <- as.integer((max(precise$date) - min(precise$date)) / 7)

# calculate sales per city
cities <- as.data.frame(table(precise$city))
names(cities) <- c('city', 'freq')

big_cities <- subset(cities, freq > n_weeks * 20)

# see what we actually pick up
ggplot(geo, aes(city)) +
  geom_histogram() +
  geom_hline(yintercept=n_weeks*20)

# add interesting cities
selected <- c(as.character(big_cities$city), 'Mountain View', 'Berkley')
bigc_geo <- subset(geo, city %in% selected)

# see the locations of the sales on the map
qmplot(long, lat, data=bigc_geo, color=I('red'), alpha=I(0.1))
qmplot(long, lat, data=bigc_geo, color=I('red'),
       maptype='toner-lite', geom='density2d')

# calculate average price and number of sales per city per day
bigsum <- bigc_geo %>%
          group_by(city, date) %>%
          summarise(n=n(),price=mean(price))

# plot number of sales in time
qplot(date, n, data=bigsum, geom='line', group=city)
qplot(date, n, data=bigsum, geom='line', group=city) + facet_wrap(~city)

# and average price in time
qplot(date, price, data=bigsum, geom='line', group=city)
qplot(date, price, data=bigsum, geom='line', group=city) + facet_wrap(~city)

# extract day and year from date (for easier manupulations)
get_month <- function(x) as.POSIXlt(x)$mon + 1
get_year <- function(x) as.POSIXlt(x)$year + 1900

# look at the distribution of monthly averages
bigsum$month <- get_month(bigsum$date)
bigsum$year <- get_year(bigsum$date)

big_montly <- bigsum %>%
group_by(city, year, month) %>%
summarise(m_price = mean(price))

qplot(factor(year + month/12), m_price, data=big_montly, geom="boxplot")

# the distribution of prices is wide, it's right skewed 
qplot(price, data = geo, geom="histogram", binwidth = 1e4, xlim = c(0, 2e6))
fp <- geom_freqpoly(aes(y = ..density..), binwidth = .05)

# distribution within each year
ggplot(geo, aes(log10(price))) + fp + aes(colour = factor(year))
# distributions by month
ggplot(geo, aes(log10(price))) + fp + aes(colour = factor(month))

# split into months within each year
ggplot(geo, aes(log10(price))) + fp + facet_grid(year ~ month)

