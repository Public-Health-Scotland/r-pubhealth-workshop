# Public Health Tools in R
# Calculating standardised rates
# Aggregated data
# Mirjam Allik
# May 2020


# Install packages
install.packages(c("epiR", "epitools", "dsr", "PHEindicatormethods", "dsrTest"))

# load
package_list <- c("epiR", "epitools", "dsr", "PHEindicatormethods", "dsrTest")
lapply(package_list, require, character.only = TRUE)

# or use package pacman: install.packages("pacman")
# pacman::p_load(popEpi, epiR, Epi, ...)  

# other packages
library(dplyr)
library(tidyr)


# Read data
# =======================================================================
# English data
eng_d <- read.csv("Data/England_deaths.csv")
head(eng_d)

# Scottish data with multiple groups
scot_d <- read.csv("Data/Scotland_deaths.csv")
head(scot_d)


# epitools
# ===============================================================================
# https://cran.r-project.org/web/packages/epitools/index.html

?ageadjust.direct

# Use eng_d data
ageadjust.direct(eng_d$Deaths, eng_d$Population, stdpop = eng_d$ESP)
ageadjust.direct(eng_d$Deaths, eng_d$Population, stdpop = eng_d$ESP)*100000 # Default 95% CI

# How would you do that for age groups?
# For ages 35-54
eng_d35_54 <- eng_d[9:12, ]
ageadjust.direct(eng_d35_54$Deaths, eng_d35_54$Population, stdpop = eng_d35_54$ESP)*100000


# For multiple groups, using Scottish data
ageadjust.direct(scot_d$deaths, scot_d$pop, stdpop = scot_d$ESP)*100000 # Default 95% CI
ageadjust.direct(scot_d$deaths_M, scot_d$pop_M, stdpop = scot_d$ESP)*100000

# or use mapply
mapply(ageadjust.direct, count = scot_d[, 3:5], pop = scot_d[, 6:8], MoreArgs = list(stdpop = scot_d$ESP))*100000



# PHEindicatormethods
# ===============================================================================
# https://cran.r-project.org/web/packages/PHEindicatormethods/index.html
# Has a built-in standard population, but limited to ESP 2013 for 19 age groups from 0-4 to 90+

?phe_dsr

# Rates for a single grooup
phe_dsr(eng_d, Deaths, Population, ESP, stdpoptype = "field") # Default 95% CI

# How would you do that for age groups?
# for ages 35-54
phe_dsr(eng_d35_54, Deaths, Population, ESP, stdpoptype = "field")

# also
eng_d %>% filter(Age %in% c("35-39", "40-44", "45-49", "50-54")) %>%
  phe_dsr(Deaths, Population, ESP, stdpoptype = "field")


# For multiple groups
# Get the data in the long format
scot_d_long <- scot_d %>%
  mutate(age = factor(age, levels = age[1:19], ordered = T)) %>% # Note that age is recoded as an ordered factor!
  gather("variable", "n", 3:8) %>%
  separate(variable, c("variable", "sex"), sep = "_", fill = "right") %>%
  mutate(sex = ifelse(is.na(sex), "T", sex)) %>%
  spread(variable, n) %>%
  arrange(sex, age) %>%
  select(-ESP)

head(scot_d_long)

# create standard population vector
stp13 <- scot_d$ESP # could also have done stp13 <- c(1000, 4000, ...)

scot_d_long  %>% 
  group_by(sex) %>% 
  phe_dsr(deaths, pop, stdpop = stp13, stdpoptype = "vector", type = "standard")




