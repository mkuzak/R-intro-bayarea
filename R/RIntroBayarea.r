# read in house sales data

sales_file <- system.file('inst/extdata', 'house-sales.csv', package='RInroBayarea' )
sales <- read.csv(sales_file, stringsAsFactors=FALSE)

# read in geolocation data
ad_file <- system.file('inst', 'extdata', 'addresses.csv', package='RIntroBayarea' )
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

geo <- join(sales, ad, by = c())