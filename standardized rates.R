# Public Health Tools in R
# Calculating standardised rates
# Aggregated data
# Mirjam Allik
# May 2020



# Install packages
install.packages(c("popEpi", "epiR", "epitools", "dsr", "PHEindicatormethods", "dsrTest"))

# load
package_list <- c("popEpi", "epiR", "epitools", "dsr", "PHEindicatormethods", "dsrTest")
lapply(package_list, require, character.only = TRUE)

# or use package pacman: install.packages("pacman")
# pacman::p_load(popEpi, epiR, Epi, ...)  



# epiR, uses aggregated data
# ===============================================================================
# https://cran.r-project.org/web//packages/epiR/index.html

# Read data
eng_d <- read.csv("Data/England_deaths.csv")
head(eng_d)

# Prepare data
death_obs <- matrix(eng_d$Deaths, nrow = 1, ncol = 19, dimnames = list("", 1:19))
pop_obs <- matrix(eng_d$Population, nrow = 1, ncol = 19, dimnames = list("", 1:19))
esp13 <- matrix(eng_d$ESP, nrow = 1, ncol = 19, dimnames = list("", 1:19))

# calcualate rates
epi.directadj(death_obs, pop_obs, esp76, units = 100000, conf.level = 0.95)

# How would you do that for age groups?
# for ages 35-54
d35_54 <- death_obs[, 9:12, drop = F]
p35_54 <-pop_obs[, 9:12, drop = F]
esp35_54 <- esp76[, 9:12, drop = F]

epi.directadj(d35_54, p35_54, esp35_54, units = 100000, conf.level = 0.95) # Default 95% CI

# For multiple groups
scot_d <- read.csv("Data/Scotland_deaths.csv")
head(scot_d)

# Prepare data
death_obs_s <- t(scot_d[, 3:5])
pop_obs_s <- t(scot_d[, 6:8])
colnames(pop_obs_s) <- colnames(death_obs_s) <- 1:19
row.names(pop_obs_s) <- row.names(death_obs_s) <- c("T", "M", "F")
esp13 <- matrix(scot_d$ESP, nrow = 1, ncol = 19, dimnames = list("", 1:19))

# calcualate rates
epi.directadj(death_obs_s, pop_obs_s, esp13, units = 100000, conf.level = 0.95)


# epitools, uses aggregated data
# ===============================================================================
# https://cran.r-project.org/web/packages/epitools/index.html


# Use eng_d data
ageadjust.direct(eng_d$Deaths, eng_d$Population, stdpop = eng_d$ESP)
ageadjust.direct(eng_d$Deaths, eng_d$Population, stdpop = eng_d$ESP)*100000 # Default 95% CI

# How would you do that for age groups?
# For ages 35-54
eng_d35_54 <- eng_d[9:12, ]
ageadjust.direct(eng_d35_54$Deaths, eng_d35_54$Population, stdpop = eng_d35_54$ESP)*100000


# For multiple groups
ageadjust.direct(scot_d$deaths, scot_d$pop, stdpop = scot_d$ESP)*100000 # Default 95% CI
ageadjust.direct(scot_d$deaths_M, scot_d$pop_M, stdpop = scot_d$ESP)*100000

# or use mapply
mapply(ageadjust.direct, count = scot_d[, 3:5], pop = scot_d[, 6:8], MoreArgs = list(stdpop = scot_d$ESP))*100000



# dsrTest
# ===============================================================================
# https://cran.r-project.org/web/packages/dsrTest/

# Rates and a test for a single grooup
dsrTest(eng_d$Deaths, eng_d$Population, stdpop = eng_d$ESP, mult = 100000)

# For multiple groups, using Scottish data
mapply(dsrTest, x = scot_d[, 3:5], n = scot_d[, 6:8], MoreArgs = list(w = scot_d$ESP, mult = 100000))



# PHEindicatormethods, can be used on aggregated data
# ===============================================================================
# https://cran.r-project.org/web/packages/PHEindicatormethods/index.html
# Has built in standard population also, but limited to ESP 2013 for 19 age groups from 0-4 to 90+

# Rates for a single grooup
phe_dsr(eng_d, Deaths, Population, ESP, stdpoptype = "field") # Default 95% CI

# How would you do that for age groups?
# for ages 35-54
phe_dsr(eng_d35_54, Deaths, Population, ESP, stdpoptype = "field")


# For multiple groups
# Get the data in the long format
scot_d_long <- scot_d %>%
  mutate(age = factor(age, levels = age[1:19], ordered = T)) %>%
  gather("variable", "n", 3:8) %>%
  separate(variable, c("variable", "sex"), sep = "_", fill = "right") %>%
  mutate(sex = ifelse(is.na(sex), "T", sex)) %>%
  spread(variable, n) %>%
  arrange(sex, age)

# create standard population
stp13 <- scot_d$ESP

scot_d_long  %>% 
  group_by(sex) %>% 
  phe_dsr(deaths, pop, stdpop = stp13, stdpoptype = "vector", type = "standard")


# dsr
# ===============================================================================
# https://cran.r-project.org/web/packages/dsr/

# standard population data needs to be in a data.frame together with age
esp13_m <- scot_d[, 1:2]
esp13_m$age <- factor(esp13_m$age, levels = esp13_m$age, ordered = T) # the age variable will need to be same as in data
names(esp13_m) <- c("age", "pop") # standard population has to be named "pop"

scot_d_long2 <- scot_d_long # the population variable in the data cannot be named "pop"
names(scot_d_long2)[5] <- "population"

# results need to be saved into an object and then printed
results <- dsr(data = scot_d_long2, event = deaths, fu = population, subgroup = sex, age = age, refdata = esp13_m, mp=100000)
results


