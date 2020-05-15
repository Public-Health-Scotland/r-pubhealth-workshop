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
# Using the aggregated English and Scottish deaths data, calculate standardized rates using the packages
# epiR, dsr and/or dsrTest.
# Try out the examples from these packages first (these are listed with the function documentation).
# How do these packages differ from epitools and PHEindicatormethods?
  
# Read data
eng_d <- read.csv("Data/England_deaths.csv") # English data
head(eng_d)

scot_d <- read.csv("Data/Scotland_deaths.csv") # Scottish data with multiple groups
head(scot_d)


# dsr
# ===============================================================================
# https://cran.r-project.org/web/packages/dsr/

# standard population data needs to be in a separate data.frame together with age
esp13_m <- scot_d[, 1:2]
esp13_m$age <- factor(esp13_m$age, levels = esp13_m$age, ordered = T) # the age variable will need to be same as in data
names(esp13_m) <- c("age", "pop") # standard population has to be named "pop"

# use long-format Scottish data
scot_d_long2 <- scot_d_long # the population variable in the data cannot be named "pop"
names(scot_d_long2)[5] <- "population"

# results need to be saved into an object and then printed
results <- dsr(data = scot_d_long2, event = deaths, fu = population, subgroup = sex, age = age, refdata = esp13_m, mp=100000)
results


# epiR
# ===============================================================================
# https://cran.r-project.org/web//packages/epiR/index.html

# Prepare data
death_obs <- matrix(eng_d$Deaths, nrow = 1, ncol = 20, dimnames = list("", 1:20))
pop_obs <- matrix(eng_d$Population, nrow = 1, ncol = 20, dimnames = list("", 1:20))
esp13 <- matrix(eng_d$ESP, nrow = 1, ncol = 20, dimnames = list("", 1:20))

# calcualate rates
epi.directadj(death_obs, pop_obs, esp13, units = 100000, conf.level = 0.95)

# How would you do that for age groups?
# for ages 35-54
d35_54 <- death_obs[, 9:12, drop = F]
p35_54 <-pop_obs[, 9:12, drop = F]
esp35_54 <- esp13[, 9:12, drop = F]

epi.directadj(d35_54, p35_54, esp35_54, units = 100000, conf.level = 0.95) # Default 95% CI


# Rates for multiple groups
# Prepare data
death_obs_s <- t(scot_d[, 3:5])
pop_obs_s <- t(scot_d[, 6:8])
colnames(pop_obs_s) <- colnames(death_obs_s) <- 1:19
row.names(pop_obs_s) <- row.names(death_obs_s) <- c("T", "M", "F")
esp13 <- matrix(scot_d$ESP, nrow = 1, ncol = 19, dimnames = list("", 1:19))

# calcualate rates
epi.directadj(death_obs_s, pop_obs_s, esp13, units = 100000, conf.level = 0.95)


# dsrTest
# ===============================================================================
# https://cran.r-project.org/web/packages/dsrTest/
# For testing if rates equal to a specific value

# Rates and a test for a single grooup
dsrTest(eng_d$Deaths, eng_d$Population, w = eng_d$ESP, mult = 100000)

dsrTest(eng_d$Deaths, eng_d$Population, w = eng_d$ESP, null.value = 1157.006, mult = 100000) # Comparison to scottish rates

# For multiple groups, using Scottish data
mapply(dsrTest, x = scot_d[, 3:5], n = scot_d[, 6:8], MoreArgs = list(w = scot_d$ESP, mult = 100000))



# Exercise 2
# Using popEpi and/or SocEpi compare the rates of poor self-rated health for two ethnic groups 
# by quintile in the 2011 Scottish Census data.
# Calculate the rates for ages 0-64 and for one or two smaller age groups, e.g. 15-29 and 30-44.
# If you used both packages, did you get the same results or are there any differences?
# If you have time, use the R package PHEindicatormethods for the same calculations. Do you get the same results?
# How do the package compare to each other, what are the benefits or problems of each of these?


d <- health_data # name the health data in SocEpi package as d
table(d$ethnicity) # Look up the ethnicities in the data set

# using SocEpi
d %>% filter(ethnicity %in% c("Irish", "OW")) %>% # select ethnic groups
  group_by(ethnicity) %>% # group by ethnicity
  group_modify(~ st_rate(.x, bad, pop, quintile, age)) %>% 
  filter(age == "all")

# using popEpi
d %>% filter(ethnicity %in% c("Irish", "OW")) %>% # select ethnic groups
  mutate(ethnicity = droplevels(ethnicity)) %>% # remove unused factor levels
  rate(obs = bad, pyrs = pop, adjust = age, weights = esp2013, print = list(quintile, ethnicity)) %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)


# for ScoEpi selecting age groups is pretty simple
# for ages 15-29 and 30-44
d %>% filter(ethnicity %in% c("Irish", "OW")) %>% # select ethnic groups
  group_by(ethnicity) %>% # group by ethnicity
  group_modify(~ st_rate(.x, bad, pop, quintile, age, age_group = c("15-29", "30-44"))) %>% 
  filter(age != "all") %>% # use filter() to select what you wish to see
  filter(ses == "overall")

# when using popEpi, you have to subset the data first and edit the age group
# ages 15-29
esp2013_15 <- esp2013[4:6] # select standard population for age grups

d %>% filter(ethnicity %in% c("Irish", "OW")) %>% # select ethnic groups
  mutate(ethnicity = droplevels(ethnicity)) %>% # remove unused factor levels
  filter(age %in% 4:6) %>%
  rate(obs = bad, pyrs = pop, adjust = age, weights = esp2013_15, print = ethnicity) %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)


# Exercise 3
# Using SocEpi and/or PHEindicatormethods calculate health inequalities (SII or RII) for the same ethnic 
# and age groups as in the previous exercise.
# If you used both packages, did you get the same results or are there any differences?
# How do the package compare to each other, what are the benefits or problems of each of these?


# Using SocEpi
d %>% filter(ethnicity %in% c("Irish", "OW")) %>%
  group_by(ethnicity) %>%
  group_modify(~ rii(.x, bad, pop, quintile, age, RII = F, W = T)) %>%
  filter(age == "all") 

# if you want results for different age groups, use age_group = c("15-29", "30-44")
d %>% filter(ethnicity %in% c("Irish", "OW")) %>%
  group_by(ethnicity) %>%
  group_modify(~ rii(.x, bad, pop, quintile, age, RII = F, W = T, age_group = c("15-29", "30-44"))) %>%
  filter(age != "all")


# using PHEindicatormethods
# define ESP 2013
esp13 <- c(5000, 5500, 5500, 5500, 6000, 6000, 6500, 7000, 7000, 7000, 7000, 6500, 6000, 5500, 5000, 4000, 2500, 2500)

# First, calculate rates
# Note! You can use other packages for this also, e.g. popEpi
q_rates_I_OW <- d %>% filter(ethnicity %in% c("Irish", "OW")) %>%
  select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>%
  summarise_all(sum) %>%
  group_by(quintile, ethnicity) %>%
  phe_dsr(bad, pop, stdpop = esp13, stdpoptype = "vector", type = "standard", multiplier = 1000)

# SII
q_rates_I_OW %>% group_by(ethnicity) %>%
  phe_sii(quintile, total_pop, value, lower_cl = lowercl, upper_cl = uppercl)


# if you want results for different age groups then filter the data first
# for ages 15-29

