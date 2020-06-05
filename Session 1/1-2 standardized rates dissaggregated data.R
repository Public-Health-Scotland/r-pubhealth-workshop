# Public Health Tools in R
# Calculating standardised rates
# Disaggregated data (small-area and individual level data)
# Mirjam Allik
# May 2020


# Note, you may need Rtools for SocEpi. For this go here https://cran.r-project.org/bin/windows/Rtools/

# If you have these packages already installed you can skip this stage
install.packages(c("popEpi", "SocEpi"))

# or from github, requires Rtools, for Rtools see https://cran.r-project.org/bin/windows/Rtools/
# devtools::install_github("m-allik/SocEpi")

# Load packages
library(popEpi)
library(SocEpi)
require(PHEindicatormethods)
require(dplyr)

# Disagregated small-area data
# We use postcode sector level self-rated health data from 2011 Scottish Census

d <- health_data # package SocEpi needs to be loaded for this
# The data is also included in the data folder of the GitHub repository
# read it using d <- read.csv("data/PS_SRH_ethnicity_2011.csv")
head(d)

?health_data # to look up data dictionary

# Run summaries to get a sense of the data
tapply(d$pop, d$ethnicity, sum) # Number of people by ethnicity

unique(d$age) # unique age group values

# popEpi, uses disaggregated data
# ===============================================================================
# https://cran.r-project.org/web/packages/popEpi/index.html

# Many built in st populations, but not 2013 ESP
# define ESP 2013
esp13 <- c(5000, 5500, 5500, 5500, 6000, 6000, 6500, 7000, 7000, 7000, 7000, 
           6500, 6000, 5500, 5000, 4000, 2500, 2500)
length(esp13)
sum(esp13)

?rate

# Rates for all ethnicities
rate(data = d, obs = bad, pyrs = pop, adjust = age, weights = esp13, subset = ethnicity == "all")

# Note, you may get a warning about integer overflow
# This seems to be an R, rather than a package issue
# https://stackoverflow.com/questions/8804779/what-is-integer-overflow-in-r-and-how-can-it-happen#8804991

rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)

# by quintile
rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, print = quintile, subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)

# by quintile and urban rural differences
rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, 
     print = list(quintile, ur2fold), subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)


# For age groups
# ages 0-64
esp13_g <- esp13[1:13] # select standard population for age groups
esp13_g

d %>% filter(age %in% 1:13) %>% # select age groups
 rate(obs = bad, pyrs = pop, adjust = age, weights = esp13_g, 
      subset = ethnicity == "all") %>% # calculate rates
 mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)


# For multiple age groups simultaneously, say compare ages 15-29 and 30-44?



# SocEpi
# ===========================================================================
# https://github.com/m-allik/SocEpi
# Very much work in progress, aimed for work on health inequalities
# May need to provide your own st population, but many built-in options

?st_rate # how to use the function
?st_pop # what st populations are available?

# rates for all ethnicities by ses (quintiles)
# A lot of results at a single go! Can be good, can be bad!
st_rate(data = d, health = bad, population = pop, ses = quintile, age = age, groups = ethnicity == "all") 

# to get less results use filter()
st_rate(d, bad, pop, quintile, age, ethnicity == "all") %>% 
  filter(age == "all")

# or save calculations and then filter
my_rates <- st_rate(data = d, health = bad, population = pop, ses = quintile, age = age, groups = ethnicity == "all") 

my_rates %>% filter(age == "all") # For all ages
my_rates %>% filter(age == "15-29") # For all ages
my_rates %>% filter(ses == "overall") # For different age groups, across SES
  

# For quintiles and urban-rural 
st_rate(d, bad, pop, quintile, age, groups = c(ethnicity == "all" & ur2fold == "Rural")) %>% 
  filter(age == "all")
st_rate(d, bad, pop, quintile, age, groups = c(ethnicity == "all" & ur2fold == "Urban")) %>% 
  filter(age == "all")

# or
d %>% group_by(ur2fold) %>%
  group_modify(~ st_rate(.x, bad, pop, quintile, age, ethnicity == "all")) %>%
  filter(age == "all")


# For different age groups
st_rate(d, bad, pop, quintile, age, age_group = c("15-44"), groups = ethnicity == "all") 

# For multiple different age groups
st_rate(d, bad, pop, quintile, age, age_group = c("15-44", "45-59"), groups = ethnicity == "all") 



# Using packages for aggregate data on individual or small-area data

# PHEindicatormethods
# ===============================================================================
# Need for some aggregation
# May need to supply your own standard population

# aggregation of data follows prior calculation
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>% # group data for aggregations
  summarise_all(sum) %>% # aggregate
  group_by(quintile, ethnicity) %>% # group data for rate calculations
  phe_dsr(bad, pop, stdpop = esp13, stdpoptype = "vector", type = "standard", multiplier = 1000) %>% # Rates calculated
  filter(ethnicity == "all")


# Note!
# Makes the assumption that your data is ordered by age from youngest to oldest
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  group_by(ethnicity, quintile, age) %>%
  summarise_all(sum) %>%
  group_by(quintile, ethnicity) %>%
  mutate(jumble = sample(1:18, 18)) %>% # re-arrange the data set
  arrange(jumble) %>% # re-arrange the data set
  phe_dsr(bad, pop, stdpop = esp13, stdpoptype = "vector", type = "standard", multiplier = 1000) %>%
  filter(ethnicity == "all")


# Results are different

# When might this matter?
my_age_groups <- c("0-4", "5-9", "10-14", "15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54")
my_age_groups[order(my_age_groups)] # look at the order of the data, note that age 5-9 is after 45-49

# So, whenever using PHEindicatormethods make sure your data is ordered by age!


# Example of jumble for SocEpi
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  mutate(jumble = sample(1:182160, 182160)) %>%
  arrange(jumble) %>% # re-arrange the data set
  st_rate(bad, pop, quintile, age, ethnicity == "all") %>% 
  filter(age == "all")

st_rate(d, bad, pop, quintile, age, ethnicity == "all") %>% 
  filter(age == "all") # results without jumble

# Results are the same!

# Example of jumble for popEpi
d %>% select(ethnicity, quintile, age, bad, pop) %>%
  mutate(jumble = sample(1:182160, 182160)) %>%
  arrange(jumble) %>% # re-arrange the data set
  rate(obs = bad, pyrs = pop, adjust = age, weights = esp13, print = quintile, subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000)

rate(d, obs = bad, pyrs = pop, adjust = age, weights = esp13, print = quintile, subset = ethnicity == "all") %>%
  mutate_at(vars(rate.adj:rate.hi), .funs = ~.*1000) # results without jumble

# Results are the same!