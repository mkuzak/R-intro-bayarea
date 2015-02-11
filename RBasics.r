# Introduction to data structures in R

# atomic vector
# -------------
v <- c(1,2.0,3.5)
v1 <- c('foo', 'bar')

# always flat
c(1, c(2, c(3,4)))

# homogenous -- all elements need to be of one type
# values will be coerced to more flexible type
c("a", 1)

# list
# ----
# heterogenous
x <- list(1:3, "a", c(TRUE, FALSE, TRUE), c(2.3, 5.9))
# list can contain lists
y <- list(list(1,2), c(3,4))


# factors
# -------
# vector containing only predefined values, used for categorical data
f <- factor(c("a", "b", "b", "a"))
f[1]
f[1] <- "c"
# arithmetics on factors usually does not make sense
f[1] + f[2]
# but
c(f)
# use case
sex_char <- c("m", "m", "m")
sex_factor <- factor(sex_char, levels = c("m", "f"))

# be carefull !!
# most data loading functions in R automatically convert character vectors to factors

# matrices and arrays
# -------------------

# Two scalar arguments to specify rows and columns
a <- matrix(1:6, ncol = 3, nrow = 2)
# One vector argument to describe all dimensions
b <- array(1:12, c(2, 3, 2))

# You can also modify an object in place by setting dim()
c <- 1:6
dim(c) <- c(3, 2)
dim(c) <- c(2, 3)
length(c)
ncol(c)
nrow(c)
dim(c)

# dataframes
# ----------
# for storing and easy maniputation of tabular data
df <- data.frame(x = 1:3, y = c("a", "b", "c"))
names(df)
colnames(df)
rownames(df)
length(df)
nrow(df)
ncol(df)

# merging dataframes together
cbind(df, data.frame(z = 3:1))
rbind(df, data.frame(x = 10, y = "z"))



