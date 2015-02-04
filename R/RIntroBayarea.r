library(plyr)
library(ggplot2)

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

# add interesting citie
selected <- c(as.character(big_cities$city), 'Mountain View', 'Berkley')
bigc_geo <- subset(geo, city %in% selected)
