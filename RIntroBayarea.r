library(ggplot2)
library(ggmap)
library(dplyr)
library(mgcv)
library(lubridate)
library(magrittr)
library(hexbin)

# read house sales data
sales <- read.csv('./data/house-sales.csv', stringsAsFactors=FALSE)

# read geolocation data
ad <- read.csv('./data/addresses.csv', stringsAsFactors=FALSE)

# by default everything is read in as strings
# we need to convert date strings into date objects
# old-style R
sales$date <- as.POSIXct(strptime(sales$date, '%Y-%m-%d'))
# new-style R
sales$date %<>% ymd()

# prices into numeric values
# old-style R
sales$price <- as.numeric(sales$price)
# new-style R
sales$price %<>% as.numeric()

# zip codes into numeric values
ad$zip %<>% as.numeric()

# check if there are missing vaules in sales or date
# old-style R
any(is.na(sales$price))
any(is.na(sales$date))
any(is.na(ad$zip))
# new-style R
sales$price %>% is.na() %>% any()
sales$date %>% is.na() %>% any()

# remove records with missing important fields
# old-style R
sales <- sales[!is.na(sales$price), ]
sales <- sales[!is.na(sales$date), ]
ad <- ad[!is.na(ad$zip), ]
# new-style R
sales %<>% filter(!is.na(price), !is.na(date))
ad %<>% filter(!is.na(zip))

# combine geo information with sales
geo <- inner_join(ad, sales)

# choose only records with good quality geocoding
precise_qual <- c(
  "QUALITY_ADDRESS_RANGE_INTERPOLATION", "QUALITY_EXACT_PARCEL_CENTROID",
  "gpsvisualizer")
precise <- filter(geo, quality %in% precise_qual)

# choose cities with at least 10 sales a week
# how many weeks does our dataset cover?
date_range <- range(precise$date)
weeks <- as.integer(date_range[2] - date_range[1]) / 7

# calculate sales per city
cities <- group_by(precise, city) %>%
  summarise(freq = n())

big_cities <- filter(cities, freq > weeks * 10)

# see what we actually pick up
ggplot(cities, aes(freq)) +
  geom_histogram(binwidth=250, alpha=I(0.7)) +
  geom_vline(xintercept=weeks*10, color=I("red"))

# add interesting cities
selected <- c(as.character(big_cities$city), 'Mountain View', 'Berkley')
bigc_geo <- filter(geo, city %in% selected)

# see the locations of the sales on the map
qmplot(long, lat, data=bigc_geo, color=I('red'), alpha=I(0.1))
qmplot(long, lat, data=bigc_geo, color=I('red'),
       maptype='toner-lite', geom='density2d')

# calculate average price and number of sales per city per day
bigsum <- bigc_geo %>%
          group_by(city, date) %>%
          summarise(n=n(),price=mean(price))

# spatial analysis see if county assignment went right
qmplot(long, lat, data=bigc_geo, color=county, alpha=I(0.05), maptype='toner-lite') +
  guides(colour = guide_legend(override.aes = list(alpha=1)))

# age of houses geolocated
qmplot(long, lat, data=bigc_geo, color=year, alpha=I(0.1), maptype='toner-lite')

# cleaning the data
select(bigc_geo, year) %>% distinct()
bigc_geo %<>% filter(year > 1700, year < 2015)

qmplot(long, lat, data=bigc_geo, color=year, alpha=I(0.1), maptype='toner-lite')

# look at SF
sf_geo <- filter(bigc_geo, city == "San Francisco")
qmplot(long, lat, data=sf_geo, color=year, alpha=I(0.1), maptype='toner-lite') +
  scale_color_gradientn(colours=heat.colors(10, alpha=0.5))
# what about the corelation between the age and the price?
qmplot(long, lat, data=sf_geo, color=year, size=price,
       alpha=I(0.1), maptype='toner-lite') +
  scale_color_gradientn(colours=heat.colors(10, alpha=0.5)) +
  scale_size_area()

qmplot(long, lat, data=sf_geo, alpha=I(0.5), stat="binhex", geom="hex",
       maptype='toner-lite')+
  scale_fill_gradientn(colours=heat.colors(16))


# tiemline
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

big_monthly <- bigsum %>%
  group_by(city, year, month) %>%
  summarise(m_price = mean(price),
            date = date[1])

qplot(factor(date), m_price, data=big_monthly, geom="boxplot") +
  theme(axis.text.x = element_text(angle=45, hjust=1))

qplot(factor(date), m_price, data=big_monthly, geom="boxplot") +
  coord_flip()

# smoothing
smooth <- function(y, x) {
  as.numeric(predict(gam(y ~ s(x), na.action = na.exclude)))
}

bigsum <- plyr::ddply(bigsum, plyr::.(city), transform,
                price_s = smooth(price, as.numeric(date)))
ggplot(bigsum, aes(date, price_s /1e6, group=city)) +
  geom_line()

index <- function(y, x) {
  y / y[order(x)[1]]
}
bigsum <- plyr::ddply(bigsum, plyr::.(city), transform,
                price_si = index(price_s, date))
ggplot(bigsum, aes(date, price_si /1e6, group=city, color=city)) +
  geom_line()

ggplot(bigsum, aes(date, price_si)) + 
  geom_line() + 
  facet_wrap(~ city)

# get the peak and last price
covar <- arrange(bigsum, city, date) %>%
  group_by(city) %>%
  summarise(
    peak = max(price_si),
    plummet = last(price_si)
  )

ggplot(covar, aes(peak, plummet)) +
  geom_point()
ggplot(covar, aes(peak, plummet)) +
  geom_point() +
  geom_text(aes(label=city), size=4, hjust=-0.05)

covar %<>% transform(delta=plummet - peak)

census <- read.csv('data/census-city.csv')
covar %<>% inner_join(census)

plot_base <- ggplot(covar, aes(y=delta)) + geom_point()
plot_base + aes(grads)
plot_base + aes(income)
plot_base + aes(housesold_size)