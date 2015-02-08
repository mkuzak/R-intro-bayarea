library(plyr)
library(ggplot2)
library(ggmap)
library(dplyr)
library(mgcv)

# read in house sales data
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

# load financial data (consumer price index)
cpi_file <- paste0(path, "/extdata/finances-cpi-west.csv")
cpi <- read.csv(cpi_file)

# add one last row (same as last available)
cpi <- rbind(cpi, data.frame(year = 2008, month = 11, cpi = cpi$cpi[nrow(cpi)]))

# start after April 2003
cpi <- subset(cpi, (year == 2003 & month >= 4) | year > 2003)

# calculate the ratio, compared to first cpi record
cpi$ratio <- cpi$cpi / cpi$cpi[1]

# plot the inflation
qplot(year + month / 12, ratio, data = cpi, geom = "line", ylab = "Inflation") + xlab(NULL)

# adjust prices for inflation
geo <- merge(geo, cpi, by=c("month", "year"), sort=F)
geo$priceadj <- geo$price / geo$ratio
ggplot(geo) +
  geom_line(aes(x=date, y=price)) +
  geom_line(aes(x=date, y=priceadj)) +
  facet_wrap(~city)



