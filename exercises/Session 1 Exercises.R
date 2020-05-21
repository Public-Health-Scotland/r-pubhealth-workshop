# Public Health Tools in R
# Session 1 Exercises
# Mirjam Allik
# May 2020


# Make sure you have the packages loaded
package_list <- c("epiR", "epitools", "dsr", "PHEindicatormethods", "dsrTest", "popEpi", "SocEpi")
lapply(package_list, require, character.only = TRUE)

# other packages of use
library(dplyr)
library(tidyr)


# Exercise 1
# Using the aggregated English and/or Scottish deaths data, calculate standardized rates using the packages
# epiR, dsr and/or dsrTest.
# Try out the examples from these packages first (these are listed with the function documentation).
# How do these packages differ from epitools and PHEindicatormethods?
  
# Read data - if already read into R
eng_d <- read.csv("Data/England_deaths.csv") # English data
head(eng_d)

scot_d <- read.csv("Data/Scotland_deaths.csv") # Scottish data with multiple groups
head(scot_d)


# dsr
# ===============================================================================
# https://cran.r-project.org/web/packages/dsr/

# Example shows how to use dsr with the Scottish data
# First, prepare standard population
# Standard population data needs to be in a separate data.frame together with age
esp13_m <- scot_d[, 1:2] # select age and ESP
esp13_m$age <- factor(esp13_m$age, levels = esp13_m$age, ordered = T) # the age variable will need to be same as in data
names(esp13_m) <- c("age", "pop") # standard population has to be named "pop"

head(esp13_m) # data.frame of age and ESP

# Second, prepare the data. The function uses long-format data
# Get the data in the long format (same as in the example for PHEindicatormethods)
scot_d_long <- scot_d %>%
  mutate(age = factor(age, levels = age[1:19], ordered = T)) %>% # Note that age is recoded as an ordered factor!
  gather("variable", "n", 3:8) %>%
  separate(variable, c("variable", "sex"), sep = "_", fill = "right") %>%
  mutate(sex = ifelse(is.na(sex), "T", sex)) %>%
  spread(variable, n) %>%
  arrange(sex, age) %>%
  mutate(population = pop) %>%
  select(-ESP, -pop)  # the population variable in the data cannot be named "pop"

head(scot_d_long)

# Third, calculate results
# results need to be saved into an object and then printed
results <- dsr(data = scot_d_long, event = deaths, fu = population, subgroup = sex, 
               age = age, refdata = esp13_m, mp=100000)
results

# For different age groups, subset the data and the standard population

# epiR
# ===============================================================================
# https://cran.r-project.org/web//packages/epiR/index.html

# Example for English data
# First, prepare data
# Data on deaths, population counts and standard population all have to be in separate matrices
death_obs <- matrix(eng_d$Deaths, nrow = 1, ncol = 20, dimnames = list("", 1:20))
pop_obs <- matrix(eng_d$Population, nrow = 1, ncol = 20, dimnames = list("", 1:20))
esp13 <- matrix(eng_d$ESP, nrow = 1, ncol = 20, dimnames = list("", 1:20))

# see what one matrix looks like (1x20 matrix)
pop_obs

# Second, calculate rates
epi.directadj(death_obs, pop_obs, esp13, units = 100000, conf.level = 0.95)

# How would you do that for age groups?
# Example for ages 35-54
d35_54 <- death_obs[, 9:12, drop = F]
p35_54 <-pop_obs[, 9:12, drop = F]
esp35_54 <- esp13[, 9:12, drop = F]

epi.directadj(d35_54, p35_54, esp35_54, units = 100000, conf.level = 0.95) # Default 95% CI


# Rates for multiple groups, Scottish data
# First, prepare data
death_obs_s <- t(scot_d[, 3:5]) # matrix of observed deaths
pop_obs_s <- t(scot_d[, 6:8]) # matrix for population
colnames(pop_obs_s) <- colnames(death_obs_s) <- 1:19 # give same column names for matrices
row.names(pop_obs_s) <- row.names(death_obs_s) <- c("T", "M", "F") # row names for matrices
esp13 <- matrix(scot_d$ESP, nrow = 1, ncol = 19, dimnames = list("", 1:19)) # 1x19 matrix for standard population

# see how one matrix looks like (3x19 matrix)
death_obs_s

# Second, calculate rates
epi.directadj(death_obs_s, pop_obs_s, esp13, units = 100000, conf.level = 0.95)


# dsrTest
# ===============================================================================
# https://cran.r-project.org/web/packages/dsrTest/
# This package is mostly for testing if rates equal to a specific value
# It will still calculate the rate too, so you can use it to just get the rates

# No specific data preparation is required, our data is in the desired format
# Rates and a test for a single group, using English data
dsrTest(eng_d$Deaths, eng_d$Population, w = eng_d$ESP, mult = 100000)

# Comparison of English data to Scottish rates. Note! null value set to the Scottish rate
dsrTest(eng_d$Deaths, eng_d$Population, w = eng_d$ESP, null.value = 1157.006, mult = 100000) 

# Rates for multiple groups, using Scottish data
mapply(dsrTest, x = scot_d[, 3:5], n = scot_d[, 6:8], MoreArgs = list(w = scot_d$ESP, mult = 100000))

# While it is possible to get the results for multiple groups, 
# the output is not convenient to read or re-use for further analysis


# If you wish to clean your environment before moving on
rm(list = ls()) # removes all objects from memory


# Exercise 2
# Using popEpi and/or SocEpi compare the rates of poor self-rated health for two ethnic groups 
# by deprivation quintiles in the 2011 Scottish Census data.
# Calculate the rates for one or two smaller age groups, e.g. 0-64, 15-29 and/or 30-44.
# If you used both packages, did you get the same results or are there any differences?
# If you have time, use the R package PHEindicatormethods for the same calculations. 
# Do you get the same results?
# How do the package compare to each other, what are the benefits or problems of each of these?


d <- health_data # Name the health data in SocEpi package as d
head(d) # what the data looks like
tapply(d$pop, d$ethnicity, sum) # Number of people by ethnic groups

# Rates for Irish and Other White groups for all ages by deprivation quintile
# using SocEpi
d %>% filter(ethnicity %in% c("Irish", "OW")) %>% # select ethnic groups
  group_by(ethnicity) %>% # group by ethnicity
  group_modify(~ st_rate(.x, bad, pop, quintile, age)) %>% 
  filter(age == "all")

# using popEpi
# You will need to define ESP 2013
esp13 <- c(5000, 5500, 5500, 5500, 6000, 6000, 6500, 7000, 7000, 7000, 7000, 6500, 
           6000, 5500, 5000, 4000, 2500, 2500)

d %>% filter(ethnicity %in% c("Irish", "OW")) %>% # select ethnic groups
  mutate(ethnicity = droplevels(ethnicity)) %>% # remove unused factor levels
  rate(obs = bad, pyrs = pop, adjust = age, weights = esp13, print = list(quintile, ethnicity)) %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)

# rates are the same, CI are different due to different methods

# Rates for age groups
# Using ScoEpi selecting age groups is pretty simple
# for ages 15-29, 30-44. Note results for 0-64 are provided by default
d %>% filter(ethnicity %in% c("Irish", "OW")) %>% # select ethnic groups
  group_by(ethnicity) %>% # group by ethnicity
  group_modify(~ st_rate(.x, bad, pop, quintile, age, age_group = c("15-29", "30-44"))) %>% 
  filter(age != "all") # use filter() to select what you wish to see
 
# add filter(ses == "overall") and the pipe (%>%) on previous line if you want only overall rates


# when using popEpi, you have to subset the data first and edit the age group
# ages 15-29
esp2013_15 <- esp13[4:6] # select standard population for age groups

d %>% filter(ethnicity %in% c("Irish", "OW")) %>% # select ethnic groups
  mutate(ethnicity = droplevels(ethnicity)) %>% # remove unused factor levels
  filter(age %in% 4:6) %>%
  rate(obs = bad, pyrs = pop, adjust = age, weights = esp2013_15, print = list(quintile, ethnicity)) %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)

# remove variable quintile from the rate() function if you wish to see overall results

# Can you figure out a way to get results for multiple age groups using popEpi?

# Using PHEindicatormethods
q_rates_I_OW <- d %>% filter(ethnicity %in% c("Irish", "OW")) %>%
  select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>%
  summarise_all(sum) %>%
  group_by(quintile, ethnicity) %>%
  phe_dsr(bad, pop, stdpop = esp13, stdpoptype = "vector", type = "standard", multiplier = 1000)

head(q_rates_I_OW) # Quick look at results, same as with other packages!



# Exercise 3
# Using SocEpi and/or PHEindicatormethods calculate health inequalities (SII or RII) for 
# the same ethnic and age groups as in the previous exercise.
# If you used both packages, did you get the same results or are there any differences?
# How do the packages compare to each other, what are the benefits or problems of each of these?


# Using SocEpi
# SII for all ages for Irish and Other White groups
d %>% filter(ethnicity %in% c("Irish", "OW")) %>%
  group_by(ethnicity) %>%
  group_modify(~ rii(.x, bad, pop, quintile, age, RII = F, W = T)) %>% 
  filter(age == "all") # Inequalities across all ages

# if you want results for different age groups, use age_group = c("15-29", "30-44")
d %>% filter(ethnicity %in% c("Irish", "OW")) %>%
  group_by(ethnicity) %>%
  group_modify(~ rii(.x, bad, pop, quintile, age, RII = F, W = T, age_group = c("15-29", "30-44"))) %>%
  filter(age != "all")


# using PHEindicatormethods
# First, calculate rates and save these. See previous exercise for that
# Note! You can use other packages for this also, e.g. popEpi

# Second, calculate SII using the rates data
# rates data q_rates_I_OW calculated previously
q_rates_I_OW %>% group_by(ethnicity) %>%
  phe_sii(quintile, total_pop, value, lower_cl = lowercl, upper_cl = uppercl)


# if you want results for different age groups then filter the data first
# for ages 15-29
# define ESP 2013 (if not defined earlier)
esp2013_15 <- esp13[4:6] # select standard population for age groups

# Calculate rates and save rates for ages 15-29
# Note! You can use other packages for this also, e.g. popEpi
q_rates_15 <- d %>% filter(ethnicity %in% c("Irish", "OW")) %>%
  filter(age %in% 4:6) %>%
  select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>%
  summarise_all(sum) %>%
  group_by(quintile, ethnicity) %>%
  phe_dsr(bad, pop, stdpop = esp2013_15, stdpoptype = "vector", type = "standard", multiplier = 1000)

head(q_rates_15) # Quick look at results
# You will note that results are not calculated if there are too few people who have stated they are
# in poor health
# SII cannot then be calculated for Irish aged 15-29


# Calculate rates and save these for ages 30-44
esp2013_30 <- esp13[7:9] # select standard population for age groups

# Note! You can use other packages for this also, e.g. popEpi
q_rates_30 <- d %>% filter(ethnicity %in% c("Irish", "OW")) %>%
  filter(age %in% 7:9) %>%
  select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>%
  summarise_all(sum) %>%
  group_by(quintile, ethnicity) %>%
  phe_dsr(bad, pop, stdpop = esp2013_30, stdpoptype = "vector", type = "standard", multiplier = 1000)

head(q_rates_30)

# Second, calculate SII using the rates data
q_rates_30 %>% group_by(ethnicity) %>%
  phe_sii(quintile, total_pop, value, lower_cl = lowercl, upper_cl = uppercl)


# Results for SII for ages 30-44 are same when using PHEindicatormethods and SocEpi
# The CI are different as the packages use different simulation methods